import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearnyColors {
  static const coral = Color(0xFFFF7A6B);
  static const coralLight = Color(0xFFFF9A7B);
  static const teal = Color(0xFF4ECDC4);
  static const tealLight = Color(0xFF7DD3C0);
  static const purple = Color(0xFF9B7EDE);
  static const purpleLight = Color(0xFFB794F4);
  static const peach = Color(0xFFFFD6C1);
  static const cream = Color(0xFFFFF8F5);
  static const sky = Color(0xFFE8F4F8);
  static const slateDark = Color(0xFF2D3748);
  static const slateMedium = Color(0xFF5A6C7D);
  static const slateLight = Color(0xFF8B9CAD);
}

class LearnyTheme {
  static ThemeData light() {
    final baseText = GoogleFonts.nunitoTextTheme();
    final heading = GoogleFonts.poppinsTextTheme();

    final textTheme = baseText.copyWith(
      displayLarge: heading.displayLarge,
      displayMedium: heading.displayMedium,
      displaySmall: heading.displaySmall,
      headlineLarge: heading.headlineLarge,
      headlineMedium: heading.headlineMedium,
      headlineSmall: heading.headlineSmall,
      titleLarge: heading.titleLarge,
      titleMedium: heading.titleMedium,
      titleSmall: heading.titleSmall,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: LearnyColors.coral,
        secondary: LearnyColors.teal,
        surface: Colors.white,
        background: LearnyColors.cream,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: LearnyColors.slateDark,
        onBackground: LearnyColors.slateDark,
      ),
      scaffoldBackgroundColor: LearnyColors.cream,
      textTheme: textTheme.apply(
        bodyColor: LearnyColors.slateDark,
        displayColor: LearnyColors.slateDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: LearnyColors.slateDark,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LearnyColors.coral,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LearnyColors.teal,
          side: const BorderSide(color: LearnyColors.teal, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: LearnyColors.sky,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class LearnyGradients {
  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [LearnyColors.peach, Color(0xFFFFF0E6), LearnyColors.sky],
  );

  static const cta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [LearnyColors.coral, LearnyColors.coralLight],
  );

  static const trust = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [LearnyColors.sky, Color(0xFFFFF0E6)],
  );
}
