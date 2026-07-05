// lib/features/submit_assessment/data/models/assessment_model.dart

class SubmitAssessmentModel {
  // Demographics
  double? bmi;
  String? age; // AgeCategory e.g. "55-59"
  String? sex; // "Male" | "Female"
  String? race; // Must match: White/Black/Asian/Hispanic/
  
  //   American Indian/Alaskan Native/Other
  int? height; // cm  (stored locally, not sent to model)
  int? weight; // kg  (stored locally, not sent to model)

  int? systolicBP; // mmHg
  int? diastolicBP; // mmHg
  double? bloodSugar; // mg/dL
  double? hba1c; // % (e.g., 5.0)
  double? cholesterol;

  // Lifestyle — sent as "Yes"/"No" strings (Flask converts to 0/1)
  String? smoking;
  String? alcohol;
  String? physicalActivity;
  String? difficultyWalking;
  int? sleepTime; // 0–24
  int? caffeineIntake; // cups per day


  // Medical
  String?
      diabetic; // "Yes"/"No"/"No, borderline diabetes"/"Yes (during pregnancy)"
  // String? generalHealth; // "Excellent"/"Very good"/"Good"/"Fair"/"Poor"
  String? asthma;
  String? brainstroke;
  String? kidneyDisease;
  String? cancerHistory; // "None"/"Skin Cancer"/"Other Cancer"
  String? chronicHypertension;
  String? liverDisease;
  String? immunologicalDiseases;
  String? myocardialInfarctionInHeart;

  // int? physicalHealthDays; // 0–30
  // int? mentalHealthDays; // 0–30

  Map<String, dynamic> toJson() {
    return {
      // ── Continuous numeric ────────────────────────────────────────────────
      "BMI": bmi,
      // "PhysicalHealth": physicalHealthDays,
      // "MentalHealth": mentalHealthDays,
      "SleepTime": sleepTime,
      "CaffeineIntake": caffeineIntake,

      // ── Categorical (passed as strings, Flask handles encoding) ───────────
      "AgeCategory": age, // e.g. "55-59"  — NOT "80+"  use "80 or older"
      "Sex": sex,
      "Race": race,
      // "GenHealth": generalHealth,

      "SystolicBP": systolicBP,
      "DiastolicBP": diastolicBP,
      "BloodSugar": bloodSugar,
      "HbA1c": hba1c,
      "Cholesterol": cholesterol,

      // ── Binary Yes/No (Flask converts to 0/1) ─────────────────────────────
      "Smoking": smoking,
      "AlcoholDrinking": alcohol,
      "PhysicalActivity": physicalActivity,
      "DiffWalking": difficultyWalking,


      "Diabetic": diabetic,
      "Asthma": asthma,
      "BrainStroke": brainstroke,
      "KidneyDisease": kidneyDisease,
      "CancerHistory": cancerHistory,
      "ChronicHypertension":chronicHypertension,
      "LiverDisease": liverDisease,
      "ImmunologicalDiseases": immunologicalDiseases,
      "MyocardialInfarctionInHeart": myocardialInfarctionInHeart,



      // NOTE: height & weight are NOT sent to the model (not in training data)
      // They are only used locally to compute BMI above.
    };
  }
}
