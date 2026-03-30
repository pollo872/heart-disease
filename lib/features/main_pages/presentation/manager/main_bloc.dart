import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_ui_model.dart';
import 'package:heart_disease/features/main_pages/data/repository/main_repo.dart';
import 'main_event.dart';
import 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  int currentIndex = 0;

  final MainRepo mainRepo;

  MainBloc(this.mainRepo) : super(MainInitialState()) {
    on<MainTabChangedEvent>(_onTabChanged);
    on<GetProfileEvent>(_getProfile);
  }

  void _onTabChanged(
    MainTabChangedEvent event,
    Emitter<MainState> emit,
  ) {
    currentIndex = event.index;
    if (currentIndex == 0) {
      add(GetProfileEvent());
    }
    emit(MainIndexChangedState(currentIndex));
  }

  Future<void> _getProfile(
    GetProfileEvent event,
    Emitter<MainState> emit,
  ) async {
    emit(ProfileLoadingState());

    try {
      final patient = await mainRepo.getProfile();
      // final latestAssessment = await mainRepo.getLatestHealthData();
      final allAssessment = await mainRepo.getAllHealthData();

      final assessmentsUI =
          allAssessment.map((e) => _mapAssessment(e)).toList();

      // String riskTitle = "";
      // String riskHint = "";
      // String riskMessage = "";
      // Color riskColor = Colors.grey;
      // Color riskBadgeColor = Colors.grey.withOpacity(.15);

      // if (allAssessment != null) {
      //   switch (allAssessment.first.riskLevel.toLowerCase()) {
      //     case "low":
      //       riskTitle = "LowRiskTitle".tr();
      //       riskHint = "LowRiskHint".tr();
      //       riskMessage =
      //           "LowRiskMessage".tr();
      //       riskColor = Colors.green;
      //       riskBadgeColor = Colors.green.withOpacity(.15);
      //       break;

      //     case "medium":
      //       riskTitle = "MediumRiskTitle".tr();
      //       riskHint = "MediumRiskHint".tr();
      //       riskMessage =
      //           "MediumRiskMessage".tr();
      //       riskColor = Colors.orange;
      //       riskBadgeColor = Colors.orange.withOpacity(.15);
      //       break;

      //     case "high":
      //       riskTitle = "HighRiskTitle".tr();
      //       riskHint = "HighRiskHint".tr();
      //       riskMessage =
      //           "HighRiskMessage".tr();
      //       riskColor = Colors.red;
      //       riskBadgeColor = Colors.red.withOpacity(.15);
      //       break;
      //   }
      // }

      emit(ProfileSuccessState(
        patient: patient,
        assessment: allAssessment.first,
        assessments: assessmentsUI,
        // riskTitle: riskTitle,
        // riskHint: riskHint,
        // riskMessage: riskMessage,
        // riskColor: riskColor,
        // riskBadgeColor: riskBadgeColor,
      ));
    } catch (e) {
      emit(ProfileErrorState(e.toString()));
    }
  }

  AssessmentUIModel _mapAssessment(assessment) {
    String riskTitle = "";
    String riskHint = "";
    String riskMessage = "";
    Color riskColor = Colors.grey;
    Color riskBadgeColor = Colors.grey.withOpacity(.15);

    switch (assessment.riskLevel.toLowerCase()) {
      case "low":
        riskTitle = "LowRiskTitle".tr();
        riskHint = "LowRiskHint".tr();
        riskMessage = "LowRiskMessage".tr();
        riskColor = Colors.green;
        riskBadgeColor = Colors.green.withOpacity(.15);
        break;

      case "medium":
        riskTitle = "MediumRiskTitle".tr();
        riskHint = "MediumRiskHint".tr();
        riskMessage = "MediumRiskMessage".tr();
        riskColor = Colors.orange;
        riskBadgeColor = Colors.orange.withOpacity(.15);
        break;

      case "high":
        riskTitle = "HighRiskTitle".tr();
        riskHint = "HighRiskHint".tr();
        riskMessage = "HighRiskMessage".tr();
        riskColor = Colors.red;
        riskBadgeColor = Colors.red.withOpacity(.15);
        break;
    }

    return AssessmentUIModel(
      predictionResult: assessment.predictionResult,
      riskLevel: assessment.riskLevel,
      probability: "${(assessment.probability * 100).toStringAsFixed(2)}%",
      createdAt: assessment.createdAt,
      riskTitle: riskTitle,
      riskHint: riskHint,
      riskMessage: riskMessage,
      riskColor: riskColor,
      riskBadgeColor: riskBadgeColor,
    );
  }
}
