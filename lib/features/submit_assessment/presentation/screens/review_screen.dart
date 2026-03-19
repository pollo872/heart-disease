import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/cubit.dart';
import 'package:heart_disease/shared/widgets/base_button.dart';

class ReviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AssessmentCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("Review")),
      body: Column(
        children: [
          Text("Age: ${cubit.model.age}"),
          Text("Sex: ${cubit.model.sex}"),

          const Spacer(),

          BaseButton(
            buttonTitle: "Submit",
            titleColor: Colors.white,
            borderRadius: 10,
            borderColor: Colors.transparent,
            backgroundColor: const Color(0xff1E63F3),
            onPressed: () {
              cubit.submit();
              Navigator.pop(context, true);
            },
          )
        ],
      ),
    );
  }
}