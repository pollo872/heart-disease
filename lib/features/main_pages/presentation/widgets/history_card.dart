import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_ui_model.dart';

class HistoryCard extends StatelessWidget {
  final String predictionResult;
  final String riskLevel;
  final String probability;
  final String createdAt;
  final AssessmentUIModel assessment;

  const HistoryCard({
    required this.predictionResult,
    required this.riskLevel,
    required this.probability,
    required this.createdAt,
    required this.assessment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// DATE + BADGE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM d, y').format(DateTime.parse(createdAt)),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: assessment.riskBadgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  assessment.riskTitle,
                  style: TextStyle(color: assessment.riskColor, fontSize: 11),
                ),
              )
            ],
          ),

          const SizedBox(height: 8),

          Text(
            assessment.riskHint,
            style: TextStyle(color: assessment.riskColor),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffE9EEF8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MetricItem(title: "Status", value: predictionResult),
                MetricItem(title: "RiskLevel", value: riskLevel),
                MetricItem(title: "Probability", value: probability),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffDCE6F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              assessment.riskMessage,
              style: const TextStyle(fontSize: 12),
            ),
          ),
         const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class MetricItem extends StatelessWidget {
  final String title;
  final String value;

  const MetricItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title.tr(),
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

///------------------------------------------------------------
/// CARD STYLE
///------------------------------------------------------------

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
      )
    ],
  );
}
