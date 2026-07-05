import 'package:heart_disease/features/main_pages/data/models/assessment_model.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_ui_model.dart';
import 'package:heart_disease/features/main_pages/data/models/patient_model.dart';

abstract class MainState {}

class MainInitialState extends MainState {
  final int currentIndex;
  MainInitialState({this.currentIndex = 0});
}

class MainIndexChangedState extends MainState {
  final int currentIndex;
  MainIndexChangedState(this.currentIndex);
}

class GetProfileLoadingState extends MainState {}

class GetProfileSuccessState extends MainState {
  final PatientModel patient;
  final AssessmentModel? assessment;
  final List<AssessmentUIModel> assessments;

  // final String riskTitle;
  // final String riskHint;
  // final String riskMessage;
  // final Color riskColor;
  // final Color riskBadgeColor;

  GetProfileSuccessState({
    required this.patient,
    required this.assessment,
    required this.assessments,
    // required this.riskTitle,
    // required this.riskHint,
    // required this.riskMessage,
    // required this.riskColor,
    // required this.riskBadgeColor,
  });
}

class GetProfileErrorState extends MainState {
  final String error;

  GetProfileErrorState(this.error);
}
