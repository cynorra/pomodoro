import 'package:flutter/material.dart';

class ZyraColors {
  const ZyraColors._();

  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color primary = Color(0xFFD4AF37);
  static const Color secondary = Color(0xFF9D76C1);
  static const Color onPrimary = Color(0xFF121212);
  static const Color onBackground = Color(0xFFE0E0E0);
  static const Color onSurface = Color(0xFFE0E0E0);
}

class ZyraTypography {
  const ZyraTypography._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.bold,
    height: 1.25,
    letterSpacing: -1.5,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.28,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.43,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.43,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );
}
