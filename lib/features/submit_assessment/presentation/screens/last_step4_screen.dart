import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/cubit.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/bar_indecator.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/drop_down.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/select_option.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/text_field.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';

class Step4 extends StatefulWidget {
  const Step4({super.key});

  @override
  State<Step4> createState() => _Step4State();
}

class _Step4State extends State<Step4> {
  String? diabetic, generalHealth, asthma, brainStroke, kidneyDisease, cancerHistory,chronicHypertension,liverDisease,immunologicalDiseases,myocardialInfarctionInHeart;
  int? physicalHealthDays, mentalHealthDays;
  // Past Heart Conditions
  // final List<String> _heartConditionOptions = [
  //   'Previous Heart Attack',
  //   'Angina / Chest Pain',
  //   'Heart Failure',
  //   'Irregular Heartbeat',
  //   'None of the above',
  // ];
  // final Set<String> _selectedHeartConditions = {};

  // // Family History
  // final List<String> _familyHistoryOptions = [
  //   'Parent with heart disease',
  //   'Family history of diabetes',
  //   'Sibling with heart disease',
  //   'None of the above',
  // ];
  // final Set<String> _selectedFamilyHistory = {};

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AssessmentCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: buildBarIndicator('Step 4 of 4', 4, cubit),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 12),
          Text(
            'Medical History'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select any conditions that apply to you'.tr(),
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _buildLabel('General Health?'),
          const SizedBox(height: 6),
          CustomDropdown<String>(
            hint: 'Select option',
            items: const [
              "Poor",
              "Fair",
              "Good",
              "Very good",
              "Excellent",
            ],
            value: generalHealth,
            onChanged: (v) => setState(() => generalHealth = v),
          ),
          const SizedBox(height: 16),

          _buildLabel('Physical Health Days (last 30 days)?'),
          const SizedBox(height: 6),
          buildTextField(
            hint: '10',
            keyboardType: TextInputType.number,
            onChanged: (v) => physicalHealthDays = int.tryParse(v),
          ),
          const SizedBox(height: 16),
          _buildLabel('Mental Health Days (last 30 days)?'),
          const SizedBox(height: 6),
          buildTextField(
            hint: '10',
            keyboardType: TextInputType.number,
            onChanged: (v) => mentalHealthDays = int.tryParse(v),
          ),
          
          const SizedBox(height: 16),
          _buildLabel('Are you diabetic?'),
          const SizedBox(height: 6),
          YesNoSelector(
            value: diabetic,
            onChanged: (v) => setState(() => diabetic = v),
          ),
          const SizedBox(height: 16),
          _buildLabel('Are you suffering from chronic high blood pressure?'),
          const SizedBox(height: 6),
          YesNoSelector(
            value: chronicHypertension,
            onChanged: (v) => setState(() => chronicHypertension = v),
          ),
          const SizedBox(height: 16),
          _buildLabel('Are you a liver patient?'),
          const SizedBox(height: 6),
          YesNoSelector(
            value: liverDisease,
            onChanged: (v) => setState(() => liverDisease = v),
          ),
          const SizedBox(height: 16),

          _buildLabel('Do you have kidney disease?'),
          const SizedBox(height: 6),
          YesNoSelector(
            value: kidneyDisease,
            onChanged: (v) => setState(() => kidneyDisease = v),
          ),
          const SizedBox(height: 16),
          _buildLabel('Do you have an autoimmune disease?'),
          const SizedBox(height: 6),
          YesNoSelector(
            value: immunologicalDiseases,
            onChanged: (v) => setState(() => immunologicalDiseases = v),
          ),
          const SizedBox(height: 16),
          _buildLabel('Did you have a stroke?'),
          const SizedBox(height: 6),
          YesNoSelector(
            value: brainStroke,
            onChanged: (v) => setState(() => brainStroke = v),
          ),
          const SizedBox(height: 16),
          _buildLabel('Did you have a heart attack?'),
          const SizedBox(height: 6),
          YesNoSelector(
            value: myocardialInfarctionInHeart,
            onChanged: (v) => setState(() => myocardialInfarctionInHeart = v),
          ),
          const SizedBox(height: 16),

          _buildLabel('Asthma?'),
          const SizedBox(height: 6),
          YesNoSelector(
            value: asthma,
            onChanged: (v) => setState(() => asthma = v),
          ),
          const SizedBox(height: 16),
          
          
          _buildLabel('Have Cancer History?'),
          const SizedBox(height: 6),
          YesNoSelector(
            value: cancerHistory,
            onChanged: (v) => setState(() => cancerHistory = v),
          ),

          // Past Heart Conditions
          // const Text(
          //   'Past Heart Conditions',
          //   style: TextStyle(
          //       fontSize: 14,
          //       fontWeight: FontWeight.w600,
          //       color: Colors.black87),
          // ),
          // const SizedBox(height: 10),
          // ..._heartConditionOptions.map((option) => _buildCheckItem(
          //       label: option,
          //       checked: _selectedHeartConditions.contains(option),
          //       onChanged: (val) {
          //         setState(() {
          //           if (option == 'None of the above') {
          //             _selectedHeartConditions.clear();
          //             if (val == true) {
          //               _selectedHeartConditions.add(option);
          //             }
          //           } else {
          //             _selectedHeartConditions.remove('None of the above');
          //             if (val == true) {
          //               _selectedHeartConditions.add(option);
          //             } else {
          //               _selectedHeartConditions.remove(option);
          //             }
          //           }
          //         });
          //       },
          //     )

          const SizedBox(height: 24),

          // Family History
          // const Text(
          //   'Family History',
          //   style: TextStyle(
          //       fontSize: 14,
          //       fontWeight: FontWeight.w600,
          //       color: Colors.black87),
          // ),
          // const SizedBox(height: 4),
          // const Text(
          //   'Select any that apply to your family',
          //   style: TextStyle(fontSize: 12, color: Colors.grey),
          // ),
          // const SizedBox(height: 10),
          // ..._familyHistoryOptions.map((option) => _buildCheckItem(
          //       label: option,
          //       checked: _selectedFamilyHistory.contains(option),
          //       onChanged: (val) {
          //         setState(() {
          //           if (option == 'None of the above') {
          //             _selectedFamilyHistory.clear();
          //             if (val == true) {
          //               _selectedFamilyHistory.add(option);
          //             }
          //           } else {
          //             _selectedFamilyHistory.remove('None of the above');
          //             if (val == true) {
          //               _selectedFamilyHistory.add(option);
          //             } else {
          //               _selectedFamilyHistory.remove(option);
          //             }
          //           }
          //         });
          //       },
          //     )),

          const SizedBox(height: 28),

          BaseButton(
            buttonTitle: "Review Answers  →",
            titleColor: Colors.white,
            borderRadius: 10,
            borderColor: Colors.transparent,
            backgroundColor: const Color(0xFF1E63F3),
            onPressed: () {
              // final heartList = _selectedHeartConditions.toList();
              // final familyList = _selectedFamilyHistory.toList();

              if (diabetic == null ||
                    generalHealth == null ||
                    asthma == null ||
                    brainStroke == null||
                    kidneyDisease == null||
                    cancerHistory == null||
                    physicalHealthDays == null||
                    mentalHealthDays == null||
                    chronicHypertension == null||
                    liverDisease == null||
                    immunologicalDiseases == null||
                    myocardialInfarctionInHeart == null
                    
                    ) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

              cubit.medicalHistory(
                physicalHealthDays: physicalHealthDays!,
                mentalHealthDays: mentalHealthDays!,
                diabetic: diabetic!,
                generalHealth: generalHealth!,
                asthma: asthma!,
                brainStroke: brainStroke!,
                kidneyDisease: kidneyDisease!,
                cancerHistory: cancerHistory!,
                chronicHypertension: chronicHypertension!,
                liverDisease: liverDisease!,
                immunologicalDiseases: immunologicalDiseases!,
                myocardialInfarctionInHeart: myocardialInfarctionInHeart!,

              );
              cubit.nextStep();
            },
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  // Widget _buildCheckItem({
  //   required String label,
  //   required bool checked,
  //   required ValueChanged<bool?> onChanged,
  // }) {
  //   return GestureDetector(
  //     onTap: () => onChanged(!checked),
  //     child: Container(
  //       margin: const EdgeInsets.only(bottom: 8),
  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(8),
  //         border: Border.all(
  //           color: checked ? const Color(0xFF1E63F3) : Colors.grey.shade200,
  //           width: checked ? 1.5 : 1,
  //         ),
  //       ),
  //       child: Row(
  //         children: [
  //           Container(
  //             width: 20,
  //             height: 20,
  //             decoration: BoxDecoration(
  //               color: checked ? const Color(0xFF1E63F3) : Colors.transparent,
  //               borderRadius: BorderRadius.circular(4),
  //               border: Border.all(
  //                 color:
  //                     checked ? const Color(0xFF1E63F3) : Colors.grey.shade400,
  //                 width: 1.5,
  //               ),
  //             ),
  //             child: checked
  //                 ? const Icon(Icons.check, color: Colors.white, size: 14)
  //                 : null,
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Text(
  //               label,
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 color: checked ? const Color(0xFF1E63F3) : Colors.black87,
  //                 fontWeight: checked ? FontWeight.w500 : FontWeight.normal,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildLabel(String text) => Text(
        'FormFieldLabel.$text'.tr(),
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
      );

  // Widget _buildTextField({
  //   required String hint,
  //   TextInputType keyboardType = TextInputType.text,
  //   required Function(String) onChanged,
  // }) {
  //   return TextField(
  //     keyboardType: keyboardType,
  //     onChanged: onChanged,
  //     decoration: InputDecoration(
  //       hintText: hint,
  //       hintStyle: const TextStyle(color: Colors.black38),
  //       filled: true,
  //       fillColor: Colors.white,
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: BorderSide(color: Colors.grey.shade200),
  //       ),
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: BorderSide(color: Colors.grey.shade200),
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: const BorderSide(color: Color(0xFF1E63F3), width: 1.5),
  //       ),
  //       contentPadding:
  //           const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  //     ),
  //   );
  // }

}
