// import 'package:flutter/material.dart';
// import 'package:heart_disease/res/app_colors.dart';
// import 'package:heart_disease/res/text_style.dart';

// final ColorScheme colorTheme =
//       AppTheme().themeDataLight.colorScheme;
//   final TextTheme textStyleTheme =
//       AppTheme().themeDataLight.textTheme;
// class AppTheme {
//   // late TextTheme arabicTextTheme;

//   // AppTheme(this.locale) {
//   //   arabicTextTheme = const TextTheme(
//   //     headlineMedium: TextStyle(color: AppColors.headlineMedium, fontSize: 22),
//   //     bodyMedium: TextStyle(color: AppColors.bodyMedium, fontSize: 16),
//   //     titleMedium: TextStyle(color: AppColors.titleMedium),
//   //     // for subtitle
//   //     labelLarge: TextStyle(color: AppColors.labelLarge, fontSize: 14),
//   //     labelMedium: TextStyle(fontSize: 14, color: AppColors.labelMedium),
//   //   );
//   // }

//   // final Locale locale;

//   /// The Light Theme
//   ThemeData get themeDataLight {
//     return ThemeData(
//       // useMaterial3: true,
//       colorScheme: ColorScheme(
//         brightness: Brightness.light,
//         background: AppColors.backGround,

//         primary: AppColors.primary,
//         onPrimary: AppColors.onPrimary,
//         primaryContainer: AppColors.primaryContainer,
//         primaryFixed: AppColors.primaryFixed,

//         secondary: AppColors.secondary,
//         secondaryContainer: AppColors.secondaryContainer,
//         onSecondary: AppColors.onSecondary,

//         error: AppColors.error,
//         onError: AppColors.onError,

//         surface: AppColors.surface,
//         onSurface: AppColors.onSurface,
//         inverseSurface: AppColors.inverseSurface,
//         surfaceDim: AppColors.surfaceDim,
//         surfaceBright: AppColors.surfaceBright,
//         surfaceContainer: AppColors.surfaceContainer,
        
//         tertiary: AppColors.tertiary,

//         // background: AppColors.black0,
//         // onBackground: AppColors.black100,
//       ),

//       appBarTheme: ThemeData.light().appBarTheme.copyWith(
//             centerTitle: false,
//             elevation: 0,
//             iconTheme: ThemeData.light().iconTheme.copyWith(
//                   color: AppColors.appBarIconColor,
//                 ),
//             titleTextStyle: AppTextStyles.headline4.copyWith(
//               color: AppColors.appBarTextColor,
//             ),
//             backgroundColor: AppColors.appBarBackground,
//           ),

//       textTheme: TextTheme(
//         headlineLarge: AppTextStyles.headline1,
//         headlineMedium: AppTextStyles.headline2,
//         headlineSmall: AppTextStyles.headline3,
//         bodyLarge: AppTextStyles.body1,
//         bodyMedium: AppTextStyles.body3,
//         bodySmall: AppTextStyles.body5,
//       ),
//     );
//   }

//   ThemeData get themeDataDark {
//     return ThemeData(brightness: Brightness.dark);
//   }

//   // TextTheme get _textTheme {
//   //   switch (locale.languageCode) {
//   //     case codeEn:
//   //       return ThemeData.light().textTheme;
//   //     case codeAr:
//   //       return arabicTextTheme;
//   //     default:
//   //       return ThemeData.light().textTheme;
//   //   }
//   // }
// }
