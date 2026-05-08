import 'package:heart_disease/features/main_pages/data/models/assessment_ui_model.dart';

abstract class AssessmentState {}

class AssessmentInitial extends AssessmentState {}

class AssessmentLoading extends AssessmentState {}

class AssessmentSuccess extends AssessmentState {
    final AssessmentUIModel assessment;
  AssessmentSuccess(this.assessment);
}

class AssessmentError extends AssessmentState {
  final String message;
  AssessmentError(this.message);
}

class AssessmentStepChanged extends AssessmentState {
  final int step;
  AssessmentStepChanged(this.step);
}