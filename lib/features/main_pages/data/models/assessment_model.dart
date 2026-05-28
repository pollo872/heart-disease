class AssessmentModel {
  final String id;
  final String predictionResult;
  final double probability;
  final String riskLevel;
  final String createdAt;
  final double bmi; // من الـ response: "BMI": 64.07

  AssessmentModel({
    required this.id,
    required this.predictionResult,
    required this.probability,
    required this.riskLevel,
    required this.createdAt,
    required this.bmi,

  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['_id'],
      predictionResult: json['predictionResult'],
      probability: json['probability'].toDouble(),
      riskLevel: json['riskLevel'],
      createdAt: json['createdAt'],
      bmi: json['BMI'].toDouble(),
    );
  }
  List<AssessmentModel> get allAssessments {
    return [];
  }
}