import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_tokens.dart';

class LearnyColors {
  static const skyPrimary = Color(0xFF7DD3E8);
  static const skyLight = Color(0xFFE8F7FA);
  static const mintPrimary = Color(0xFF8FE5C2);
  static const mintLight = Color(0xFFB8F0D8);
  static const lavender = Color(0xFFC5B9E8);
  static const lavenderLight = Color(0xFFDDD6F2);
  static const cream = Color(0xFFFFF8F0);
  static const neutralDark = Color(0xFF2D3748);
  static const neutralMedium = Color(0xFF5A6C7D);
  static const neutralLight = Color(0xFF8B9CAD);
  static const neutralSoft = Color(0xFFE8EDF2);
  static const neutralCream = Color(0xFFF7F9FC);
  static const coral = Color(0xFFFF9A8B);
  static const coralLight = Color(0xFFFFC4BC);
  static const sunshine = Color(0xFFFFD97A);
  static const sunshineLight = Color(0xFFFFE9AA);
  static const sage = Color(0xFFA8D5BA);
  static const success = Color(0xFF7DD3C8);
  static const highlight = Color(0xFFFFF4E1);

  // Compatibility aliases for existing screens.
  static const teal = mintPrimary;
  static const tealLight = mintLight;
  static const purple = lavender;
  static const purpleLight = lavenderLight;
  static const peach = highlight;
  static const sky = skyLight;
  static const slateDark = neutralDark;
  static const slateMedium = neutralMedium;
  static const slateLight = neutralLight;
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
        primary: LearnyColors.skyPrimary,
        secondary: LearnyColors.mintPrimary,
        surface: Colors.white,
        background: LearnyColors.cream,
        onPrimary: Colors.white,
        onSecondary: LearnyColors.neutralDark,
        onSurface: LearnyColors.neutralDark,
        onBackground: LearnyColors.neutralDark,
      ),
      scaffoldBackgroundColor: LearnyColors.cream,
      textTheme: textTheme.apply(
        bodyColor: LearnyColors.neutralDark,
        displayColor: LearnyColors.neutralDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: LearnyColors.neutralDark,
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
          backgroundColor: LearnyColors.skyPrimary,
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
          foregroundColor: LearnyColors.skyPrimary,
          side: const BorderSide(color: LearnyColors.skyPrimary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: LearnyColors.neutralCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      extensions: const [
        LearnyTokens.light,
      ],
    );
  }
}

class LearnyGradients {
  static const hero = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [LearnyColors.skyLight, LearnyColors.cream],
  );

  static const cta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [LearnyColors.skyPrimary, LearnyColors.mintPrimary],
  );

  static const trust = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [LearnyColors.skyLight, LearnyColors.cream],
  );

  static const card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, LearnyColors.neutralCream],
  );
}
