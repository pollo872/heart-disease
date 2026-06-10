import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/cubit.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/bar_indecator.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/text_field.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';

class Step3 extends StatefulWidget {
  const Step3({super.key});

  @override
  State<Step3> createState() => _Step3State();
}

class _Step3State extends State<Step3> {
  int? systolicBP;
  int? diastolicBP;
  double? bloodSugar;
  double? cholesterol;
  
  // final TextEditingController _systolicCtrl = TextEditingController();
  // final TextEditingController _diastolicCtrl = TextEditingController();
  // @override
  // void dispose() {
  //   _systolicCtrl.dispose();
  //   _diastolicCtrl.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AssessmentCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: buildBarIndicator('Step 3 of 4', 3, cubit),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              'Vital Signs & Labs'.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Please provide your vital signs and lab results'.tr(),
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Smoking
            
            _buildBloodPressureCard(),
            const SizedBox(height: 16),

            _buildLabel('Blood Sugar (mg/dL)'),
            const SizedBox(height: 6),
            buildTextField(
              hint: '100',
              keyboardType: TextInputType.number,
              onChanged: (v) => bloodSugar = double.tryParse(v),
            ),
            const SizedBox(height: 16),
            _buildLabel('Cholesterol (mg/dL)'),
            const SizedBox(height: 6),
            buildTextField(
              hint: '200',
              keyboardType: TextInputType.number,
              onChanged: (v) => cholesterol = double.tryParse(v),
            ),
            const SizedBox(height: 16),

            
            

            const SizedBox(height: 28),

            BaseButton(
              buttonTitle: "Continue to Step 4  →",
              titleColor: Colors.white,
              borderRadius: 10,
              borderColor: Colors.transparent,
              backgroundColor: const Color(0xFF1E63F3),
              onPressed: () {
                if (systolicBP == null ||
                    diastolicBP == null ||
                    bloodSugar == null ||
                    cholesterol == null 
                    ) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }
                cubit.healthMeasurements(
                  systolicBP: systolicBP!,
                  diastolicBP: diastolicBP!,
                  bloodSugar: bloodSugar!,
                  cholesterol: cholesterol!,
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

  Widget _buildBloodPressureCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0E4FF), width: 1.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Blood Pressure'.tr(),
            style: TextStyle(
              color: Color(0xFF1E63F3),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Systolic',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                   buildTextField(
                      hint: '120',
                      keyboardType: TextInputType.number,
                      onChanged: (v) => systolicBP = int.tryParse(v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Diastolic',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                   buildTextField(
                      hint: '80',
                      keyboardType: TextInputType.number,
                      onChanged: (v) => diastolicBP = int.tryParse(v),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('mmHg',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
  //Blood Pressure Card
}
