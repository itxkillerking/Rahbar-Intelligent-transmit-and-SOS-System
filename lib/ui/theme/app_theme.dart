import 'package:flutter/material.dart';

class AppTheme {
  // Primary Brand Colors
  static const Color primaryColor = Color(0xFFE11D48); // Premium Emergency Red
  static const Color secondaryColor = Color(0xFF064E3B); // Deep Pakistan Green
  static const Color accentBlue = Color(0xFF2563EB); // Modern Blue Accent (kept for specific transitional states)
  
  // Pakistan Green Palette
  static const Color pakistanGreen = Color(0xFF047857);
  static const Color premiumGreen = Color(0xFF059669);
  static const Color brightGreenAccent = Color(0xFF10B981);
  static const Color lightGreenSurface = Color(0xFFECFDF5);
  
  // Background & Surface
  static const Color backgroundColor = Color(0xFFF8FAF9); // Very light green-tinted neutral
  static const Color surfaceColor = Colors.white;
  
  // Semantic Colors
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFD97706); // Warning Amber
  static const Color safeColor = Color(0xFF10B981);
  static const Color textPrimary = Color(0xFF0F172A); // Dark Main Text
  static const Color textSecondary = Color(0xFF475569); // Secondary Text

  // Typography
  static const TextStyle displayStyle = TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5);
  static const TextStyle headingStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.3);
  static const TextStyle titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary);
  static const TextStyle bodyStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary);
  static const TextStyle captionStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary);

  // Spacing & Radius
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  static const double cornerRadiusSm = 12.0;
  static const double cornerRadiusMd = 20.0;
  static const double cornerRadiusLg = 28.0;
  static const double cornerRadiusPill = 999.0;

  // Gradients
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF059669)],
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF43F5E), Color(0xFF881337)], // Bright Rose to Deep Dark Red
  );

  // Shadows
  static final List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> glowShadowRed = [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.25),
      blurRadius: 24,
      spreadRadius: 2,
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Inter', // Or system default if Inter isn't loaded
      colorScheme: ColorScheme.fromSeed(
        seedColor: secondaryColor,
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
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0, // Using custom shadows where needed
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
    );
  }
}
