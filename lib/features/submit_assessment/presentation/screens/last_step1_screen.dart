import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/cubit.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/drop_down.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/text_field.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';

class Step1 extends StatefulWidget {
  const Step1({super.key});

  @override
  State<Step1> createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  String? age;
  String? gender;
  String? race;
  int? height;
  int? weight;


  @override
 

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AssessmentCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
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
              'Step 1 of 4'.tr(),
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 1 / 4,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF1E63F3),
            minHeight: 4,
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
              'Demographics & Basic Health'.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
             Text(
              'Please provide your basic information'.tr(),
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Age field
            _buildLabel('Age (years)'),
            const SizedBox(height: 6),
            CustomDropdown<String>(
              
              hint: "Select your age range",
              items: [
                "18-24", "25-29", "30-34", "35-39", "40-44", "45-49",
                "50-54", "55-59", "60-64", "65-69", "70-74", "75-79",
                "80 or older", // was "80+" — WRONG
              ],
              value: age,
              onChanged: (v) => setState(() => age = v),
            ),
            const SizedBox(height: 16),

            // Sex field
            _buildLabel('Gender'),
            const SizedBox(height: 6),
            CustomDropdown<String>(
              hint: 'Select your gender',
              items: ['Male', 'Female'],
              value: gender,
              onChanged: (v) => setState(() => gender = v),
            ),
            const SizedBox(height: 16),

            _buildLabel('Race'),
            const SizedBox(height: 6),
            CustomDropdown<String>(
              // title: "Race",
              hint: "select your race",
              items: [
                "White",
                "Black",
                "Asian",
                "Hispanic",
                "American Indian/Alaskan Native",
                "Other",
              ],
              value: race,
              onChanged: (v) => setState(() => race = v),
            ),
            const SizedBox(height: 16),


            // Height field
            _buildLabel('Height (cm)'),
            const SizedBox(height: 6),
            buildTextField(
              hint: '170',
              keyboardType: TextInputType.number,
              onChanged: (v) => height = int.tryParse(v),
            ),
            const SizedBox(height: 16),

            // Weight field
            _buildLabel('Weight (kg)'),
            const SizedBox(height: 6),
            buildTextField(
              hint: '70',
              keyboardType: TextInputType.number,
              onChanged: (v) => weight = int.tryParse(v),
            ),
            const SizedBox(height: 20),

            // Blood Pressure Card
            // Container(
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(12),
            //     border: Border.all(color: const Color(0xFFD0E4FF), width: 1.5),
            //   ),
            //   padding: const EdgeInsets.all(14),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Text(
            //         'Blood Pressure',
            //         style: TextStyle(
            //           color: Color(0xFF1E63F3),
            //           fontWeight: FontWeight.w600,
            //           fontSize: 14,
            //         ),
            //       ),
            //       const SizedBox(height: 12),
            //       Row(
            //         children: [
            //           Expanded(
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 const Text('Systolic',
            //                     style: TextStyle(
            //                         fontSize: 12, color: Colors.grey)),
            //                 const SizedBox(height: 4),
            //                 TextField(
            //                   controller: _systolicCtrl,
            //                   keyboardType: TextInputType.number,
            //                   decoration: InputDecoration(
            //                     hintText: '120',
            //                     hintStyle:
            //                         const TextStyle(color: Colors.black45),
            //                     filled: true,
            //                     fillColor: const Color(0xFFF5F7FA),
            //                     border: OutlineInputBorder(
            //                       borderRadius: BorderRadius.circular(8),
            //                       borderSide: BorderSide.none,
            //                     ),
            //                     contentPadding: const EdgeInsets.symmetric(
            //                         horizontal: 12, vertical: 10),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //           const SizedBox(width: 12),
            //           Expanded(
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 const Text('Diastolic',
            //                     style: TextStyle(
            //                         fontSize: 12, color: Colors.grey)),
            //                 const SizedBox(height: 4),
            //                 TextField(
            //                   controller: _diastolicCtrl,
            //                   keyboardType: TextInputType.number,
            //                   decoration: InputDecoration(
            //                     hintText: '80',
            //                     hintStyle:
            //                         const TextStyle(color: Colors.black45),
            //                     filled: true,
            //                     fillColor: const Color(0xFFF5F7FA),
            //                     border: OutlineInputBorder(
            //                       borderRadius: BorderRadius.circular(8),
            //                       borderSide: BorderSide.none,
            //                     ),
            //                     contentPadding: const EdgeInsets.symmetric(
            //                         horizontal: 12, vertical: 10),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //       const SizedBox(height: 6),
            //       const Text('mmHg',
            //           style: TextStyle(fontSize: 11, color: Colors.grey)),
            //     ],
            //   ),
            // ),

            const SizedBox(height: 28),

            BaseButton(
              buttonTitle: "Continue to Step 2  →",
              titleColor: Colors.white,
              borderRadius: 10,
              borderColor: Colors.transparent,
              backgroundColor: const Color(0xFF1E63F3),
              onPressed: () {
                if (age == null ||
                    gender == null ||
                    race == null ||
                    height == null ||
                    weight == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }
                final double bmi =
                    weight! / ((height! / 100.0) * (height! / 100.0));
                cubit.updateDemographics(
                  age: age!,
                  gender: gender!,
                  race: race!,
                  height: height!,
                  weight: weight!,
                  bmi: double.parse(bmi.toStringAsFixed(1)),
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
