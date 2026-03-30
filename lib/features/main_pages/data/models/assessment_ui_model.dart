import 'package:flutter/material.dart';

class AssessmentUIModel {
  final String predictionResult;
  final String riskLevel;
  final String probability;
  final String createdAt;

  final String riskTitle;
  final String riskHint;
  final String riskMessage;
  final Color riskColor;
  final Color riskBadgeColor;

  AssessmentUIModel({
    required this.predictionResult,
    required this.riskLevel,
    required this.probability,
    required this.createdAt,
    required this.riskTitle,
    required this.riskHint,
    required this.riskMessage,
    required this.riskColor,
    required this.riskBadgeColor,
  });
}