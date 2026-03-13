class AssessmentModel {
  final String id;
  final String predictionResult;
  final double probability;
  final String riskLevel;
  final String createdAt;

  AssessmentModel({
    required this.id,
    required this.predictionResult,
    required this.probability,
    required this.riskLevel,
    required this.createdAt,

  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['_id'],
      predictionResult: json['predictionResult'],
      probability: json['probability'].toDouble(),
      riskLevel: json['riskLevel'],
      createdAt: json['createdAt'],
    );
  }
}