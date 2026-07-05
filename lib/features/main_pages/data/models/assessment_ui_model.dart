// import 'package:flutter/material.dart';

// class AssessmentUIModel {
//   final String predictionResult;
//   final String riskLevel;
//   final String probability;
//   final String createdAt;

//   final String riskTitle;
//   final String riskHint;
//   final String riskMessage;
//   final Color riskColor;
//   final Color riskBadgeColor;
//   final double bmi; // من الـ response: "BMI": 64.07

//   AssessmentUIModel({
//     required this.predictionResult,
//     required this.riskLevel,
//     required this.probability,
//     required this.createdAt,
//     required this.riskTitle,
//     required this.riskHint,
//     required this.riskMessage,
//     required this.riskColor,
//     required this.riskBadgeColor,
//     required this.bmi,
//   });
// }

// ─── أضيف الـ field ده جوا class AssessmentUIModel ───────────────────────────
// في ملف: lib/features/main_pages/data/models/assessment_ui_model.dart
//
// زود الـ field ده:
//   final AiAnalysisUI? aiAnalysis;
//
// وزوده في الـ constructor:
//   this.aiAnalysis,
//
// مثال بعد التعديل:
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
// import the AiAnalysisUI from result_screen or move it to a shared file
// For simplicity, copy AiAnalysisUI class here instead:

class AiAnalysisUI {
  final String summary;
  final List<String> riskFactors;
  final List<String> positiveFactors;
  final List<String> recommendations;
  final List<String> lifestyleTips;
  final List<String> warningSigns;
  final String followUp;

  AiAnalysisUI({
    required this.summary,
    required this.riskFactors,
    required this.positiveFactors,
    required this.recommendations,
    required this.lifestyleTips,
    required this.warningSigns,
    required this.followUp,
  });
}

class AssessmentUIModel {
  final String predictionResult;
  final String riskLevel;
  final String? sugerLevel;
  final String? cholesterolLevel;
  final String? bPLevel;
  final String probability;
  final String createdAt;
  final String riskTitle;
  final String riskHint;
  final String riskMessage;
  final String riskIconPath;
  final Color riskColor;
  // final Color dpColor;
  // final Color dpBgColor;
  // final Color sugerColor;
  // final Color sugerBgColor;
  // final Color cholesterolColor;
  // final Color cholesterolBgColor;
  final Color riskBadgeColor;
  final double bmi; 
  final int systolicBP;
  final int diastolicBP;
  final double bloodSugar; 
  final double hba1c;
  final double cholesterol; 
  final AiAnalysisUI? aiAnalysis; // ← الجديد

  AssessmentUIModel({
    required this.predictionResult,
    required this.riskLevel,
    this.sugerLevel,
    this.cholesterolLevel,
    this.bPLevel,
    required this.probability,
    required this.createdAt,
    required this.riskTitle,
    required this.riskHint,
    required this.riskMessage,
    required this.riskColor,
    required this.riskIconPath,
    // required this.dpColor,
    // required this.dpBgColor,
    // required this.sugerColor,
    // required this.sugerBgColor,
    // required this.cholesterolColor,
    // required this.cholesterolBgColor,
    required this.riskBadgeColor,
    required this.bmi,
    required this.systolicBP,
    required this.diastolicBP,
    required this.bloodSugar,
    required this.hba1c,
    required this.cholesterol,
    this.aiAnalysis, // ← الجديد
  });
}