import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';
import 'package:heart_disease/theme/app_theme.dart';

class StartAssessmentCard extends StatelessWidget {
  final VoidCallback onPressed;

  const StartAssessmentCard({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9), // نفس الخلفية
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🔵 الدائرة اللي فيها +
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 36,
            ),
          ),

          const SizedBox(height: 16),

          /// 📝 العنوان
           Text(
            "StartNewAssessment".tr(),
            style: AppTextStyles.subTitle.copyWith(
              color: AppColors.textBlue,
              
            ),
          ),

          const SizedBox(height: 8),

          /// 📄 الوصف
           Text(
            "CompleteEvaluation".tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.subTitle.copyWith(
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),
          BaseButton(
            buttonTitle: "BeginAssessment",
            titleColor: AppColors.background,
            borderRadius: 10,
            borderColor: AppColors.primary,
            backgroundColor: AppColors.primary,
            onPressed: onPressed,
          ),

          /// 🔘 الزرار
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     onPressed: onPressed,
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: const Color(0xFF2F6BFF),
          //       padding: const EdgeInsets.symmetric(vertical: 14),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //       elevation: 0,
          //     ),
          //     child: const Text(
          //       "Begin Assessment",
          //       style: TextStyle(
          //         fontSize: 14,
          //         color: Colors.white,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
