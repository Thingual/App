import 'package:flutter/material.dart';

/// Thingual Brand Colors
/// Based on the official Thingual Brand Guide
class ThingualColors {
  // Core Palette
  static const Color deepIndigo = Color(0xFF4338CA);
  static const Color vivdCyan = Color(0xFF06B6D4);
  static const Color amber = Color(0xFFF59E0B);
  static const Color ink = Color(0xFF0F172A);
  static const Color cloud = Color(0xFFF8FAFC);

  // Extended Indigo Tints & Shades
  static const Color indigoShade900 = Color(0xFF312E81);
  static const Color indigoShade800 = Color(0xFF4338CA);
  static const Color indigoShade700 = Color(0xFF5046E5);
  static const Color indigoShade600 = Color(0xFF6366F1);
  static const Color indigoShade500 = Color(0xFF818CF8);

  // Extended Cyan Tints & Shades
  static const Color cyanShade900 = Color(0xFF0E7490);
  static const Color cyanShade800 = Color(0xFF06B6D4);
  static const Color cyanShade700 = Color(0xFF22D3EE);
  static const Color cyanShade600 = Color(0xFF67E8F9);
  static const Color cyanShade500 = Color(0xFFA5F3FC);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFFA500);

  // Neutral Colors for light/dark mode
  static const Color darkBg = Color(0xFF070B14);
  static const Color darkSurface = Color(0xFF0D1220);
  static const Color darkSurfaceHover = Color(0xFF131B2E);
  static const Color lightText = Color(0xFFE2E8F0);
  static const Color dimText = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepIndigo, vivdCyan],
  );

  static const LinearGradient primaryGradientReverse = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [vivdCyan, deepIndigo],
  );

  static const LinearGradient indigoToAmberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepIndigo, amber],
  );

  static const LinearGradient deepInkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF080C18), Color(0xFF0F1832)],
  );
}
