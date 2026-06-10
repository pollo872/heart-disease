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

  // ✅ Cache fields
  ProfileSuccessState? _cachedState;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  MainBloc(this.mainRepo) : super(MainInitialState()) {
    on<MainTabChangedEvent>(_onTabChanged);
    on<GetProfileEvent>(_getProfile);
    on<RefreshIfChangedEvent>(_refreshIfChanged); // ✅ جديد
  }

  void _onTabChanged(
    MainTabChangedEvent event,
    Emitter<MainState> emit,
  ) {
    currentIndex = event.index;
    emit(MainIndexChangedState(currentIndex));

    // ✅ لو في cache، استخدمه فوراً وبعدين اتشيك على تغييرات في الخلفية
    if (_cachedState != null) {
      emit(_cachedState!);
      add(RefreshIfChangedEvent());
    } else {
      add(GetProfileEvent());
    }
  }

  Future<void> _getProfile(
    GetProfileEvent event,
    Emitter<MainState> emit,
  ) async {
    // ✅ لو في cache حديث (أقل من 5 دقايق)، استخدمه
    if (_isCacheValid()) {
      emit(_cachedState!);
      return;
    }

    emit(ProfileLoadingState());
    await _fetchAndCache(emit);
  }

  // ✅ بيجيب عدد الـ assessments بس ويقارن من غير ما يعمل full reload
  Future<void> _refreshIfChanged(
    RefreshIfChangedEvent event,
    Emitter<MainState> emit,
  ) async {
    if (_cachedState == null) {
      add(GetProfileEvent());
      return;
    }

    try {
      final profileData = await mainRepo.getFullProfile();
      final cachedCount = _cachedState!.assessments.length;
      final newCount = profileData.allAssessments.length;

      final hasNewData = newCount != cachedCount ||
          (profileData.allAssessments.isNotEmpty &&
              _cachedState!.assessments.isNotEmpty &&
              profileData.allAssessments.first.createdAt !=
                  _cachedState!.assessments.first.createdAt);

      if (hasNewData) {
        // ✅ في داتا جديدة → حمّل كل حاجة من أول
        await _fetchAndCache(emit);
      }
      // لو مفيش تغيير → مش بتعمل emit جديد (الـ UI مش هيتحرك)
    } catch (_) {
      // Silently fail — الـ cache القديم لسه شغال
    }
  }

  // ✅ Helper: هل الـ cache لسه صالح؟
  bool _isCacheValid() {
    if (_cachedState == null || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  // ✅ Helper: جيب الداتا وخزنها في الـ cache
  Future<void> _fetchAndCache(Emitter<MainState> emit) async {
  try {
    // ✅ call واحد بس
    final profileData = await mainRepo.getFullProfile();
    
    final assessmentsUI = profileData.allAssessments
        .map((e) => mapAssessment(e))
        .toList();

    final newState = ProfileSuccessState(
      patient: profileData.patient,
      assessment: profileData.latestAssessment,
      assessments: assessmentsUI,
    );

    _cachedState = newState;
    _lastFetchTime = DateTime.now();
    emit(newState);
  } catch (e) {
    emit(ProfileErrorState(e.toString()));
  }
}
  // ✅ لما المستخدم يعمل assessment جديد، استدعي دي عشان تمسح الـ cache
  void invalidateCache() {
    _cachedState = null;
    _lastFetchTime = null;
  }
}

AssessmentUIModel mapAssessment(assessment) {
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
    probability: "${(assessment.probability * 100).toStringAsFixed(2)}",
    createdAt: assessment.createdAt,
    riskTitle: riskTitle,
    riskHint: riskHint,
    riskMessage: riskMessage,
    riskColor: riskColor,
    riskBadgeColor: riskBadgeColor,
    bmi: assessment.bmi,
    systolicBP: assessment.systolicBP,
    diastolicBP: assessment.diastolicBP,
    bloodSugar: assessment.bloodSugar,
    cholesterol: assessment.cholesterol,
    aiAnalysis: assessment.aiAnalysis != null
        ? AiAnalysisUI(
            summary: assessment.aiAnalysis!.summary,
            riskFactors: assessment.aiAnalysis!.riskFactors,
            positiveFactors: assessment.aiAnalysis!.positiveFactors,
            recommendations: assessment.aiAnalysis!.recommendations,
            lifestyleTips: assessment.aiAnalysis!.lifestyleTips,
            warningSigns: assessment.aiAnalysis!.warningSigns,
            followUp: assessment.aiAnalysis!.followUp,
          )
        : null,
  );
}
