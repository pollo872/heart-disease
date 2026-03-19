import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/cubit.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/drop_down.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/snackbar_err.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';

class Step1 extends StatefulWidget {
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
  Widget build(BuildContext context) {
    final cubit = context.read<AssessmentCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("Demographics & Basic Health")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomDropdown<String>(
              title: "Gender",
              items: ["Male", "Female"],
              value: gender,
              onChanged: (v) => setState(() => gender = v),
            ),
            const SizedBox(height: 12),
            CustomDropdown<String>(
              title: "Age",
              items: ["18-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80+"],
              value: age,
              onChanged: (v) => setState(() => age = v),
            ),
            const SizedBox(height: 12),
            CustomDropdown<String>(
              title: "race",
              items: ["Black", "White", "Asian"],
              value: race,
              onChanged: (v) => setState(() => race = v),
            ),
            const SizedBox(height: 12),
            CustomDropdown<int>(
              title: "Height(cm)",
              items: List.generate(250, (i) => i + 100),
              value: height,
              onChanged: (v) => setState(() => height = v),
            ),
            const SizedBox(height: 12),
            CustomDropdown<int>(
              title: "Weight(kg)",
              items:List.generate(200, (i) => i + 30),
              value: weight,
              onChanged: (v) => setState(() => weight = v),
            ),
            const Spacer(),
            BaseButton(
              buttonTitle: "Next",
              titleColor: Colors.white,
              borderRadius: 10,
              borderColor: Colors.transparent,
              backgroundColor: const Color(0xff1E63F3),
              onPressed: () {
                if (age == null || gender == null) {
                  showError(context, "Please fill all fields");
                  return;
                }
                cubit.updateDemographics(
                  age: age!,
                  gender: gender!,
                  race: race!,
                  height: height ?? 100,
                  weight: weight ?? 30,
                  bmi: weight!/((height!/100) * (height!/100))
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
