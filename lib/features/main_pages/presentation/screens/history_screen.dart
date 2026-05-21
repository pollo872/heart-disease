import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_state.dart';
import 'package:heart_disease/features/main_pages/presentation/screens/result_screen.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/history_card.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/history_header.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/main_appbar.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/new_assessment_card.dart';
import 'package:heart_disease/features/submit_assessment/presentation/widgets/assessment_flow.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        if (state is ProfileLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProfileErrorState) {
          return Center(child: Text(state.error));
        }

        if (state is ProfileSuccessState) {
          return _HistoryContent(state: state);
        }

        return const Center(child: Text("No Data Yet"));
      },
    );
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent({required this.state});
  final ProfileSuccessState state;

  @override
  Widget build(BuildContext context) {
    final assessments = state.assessments;
    final hasAssessment = assessments.isNotEmpty;
    // final probability = hasAssessment
    //     ? "${(assessment.probability * 100).toStringAsFixed(2)}%"
    //     : "";

    // final predictionResult = assessment?.predictionResult ?? "";
    // final riskLevel = assessment?.riskLevel ?? "";
    // final createdAt = assessment?.createdAt ?? "";
    return Scaffold(
      appBar: mainAppBar("History", context),
      body: Center(
        child: Column(
          children: [
            StartAssessmentCard(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AssessmentFlow(),
                  ),
                );

                /// 👇 هنا ممكن تعمل refresh للـ history
                // context.read<HistoryCubit>().getHistory();
                // final result = await Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => const AssessmentFlow()),
                // );

                // if (result == true) {
                //   context.read<HistoryCubit>().getHistory();
                // }
              },
            ),
            if (hasAssessment) ...[
              HistoryHeader(),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: state.assessments.map((item) {
                      return HistoryCard(
                        predictionResult: item.predictionResult,
                        riskLevel: item.riskLevel,
                        probability: item.probability,
                        createdAt: item.createdAt,
                        assessment: item,
                        onpressed: () {
                          // لما بتعمل push للـ ResultScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context
                                    .read<MainBloc>(), // ← مرر الـ bloc الموجود
                                child: ResultScreen(
                                  score: double.parse(
                                      item.probability),
                                  // riskLevel: item.riskLevel,
                                  createdAt: item.createdAt,
                                  assessment: item,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ] else ...[
              const SizedBox(height: 20),
              _EmptyHistoryCard(),
            ]
          ],
        ),
      ),
    );
  }
}



class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA), // خلفية فاتحة
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E6ED),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 📈 الايقونة
          Icon(
            Icons.trending_up_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 16),

          /// 📝 العنوان
           Text(
            "No Assessment History".tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C2A3A),
            ),
          ),

          const SizedBox(height: 8),

          /// 📄 الوصف
           Text(
            "Start your first assessment".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}