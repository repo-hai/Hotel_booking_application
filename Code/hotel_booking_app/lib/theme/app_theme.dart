import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primary = Color(0xFF1565C0);
  static const Color white = Colors.white;
  static const Color background = Color(0xFFF5F6FA);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color danger = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA726);
  static const Color purple = Color(0xFF7C4DFF);

  static const Color statBlue = Color(0xFFE3F2FD);
  static const Color statGreen = Color(0xFFE8F5E9);
  static const Color statOrange = Color(0xFFFFF3E0);
  static const Color statPurple = Color(0xFFF3E5F5);

  static const Color statIconBlue = Color(0xFF1E88E5);
  static const Color statIconGreen = Color(0xFF43A047);
  static const Color statIconOrange = Color(0xFFFB8C00);
  static const Color statIconPurple = Color(0xFF7C4DFF);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: false,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
        ),
      );
}
