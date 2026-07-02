// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:heart_disease/core/utils/error_message_handler.dart';
// import 'package:heart_disease/features/main_pages/data/models/assessment_ui_model.dart';
// import 'package:heart_disease/features/main_pages/data/repository/main_repo.dart';
// import 'main_event.dart';
// import 'main_state.dart';

// class MainBloc extends Bloc<MainEvent, MainState> {
//   int currentIndex = 0;
//   final MainRepo mainRepo;

//   // ✅ Cache fields
//   ProfileSuccessState? _cachedState;
//   DateTime? _lastFetchTime;
//   static const _cacheDuration = Duration(minutes: 5);

//   MainBloc(this.mainRepo) : super(MainInitialState()) {
//     on<MainTabChangedEvent>(_onTabChanged);
//     on<GetProfileEvent>(_getProfile);
//     on<RefreshIfChangedEvent>(_refreshIfChanged); // ✅ جديد
//   }

//   void _onTabChanged(
//     MainTabChangedEvent event,
//     Emitter<MainState> emit,
//   ) {
//     currentIndex = event.index;
//     emit(MainIndexChangedState(currentIndex));

//     // ✅ لو في cache، استخدمه فوراً وبعدين اتشيك على تغييرات في الخلفية
//     if (_cachedState != null) {
//       emit(_cachedState!);
//       add(RefreshIfChangedEvent());
//     } else {
//       add(GetProfileEvent());
//     }
//   }

//   Future<void> _getProfile(
//     GetProfileEvent event,
//     Emitter<MainState> emit,
//   ) async {
//     // ✅ لو في cache حديث (أقل من 5 دقايق)، استخدمه
//     if (_isCacheValid()) {
//       emit(_cachedState!);
//       return;
//     }

//     emit(ProfileLoadingState());
//     await _fetchAndCache(emit);
//   }

//   // ✅ بيجيب عدد الـ assessments بس ويقارن من غير ما يعمل full reload
//   Future<void> _refreshIfChanged(
//     RefreshIfChangedEvent event,
//     Emitter<MainState> emit,
//   ) async {
//     if (_cachedState == null) {
//       add(GetProfileEvent());
//       return;
//     }

//     try {
//       final profileData = await mainRepo.getFullProfile();
//       final cachedCount = _cachedState!.assessments.length;
//       final newCount = profileData.allAssessments.length;

//       final hasNewData = newCount != cachedCount ||
//           (profileData.allAssessments.isNotEmpty &&
//               _cachedState!.assessments.isNotEmpty &&
//               profileData.allAssessments.first.createdAt !=
//                   _cachedState!.assessments.first.createdAt);

//       if (hasNewData) {
//         // ✅ في داتا جديدة → حمّل كل حاجة من أول
//         await _fetchAndCache(emit);
//       }
//       // لو مفيش تغيير → مش بتعمل emit جديد (الـ UI مش هيتحرك)
//     } catch (_) {
//       // Silently fail — الـ cache القديم لسه شغال
//     }
//   }

//   // ✅ Helper: هل الـ cache لسه صالح؟
//   bool _isCacheValid() {
//     if (_cachedState == null || _lastFetchTime == null) return false;
//     return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
//   }

//   // ✅ Helper: جيب الداتا وخزنها في الـ cache
//   Future<void> _fetchAndCache(Emitter<MainState> emit) async {
//     try {
//       // ✅ call واحد بس
//       final profileData = await mainRepo.getFullProfile();

//       final assessmentsUI =
//           profileData.allAssessments.map((e) => mapAssessment(e)).toList();

//       final newState = ProfileSuccessState(
//         patient: profileData.patient,
//         assessment: profileData.latestAssessment,
//         assessments: assessmentsUI,
//       );

//       _cachedState = newState;
//       _lastFetchTime = DateTime.now();
//       emit(newState);
//     } catch (e) {
//       emit(ProfileErrorState(ErrorMessageHandler.getMessage(e)));
//     }
//   }

//   // ✅ لما المستخدم يعمل assessment جديد، استدعي دي عشان تمسح الـ cache
//   void invalidateCache() {
//     _cachedState = null;
//     _lastFetchTime = null;
//   }
// }

// AssessmentUIModel mapAssessment(assessment) {
//   String riskTitle = "";
//   String riskHint = "";
//   String riskMessage = "";
//   Color riskColor = Colors.grey;
//   // Color dpColor = Colors.grey;
//   // Color sugerColor = Colors.grey;
//   // Color cholesterolColor = Colors.grey;
//   Color riskBadgeColor = Colors.grey.withOpacity(.15);
//   // Color dpBgColor = Colors.grey.withOpacity(.15);
//   // Color sugerBgColor = Colors.grey.withOpacity(.15);
//   // Color cholesterolBgColor = Colors.grey.withOpacity(.15);

//   switch (assessment.riskLevel.toLowerCase()) {
//     case "low":
//       riskTitle = "LowRiskTitle".tr();
//       riskHint = "LowRiskHint".tr();
//       riskMessage = "LowRiskMessage".tr();
//       riskColor = Colors.green;
//       riskBadgeColor = Colors.green.withOpacity(.15);
//       break;

//     case "medium":
//       riskTitle = "MediumRiskTitle".tr();
//       riskHint = "MediumRiskHint".tr();
//       riskMessage = "MediumRiskMessage".tr();
//       riskColor = Colors.orange;
//       riskBadgeColor = Colors.orange.withOpacity(.15);
//       break;

//     case "high":
//       riskTitle = "HighRiskTitle".tr();
//       riskHint = "HighRiskHint".tr();
//       riskMessage = "HighRiskMessage".tr();
//       riskColor = Colors.red;
//       riskBadgeColor = Colors.red.withOpacity(.15);
//       break;
//   }
//   // switch (assessment.dpLevel.toLowerCase()) {
//   //   case "normal":
//   //     dpColor = Colors.green;
//   //     dpBgColor = Colors.green.withOpacity(.15);
//   //     break;

//   //   case "elevated":
//   //     dpColor = Colors.orange;
//   //     dpBgColor = Colors.orange.withOpacity(.15);
//   //     break;

//   //   case "high":
//   //     dpColor = Colors.red;
//   //     dpBgColor = Colors.red.withOpacity(.15);
//   //     break;
//   // }
//   // switch (assessment.sugerLevel.toLowerCase()) {
//   //   case "normal":
//   //     sugerColor = Colors.green;
//   //     sugerBgColor = Colors.green.withOpacity(.15);
//   //     break;

//   //   case "elevated":
//   //     sugerColor = Colors.orange;
//   //     sugerBgColor = Colors.orange.withOpacity(.15);
//   //     break;

//   //   case "high":
//   //     sugerColor = Colors.red;
//   //     sugerBgColor = Colors.red.withOpacity(.15);
//   //     break;
//   // }
//   // switch (assessment.cholesterolLevel.toLowerCase()) {
//   //   case "normal":
//   //     cholesterolColor = Colors.green;
//   //     cholesterolBgColor = Colors.green.withOpacity(.15);
//   //     break;

//   //   case "elevated":
//   //     cholesterolColor = Colors.orange;
//   //     cholesterolBgColor = Colors.orange.withOpacity(.15);
//   //     break;

//   //   case "high":
//   //     cholesterolColor = Colors.red;
//   //     cholesterolBgColor = Colors.red.withOpacity(.15);
//   //     break;
//   // }

//   return AssessmentUIModel(
//     predictionResult: assessment.predictionResult,
//     riskLevel: assessment.riskLevel,
//     sugerLevel: assessment.sugerLevel,
//     cholesterolLevel: assessment.cholesterolLevel,
//     dPLevel: assessment.dPLevel,
//     probability: "${(assessment.probability * 100).toStringAsFixed(2)}",
//     createdAt: assessment.createdAt,
//     riskTitle: riskTitle,
//     riskHint: riskHint,
//     riskMessage: riskMessage,
//     riskColor: riskColor,
//     // dpColor: dpColor,
//     // dpBgColor: dpBgColor,
//     // sugerColor: sugerColor,
//     // sugerBgColor: sugerBgColor,
//     // cholesterolColor: cholesterolColor,
//     // cholesterolBgColor: cholesterolBgColor,
//     riskBadgeColor: riskBadgeColor,
//     bmi: assessment.bmi,
//     systolicBP: assessment.systolicBP,
//     diastolicBP: assessment.diastolicBP,
//     bloodSugar: assessment.bloodSugar,
//     cholesterol: assessment.cholesterol,
//     aiAnalysis: assessment.aiAnalysis != null
//         ? AiAnalysisUI(
//             summary: assessment.aiAnalysis!.summary,
//             riskFactors: assessment.aiAnalysis!.riskFactors,
//             positiveFactors: assessment.aiAnalysis!.positiveFactors,
//             recommendations: assessment.aiAnalysis!.recommendations,
//             lifestyleTips: assessment.aiAnalysis!.lifestyleTips,
//             warningSigns: assessment.aiAnalysis!.warningSigns,
//             followUp: assessment.aiAnalysis!.followUp,
//           )
//         : null,
//   );
// }


import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/core/path_strings.dart';
import 'package:heart_disease/core/utils/error_message_handler.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_model.dart';
import 'package:heart_disease/features/main_pages/data/models/assessment_ui_model.dart';
import 'package:heart_disease/features/main_pages/data/models/patient_model.dart';
import 'package:heart_disease/features/main_pages/data/repository/main_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_event.dart';
import 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  int currentIndex = 0;
  final MainRepo mainRepo;

  // ✅ In-memory cache (fast, cleared on app close)
  ProfileSuccessState? _cachedState;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  // ✅ Persistent cache keys (SharedPreferences)
  static const _persistedProfileKey = 'cached_profile_data';
  static const _persistedTimeKey = 'cached_profile_time';

  MainBloc(this.mainRepo) : super(MainInitialState()) {
    on<MainTabChangedEvent>(_onTabChanged);
    on<GetProfileEvent>(_getProfile);
    on<RefreshIfChangedEvent>(_refreshIfChanged);
  }

  void _onTabChanged(
    MainTabChangedEvent event,
    Emitter<MainState> emit,
  ) {
    currentIndex = event.index;
    emit(MainIndexChangedState(currentIndex));

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
    // 1) In-memory cache still fresh? use it directly
    if (_isCacheValid()) {
      emit(_cachedState!);
      return;
    }

    // 2) No fresh in-memory cache -> try persisted cache first (instant UI, offline-friendly)
    final persisted = await _loadPersistedProfile();
    if (persisted != null) {
      _cachedState = persisted;
      emit(persisted);
      // refresh quietly in the background
      add(RefreshIfChangedEvent());
      return;
    }

    // 3) Nothing cached anywhere -> normal loading flow
    emit(ProfileLoadingState());
    await _fetchAndCache(emit);
  }

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
        await _fetchAndCache(emit);
      }
    } catch (e) {
      // Silently fail — the old cache (in-memory or persisted) is still shown
      debugPrint('Background refresh failed: ${ErrorMessageHandler.getMessage(e)}');
    }
  }

  bool _isCacheValid() {
    if (_cachedState == null || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  Future<void> _fetchAndCache(Emitter<MainState> emit) async {
    try {
      final profileData = await mainRepo.getFullProfile();

      final assessmentsUI =
          profileData.allAssessments.map((e) => mapAssessment(e)).toList();

      final newState = ProfileSuccessState(
        patient: profileData.patient,
        assessment: profileData.latestAssessment,
        assessments: assessmentsUI,
      );

      _cachedState = newState;
      _lastFetchTime = DateTime.now();
      emit(newState);

      // ✅ persist to disk so it survives app restarts
      await _persistProfile(profileData);
    } catch (e) {
      // If the network call fails and we have NO cache at all, show the error.
      // If we already emitted a cached/persisted state earlier, don't overwrite it with an error.
      if (_cachedState == null) {
        emit(ProfileErrorState(ErrorMessageHandler.getMessage(e)));
      } else {
        debugPrint('Fetch failed, keeping cached state: ${ErrorMessageHandler.getMessage(e)}');
      }
    }
  }

  // ---------- Persistence helpers ----------

  Future<void> _persistProfile(ProfileData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final map = {
        'patient': data.patient.toJson(),
        'latestAssessment': data.latestAssessment?.toJson(),
        'allAssessments': data.allAssessments.map((a) => a.toJson()).toList(),
      };

      await prefs.setString(_persistedProfileKey, jsonEncode(map));
      await prefs.setString(_persistedTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      // Persistence failing shouldn't break the app, just log it
      debugPrint('Failed to persist profile cache: $e');
    }
  }

  Future<ProfileSuccessState?> _loadPersistedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_persistedProfileKey);
      if (raw == null) return null;

      final map = jsonDecode(raw) as Map<String, dynamic>;

      final patient = PatientModel.fromJson(map['patient']);

      final latestRaw = map['latestAssessment'];
      final latestAssessment =
          latestRaw != null ? AssessmentModel.fromJson(latestRaw) : null;

      final allRaw = map['allAssessments'] as List? ?? [];
      final allAssessments =
          allRaw.map((item) => AssessmentModel.fromJson(item)).toList();

      final assessmentsUI = allAssessments.map((e) => mapAssessment(e)).toList();

      return ProfileSuccessState(
        patient: patient,
        assessment: latestAssessment,
        assessments: assessmentsUI,
      );
    } catch (e) {
      debugPrint('Failed to load persisted profile cache: $e');
      return null;
    }
  }

  // ✅ Call this on logout, or after account deletion
  Future<void> clearPersistedCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_persistedProfileKey);
    await prefs.remove(_persistedTimeKey);
  }

  // ✅ Call this when the user creates a new assessment
  void invalidateCache() {
    _cachedState = null;
    _lastFetchTime = null;
  }
}

AssessmentUIModel mapAssessment(assessment) {
  String riskTitle = "";
  String riskHint = "";
  String riskMessage = "";
  String riskIconPath = "";
  Color riskColor = Colors.grey;
  Color riskBadgeColor = Colors.grey.withOpacity(.15);

  switch (assessment.riskLevel.toLowerCase()) {
    case "low":
      riskTitle = "LowRiskTitle".tr();
      riskHint = "LowRiskHint".tr();
      riskMessage = "LowRiskMessage".tr();
      riskColor = Colors.green;
      riskBadgeColor = Colors.green.withOpacity(.15);
      riskIconPath = PathStrings.stableRiskIconPath;
      break;

    case "medium":
      riskTitle = "MediumRiskTitle".tr();
      riskHint = "MediumRiskHint".tr();
      riskMessage = "MediumRiskMessage".tr();
      riskColor = Color(0xFFD08700); // Orange color
      riskBadgeColor = Color(0xFFFEFCE8);
      riskIconPath = PathStrings.stableRiskIconPath;
      break;

    case "high":
      riskTitle = "HighRiskTitle".tr();
      riskHint = "HighRiskHint".tr();
      riskMessage = "HighRiskMessage".tr();
      riskColor = Colors.red;
      riskBadgeColor = Colors.red.withOpacity(.15);
      riskIconPath = PathStrings.highRiskIconPath;

      break;
  }

  return AssessmentUIModel(
    predictionResult: assessment.predictionResult,
    riskLevel: assessment.riskLevel,
    sugerLevel: assessment.sugerLevel,
    cholesterolLevel: assessment.cholesterolLevel,
    dPLevel: assessment.dPLevel,
    probability: "${(assessment.probability * 100).toStringAsFixed(2)}",
    createdAt: assessment.createdAt,
    riskTitle: riskTitle,
    riskHint: riskHint,
    riskMessage: riskMessage,
    riskIconPath: riskIconPath,
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