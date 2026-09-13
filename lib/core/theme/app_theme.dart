import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors pulled from the website's app/globals.css brand tokens
/// (--brand-primary, --brand-accent, --brand-secondary) so the mobile app
/// matches the site's visual identity rather than inventing a new palette.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF0E5A8A);
  static const primaryDark = Color(0xFF3B9CD9);
  static const accent = Color(0xFFE6A627);
  static const accentDark = Color(0xFFF2B84B);
  static const accentStrong = Color(0xFF9A6A00);
  static const secondary = Color(0xFF2E7D5B);
  static const secondaryDark = Color(0xFF4FA77E);
  static const textPrimaryLight = Color(0xFF0F172A);
  static const textPrimaryDark = Color(0xFFF1F5F9);

  // Website's surface/muted/border tiers (app/globals.css --bg-surface,
  // --bg-muted, --border), not covered by Material's seeded ColorScheme.
  static const bgSurfaceLight = Color(0xFFF8FAFC);
  static const bgMutedLight = Color(0xFFF1F5F9);
  static const borderLight = Color(0xFFE2E8F0);
  static const bgSurfaceDark = Color(0xFF111827);
  static const bgMutedDark = Color(0xFF1F2937);
  static const borderDark = Color(0xFF374151);

  // Website's signature blue->green gradient (used on cards/buttons/CTA
  // bands) — see --gradient-blue/--gradient-green in app/globals.css.
  static const gradientBlue = Color(0xFF107BD9);
  static const gradientGreen = Color(0xFF69B249);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientBlue, gradientGreen],
  );
}

/// Spacing scale used across the app instead of ad-hoc magic numbers.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Corner-radius scale used across cards, buttons, dialogs, inputs, etc.
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
      tertiary: AppColors.accentDark,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    final baseTextTheme = ThemeData(brightness: scheme.brightness).textTheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Verdana itself can't be legally bundled (proprietary, no free
      // redistribution license) — Arimo is a free, metrically-compatible
      // stand-in with the same clean humanist-sans look.
      textTheme: GoogleFonts.arimoTextTheme(baseTextTheme),
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
