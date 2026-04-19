import 'package:flutter/material.dart';
import 'brand_colors.dart';

const String _kGoogleFontsPackage = 'google_fonts';

/// Thingual Theme Configuration
/// Based on Outfit and JetBrains Mono fonts and Thingual brand guide
class ThingualTheme {
  /// Get the complete light theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: ThingualColors.deepIndigo,
        secondary: ThingualColors.vivdCyan,
        tertiary: ThingualColors.amber,
        surface: Colors.white,
        surfaceContainer: ThingualColors.cloud,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        outline: Colors.grey[300]!,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 57,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.03,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 45,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.02,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 36,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.02,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.015,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.01,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontFamily: 'JetBrains Mono',
          package: _kGoogleFontsPackage,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.05,
        ),
        labelMedium: TextStyle(
          fontFamily: 'JetBrains Mono',
          package: _kGoogleFontsPackage,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          fontFamily: 'JetBrains Mono',
          package: _kGoogleFontsPackage,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ThingualColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: ThingualColors.ink,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThingualColors.deepIndigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ThingualColors.deepIndigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ThingualColors.deepIndigo,
          side: const BorderSide(color: ThingualColors.deepIndigo),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: ThingualColors.deepIndigo),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ThingualColors.deepIndigo,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey[200]!),
        ),
      ),
    );
  }

  /// Get the complete dark theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: ThingualColors.deepIndigo,
        secondary: ThingualColors.vivdCyan,
        tertiary: ThingualColors.amber,
        surface: ThingualColors.darkSurface,
        surfaceContainer: ThingualColors.darkSurfaceHover,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        outline: Colors.grey[700]!,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 57,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.03,
          color: ThingualColors.lightText,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 45,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.02,
          color: ThingualColors.lightText,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 36,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.02,
          color: ThingualColors.lightText,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.015,
          color: ThingualColors.lightText,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.01,
          color: ThingualColors.lightText,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: ThingualColors.lightText,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: ThingualColors.lightText,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ThingualColors.lightText,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ThingualColors.lightText,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: ThingualColors.lightText,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: ThingualColors.dimText,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Outfit',
          package: _kGoogleFontsPackage,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: ThingualColors.dimText,
        ),
        labelLarge: TextStyle(
          fontFamily: 'JetBrains Mono',
          package: _kGoogleFontsPackage,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.05,
          color: ThingualColors.lightText,
        ),
        labelMedium: TextStyle(
          fontFamily: 'JetBrains Mono',
          package: _kGoogleFontsPackage,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: ThingualColors.dimText,
        ),
        labelSmall: TextStyle(
          fontFamily: 'JetBrains Mono',
          package: _kGoogleFontsPackage,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: ThingualColors.dimText,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ThingualColors.darkSurface,
        foregroundColor: ThingualColors.lightText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: ThingualColors.lightText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThingualColors.deepIndigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ThingualColors.deepIndigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ThingualColors.vivdCyan,
          side: const BorderSide(color: ThingualColors.vivdCyan),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: ThingualColors.vivdCyan),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ThingualColors.deepIndigo,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: ThingualColors.darkSurface,
      ),
      cardTheme: CardThemeData(
        color: ThingualColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
    );
  }
}

/// Spacing constants
class ThingualSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Border radius constants
class ThingualRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 20;
  static const double full = 9999;
}

/// Shadow constants
class ThingualShadows {
  static const BoxShadow sm = BoxShadow(
    color: Color.fromARGB(25, 0, 0, 0),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow md = BoxShadow(
    color: Color.fromARGB(10, 0, 0, 0),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow lg = BoxShadow(
    color: Color.fromARGB(16, 0, 0, 0),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static const BoxShadow xl = BoxShadow(
    color: Color.fromARGB(20, 0, 0, 0),
    blurRadius: 20,
    offset: Offset(0, 8),
  );
}
