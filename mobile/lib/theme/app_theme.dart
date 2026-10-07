import 'package:flutter/material.dart';

class AppColors {
  // Brand Reds matching the UI reference
  static const Color primaryRed = Color(0xFFE51E2B);
  static const Color darkRed = Color(0xFFB8141E);
  static const Color glowRed = Color(0xFFFF3344);
  static const Color softRed = Color(0xFFFDE8E9);

  // Dark Theme (Emergency Pulse Screen 1)
  static const Color darkBackground = Color(0xFF090A0C);
  static const Color darkCard = Color(0xFF14161B);
  static const Color darkBorder = Color(0xFF22252E);

  // Light Theme (Dashboard & Detail Screens 2 & 3)
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightCard = Colors.white;
  static const Color lightBorder = Color(0xFFEBECEF);

  // Typography
  static const Color textBlack = Color(0xFF111116);
  static const Color textDarkGrey = Color(0xFF555964);
  static const Color textMuted = Color(0xFF8E929E);
  static const Color textWhite = Colors.white;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryRed,
        primary: AppColors.primaryRed,
        surface: AppColors.lightBackground,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textBlack),
        titleTextStyle: TextStyle(
          color: AppColors.textBlack,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
