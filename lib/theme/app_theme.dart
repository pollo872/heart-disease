import 'package:flutter/material.dart';

// ============================================================
//  HeartGuard App Theme
//  مستخرج من الـ Figma design بتاعك
// ============================================================

class AppColors {
  AppColors._();

  // --- Primary ---
  static const Color primary        = Color(0xFF2563EB);
  static const Color primaryDark    = Color(0xFF1D4ED8);
  static const Color primaryLight   = Color(0xFFEFF6FF);

  // --- Background & Surface ---
  static const Color background     = Color(0xFFFFFFFF);
  static const Color surface        = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // --- Text ---
  static const Color textPrimary    = Color(0xFF1E293B);
  static const Color textSecondary  = Color(0xFF64748B);
  static const Color textHint       = Color(0xFF94A3B8);

  // --- Border ---
  static const Color border         = Color(0xFFCBD5E1);
  static const Color borderLight    = Color(0xFFE2E8F0);

  // --- Risk: Low ---
  static const Color riskLow        = Color(0xFF22C55E);
  static const Color riskLowBg      = Color(0xFFEAF3DE);
  static const Color riskLowText    = Color(0xFF3B6D11);

  // --- Risk: Medium ---
  static const Color riskMedium     = Color(0xFFF59E0B);
  static const Color riskMediumBg   = Color(0xFFFAEEDA);
  static const Color riskMediumText = Color(0xFF854F0B);

  // --- Risk: High ---
  static const Color riskHigh       = Color(0xFFEF4444);
  static const Color riskHighBg     = Color(0xFFFCEBEB);
  static const Color riskHighText   = Color(0xFFA32D2D);

  // --- Icon accent colors (Quick Actions) ---
  static const Color iconBlue       = Color(0xFFEFF6FF);
  static const Color iconGreen      = Color(0xFFEAF3DE);
  static const Color iconPurple     = Color(0xFFEEEDFE);
}

// ============================================================

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Inter'; // أو بدّله بـ اسم الخط اللي حاطّه

  // Page title — 22px / w500
  static const TextStyle pageTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Section heading — 18px / w500
  static const TextStyle heading = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Card title — 15px / w500
  static const TextStyle cardTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Body — 14px / w400
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // Body secondary — 14px مع لون ثانوي
  static const TextStyle bodySecondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Caption / hint — 12px / w400
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Big score number — 32px / w500
  static const TextStyle scoreNumber = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  // Button label — 15px / w500
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}

// ============================================================

class AppRadius {
  AppRadius._();

  static const double sm  = 8;   // inputs, small elements
  static const double md  = 12;  // buttons
  static const double lg  = 16;  // cards
  static const double pill = 50; // badges / chips

  static const BorderRadius radiusSm   = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd   = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg   = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusPill = BorderRadius.all(Radius.circular(pill));
}

// ============================================================

class AppSpacing {
  AppSpacing._();

  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 20;
  static const double xxl = 24;
}

// ============================================================

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primaryLight,
      onSecondary: AppColors.primary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.riskHigh,
      onError: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.heading,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMd,
        ),
        textStyle: AppTextStyles.button,
        elevation: 0,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        minimumSize: const Size(double.infinity, 50),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMd,
        ),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        elevation: 0,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: AppRadius.radiusSm,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusSm,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusSm,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),

    cardTheme: CardTheme(
      color: AppColors.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLg,
        side: const BorderSide(color: AppColors.borderLight),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 1,
      space: 0,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );
}

// ============================================================
//  Risk Badge Widget — جاهز للاستخدام مباشرة
// ============================================================

enum RiskLevel { low, medium, high }

class RiskBadge extends StatelessWidget {
  final RiskLevel level;

  const RiskBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (level) {
      RiskLevel.low    => ('Low Risk',    AppColors.riskLowBg,    AppColors.riskLowText),
      RiskLevel.medium => ('Medium Risk', AppColors.riskMediumBg, AppColors.riskMediumText),
      RiskLevel.high   => ('High Risk',   AppColors.riskHighBg,   AppColors.riskHighText),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.radiusPill,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}
