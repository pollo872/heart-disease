import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/cubit.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/bar_indecator.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/select_option.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/text_field.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';

class Step2 extends StatefulWidget {
  const Step2({super.key});

  @override
  State<Step2> createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  String? smoking;
  String? alcohol;
  String? physicalActivity;
  String? difficultyWalking;
  int? sleepTime;
  int? coffeeIntake;
  @override
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AssessmentCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: buildBarIndicator('Step 2 of 4', 2, cubit),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              'Lifestyle & Habits'.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Help us understand your daily lifestyle choices'.tr(),
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildLabel('Sleep Time (hours per day)?'),
            const SizedBox(height: 6),
            buildTextField(
              hint: '8',
              keyboardType: TextInputType.number,
              onChanged: (v) => sleepTime = int.tryParse(v),
            ),
            const SizedBox(height: 16),
            _buildLabel('Caffeine Intake (cups per day)?'),
            const SizedBox(height: 6),
            buildTextField(
              hint: '2',
              keyboardType: TextInputType.number,
              onChanged: (v) => coffeeIntake = int.tryParse(v),
            ),
            const SizedBox(height: 16),

            // Smoking
            _buildLabel('Do you smoke?'),
            const SizedBox(height: 6),
            YesNoSelector(
              value: smoking,
              onChanged: (v) => setState(() => smoking = v),
            ),
            const SizedBox(height: 16),

            // Diet
            _buildLabel('Do you drink alcohol?'),
            const SizedBox(height: 6),
            YesNoSelector(
              value: alcohol,
              onChanged: (v) => setState(() => alcohol = v),
            ),
            const SizedBox(height: 16),

            // Exercise
            _buildLabel('Physical activity (exercise)?'),
            const SizedBox(height: 6),
            YesNoSelector(
              value: physicalActivity,
              onChanged: (v) => setState(() => physicalActivity = v),
            ),
            const SizedBox(height: 16),

            // Stress
            _buildLabel('Difficulty walking/climbing stairs?'),
            const SizedBox(height: 6),
            YesNoSelector(
              value: difficultyWalking,
              onChanged: (v) => setState(() => difficultyWalking = v),
            ),

            const SizedBox(height: 28),

            BaseButton(
              buttonTitle: "Continue to Step 3  →",
              titleColor: Colors.white,
              borderRadius: 10,
              borderColor: Colors.transparent,
              backgroundColor: const Color(0xFF1E63F3),
              onPressed: () {
                if (smoking == null ||
                    alcohol == null ||
                    physicalActivity == null ||
                    difficultyWalking == null ||
                    sleepTime == null ||
                    coffeeIntake == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }
                cubit.updateLifestyle(
                  smoking: smoking!,
                  alcohol: alcohol!,
                  physicalActivity: physicalActivity!,
                  difficultyWalking: difficultyWalking!,
                  sleepTime: sleepTime!,
                  coffeeIntake: coffeeIntake! ,
                );
                cubit.nextStep();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        'FormFieldLabel.$text'.tr(),
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
      );

  // Widget _buildDropdown<T>({
  //   required String hint,
  //   required List<T> items,
  //   required T? value,
  //   required ValueChanged<T?> onChanged,
  // }) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: Colors.grey.shade200),
  //     ),
  //     padding: const EdgeInsets.symmetric(horizontal: 14),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton<T>(
  //         isExpanded: true,
  //         hint: Text(hint,
  //             style: const TextStyle(color: Colors.black38, fontSize: 14)),
  //         value: value,
  //         icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
  //         items: items
  //             .map((e) => DropdownMenuItem<T>(
  //                   value: e,
  //                   child: Text(e.toString(),
  //                       style: const TextStyle(fontSize: 14)),
  //                 ))
  //             .toList(),
  //         onChanged: onChanged,
  //       ),
  //     ),
  //   );
  // }
}
