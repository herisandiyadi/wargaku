import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        fontFamily: 'PlusJakartaSans',
        scaffoldBackgroundColor: AppColors.lightBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brandBlue,
          primary: AppColors.brandBlue,
          error: AppColors.emergencyRed,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.dark,
          elevation: 0,
        ),
      );
}
