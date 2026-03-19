import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/cubit.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/drop_down.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';

class Step2 extends StatefulWidget {
  @override
  State<Step2> createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  String? smoking, alcohol, physicalActivity, difficultyWalking;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AssessmentCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("Lifestyle & Habits")),
      body: Column(
        children: [
          CustomDropdown(
            title: "Do you smoke?",
            items: ["Yes", "No"],
            value: smoking,
            onChanged: (v) => setState(() => smoking = v),
          ),
          const SizedBox(height: 12),
          CustomDropdown(
            title: "Do you drink alcohol?",
            items: ["Yes", "No"],
            value: alcohol,
            onChanged: (v) => setState(() => alcohol = v),
          ),
          const SizedBox(height: 12),
          CustomDropdown(
            title: "Physical activity (exercise)?",
            items: ["Yes", "No"],
            value: physicalActivity,
            onChanged: (v) => setState(() => physicalActivity = v),
          ),
          const SizedBox(height: 12),
          CustomDropdown(
            title: "Difficulty walking/climbing stairs?",
            items: ["Yes", "No"],
            value: difficultyWalking,
            onChanged: (v) => setState(() => difficultyWalking = v),
          ),
          
          const Spacer(),
          BaseButton(
            buttonTitle: "Next",
            titleColor: Colors.white,
            borderRadius: 10,
            borderColor: Colors.transparent,
            backgroundColor: const Color(0xff1E63F3),
            onPressed: () {
              cubit.updateLifestyle(
                smoking: smoking!,
                alcohol: alcohol!,
                physicalActivity: physicalActivity!,
                difficultyWalking: difficultyWalking!,
              );
              cubit.nextStep();
            },
          )
        ],
      ),
    );
  }
}
