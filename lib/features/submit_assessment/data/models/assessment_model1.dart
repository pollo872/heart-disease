// lib/features/submit_assessment/data/models/assessment_model.dart

class SubmitAssessmentModel {
  // Demographics
  double? bmi;
  String? age;          // AgeCategory e.g. "55-59"
  String? sex;          // "Male" | "Female"
  String? race;         // Must match: White/Black/Asian/Hispanic/
                        //   American Indian/Alaskan Native/Other
  int?    height;       // cm  (stored locally, not sent to model)
  int?    weight;       // kg  (stored locally, not sent to model)

  // Lifestyle — sent as "Yes"/"No" strings (Flask converts to 0/1)
  String? smoking;
  String? alcohol;
  String? physicalActivity;
  String? difficultyWalking;

  // Medical
  String? diabetic;     // "Yes"/"No"/"No, borderline diabetes"/"Yes (during pregnancy)"
  String? generalHealth;// "Excellent"/"Very good"/"Good"/"Fair"/"Poor"
  String? asthma;
  String? stroke;
  String? kidneyDisease;
  String? skinCancer;

  // Numeric health metrics
  int? physicalHealthDays;  // 0–30
  int? mentalHealthDays;    // 0–30
  int? sleepTime;           // 0–24

  Map<String, dynamic> toJson() {
    return {
      // ── Continuous numeric ────────────────────────────────────────────────
      "BMI":            bmi,
      "PhysicalHealth": physicalHealthDays,
      "MentalHealth":   mentalHealthDays,
      "SleepTime":      sleepTime,

      // ── Categorical (passed as strings, Flask handles encoding) ───────────
      "AgeCategory":      age,       // e.g. "55-59"  — NOT "80+"  use "80 or older"
      "Sex":              sex,
      "Race":             race,
      "GenHealth":        generalHealth,

      // ── Binary Yes/No (Flask converts to 0/1) ─────────────────────────────
      "Smoking":          smoking,
      "AlcoholDrinking":  alcohol,
      "PhysicalActivity": physicalActivity,
      "DiffWalking":      difficultyWalking,
      "Diabetic":         diabetic,
      "Asthma":           asthma,
      "Stroke":           stroke,
      "KidneyDisease":    kidneyDisease,
      "SkinCancer":       skinCancer,

      // NOTE: height & weight are NOT sent to the model (not in training data)
      // They are only used locally to compute BMI above.
    };
  }
}
