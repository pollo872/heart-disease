import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:heart_disease/core/path_strings.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_ui_model.dart';
import 'package:heart_disease/theme/app_theme.dart';

class HistoryCard extends StatelessWidget {
  final String predictionResult;
  final String riskLevel;
  final String probability;
  final String createdAt;
  final AssessmentUIModel assessment;
  final VoidCallback onpressed;

  const HistoryCard({
    super.key,
    required this.predictionResult,
    required this.riskLevel,
    required this.probability,
    required this.createdAt,
    required this.assessment,
    required this.onpressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onpressed,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// DATE + BADGE
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6EEFF),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    PathStrings.historyCardIconPath,
                    width: 22,
                    height: 22,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM d, y')
                            .format(DateTime.parse(createdAt)),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Image.asset(
                            assessment.riskIconPath,
                            width: 16,
                            height: 16,
                            color: assessment.riskColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            assessment.riskHint,
                            style: AppTextStyles.subTitle,
                          ),
                        ],
                      ),
                    ],
                  ),
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
                    style: AppTextStyles.subTitle
                        .copyWith(color: assessment.riskColor, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffE9EEF8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MetricItem(
                    title: "Status",
                    value: 'StatusFromBack.$predictionResult'.tr(),
                  ),
                  MetricItem(
                    title: "RiskLevel",
                    value: 'RiskLevelFromBack.$riskLevel'.tr(),
                  ),
                  MetricItem(
                    title: "Probability",
                    value: "$probability%",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffDCE6F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                assessment.riskMessage,
                style:
                    AppTextStyles.subTitle.copyWith(color: AppColors.textBlue),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class MetricItem extends StatelessWidget {
  final String title;
  final String value;

  const MetricItem({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title.tr(),
            style: const TextStyle(
                color: AppColors.textLatestGray,
                fontSize: 14,
                fontWeight: FontWeight.w400)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textGreen,
                fontSize: 16)),
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
