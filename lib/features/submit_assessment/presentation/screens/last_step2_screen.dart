import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/cubit.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/drop_down.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';

class Step2 extends StatefulWidget {
  const Step2({super.key});

  @override
  State<Step2> createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  String? smoking;
  String? alcohol;
  String? exerciseFrequency;
  String? stressLevel;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AssessmentCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading:  BackButton(color: Colors.black87,onPressed: () => cubit.prevStep(),),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            Text(
             'HealthAssessment'.tr(),
              style: TextStyle(
                color: Color(0xFF1E63F3),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Step 2 of 3'.tr(),
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 2 / 3,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF1E63F3),
            minHeight: 3,
          ),
        ),
      ),
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

            // Smoking
            _buildLabel('Do you smoke?'),
            const SizedBox(height: 6),
            CustomDropdown<String>(
              hint: 'Select option',
              items: const [
                'Yes',
                'No',
              ],
              value: smoking,
              onChanged: (v) => setState(() => smoking = v),
            ),
            const SizedBox(height: 16),

            // Diet
            _buildLabel('Do you drink alcohol?'),
            const SizedBox(height: 6),
            CustomDropdown<String>(
              hint: 'Select option',
              items: const [
                'Yes',
                'No',
              ],
              value: alcohol,
              onChanged: (v) => setState(() => alcohol = v),
            ),
            const SizedBox(height: 16),

            // Exercise
            _buildLabel('Physical activity (exercise)?'),
            const SizedBox(height: 6),
            CustomDropdown<String>(
              hint: 'Select option',
              items: const [
                'Yes',
                'No',
              ],
              value: exerciseFrequency,
              onChanged: (v) => setState(() => exerciseFrequency = v),
            ),
            const SizedBox(height: 16),

            // Stress
            _buildLabel('Difficulty walking/climbing stairs?'),
            const SizedBox(height: 6),
            CustomDropdown<String>(
              hint: 'Select option',
              items: const [
                'Yes',
                'No',
              ],
              value: stressLevel,
              onChanged: (v) => setState(() => stressLevel = v),
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
                    exerciseFrequency == null ||
                    stressLevel == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }
                cubit.updateLifestyle(
                  smoking: smoking!,
                  alcohol: alcohol!,
                  physicalActivity: exerciseFrequency!,
                  difficultyWalking: stressLevel!,
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
