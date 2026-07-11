# -*- coding: utf-8 -*-
"""
heartguard_knowledge.py

Static clinical knowledge base for HeartGuard: plain-language feature
explanations, specialist referral mapping, non-modifiable-feature
filtering, and the dual-layer clinical advisory service.

ADVISORY ARCHITECTURE (two independent layers):
  1. Baseline library (_ACTION_PLAN_LIBRARY): authoritative, AHA-aligned,
     non-prescriptive advice text. This is the clinical source of truth
     and is ALWAYS available with zero external dependencies.
  2. Optional Grok enhancement (_fetch_grok_advice): a UI-polish layer
     that asks the Grok API to rewrite the baseline text in a warmer,
     more encouraging tone for patients, WITHOUT changing any clinical
     fact. On any failure (missing key, network error, timeout, bad
     response, malformed JSON), it silently falls back to the baseline
     text unchanged. get_clinical_advice()'s `enhance` flag controls
     whether this layer is even attempted -- callers that need strictly
     clinical, unedited text (e.g. the physician-facing PDF report) pass
     enhance=False and skip the Grok call entirely.

On top of the advice text itself, get_clinical_advice() adds:
  - Impact percentages: each top feature's SHAP magnitude expressed as a
    share (%) of the total SHAP magnitude across the reported top
    features, e.g. "BloodSugar: 15% high-risk impact".
  - Trend-aware feedback: if a previous probability is available (from
    heartguard_db.get_history), a plain-language sentence describing the
    percentage-point change in risk, e.g. "Risk has improved by 5% since
    your last assessment." Safely omitted (None) for first-time patients.
"""

import json
import os
import requests

# ---------------------------------------------------------------------------
# Plain-language explanation of why each feature affects cardiovascular risk.
# Keys must match heartguard_transformers.FEATURE_ORDER exactly -- the
# numerical block (including the 5 optional lab tests), the binary
# categorical block, the 5 Missing_Flag_* columns, then the 5 Race one-hot
# columns (Race_1..Race_5).
# ---------------------------------------------------------------------------
FEATURE_EXPLANATIONS = {
    "AgeCategory": "Cardiovascular risk rises steadily with age due to cumulative arterial wear.",
    "BMI": "Elevated BMI is linked to higher blood pressure, insulin resistance, and lipid abnormalities.",
    "SystolicBP": "High systolic pressure increases strain on arterial walls and the heart's pumping load.",
    "DiastolicBP": "Elevated diastolic pressure reflects sustained vascular resistance between heartbeats.",
    "BloodSugar": "High blood sugar signals impaired insulin regulation, a major driver of vascular damage.",
    "Cholesterol": "Elevated cholesterol contributes to plaque buildup (atherosclerosis) in the arteries.",
    "HbA1c": "HbA1c reflects long-term blood sugar control; sustained elevation damages blood vessels over time.",
    "SleepTime": "Both short and irregular sleep durations are associated with elevated cardiovascular risk.",
    "AlcoholDrinking": "Heavier alcohol intake is linked to hypertension and cardiomyopathy risk.",
    "Sex": "Biological sex affects baseline cardiovascular risk profiles and typical disease onset age.",
    "Smoking": "Smoking damages the endothelium and accelerates atherosclerosis.",
    "BrainStroke": "A history of stroke indicates existing vascular disease and strongly elevates future cardiac risk.",
    "DiffWalking": "Difficulty walking can reflect reduced cardiovascular conditioning or existing circulatory limitation.",
    "Diabetic": "Diabetes substantially accelerates vascular and cardiac damage.",
    "Asthma": "Chronic respiratory disease can contribute to increased cardiovascular strain.",
    "KidneyDisease": "Kidney disease is closely linked to hypertension and accelerated cardiovascular damage.",
    "CancerHistory": "History of cancer or its treatment (e.g. certain chemotherapies) can affect cardiovascular health.",
    "ChronicHypertension": "Chronic high blood pressure is one of the strongest predictors of cardiac events.",
    "LiverDisease": "Liver disease can alter lipid metabolism and contribute to cardiovascular risk.",
    "ImmunologicalDiseases": "Immune system disorders can drive chronic inflammation, a known contributor to cardiovascular risk.",
    "MyocardialInfarctionInHeart": "A prior heart attack is one of the strongest predictors of future cardiac events.",
    "Missing_Flag_SystolicBP": "Blood pressure was not measured, so a normal reading was assumed for scoring purposes.",
    "Missing_Flag_DiastolicBP": "Blood pressure was not measured, so a normal reading was assumed for scoring purposes.",
    "Missing_Flag_BloodSugar": "A blood sugar test was not on file, so a normal reading was assumed for scoring purposes.",
    "Missing_Flag_Cholesterol": "A cholesterol panel was not on file, so a normal reading was assumed for scoring purposes.",
    "Missing_Flag_HbA1c": "An HbA1c test was not on file, so a normal reading was assumed for scoring purposes.",
    "Race_1": "Race/ethnicity is associated with differing baseline cardiovascular risk profiles in population studies.",
    "Race_2": "Race/ethnicity is associated with differing baseline cardiovascular risk profiles in population studies.",
    "Race_3": "Race/ethnicity is associated with differing baseline cardiovascular risk profiles in population studies.",
    "Race_4": "Race/ethnicity is associated with differing baseline cardiovascular risk profiles in population studies.",
    "Race_5": "Race/ethnicity is associated with differing baseline cardiovascular risk profiles in population studies.",
}

# Which specialist to recommend when a given feature is the #1 risk driver.
SPECIALIST_MAP = {
    "AgeCategory": "General Practitioner / Geriatric Cardiology",
    "BMI": "Endocrinologist / Registered Dietitian",
    "SystolicBP": "Cardiologist",
    "DiastolicBP": "Cardiologist",
    "BloodSugar": "Endocrinologist",
    "Cholesterol": "Lipid Specialist / Cardiologist",
    "HbA1c": "Endocrinologist",
    "SleepTime": "Sleep Medicine Specialist",
    "AlcoholDrinking": "Hepatologist / Addiction Medicine",
    "Sex": "General Practitioner",
    "Smoking": "Pulmonologist / Smoking Cessation Specialist",
    "BrainStroke": "Neurologist / Cardiologist",
    "DiffWalking": "Sports Medicine Physician / Physiotherapist",
    "Diabetic": "Endocrinologist",
    "Asthma": "Pulmonologist",
    "KidneyDisease": "Nephrologist",
    "CancerHistory": "Oncologist",
    "ChronicHypertension": "Cardiologist",
    "LiverDisease": "Hepatologist",
    "ImmunologicalDiseases": "Rheumatologist / Immunologist",
    "MyocardialInfarctionInHeart": "Cardiologist",
    "Missing_Flag_SystolicBP": "General Practitioner",
    "Missing_Flag_DiastolicBP": "General Practitioner",
    "Missing_Flag_BloodSugar": "General Practitioner",
    "Missing_Flag_Cholesterol": "General Practitioner",
    "Missing_Flag_HbA1c": "General Practitioner",
    "Race_1": "General Practitioner",
    "Race_2": "General Practitioner",
    "Race_3": "General Practitioner",
    "Race_4": "General Practitioner",
    "Race_5": "General Practitioner",
}

# ---------------------------------------------------------------------------
# Baseline advisory library. Non-prescriptive (no dosing/medication
# guidance) and phrased to align with American Heart Association (AHA)
# screening/lifestyle guidance. This is the clinical source of truth --
# get_clinical_advice() always computes this first, regardless of whether
# the Grok enhancement layer is used or available.
# ---------------------------------------------------------------------------
_ACTION_PLAN_LIBRARY = {
    "AgeCategory": "Per AHA guidance, schedule routine cardiovascular risk screening at a frequency appropriate for your age group, even in the absence of symptoms.",
    "BMI": "AHA guidance links elevated BMI to higher cardiovascular risk; discuss a structured, sustainable weight-management plan with a dietitian or your physician.",
    "SystolicBP": "Monitor blood pressure regularly against AHA-defined categories (normal, elevated, hypertension stage 1/2) and reduce sodium intake.",
    "DiastolicBP": "Monitor blood pressure regularly against AHA-defined categories and discuss home blood pressure tracking with your doctor.",
    "BloodSugar": "Request a glucose-tolerance follow-up and review carbohydrate intake; sustained elevation is a recognized cardiovascular risk factor.",
    "Cholesterol": "Request a full lipid panel and discuss dietary fat sources with a clinician, consistent with AHA cholesterol management guidance.",
    "HbA1c": "Follow up with an endocrinologist to review long-term glucose control; HbA1c is a key marker in AHA/ADA joint cardiovascular risk guidance.",
    "SleepTime": "Aim for the AHA-recommended 7-9 hours of consistent sleep; consider a sleep study if your sleep is short or irregular.",
    "AlcoholDrinking": "Review alcohol intake with your physician relative to AHA moderate-consumption guidelines for cardiovascular health.",
    "Sex": "Discuss sex-specific cardiovascular risk factors and typical disease-onset patterns with your doctor.",
    "Smoking": "Consider a structured smoking-cessation program; the AHA identifies smoking cessation as one of the highest-impact modifiable risk reductions available.",
    "BrainStroke": "Ensure secondary stroke-prevention follow-up is active with your neurologist and cardiologist, per AHA/ASA guidance on recurrent event prevention.",
    "DiffWalking": "Discuss a supervised, cardio-safe activity plan to gradually rebuild mobility and conditioning, in line with AHA physical activity guidance.",
    "Diabetic": "Maintain regular endocrinology follow-up for glucose management; diabetes is a major independent cardiovascular risk factor per AHA guidance.",
    "Asthma": "Ensure the respiratory condition is well-controlled and discuss cardio-safe exercise options with your physician.",
    "KidneyDisease": "Coordinate blood-pressure and cardiovascular monitoring with your nephrologist, given the well-established kidney-heart risk relationship.",
    "CancerHistory": "Discuss cardio-oncology follow-up if you received cardiotoxic treatments, consistent with AHA cardio-oncology guidance.",
    "ChronicHypertension": "Confirm blood pressure is being actively managed and monitored; sustained hypertension is one of the strongest AHA-recognized predictors of cardiac events.",
    "LiverDisease": "Coordinate lipid and cardiovascular monitoring with your hepatologist, given liver disease's effect on lipid metabolism.",
    "ImmunologicalDiseases": "Discuss cardiovascular monitoring with your rheumatologist/immunologist given the chronic inflammation-cardiovascular risk link.",
    "MyocardialInfarctionInHeart": "Confirm you are enrolled in post-cardiac-event follow-up and cardiac rehabilitation, per AHA secondary-prevention guidance.",
    "Missing_Flag_SystolicBP": "Consider getting your blood pressure measured for a more precise, guideline-based risk assessment.",
    "Missing_Flag_DiastolicBP": "Consider getting your blood pressure measured for a more precise, guideline-based risk assessment.",
    "Missing_Flag_BloodSugar": "Consider completing a blood sugar test for a more precise risk assessment.",
    "Missing_Flag_Cholesterol": "Consider completing a cholesterol panel for a more precise, guideline-based risk assessment.",
    "Missing_Flag_HbA1c": "Consider completing an HbA1c test for a more precise risk assessment.",
    "Race_1": "Discuss race-specific cardiovascular screening considerations with your doctor, consistent with population-level AHA risk guidance.",
    "Race_2": "Discuss race-specific cardiovascular screening considerations with your doctor, consistent with population-level AHA risk guidance.",
    "Race_3": "Discuss race-specific cardiovascular screening considerations with your doctor, consistent with population-level AHA risk guidance.",
    "Race_4": "Discuss race-specific screening considerations with your doctor, consistent with population-level AHA risk guidance.",
    "Race_5": "Discuss race-specific screening considerations with your doctor, consistent with population-level AHA risk guidance.",
}

# ---------------------------------------------------------------------------
# Non-modifiable feature filtering.
# ---------------------------------------------------------------------------
# Demographic features the model legitimately uses but a patient can't act
# on. Race is one-hot encoded as Race_1..Race_5, so it's matched by prefix
# rather than listed individually. "Age" is included alongside the actual
# "AgeCategory" feature name so this stays robust to either naming.
NON_MODIFIABLE_FEATURES = {"AgeCategory", "Age", "Sex"}
NON_MODIFIABLE_PREFIXES = ("Race_",)


def _is_modifiable(feature_name):
    if feature_name in NON_MODIFIABLE_FEATURES:
        return False
    if feature_name.startswith(NON_MODIFIABLE_PREFIXES):
        return False
    return True


def filter_non_modifiable(top_features):
    """
    Removes clinically non-modifiable demographic features (Age/
    AgeCategory, Sex, and any Race_* one-hot column) from a SHAP-ranked
    feature list. These are real risk drivers the model legitimately
    uses, but a patient can't act on them.

    Callers should pass in an UNCAPPED, SHAP-ranked list here (rank first,
    filter second) so filtering naturally promotes the next most
    impactful ACTIONABLE factor into a demographic feature's place,
    rather than just shrinking an already-truncated list.

    Safe on any input, including an empty list or a list where nothing
    modifiable remains: returns whatever's left (possibly []) rather than
    raising.
    """
    return [f for f in top_features if _is_modifiable(f["feature"])]


def calculate_impact_percentages(top_features):
    """
    Given a ranked list of top-impacting features (each a dict with at
    least "feature" and "shap_value"), express each feature's share of the
    total SHAP magnitude across this list as a percentage (0-100, rounded
    to 1 decimal place). Percentages are relative to the supplied list
    only, not the full feature set, so they always sum to ~100%.

    Args:
        top_features: list of dicts, each {"feature": str, "shap_value": float}

    Returns: dict mapping feature name -> impact percentage (float).
    """
    total_magnitude = sum(abs(f["shap_value"]) for f in top_features)
    if total_magnitude == 0:
        return {f["feature"]: 0.0 for f in top_features}
    return {
        f["feature"]: round(abs(f["shap_value"]) / total_magnitude * 100, 1)
        for f in top_features
    }


def _impact_label(shap_value):
    """Plain-language direction label for a SHAP value's sign."""
    if shap_value > 0:
        return "high-risk"
    if shap_value < 0:
        return "protective"
    return "neutral"


def get_risk_trend_sentiment(current_probability, previous_probability):
    """
    Compare the current predicted probability against the patient's most
    recent stored probability (see heartguard_db.get_history) and describe
    the change in plain language.

    Both probabilities are expected in the 0-1 range, as produced by the
    model and stored in heartguard_db. The change is reported in
    percentage points, e.g. "Risk has improved by 5% since your last
    assessment." A +/-2 percentage point band around zero change is
    treated as stable, mirroring heartguard_db.get_trend()'s own noise
    band.

    Returns None if no previous probability is available (first-time
    patient / insufficient history) -- callers should omit the trend
    sentence entirely in that case rather than showing a placeholder.
    """
    if previous_probability is None:
        return None

    delta_points = (previous_probability - current_probability) * 100
    if abs(delta_points) < 2:
        return "Risk has remained stable since your last assessment."
    if delta_points > 0:
        return f"Risk has improved by {delta_points:.0f}% since your last assessment."
    return f"Risk has increased by {abs(delta_points):.0f}% since your last assessment."


# ---------------------------------------------------------------------------
# Grok enhancement layer (optional, UI-only).
# ---------------------------------------------------------------------------
# Placeholder Grok (xAI) endpoint/model -- set the GROK_API_KEY environment
# variable in the deployment environment to enable this layer. With no key
# configured, _fetch_grok_advice() short-circuits straight to the baseline
# text, so the app runs perfectly well with this feature entirely disabled.
GROK_API_URL = "https://api.x.ai/v1/chat/completions"
GROK_MODEL = "grok-beta"
GROK_API_TIMEOUT_SECONDS = 4
GROK_API_KEY = os.environ.get("GROK_API_KEY")


def _fetch_grok_advice(base_advice):
    """
    Attempts to rewrite a dict of baseline advice strings (feature name ->
    advice) in a warmer, more encouraging patient-facing tone using the
    Grok API, WITHOUT changing any clinical fact, instruction, or
    referral. This is a UI-polish layer only, never a source of new
    clinical content -- the baseline text from _ACTION_PLAN_LIBRARY
    remains the clinical source of truth regardless of what this function
    returns.

    CRITICAL FALLBACK CONTRACT: on ANY failure -- no API key configured,
    network error, timeout, non-2xx response, malformed/missing JSON,
    an unexpected feature key, or any other exception -- this function
    returns `base_advice` completely UNCHANGED. A broken or unavailable
    third-party API must never break scoring or degrade the advice shown
    to a patient; at worst it just doesn't get the friendlier rewrite.

    Returns: dict mapping feature name -> advice string (Grok-rewritten
    where possible, otherwise identical to base_advice).
    """
    if not GROK_API_KEY or not base_advice:
        return base_advice

    try:
        prompt = (
            "Rewrite each of the following cardiovascular risk-factor advice "
            "sentences in a warmer, more encouraging tone for a patient-facing "
            "app. Preserve every clinical fact and instruction exactly -- do "
            "not add, remove, or change any medical recommendation or "
            "referral. Return ONLY a JSON object mapping each feature name to "
            "its rewritten sentence, with no other text.\n\n"
            f"{json.dumps(base_advice)}"
        )
        response = requests.post(
            GROK_API_URL,
            headers={"Authorization": f"Bearer {GROK_API_KEY}"},
            json={
                "model": GROK_MODEL,
                "messages": [{"role": "user", "content": prompt}],
                "temperature": 0.3,
            },
            timeout=GROK_API_TIMEOUT_SECONDS,
        )
        response.raise_for_status()
        data = response.json()
        content = data["choices"][0]["message"]["content"]
        enhanced = json.loads(content)

        if not isinstance(enhanced, dict) or not enhanced:
            return base_advice

        # Only accept enhanced text for features we actually asked about;
        # anything Grok omitted (or hallucinated an unexpected key for)
        # falls back to the baseline sentence for that feature, rather
        # than silently dropping or fabricating a factor.
        return {
            feature: enhanced.get(feature, base_advice[feature])
            for feature in base_advice
        }
    except Exception:
        # Deliberately broad: ANY failure mode here (network, auth,
        # timeout, malformed JSON, missing keys, rate limiting, etc.)
        # must fall back silently. This is a UI polish layer, not a
        # clinical dependency.
        return base_advice


def get_clinical_advice(
    top_features,
    trend=None,
    current_probability=None,
    previous_probability=None,
    enhance=True,
):
    """
    Build the full "Personalized Action Plan" payload for a prediction:
    dual-layer advice text (baseline + optional Grok rewrite), each
    feature's impact percentage, and a plain-language trend sentence.

    Args:
        top_features: ranked list of dicts, each {"feature": str,
            "shap_value": float}, as identified by SHAP for this patient
            and already passed through filter_non_modifiable().
        trend: optional trend label from heartguard_db.get_trend()
            ('improving' | 'worsening' | 'stable' | 'insufficient_data').
            Only used to suppress the trend sentence when there isn't
            enough history yet, even if probabilities are passed by
            mistake.
        current_probability / previous_probability: current and most
            recent-prior predicted probabilities (0-1 range), used to
            compute the percentage-point change described in the trend
            sentence. Leave both as None for first-time patients --
            get_risk_trend_sentiment() returns None in that case rather
            than raising, so trend insight is skipped gracefully.
        enhance: if True (the default -- intended for the patient-facing
            UI), attempts the Grok rewrite via _fetch_grok_advice(), which
            itself falls back to the baseline text on any failure. If
            False (intended for the strictly-clinical PDF physician
            report), the Grok call is skipped entirely and only the raw
            AHA-aligned baseline text from _ACTION_PLAN_LIBRARY is used.

    Returns: dict with:
        "advice": feature name -> advice string, prefixed with its impact
            percentage and direction, e.g. "BloodSugar: 15% high-risk
            impact. Request a glucose-tolerance follow-up..."
        "impact": feature name -> impact percentage (float)
        "trend_summary": plain-language trend sentence, or None if there
            is no usable history.
    """
    feature_names = [f["feature"] for f in top_features]
    base_advice = {
        feature: _ACTION_PLAN_LIBRARY.get(
            feature, "Discuss this risk factor with your physician."
        )
        for feature in feature_names
    }
    advice_text = _fetch_grok_advice(base_advice) if enhance else base_advice

    impact = calculate_impact_percentages(top_features)

    advice = {}
    for f in top_features:
        name = f["feature"]
        pct = impact[name]
        label = _impact_label(f["shap_value"])
        advice[name] = (
            f"{name}: {pct:.0f}% {label} impact. {advice_text.get(name, '')}"
        ).strip()

    trend_summary = None
    if trend != "insufficient_data":
        trend_summary = get_risk_trend_sentiment(current_probability, previous_probability)

    return {"advice": advice, "impact": impact, "trend_summary": trend_summary}
