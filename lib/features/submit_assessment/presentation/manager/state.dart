abstract class AssessmentState {}

class AssessmentInitial extends AssessmentState {}

class AssessmentLoading extends AssessmentState {}

class AssessmentSuccess extends AssessmentState {}

class AssessmentError extends AssessmentState {
  final String message;
  AssessmentError(this.message);
}

class AssessmentStepChanged extends AssessmentState {
  final int step;
  AssessmentStepChanged(this.step);
}