import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/core/di/service_locator.dart';
import 'package:heart_disease/features/main_pages/presentation/screens/result_screen.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/cubit.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/state.dart';
import 'package:heart_disease/features/submit_assessment/presentation/screens/last_review_screen.dart';
import 'package:heart_disease/features/submit_assessment/presentation/screens/last_step1_screen.dart';
import 'package:heart_disease/features/submit_assessment/presentation/screens/last_step2_screen.dart';
import 'package:heart_disease/features/submit_assessment/presentation/screens/last_step3_screen.dart';


class AssessmentFlow extends StatelessWidget {
  const AssessmentFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AssessmentCubit>(),
      child: BlocConsumer<AssessmentCubit, AssessmentState>(
        listener: (context, state) {
          if (state is AssessmentError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is AssessmentSuccess) {
               Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: double.parse(state.assessment.probability),
            riskLevel: state.assessment.riskLevel,
            createdAt: state.assessment.createdAt,
            assessment: state.assessment,
          ),
        ),
      );
          }
        },
        builder: (context, state) {
          final cubit = context.read<AssessmentCubit>();

          if (state is AssessmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          switch (cubit.step) {
            case 0:
              return Step1();
            case 1:
              return Step2();
            case 2:
              return Step3();
            case 3:
              return ReviewScreen();
            default:
              return Step1();
          }
        },
      ),
    );
  }
}