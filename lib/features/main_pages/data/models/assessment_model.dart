// class AssessmentModel {
//   final String id;
//   final String predictionResult;
//   final double probability;
//   final String riskLevel;
//   final String createdAt;
//   final double bmi; // من الـ response: "BMI": 64.07

//   AssessmentModel({
//     required this.id,
//     required this.predictionResult,
//     required this.probability,
//     required this.riskLevel,
//     required this.createdAt,
//     required this.bmi,

//   });

//   factory AssessmentModel.fromJson(Map<String, dynamic> json) {
//     return AssessmentModel(
//       id: json['_id'],
//       predictionResult: json['predictionResult'],
//       probability: json['probability'].toDouble(),
//       riskLevel: json['riskLevel'],
//       createdAt: json['createdAt'],
//       bmi: json['BMI'].toDouble(),
//     );
//   }
//   List<AssessmentModel> get allAssessments {
//     return [];
//   }
// }

class AiAnalysis {
  final String summary;
  final List<String> riskFactors;
  final List<String> positiveFactors;
  final List<String> recommendations;
  final List<String> lifestyleTips;
  final List<String> warningSigns;
  final String followUp;

  AiAnalysis({
    required this.summary,
    required this.riskFactors,
    required this.positiveFactors,
    required this.recommendations,
    required this.lifestyleTips,
    required this.warningSigns,
    required this.followUp,
  });

  // من Flask مباشرة (snake_case)
  factory AiAnalysis.fromJson(Map<String, dynamic> json) {
    return AiAnalysis(
      summary: json['summary'] ?? '',
      riskFactors: List<String>.from(json['risk_factors'] ?? []),
      positiveFactors: List<String>.from(json['positive_factors'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      lifestyleTips: List<String>.from(json['lifestyle_tips'] ?? []),
      warningSigns: List<String>.from(json['warning_signs'] ?? []),
      followUp: json['follow_up'] ?? '',
    );
  }

  // من MongoDB — بيحفظ camelCase، فنقرأ الاتنين
  factory AiAnalysis.fromMongoJson(Map<String, dynamic> json) {
    print("aiAnalysis keys: ${json.keys}"); // ✅ هتشوف الـ keys الحقيقية
    print("summary: ${json['summary']}");
    return AiAnalysis(
      summary: json['summary'] ?? '',
      riskFactors:
          List<String>.from(json['riskFactors'] ?? json['risk_factors'] ?? []),
      positiveFactors: List<String>.from(
          json['positiveFactors'] ?? json['positive_factors'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      lifestyleTips: List<String>.from(
          json['lifestyleTips'] ?? json['lifestyle_tips'] ?? []),
      warningSigns: List<String>.from(
          json['warningSigns'] ?? json['warning_signs'] ?? []),
      followUp: json['followUp'] ?? json['follow_up'] ?? '',
    );
  }
}

class AssessmentModel {
  final String id;
  final String predictionResult;
  final double probability;
  final String riskLevel;
  final String dPLevel;
  final String sugerLevel;
  final String cholesterolLevel;
  final String createdAt;
  final double bmi;
  final int systolicBP;
  final int diastolicBP;
  final double bloodSugar;
  final double cholesterol;
  final AiAnalysis? aiAnalysis;

  AssessmentModel({
    required this.id,
    required this.predictionResult,
    required this.probability,
    required this.riskLevel,
    required this.sugerLevel,
    required this.cholesterolLevel,
    required this.dPLevel,
    required this.createdAt,
    required this.bmi,
    this.systolicBP = 0,
    this.diastolicBP = 0,
    this.bloodSugar = 0,
    this.cholesterol = 0,
    this.aiAnalysis,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['_id'],
      predictionResult: json['predictionResult'],
      probability: (json['probability'] as num).toDouble(),
      riskLevel: json['riskLevel'],
      sugerLevel: json['sugerLevel'],
      cholesterolLevel: json['cholesterolLevel'],
      dPLevel: json['dPLevel'],
      createdAt: json['createdAt'],
      bmi: (json['BMI'] as num).toDouble(),
      systolicBP: (json['SystolicBP'] as num?)?.toInt() ?? 0,
      diastolicBP: (json['DiastolicBP'] as num?)?.toInt() ?? 0,
      bloodSugar: (json['BloodSugar'] as num?)?.toDouble() ?? 0.0,
      cholesterol: (json['Cholesterol'] as num?)?.toDouble() ?? 0.0,
      aiAnalysis: json['aiAnalysis'] != null
          ? AiAnalysis.fromMongoJson(json['aiAnalysis'])
          : null,
    );
  }
}
