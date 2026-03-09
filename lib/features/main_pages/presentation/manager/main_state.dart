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

class ProfileLoadingState extends MainState {}

class ProfileSuccessState extends MainState {
  final PatientModel patient;

  ProfileSuccessState(this.patient);
}

class ProfileErrorState extends MainState {
  final String error;

  ProfileErrorState(this.error);
}
