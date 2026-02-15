import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_tokens.dart';

class LearnyColors {
  // Website Aligned Colors
  static const coral = Color(0xFFFF7A6B);
  static const coralLight = Color(0xFFFF9A7B);
  static const tealPrimary = Color(0xFF4ECDC4);
  static const tealLight = Color(0xFF7DD3C0);
  static const purplePrimary = Color(0xFF9B7EDE);
  static const purpleLight = Color(0xFFB794F4);
  
  static const peach = Color(0xFFFFD6C1);
  static const cream = Color(0xFFFFF8F5); // Website cream
  static const sky = Color(0xFFE8F4F8); // Website sky
  
  static const slateDark = Color(0xFF2D3748);
  static const slateMedium = Color(0xFF5A6C7D);
  static const slateLight = Color(0xFF8B9CAD);

  // Legacy/Compatibility definitions (mapped to new palette)
  static const skyPrimary = tealPrimary; // Using Teal as primary to match site vibe or keep Sky? 
  // Website uses Coral/Teal/Purple as main accents. 
  // Let's keep SkyPrimary as a variation of Teal or Sky for compatibility if needed, 
  // but better to align "Primary" with the website's primary. 
  // Website doesn't explicitly define "primary" color in the config shown, but "Coral" seems to be the CTA color.
  // Mobile app uses SkyPrimary (Blue) a lot. 
  // Let's map SkyPrimary to Teal or keep it as a distinct blue if the site has blue? 
  // Site has "Sky" #E8F4F8. 
  // Let's keep SkyPrimary but maybe tweak it or stick to Teal/Coral. 
  // For now, I will update specific values and keep aliases.

  static const skyLightOld = Color(0xFFE8F7FA); // Keeping for safe fallback if needed
  static const skyLight = sky; // Restored alias for compatibility
  
  // Aliases for compatibility with existing code
  static const mintPrimary = tealPrimary;
  static const mintLight = tealLight;
  static const lavender = purplePrimary;
  static const lavenderLight = purpleLight;
  
  static const neutralDark = slateDark;
  static const neutralMedium = slateMedium;
  static const neutralLight = slateLight;
  static const neutralSoft = Color(0xFFE8EDF2); // Kept close to sky
  static const neutralCream = cream;
  
  static const sunshine = Color(0xFFFFD97A); // Keeping sunshine as it might be used
  static const sunshineLight = Color(0xFFFFE9AA);
  static const sage = Color(0xFFA8D5BA);
  static const success = tealPrimary; // Teal is good for success
  static const highlight = peach;

  // Compatibility aliases
  static const teal = tealPrimary;
  static const purple = purplePrimary;
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
        primary: LearnyColors.tealPrimary, // Updated to Teal
        secondary: LearnyColors.coral,     // Coral as secondary/accent
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
          backgroundColor: LearnyColors.coral, // CTA color
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
          foregroundColor: LearnyColors.tealPrimary,
          side: const BorderSide(color: LearnyColors.tealPrimary, width: 2),
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
  // Website: linear-gradient(135deg, #FFD6C1 0%, #FFF0E6 50%, #E8F4F8 100%)
  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      LearnyColors.peach,
      Color(0xFFFFF0E6),
      LearnyColors.sky,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Website: linear-gradient(135deg, #FF7A6B, #FF9A7B)
  static const cta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [LearnyColors.coral, LearnyColors.coralLight],
  );

  // Website: linear-gradient(135deg, #E8F4F8 0%, #FFF0E6 100%)
  static const trust = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [LearnyColors.sky, Color(0xFFFFF0E6)],
  );

  static const card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, LearnyColors.cream],
  );
}
