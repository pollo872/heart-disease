import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/cubit.dart';

 buildBarIndicator(
    String title, int value, AssessmentCubit cubit) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: BackButton(
      color: Colors.black87,
      onPressed: () => cubit.prevStep(),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HealthAssessment'.tr(),
          style: TextStyle(
            color: Color(0xFF1E63F3),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          title.tr(),
          style: TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(4),
      child: LinearProgressIndicator(
        value: value/4,
        backgroundColor: Colors.grey[200],
        color: const Color(0xFF1E63F3),
        minHeight: 4,
      ),
    ),
  );
}
