// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

abstract class AppTheme {
  // ── Palette ────────────────────────────────────────────────────────────────
  static const Color background   = Color(0xFF0F1117);
  static const Color surface      = Color(0xFF1A1D27);
  static const Color surfaceHigh  = Color(0xFF232738);
  static const Color border       = Color(0xFF2A2E3D);

  static const Color primary      = Color(0xFF4F8EF7);  // Blue
  static const Color primaryLight = Color(0xFF7BB3FF);
  static const Color accent       = Color(0xFFE05C7A);  // Rose
  static const Color danger       = Color(0xFFFF6B6B);
  static const Color dangerLight  = Color(0xFFFF9494);
  static const Color success      = Color(0xFF4ECBA1);
  static const Color warning      = Color(0xFFFFB347);

  static const Color textPrimary   = Color(0xFFF0F2FA);
  static const Color textSecondary = Color(0xFF8892A4);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF7B5EF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [danger, Color(0xFFFF9494)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Typography ─────────────────────────────────────────────────────────────
  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'Cairo',          // add to pubspec.yaml
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle labelStyle = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle numericStyle = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -1,
  );

  // ── ThemeData ──────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: accent,
          surface: surface,
          error: danger,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
      );
}
