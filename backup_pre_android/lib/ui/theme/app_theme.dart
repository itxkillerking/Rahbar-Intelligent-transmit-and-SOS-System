import 'package:flutter/material.dart';

class AppTheme {
  // Primary Brand Colors
  static const Color primaryColor = Color(0xFFD32F2F); // Emergency Red
  static const Color secondaryColor = Color(0xFF1E3A8A); // Deep Trustworthy Blue
  
  // Background & Surface
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Colors.white;
  
  // Semantic Colors
  static const Color errorColor = Color(0xFFDC2626);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color safeColor = Color(0xFF10B981);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  // Typography
  static const TextStyle displayStyle = TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary);
  static const TextStyle headingStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary);
  static const TextStyle titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary);
  static const TextStyle bodyStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary);
  static const TextStyle captionStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary);

  // Spacing & Radius
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double cornerRadiusSm = 8.0;
  static const double cornerRadiusMd = 16.0;
  static const double cornerRadiusLg = 24.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        error: errorColor,
        surface: surfaceColor,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      textTheme: const TextTheme(
        displayLarge: displayStyle,
        headlineMedium: headingStyle,
        titleMedium: titleStyle,
        bodyMedium: bodyStyle,
        labelMedium: captionStyle,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cornerRadiusMd)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cornerRadiusSm)),
          padding: const EdgeInsets.symmetric(vertical: spacingMedium, horizontal: spacingLarge),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
