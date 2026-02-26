// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:heart_disease/res/app_colors.dart';



class AppGradiant {
  static final gradiant1 = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFEFF6FF), Color(0xFFFFFFFF)]);
  static final gradiant2 = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.primary, Color(0xFF1447E6)]);
  static final articleGredient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFDBEAFE), Color(0xFFCBFBF1)]);
  static final doctorAvatarContainr = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2B7FFF), Color(0xFF00BBA7)]);
}
