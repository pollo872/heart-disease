import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/submit_assessment/data/models/assessment_model.dart';

import 'package:heart_disease/features/submit_assessment/data/repositories/assessment_repo.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/state.dart';

class AssessmentCubit extends Cubit<AssessmentState> {
  final AssessmentRepository repo;

  AssessmentCubit(this.repo) : super(AssessmentInitial());

  int step = 0;

  final model = SubmitAssessmentModel();

  /// 🔄 NAVIGATION
  void nextStep() {
    step++;
    emit(AssessmentStepChanged(step));
  }

  void prevStep() {
    if (step > 0) {
      step--;
      emit(AssessmentStepChanged(step));
    }
  }

  /// 📊 DEMOGRAPHICS
  void updateDemographics({
    required String age,
    required String gender,
    required String race,
    required int height,
    required int weight,
    required double bmi,
  }) {
    model.age = age;
    model.sex = gender;
    model.race = race;
    model.height = height;
    model.weight = weight;
    model.bmi = bmi;
  }

  /// 🧬 LIFESTYLE
  void updateLifestyle({
    required String smoking,
    required String alcohol,
    required String physicalActivity,
    required String difficultyWalking,
  }) {
    model.smoking = smoking;
    model.alcohol = alcohol;
    model.physicalActivity = physicalActivity;
    model.difficultyWalking = difficultyWalking;
  }
  void medicalHistory({
    required String diabetic,
    required String generalHealth ,
    required String asthma,
    required String stroke,
    required String kidneyDisease,
    required String skinCancer,
    required int physicalHealthDays,
    required int mentalHealthDays ,
    required int sleepTime ,

  }) {
    model.diabetic = diabetic;
    model.generalHealth = generalHealth ;
    model.asthma = asthma;
    model.stroke = stroke;
    model.kidneyDisease = kidneyDisease;
    model.skinCancer = skinCancer;
    model.physicalHealthDays = physicalHealthDays;
    model.mentalHealthDays  = mentalHealthDays ;
    model.sleepTime  = sleepTime ;
  }

  /// 🫀 MEDICAL
  // void updateMedical(List<String> list) {
  //   model.medicalHistory = list;
  // }

  /// 🚀 SUBMIT
  Future<void> submit() async {
    emit(AssessmentLoading());

    final result = await repo.submit(model.toJson());
    if (isClosed) return;

    result.fold(
      (failure) => emit(AssessmentError(failure.message)),
      (_) => emit(AssessmentSuccess()),
    );
  }
}