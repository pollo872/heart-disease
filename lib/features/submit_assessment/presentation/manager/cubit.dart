import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/core/utils/error_message_handler.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_ui_model.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/submit_assessment/data/models/assessment_model1.dart';
import 'package:heart_disease/features/submit_assessment/data/repositories/assessment_repo.dart';
import 'package:heart_disease/features/submit_assessment/presentation/manager/state.dart';

class AssessmentCubit extends Cubit<AssessmentState> {
  final AssessmentRepository repo;

  AssessmentCubit(this.repo) : super(AssessmentInitial());

  int step = 0;

  final model = SubmitAssessmentModel();

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
    required int sleepTime ,
    required int coffeeIntake ,

  }) {
    model.smoking = smoking;
    model.alcohol = alcohol;
    model.physicalActivity = physicalActivity;
    model.difficultyWalking = difficultyWalking;
    model.sleepTime  = sleepTime ;
    model.caffeineIntake = coffeeIntake ;

  }

  void healthMeasurements({
    required int systolicBP,
    required int diastolicBP,
    required double bloodSugar,
    required double hba1c,
    required double cholesterol,
  }) {
    model.systolicBP = systolicBP;
    model.diastolicBP = diastolicBP;
    model.bloodSugar = bloodSugar;
    model.hba1c = hba1c;
    model.cholesterol = cholesterol;
  }


  void medicalHistory({
    required String diabetic,
    // required String generalHealth ,
    required String asthma,
    required String brainStroke,
    required String kidneyDisease,
    required String cancerHistory,
    required String chronicHypertension,
    required String liverDisease,
    required String immunologicalDiseases,
    required String myocardialInfarctionInHeart,
    // required int physicalHealthDays,
    // required int mentalHealthDays ,

  }) {
    model.diabetic = diabetic;
    // model.generalHealth = generalHealth ;
    model.asthma = asthma;
    model.brainstroke = brainStroke;
    model.kidneyDisease = kidneyDisease;
    model.cancerHistory = cancerHistory;
    model.chronicHypertension = chronicHypertension;
    model.liverDisease = liverDisease;
    model.immunologicalDiseases = immunologicalDiseases;
    model.myocardialInfarctionInHeart = myocardialInfarctionInHeart;
    // model.physicalHealthDays = physicalHealthDays;
    // model.mentalHealthDays  = mentalHealthDays ;
  }

  /// 🫀 MEDICAL
  // void updateMedical(List<String> list) {
  //   model.medicalHistory = list;
  // }

  /// 🚀 SUBMIT
  Future<AssessmentUIModel?> submit() async {
  emit(AssessmentLoading());

  final result = await repo.submit(model.toJson());
  if (isClosed) return null;

  // AssessmentUIModel? assessmentUI;

  result.fold(
    (failure) => emit(AssessmentError(ErrorMessageHandler.getMessage(failure))),
    (assessmentModel) {
      final assessmentUI = mapAssessment(assessmentModel); // map الداتا الجاية من السيرفر
      emit(AssessmentSuccess(assessmentUI));
    },
  );


  return null;
}
}
