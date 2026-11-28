import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Nocturne Atelier Design System — Colors
///
/// Built deliberately for low-light environments: deeply steeped espresso
/// undertones, spun copper/caramel accents, matcha restorative tones, and
/// crema hairlines. Zero blur filters, zero drop shadows, zero cool hues.
class ZyraColors {
  const ZyraColors._();

  // Surface Tiers (Layer 0 -> Layer 1 -> Layer 2)
  static const Color background = Color(0xFF14100D); // Canvas Base (Espresso Black)
  static const Color surfaceDim = Color(0xFF171310); // Docked bars / chrome
  static const Color surfaceLowest = Color(0xFF110D0A);
  static const Color surface = Color(0xFF1D1814); // Base Surface (Dark Roast Card)
  static const Color surfaceElevated = Color(0xFF261F19); // Elevated Surface (Warm Wood Grain)
  static const Color surfaceHighest = Color(0xFF393430); // Active / pressed tray

  // Accents
  static const Color primary = Color(0xFFD98E4A); // Warm Caramel / Spun Copper
  static const Color primaryBright = Color(0xFFFFB77A); // Warm Copper Highlight
  static const Color primaryHover = Color(0xFFE49E5E);
  static const Color onPrimary = Color(0xFF14100D);

  static const Color secondary = Color(0xFF9DB07A); // Matcha Green (breaks, completion)
  static const Color secondaryBright = Color(0xFFBACE95);
  static const Color secondaryContainer = Color(0xFF3C4C20);
  static const Color onSecondary = Color(0xFF14100D);

  static const Color tertiary = Color(0xFFD3C4B0); // Warm parchment
  static const Color onTertiary = Color(0xFF382F21);

  // Text & Hairlines
  static const Color onBackground = Color(0xFFF2E8D8); // Crema
  static const Color onSurface = Color(0xFFF2E8D8); // Crema
  static const Color textSecondary = Color(0xFFA39683); // Warm Taupe
  static const Color textTertiary = Color(0xFF6E6354); // Charcoal Roast

  static const Color hairline = Color(0x14F2E8D8); // rgba(242, 232, 216, 0.08)
  static const Color hairlineStrong = Color(0x1FF2E8D8); // rgba(242, 232, 216, 0.12)
  static const Color divider = Color(0x0FF2E8D8); // rgba(242, 232, 216, 0.06)

  // Semantic
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);

  // Focal Illumination (static radial lamp glow behind hero elements)
  static const RadialGradient lampGlow = RadialGradient(
    center: Alignment.center,
    radius: 0.7,
    colors: [
      Color(0x14D98E4A), // ~8% warm caramel
      Color(0x0014100D), // transparent espresso
    ],
  );

  // Okey / Felt Table Accent (deep nocturnal forest felt)
  static const Color feltDark = Color(0xFF121D17);
  static const Color feltMid = Color(0xFF192820);
  static const Color tileIvory = Color(0xFFF5EFE6);
}

/// Nocturne Atelier Design System — Typography
///
/// - Headings: Newsreader (editorial serif, natural italics)
/// - UI & Body: Inter (high-clarity sans-serif)
/// - Timers & Metrics: JetBrains Mono (strict tabular figures)
class ZyraTypography {
  const ZyraTypography._();

  static TextStyle get displayLarge => GoogleFonts.jetBrainsMono(
        fontSize: 56,
        fontWeight: FontWeight.w500,
        height: 1.12,
        letterSpacing: -2.0,
        color: ZyraColors.onBackground,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get editorialDisplay => GoogleFonts.newsreader(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        height: 1.2,
        letterSpacing: -0.6,
        color: ZyraColors.onBackground,
      );

  static TextStyle get editorialItalic => GoogleFonts.newsreader(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        height: 1.25,
        letterSpacing: -0.4,
        color: ZyraColors.onBackground,
      );

  static TextStyle get headlineLarge => GoogleFonts.newsreader(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        height: 1.25,
        letterSpacing: -0.4,
        color: ZyraColors.onBackground,
      );

  static TextStyle get headlineMedium => GoogleFonts.newsreader(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: -0.3,
        color: ZyraColors.onBackground,
      );

  static TextStyle get titleLarge => GoogleFonts.newsreader(
        fontSize: 19,
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: -0.2,
        color: ZyraColors.onBackground,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: -0.1,
        color: ZyraColors.onBackground,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: ZyraColors.onBackground,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: ZyraColors.textSecondary,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: 0.1,
        color: ZyraColors.onBackground,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: 0.3,
        color: ZyraColors.textSecondary,
      );

  static TextStyle get sectionLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 1.4,
        color: ZyraColors.textSecondary,
      );

  static TextStyle get dataMono => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.35,
        letterSpacing: -0.2,
        color: ZyraColors.onBackground,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get dataMonoLarge => GoogleFonts.jetBrainsMono(
        fontSize: 26,
        fontWeight: FontWeight.w500,
        height: 1.15,
        letterSpacing: -0.8,
        color: ZyraColors.onBackground,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

/// Complete Material 3 ThemeData for Nocturne Atelier.
class ZyraTheme {
  const ZyraTheme._();

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: ZyraColors.primary,
      scaffoldBackgroundColor: ZyraColors.background,
      canvasColor: ZyraColors.background,
      colorScheme: const ColorScheme.dark(
        primary: ZyraColors.primary,
        onPrimary: ZyraColors.onPrimary,
        primaryContainer: ZyraColors.primaryBright,
        onPrimaryContainer: ZyraColors.onPrimary,
        secondary: ZyraColors.secondary,
        onSecondary: ZyraColors.onSecondary,
        secondaryContainer: ZyraColors.secondaryContainer,
        onSecondaryContainer: ZyraColors.secondaryBright,
        tertiary: ZyraColors.tertiary,
        onTertiary: ZyraColors.onTertiary,
        surface: ZyraColors.surface,
        onSurface: ZyraColors.onSurface,
        onSurfaceVariant: ZyraColors.textSecondary,
        outline: ZyraColors.textTertiary,
        outlineVariant: ZyraColors.hairline,
        error: ZyraColors.error,
        onError: ZyraColors.onError,
        errorContainer: ZyraColors.errorContainer,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: ZyraTypography.displayLarge,
        headlineLarge: ZyraTypography.headlineLarge,
        headlineMedium: ZyraTypography.headlineMedium,
        titleLarge: ZyraTypography.titleLarge,
        titleMedium: ZyraTypography.titleMedium,
        bodyMedium: ZyraTypography.bodyMedium,
        bodySmall: ZyraTypography.bodySmall,
        labelLarge: ZyraTypography.labelLarge,
        labelSmall: ZyraTypography.labelSmall,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ZyraColors.background,
        foregroundColor: ZyraColors.onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: ZyraTypography.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: ZyraColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: ZyraColors.hairline, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ZyraColors.divider,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZyraColors.surface,
        hintStyle: ZyraTypography.bodyMedium.copyWith(
          color: ZyraColors.textTertiary,
        ),
        labelStyle: ZyraTypography.bodySmall.copyWith(
          color: ZyraColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ZyraColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ZyraColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ZyraColors.primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ZyraColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ZyraColors.primary,
          foregroundColor: ZyraColors.onPrimary,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: ZyraTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ZyraColors.onBackground,
          side: const BorderSide(color: ZyraColors.hairlineStrong),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          textStyle: ZyraTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ZyraColors.primary,
          shape: const StadiumBorder(),
          textStyle: ZyraTypography.labelLarge,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ZyraColors.onPrimary;
          }
          return ZyraColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ZyraColors.primary;
          }
          return ZyraColors.surfaceElevated;
        }),
        trackOutlineColor: WidgetStateProperty.all(ZyraColors.hairline),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ZyraColors.surfaceElevated,
        contentTextStyle: ZyraTypography.bodyMedium.copyWith(
          color: ZyraColors.onBackground,
        ),
        actionTextColor: ZyraColors.primary,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: ZyraColors.hairlineStrong),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ZyraColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: ZyraColors.hairlineStrong),
        ),
        titleTextStyle: ZyraTypography.titleLarge,
        contentTextStyle: ZyraTypography.bodyMedium.copyWith(
          color: ZyraColors.textSecondary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ZyraColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: ZyraColors.hairlineStrong),
        ),
      ),
    );
  }
}
