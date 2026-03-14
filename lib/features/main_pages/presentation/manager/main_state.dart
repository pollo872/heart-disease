import 'package:flutter/material.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_model.dart';
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
  final AssessmentModel? assessment;

  final String riskTitle;
  final String riskHint;
  final String riskMessage;
  final Color riskColor;
  final Color riskBadgeColor;

  ProfileSuccessState({
    required this.patient,
    required this.assessment,
    required this.riskTitle,
    required this.riskHint,
    required this.riskMessage,
    required this.riskColor,
    required this.riskBadgeColor,
  });
}

class ProfileErrorState extends MainState {
  final String error;

  ProfileErrorState(this.error);
}



