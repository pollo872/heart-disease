from typing import Any, Dict, List, Optional, Set, Tuple

FEATURE_PRIORITY: List[Tuple[str, float]] = [
    ("MyocardialInfarctionInHeart", 0.49939401466091127),
    ("ChronicHypertension", 0.10390190029980124),
    ("Cholesterol", 0.04658826629688437),
    ("Diabetic", 0.011265799969786302),
    ("SleepTime", 0.01083431736609357),
    ("BrainStroke", 0.010234174636702054),
    ("AlcoholDrinking", 0.0101881029424144),
    ("Smoking", 0.010031474244798144),
    ("DiastolicBP", 0.009893441247967344),
    ("HbA1c", 0.007872340284258443),
    ("CancerHistory", 0.006854626526155206),
    ("BMI", 0.006260057145398395),
    ("BloodSugar", 0.004645298108439746),
    ("SystolicBP", 0.004100642970939204),
    ("Asthma", 0.0016026137058602092),
    ("Missing_Flag_Cholesterol", 0.0014012824583019936),
    ("Missing_Flag_HbA1c", 0.0012504800887878059),
    ("LiverDisease", 0.0012097207293791147),
    ("Missing_Flag_BloodSugar", 0.0009420441534459187),
    ("KidneyDisease", 0.0006520678433795517),
    ("Missing_Flag_DiastolicBP", 0.00013651607949772898),
    ("Missing_Flag_SystolicBP", 0.00011607466178604461),
    ("DiffWalking", 0.0),
    ("ImmunologicalDiseases", 0.0),
]
SKIP_FEATURES = {"Age", "Sex", "Race"}
MISSING_FLAG_PREFIX = "Missing_Flag_"
LAB_FEATURES: Set[str] = {
    "SystolicBP",
    "DiastolicBP",
    "BloodSugar",
    "Cholesterol",
    "HbA1c",
}
CHOLESTEROL_HIGH_MGDL = 200.0
BLOOD_SUGAR_HIGH_MGDL = 126.0
BLOOD_SUGAR_PREDIABETIC_MGDL = 100.0
HBA1C_HIGH_PERCENT = 6.5
HBA1C_PREDIABETIC_PERCENT = 5.7
SYSTOLIC_BP_HIGH = 140.0
DIASTOLIC_BP_HIGH = 90.0
BMI_OBESE = 30.0
BMI_HEALTHY_MIN = 18.5
BMI_HEALTHY_MAX = 24.9
SLEEP_HEALTHY_MIN_HOURS = 6.0
SLEEP_HEALTHY_MAX_HOURS = 9.0


def _get(patient_data: Dict[str, Any], key: str, default: Any = None) -> Any:
    value = patient_data.get(key, default)
    return default if value is None else value


def _as_bool(value: Any) -> bool:
    if isinstance(value, str):
        return value.strip().lower() in {"yes", "true", "1"}
    return bool(value)


def _infer_missing_labs(patient_data: Dict[str, Any]) -> Set[str]:
    return {feature for feature in LAB_FEATURES if patient_data.get(feature) is None}


def _risk_myocardial_infarction(
    pd_: Dict[str, Any], missing_labs: Set[str]
) -> Optional[str]:
    if _as_bool(_get(pd_, "MyocardialInfarctionInHeart", False)):
        return "History of a previous heart attack (myocardial infarction)"
    return None


def _risk_hypertension(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if _as_bool(_get(pd_, "ChronicHypertension", False)):
        return "Diagnosed with chronic hypertension"
    return None


def _risk_cholesterol(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if "Cholesterol" in missing_labs:
        return None
    value = _get(pd_, "Cholesterol")
    if value is not None and float(value) >= CHOLESTEROL_HIGH_MGDL:
        return f"Elevated cholesterol ({value} mg/dL)"
    return None


def _risk_diabetic(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if _as_bool(_get(pd_, "Diabetic", False)):
        return "Diagnosed with diabetes"
    return None


def _risk_sleep(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    value = _get(pd_, "SleepTime")
    if value is None:
        return None
    value = float(value)
    if value < SLEEP_HEALTHY_MIN_HOURS:
        return f"Insufficient sleep duration ({value} hours/night)"
    if value > SLEEP_HEALTHY_MAX_HOURS:
        return f"Excessive sleep duration ({value} hours/night)"
    return None


def _risk_stroke(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if _as_bool(_get(pd_, "BrainStroke", False)):
        return "History of a previous stroke"
    return None


def _risk_alcohol(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if _as_bool(_get(pd_, "AlcoholDrinking", False)):
        return "Regular alcohol consumption"
    return None


def _risk_smoking(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if _as_bool(_get(pd_, "Smoking", False)):
        return "Current smoker"
    return None


def _risk_diastolic_bp(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if "DiastolicBP" in missing_labs:
        return None
    value = _get(pd_, "DiastolicBP")
    if value is not None and float(value) >= DIASTOLIC_BP_HIGH:
        return f"Elevated diastolic blood pressure ({value} mmHg)"
    return None


def _risk_hba1c(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if "HbA1c" in missing_labs:
        return None
    value = _get(pd_, "HbA1c")
    if value is None:
        return None
    value = float(value)
    if value >= HBA1C_HIGH_PERCENT:
        return f"HbA1c in the diabetic range ({value}%)"
    if value >= HBA1C_PREDIABETIC_PERCENT:
        return f"HbA1c in the prediabetic range ({value}%)"
    return None


def _risk_cancer_history(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if _as_bool(_get(pd_, "CancerHistory", False)):
        return "History of cancer"
    return None


def _risk_bmi(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    value = _get(pd_, "BMI")
    if value is None:
        return None
    value = float(value)
    if value >= BMI_OBESE:
        return f"Obesity (BMI {value})"
    return None


def _risk_blood_sugar(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if "BloodSugar" in missing_labs:
        return None
    value = _get(pd_, "BloodSugar")
    if value is None:
        return None
    value = float(value)
    if value >= BLOOD_SUGAR_HIGH_MGDL:
        return f"Elevated blood sugar in the diabetic range ({value} mg/dL)"
    if value >= BLOOD_SUGAR_PREDIABETIC_MGDL:
        return f"Blood sugar in the prediabetic range ({value} mg/dL)"
    return None


def _risk_systolic_bp(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if "SystolicBP" in missing_labs:
        return None
    value = _get(pd_, "SystolicBP")
    if value is not None and float(value) >= SYSTOLIC_BP_HIGH:
        return f"Elevated systolic blood pressure ({value} mmHg)"
    return None


def _risk_asthma(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if _as_bool(_get(pd_, "Asthma", False)):
        return "Diagnosed with asthma"
    return None


def _risk_liver_disease(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if _as_bool(_get(pd_, "LiverDisease", False)):
        return "History of liver disease"
    return None


def _risk_kidney_disease(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if _as_bool(_get(pd_, "KidneyDisease", False)):
        return "History of kidney disease"
    return None


def _risk_diff_walking(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if _as_bool(_get(pd_, "DiffWalking", False)):
        return "Reports difficulty walking or climbing stairs"
    return None


def _risk_immunological(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if _as_bool(_get(pd_, "ImmunologicalDiseases", False)):
        return "History of an immunological disease"
    return None


RISK_EVALUATORS = {
    "MyocardialInfarctionInHeart": _risk_myocardial_infarction,
    "ChronicHypertension": _risk_hypertension,
    "Cholesterol": _risk_cholesterol,
    "Diabetic": _risk_diabetic,
    "SleepTime": _risk_sleep,
    "BrainStroke": _risk_stroke,
    "AlcoholDrinking": _risk_alcohol,
    "Smoking": _risk_smoking,
    "DiastolicBP": _risk_diastolic_bp,
    "HbA1c": _risk_hba1c,
    "CancerHistory": _risk_cancer_history,
    "BMI": _risk_bmi,
    "BloodSugar": _risk_blood_sugar,
    "SystolicBP": _risk_systolic_bp,
    "Asthma": _risk_asthma,
    "LiverDisease": _risk_liver_disease,
    "KidneyDisease": _risk_kidney_disease,
    "DiffWalking": _risk_diff_walking,
    "ImmunologicalDiseases": _risk_immunological,
}


def _positive_smoking(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    return "Non-smoker" if not _as_bool(_get(pd_, "Smoking", False)) else None


def _positive_alcohol(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    return (
        "Does not consume alcohol"
        if not _as_bool(_get(pd_, "AlcoholDrinking", False))
        else None
    )


def _positive_sleep(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    value = _get(pd_, "SleepTime")
    if value is None:
        return None
    value = float(value)
    if SLEEP_HEALTHY_MIN_HOURS <= value <= SLEEP_HEALTHY_MAX_HOURS:
        return f"Adequate sleep duration ({value} hours/night)"
    return None


def _positive_bmi(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    value = _get(pd_, "BMI")
    if value is None:
        return None
    value = float(value)
    if BMI_HEALTHY_MIN <= value <= BMI_HEALTHY_MAX:
        return f"Healthy BMI ({value})"
    return None


def _positive_cholesterol(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    if "Cholesterol" in missing_labs:
        return None
    value = _get(pd_, "Cholesterol")
    if value is not None and float(value) < CHOLESTEROL_HIGH_MGDL:
        return "Normal cholesterol level"
    return None


def _positive_blood_pressure(
    pd_: Dict[str, Any], missing_labs: Set[str]
) -> Optional[str]:
    if "SystolicBP" in missing_labs or "DiastolicBP" in missing_labs:
        return None
    sbp = _get(pd_, "SystolicBP")
    dbp = _get(pd_, "DiastolicBP")
    if sbp is None or dbp is None:
        return None
    if float(sbp) < SYSTOLIC_BP_HIGH and float(dbp) < DIASTOLIC_BP_HIGH:
        return "Normal blood pressure"
    return None


def _positive_no_diabetes(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    return (
        "No history of diabetes" if not _as_bool(_get(pd_, "Diabetic", False)) else None
    )


def _positive_no_stroke(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    return (
        "No history of stroke"
        if not _as_bool(_get(pd_, "BrainStroke", False))
        else None
    )


def _positive_no_mi(pd_: Dict[str, Any], missing_labs: Set[str]) -> Optional[str]:
    return (
        "No history of heart attack"
        if not _as_bool(_get(pd_, "MyocardialInfarctionInHeart", False))
        else None
    )


POSITIVE_EVALUATORS = {
    "MyocardialInfarctionInHeart": _positive_no_mi,
    "Cholesterol": _positive_cholesterol,
    "Diabetic": _positive_no_diabetes,
    "SleepTime": _positive_sleep,
    "BrainStroke": _positive_no_stroke,
    "AlcoholDrinking": _positive_alcohol,
    "Smoking": _positive_smoking,
    "DiastolicBP": _positive_blood_pressure,
    "BMI": _positive_bmi,
}


def _generate_profile(patient_data: Dict[str, Any]) -> str:
    age = _get(patient_data, "Age", "unknown age")
    sex_raw = _get(patient_data, "Sex", None)
    if sex_raw in (1, "1"):
        sex_label = "male"
    elif sex_raw in (2, "2"):
        sex_label = "female"
    elif isinstance(sex_raw, str) and sex_raw.strip().lower() in {"male", "m"}:
        sex_label = "male"
    elif isinstance(sex_raw, str) and sex_raw.strip().lower() in {"female", "f"}:
        sex_label = "female"
    else:
        sex_label = "patient"
    return f"The patient is a {age}-year-old {sex_label}."


def _generate_lifestyle_overview(patient_data: Dict[str, Any]) -> Any:
    unhealthy: List[str] = []
    if _as_bool(_get(patient_data, "Smoking", False)):
        unhealthy.append("Current smoker")
    if _as_bool(_get(patient_data, "AlcoholDrinking", False)):
        unhealthy.append("Regular alcohol consumption")
    sleep = _get(patient_data, "SleepTime")
    if sleep is not None:
        sleep = float(sleep)
        if sleep < SLEEP_HEALTHY_MIN_HOURS:
            unhealthy.append(f"Insufficient sleep duration ({sleep} hours/night)")
        elif sleep > SLEEP_HEALTHY_MAX_HOURS:
            unhealthy.append(f"Excessive sleep duration ({sleep} hours/night)")
    if not unhealthy:
        return "TODO: All lifestyle habits are healthy -- please specify the exact wording you'd like used for this case."
    return unhealthy


def generate_summary(patient_data: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "profile": _generate_profile(patient_data),
        "lifestyle_overview": _generate_lifestyle_overview(patient_data),
    }


def generate_risk_factors(
    patient_data: Dict[str, Any],
    missing_labs: Optional[Set[str]] = None,
    max_factors: int = 3,
) -> List[str]:
    missing_labs = (
        missing_labs if missing_labs is not None else _infer_missing_labs(patient_data)
    )
    results: List[str] = []
    for feature_name, _importance in FEATURE_PRIORITY:
        if len(results) >= max_factors:
            break
        if feature_name in SKIP_FEATURES or feature_name.startswith(
            MISSING_FLAG_PREFIX
        ):
            continue
        evaluator = RISK_EVALUATORS.get(feature_name)
        if evaluator is None:
            continue
        finding = evaluator(patient_data, missing_labs)
        if finding:
            results.append(finding)
    return results


def generate_positive_factors(
    patient_data: Dict[str, Any], missing_labs: Optional[Set[str]] = None
) -> List[str]:
    missing_labs = (
        missing_labs if missing_labs is not None else _infer_missing_labs(patient_data)
    )
    results: List[str] = []
    for feature_name, _importance in FEATURE_PRIORITY:
        if feature_name in SKIP_FEATURES or feature_name.startswith(
            MISSING_FLAG_PREFIX
        ):
            continue
        evaluator = POSITIVE_EVALUATORS.get(feature_name)
        if evaluator is None:
            continue
        finding = evaluator(patient_data, missing_labs)
        if finding:
            results.append(finding)
    return results


def generate_recommendations(patient_data: Dict[str, Any]) -> List[str]:
    recommendations: List[str] = []
    if _as_bool(_get(patient_data, "Smoking", False)):
        recommendations.append("Smoking cessation is strongly recommended.")
    else:
        recommendations.append("Maintain your current non-smoking status.")
    if _as_bool(_get(patient_data, "AlcoholDrinking", False)):
        recommendations.append("Reduce alcohol consumption.")
    else:
        recommendations.append("Continue avoiding alcohol consumption.")
    sleep = _get(patient_data, "SleepTime")
    if sleep is not None:
        sleep = float(sleep)
        if sleep < SLEEP_HEALTHY_MIN_HOURS or sleep > SLEEP_HEALTHY_MAX_HOURS:
            recommendations.append(
                "Improve sleep hygiene to reach 6-9 hours per night."
            )
        else:
            recommendations.append("Maintain your current healthy sleep schedule.")
    if _as_bool(_get(patient_data, "ChronicHypertension", False)):
        recommendations.append(
            "Continue monitoring and managing blood pressure with your physician."
        )
    if _as_bool(_get(patient_data, "Diabetic", False)):
        recommendations.append(
            "Continue monitoring blood sugar levels and follow your diabetes care plan."
        )
    return recommendations


def generate_lifestyle_tips(patient_data: Dict[str, Any]) -> List[str]:
    tips: List[str] = []
    sleep = _get(patient_data, "SleepTime")
    if sleep is not None:
        sleep = float(sleep)
        if sleep < SLEEP_HEALTHY_MIN_HOURS:
            tips.append(
                "Try to go to bed at a consistent time each night to get closer to 7-8 hours of sleep."
            )
        elif sleep > SLEEP_HEALTHY_MAX_HOURS:
            tips.append(
                "Very long sleep can sometimes signal other health issues -- consider discussing this with your doctor."
            )
        else:
            tips.append(
                "Keep up your healthy sleep routine -- it supports heart health."
            )
    if not tips:
        tips.append(
            "Maintaining a balanced sleep schedule supports overall heart health."
        )
    return tips


def generate_warning_signs(patient_data: Dict[str, Any]) -> List[str]:
    warnings: List[str] = []
    if _as_bool(_get(patient_data, "ChronicHypertension", False)):
        warnings.append(
            "Hypertension: Seek immediate care for severe headache, blurred vision, chest pain, or shortness of breath."
        )
    if _as_bool(_get(patient_data, "Diabetic", False)):
        warnings.append(
            "Diabetes: Watch for excessive thirst, frequent urination, blurred vision, confusion, or unexplained fatigue, which can signal dangerously high or low blood sugar."
        )
    if _as_bool(_get(patient_data, "MyocardialInfarctionInHeart", False)):
        warnings.append(
            "Previous Heart Attack: Seek emergency care immediately for chest pain or pressure, pain spreading to the arm or jaw, shortness of breath, or cold sweats."
        )
    if _as_bool(_get(patient_data, "BrainStroke", False)):
        warnings.append(
            "Previous Stroke: Seek emergency care immediately for sudden numbness or weakness (especially on one side), sudden confusion, trouble speaking, or sudden severe headache."
        )
    return warnings


def generate_clinical_interpretation(
    patient_data: Dict[str, Any],
    prediction: Any,
    probability: float,
    missing_labs: Optional[List[str]] = None,
) -> Dict[str, Any]:
    missing_set = (
        set(missing_labs)
        if missing_labs is not None
        else _infer_missing_labs(patient_data)
    )
    return {
        "prediction": prediction,
        "probability": probability,
        "summary": generate_summary(patient_data),
        "main_risk_factors": generate_risk_factors(patient_data, missing_set),
        "positive_factors": generate_positive_factors(patient_data, missing_set),
        "recommendations": generate_recommendations(patient_data),
        "lifestyle_tips": generate_lifestyle_tips(patient_data),
        "warning_signs": generate_warning_signs(patient_data),
    }
