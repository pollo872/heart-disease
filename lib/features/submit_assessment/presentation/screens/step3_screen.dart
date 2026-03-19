import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/cubit.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/drop_down.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';

class Step3 extends StatefulWidget {
  @override
  State<Step3> createState() => _Step3State();
}

class _Step3State extends State<Step3> {
  String? diabetic, generalHealth, asthma, stroke, kidneyDisease, skinCancer;
  int? physicalHealthDays, mentalHealthDays, sleepTime;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AssessmentCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("Medical History")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomDropdown(
              title: "Diabetic?",
              items: ["Yes", "No"],
              value: diabetic,
              onChanged: (v) => setState(() => diabetic = v),
            ),
            const SizedBox(height: 12),
            CustomDropdown(
              title: "General Health?",
              items: ["Good", "Fair", "Poor", "Excellent", "Very good"],
              value: generalHealth,
              onChanged: (v) => setState(() => generalHealth = v),
            ),
            const SizedBox(height: 12),
            CustomDropdown(
              title: "Asthma?",
              items: ["Yes", "No"],
              value: asthma,
              onChanged: (v) => setState(() => asthma = v),
            ),
            const SizedBox(height: 12),
            CustomDropdown(
              title: "Stroke?",
              items: ["Yes", "No"],
              value: stroke,
              onChanged: (v) => setState(() => stroke = v),
            ),
            const SizedBox(height: 12),
            CustomDropdown(
              title: "Kidney Disease?",
              items: ["Yes", "No"],
              value: kidneyDisease,
              onChanged: (v) => setState(() => kidneyDisease = v),
            ),
            const SizedBox(height: 12),
            CustomDropdown(
              title: "Skin Cancer?",
              items: ["Yes", "No"],
              value: skinCancer,
              onChanged: (v) => setState(() => skinCancer = v),
            ),
            const SizedBox(height: 12),
            CustomDropdown(
              title: "Physical Health Days (last 30 days)?",
              items: List.generate(100, (i) => i),
              value: physicalHealthDays,
              onChanged: (v) => setState(() => physicalHealthDays = v),
            ),
            const SizedBox(height: 12),
            CustomDropdown(
              title: "Mental Health Days (last 30 days)?",
              items: List.generate(100, (i) => i),
              value: mentalHealthDays,
              onChanged: (v) => setState(() => mentalHealthDays = v),
            ),
            const SizedBox(height: 12),
            CustomDropdown(
              title: "Sleep Time (hours per day)?",
              items: List.generate(24, (i) => i),
              value: sleepTime,
              onChanged: (v) => setState(() => sleepTime = v),
            ),
            
            const SizedBox(height: 30),
            BaseButton(
              buttonTitle: "Next",
              titleColor: Colors.white,
              borderRadius: 10,
              borderColor: Colors.transparent,
              backgroundColor: const Color(0xff1E63F3),
              onPressed: () {
                cubit.medicalHistory(
                  diabetic: diabetic!,
                  generalHealth: generalHealth!,
                  asthma: asthma!,
                  stroke: stroke!,
                  kidneyDisease: kidneyDisease!,
                  skinCancer: skinCancer!,
                  physicalHealthDays: physicalHealthDays!,
                  mentalHealthDays: mentalHealthDays!,
                  sleepTime: sleepTime!,
                );
                cubit.nextStep();
              },
            )
          ],
        ),
      ),
    );
  }
}
