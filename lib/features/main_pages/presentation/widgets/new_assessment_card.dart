import 'package:flutter/material.dart';
import 'package:heart_disease/res/app_colors.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';

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
          color: const Color(0xFF2F6BFF),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🔵 الدائرة اللي فيها +
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFF2F6BFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(height: 16),

          /// 📝 العنوان
          const Text(
            "Start New Assessment",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C2A3A),
            ),
          ),

          const SizedBox(height: 8),

          /// 📄 الوصف
          const Text(
            "Complete a comprehensive heart health evaluation",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),
          BaseButton(
            buttonTitle: "Begin Assessment",
            titleColor: AppColors.baseBtnColorWhite,
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
