"""
heartguard_transformers.py

Custom sklearn-compatible transformers used inside the HeartGuard
ImbPipeline. This module MUST be imported (not redefined inline) by both
Model_Optimization.ipynb (to build/save the pipeline) and app.py (to load
it), because joblib/pickle needs to resolve these classes by their module
path at load time. Defining them only inside a notebook breaks deployment,
since the notebook's __main__ namespace isn't importable from Flask.

SCHEMA NOTE (HeartGuardDatasetFinal_v2.csv):
Columns fall into four groups by how they need to be encoded:
  - CORE_NUMERICAL_COLS: continuous, always-expected, imputed jointly by
    IterativeImputer using every other numerical column as a predictor.
  - OPTIONAL_LAB_COLS: continuous LAB TEST results the caller may skip
    (SystolicBP, DiastolicBP, BloodSugar, Cholesterol, HbA1c). If skipped,
    ClinicalFeatureEngineer fills the value with a fixed clinical
    "normal range" constant (NOT the IterativeImputer's learned estimate)
    and raises a companion Missing_Flag_<col> = 1 so the model can learn to
    discount the filled value rather than treating it as a real reading.
    NUMERICAL_COLS = CORE_NUMERICAL_COLS + OPTIONAL_LAB_COLS: once the
    optional labs are pre-filled by ClinicalFeatureEngineer they have zero
    remaining missingness, so they still flow through the same
    StandardScaler + IterativeImputer block as the core numerical columns
    (harmless -- and it means IterativeImputer gets to use real, provided
    lab values as extra predictors when they're available).
  - BINARY_CATEGORICAL_COLS + MISSING_FLAG_COLS: true 0/1 flags, passed
    through untouched (rounded post-SMOTEENN by CategoricalRounder).
  - RACE_COL: a 5-category NOMINAL field (values 1.0-5.0), one-hot encoded
    in its own ColumnTransformer block.
"""

import numpy as np
import pandas as pd
from sklearn.base import BaseEstimator, TransformerMixin

# ---------------------------------------------------------------------------
# Canonical column groups for HeartGuardDatasetFinal_v2.csv
# ---------------------------------------------------------------------------
CORE_NUMERICAL_COLS = ['AgeCategory', 'BMI', 'SleepTime', 'AlcoholDrinking']

# Lab tests the caller may skip. Order here fixes the order of the derived
# Missing_Flag_* columns everywhere below.
OPTIONAL_LAB_COLS = ['SystolicBP', 'DiastolicBP', 'BloodSugar', 'Cholesterol', 'HbA1c']

# Clinical "normal range" constants used to fill a skipped test. These are
# standard reference midpoints (AHA "normal" BP, fasting glucose, desirable
# total cholesterol, non-diabetic HbA1c) -- adjust here if your clinical
# team uses different reference values; nothing else needs to change.
NORMAL_RANGE_DEFAULTS = {
    'SystolicBP': 120.0,   # AHA "normal" systolic BP
    'DiastolicBP': 80.0,   # AHA "normal" diastolic BP
    'BloodSugar': 90.0,    # normal fasting glucose, mg/dL
    'Cholesterol': 180.0,  # desirable total cholesterol, mg/dL
    'HbA1c': 5.4,          # normal (non-diabetic) HbA1c, %
}

MISSING_FLAG_COLS = [f'Missing_Flag_{c}' for c in OPTIONAL_LAB_COLS]

# All columns that go through StandardScaler + IterativeImputer.
NUMERICAL_COLS = CORE_NUMERICAL_COLS + OPTIONAL_LAB_COLS

BINARY_CATEGORICAL_COLS = [
    'Sex', 'Smoking', 'BrainStroke', 'DiffWalking', 'Diabetic', 'Asthma',
    'KidneyDisease', 'CancerHistory', 'ChronicHypertension', 'LiverDisease',
    'ImmunologicalDiseases', 'MyocardialInfarctionInHeart'
]

# Nominal, multi-category column. Kept separate from BINARY_CATEGORICAL_COLS
# because it needs one-hot encoding rather than pass-through + rounding.
RACE_COL = 'Race'
RACE_CATEGORIES = [1.0, 2.0, 3.0, 4.0, 5.0]
RACE_ONEHOT_COLS = [f'Race_{int(c)}' for c in RACE_CATEGORIES]

# Raw, pre-encoding categorical columns (what the input DataFrame / API
# payload actually contains -- one 'Race' column, not five; no Missing_Flag
# columns, since those are DERIVED by ClinicalFeatureEngineer, never sent
# by the caller).
CATEGORICAL_COLS = BINARY_CATEGORICAL_COLS + [RACE_COL]

# The fixed OUTPUT column order guaranteed by column_scaler in the notebook:
# numerical block, then binary categorical block, then Missing_Flag block,
# then Race one-hot block. SHAP and the Heart Age model both rely on this
# exact order to label the classifier's input array.
# 9 numerical + 12 binary + 5 missing-flags + 5 Race one-hot = 31 features.
FEATURE_ORDER = NUMERICAL_COLS + BINARY_CATEGORICAL_COLS + MISSING_FLAG_COLS + RACE_ONEHOT_COLS


def get_engineered_columns(raw_columns):
    """
    ClinicalFeatureEngineer.transform() always returns the original raw
    columns (in their fitted order) with MISSING_FLAG_COLS appended at the
    end. Both the notebook (to build column_scaler's index lists) and any
    other consumer that needs to know the post-feature-engineering column
    layout should call this rather than re-deriving it by hand.
    """
    return list(raw_columns) + MISSING_FLAG_COLS


# ACC/AHA-aligned risk stratification bands used across app.py and the PDF
# report, kept in one place so thresholds can't drift between call sites.
RISK_BANDS = (
    (0.10, "Low"),
    (0.30, "Moderate"),
    (float("inf"), "High"),
)


def get_risk_band(probability):
    """Maps a predicted probability to 'Low' / 'Moderate' / 'High'."""
    for upper_bound, label in RISK_BANDS:
        if probability < upper_bound:
            return label
    return "High"


def transform_for_shap(pipeline, X):
    """
    Manually replays every pipeline step EXCEPT the resampler (SMOTEENN,
    fit-time only, never applied at inference) to reproduce the exact
    feature array the classifier scores. Done explicitly step-by-step
    (rather than relying on Pipeline.transform/slicing) because SMOTEENN
    has no .transform method, so a generic pipeline-level call would
    raise. Returns a numpy array with columns in FEATURE_ORDER, matching
    what shap.TreeExplainer needs to explain the classifier.
    """
    X1 = pipeline.named_steps["feature_engineer"].transform(X)
    X2 = pipeline.named_steps["imputer"].transform(X1)
    X3 = pipeline.named_steps["column_scaler"].transform(X2)
    X4 = pipeline.named_steps["rounder"].transform(X3)
    return X4


class ClinicalFeatureEngineer(BaseEstimator, TransformerMixin):
    """
    Replaces the manual, outside-the-pipeline steps from the original
    notebooks (Sex remap + 1st/99th percentile clipping + a data-quality
    guard on AgeCategory + optional-lab missing-flagging) with a proper
    fit/transform step, so clip bounds are learned ONLY on training data
    (no leakage) and travel inside the saved pipeline artifact.

    input_sex_map controls how raw incoming Sex codes are remapped to the
    model's internal encoding (0/1). Default assumes the dataset's codes
    (1=Male, 2=Female) mapped to (0=Male, 1=Female). Exposed as a
    constructor param so callers with a different upstream encoding can
    override it without subclassing.
    """

    def __init__(self, numerical_cols=None, input_sex_map=None):
        self.numerical_cols = numerical_cols if numerical_cols is not None else NUMERICAL_COLS
        self.input_sex_map = input_sex_map if input_sex_map is not None else {1: 0, 2: 1}

    def fit(self, X, y=None):
        X = pd.DataFrame(X).copy()
        self.feature_names_in_ = X.columns.tolist()
        X = self._clean_age_category(X)
        # Clip bounds are computed on genuinely-observed values only.
        # pandas' .quantile() skips NaN automatically, so rows that are
        # missing an optional lab (not yet filled at this point in fit())
        # don't distort the learned percentiles -- important here since
        # some optional labs are missing in the majority of rows.
        self.clip_bounds_ = {
            col: (X[col].quantile(0.01), X[col].quantile(0.99))
            for col in self.numerical_cols
        }
        return self

    def transform(self, X):
        if isinstance(X, pd.DataFrame):
            # Reindex defensively so column ORDER always matches what the
            # pipeline was fitted on, even if raw input (e.g. from Flask)
            # arrives with columns in a different order.
            X = X.reindex(columns=self.feature_names_in_).copy()
        else:
            X = pd.DataFrame(X, columns=self.feature_names_in_).copy()

        # NOTE: expects the dataset's raw codes by default (1=Male, 2=Female).
        # Remap is driven by self.input_sex_map so it's configurable
        # per-deployment instead of hardcoded.
        X['Sex'] = X['Sex'].replace(self.input_sex_map)

        X = self._clean_age_category(X)
        X = self._flag_and_fill_optional_labs(X)

        for col, (lower, upper) in self.clip_bounds_.items():
            X[col] = np.clip(X[col], lower, upper)

        return X

    @staticmethod
    def _clean_age_category(X):
        """
        Data-quality guard: the source data contains a small number of rows
        with a corrupted/denormalized AgeCategory value (~5.4e-79) from a
        bad upstream export step. Real values range 1-80, so anything
        outside that range is treated as missing and left for
        IterativeImputer to fill downstream, rather than being clipped/
        treated as a literal near-zero age.
        """
        if 'AgeCategory' in X.columns:
            X = X.copy()
            out_of_range = (X['AgeCategory'] < 1) | (X['AgeCategory'] > 80)
            X.loc[out_of_range, 'AgeCategory'] = np.nan
        return X

    @staticmethod
    def _flag_and_fill_optional_labs(X):
        """
        For each optional lab test: record whether it was skipped
        (Missing_Flag_<col> = 1) BEFORE filling, then fill the skipped
        value with a fixed clinical "normal range" constant rather than
        IterativeImputer's learned per-patient estimate. This lets the
        model use a safe default when a test wasn't run while still
        knowing, via the flag, that the value is an assumption rather than
        an observed result.
        """
        X = X.copy()
        for col in OPTIONAL_LAB_COLS:
            missing = X[col].isna()
            X[f'Missing_Flag_{col}'] = missing.astype(int)
            X.loc[missing, col] = NORMAL_RANGE_DEFAULTS[col]
        return X


class CategoricalRounder(BaseEstimator, TransformerMixin):
    """
    Rounds the categorical feature block (binary flags + Missing_Flag
    block + the Race one-hot block) back to strict {0, 1} integers. Needed
    because SMOTEENN interpolates between neighbors during resampling,
    which produces non-binary values for categorical columns. Operates on
    fixed column positions produced by the preceding ColumnTransformer,
    which always emits
    [numerical block][binary categorical block][missing-flag block][Race one-hot block].

    NOTE on Race: interpolation can, in rare cases, leave more than one of
    the 5 Race one-hot columns > 0 for the same resampled row; rounding
    each independently means a resampled row could end up with more than
    one Race flag set to 1. This is the same simplification already used
    for the binary block and is accepted here rather than swapping in a
    categorical-aware resampler (e.g. SMOTENC), which would be a real
    algorithm change.
    """

    def __init__(self, n_numerical, n_categorical):
        self.n_numerical = n_numerical
        self.n_categorical = n_categorical

    def fit(self, X, y=None):
        return self

    def transform(self, X):
        X = np.asarray(X, dtype=float).copy()
        start = self.n_numerical
        end = start + self.n_categorical
        X[:, start:end] = np.where(X[:, start:end] > 0, 1, 0)
        return X
