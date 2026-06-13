import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color tokens ────────────────────────────────────────────────────────────
// Derived from a single seed (indigo-slate) with one warm accent.
// Background is a cool off-white — not white, not gradient. Surface cards
// sit on it with elevation rather than competing gradient layers.

class PebloColors {
  PebloColors._();

  // Brand primaries
  static const Color brand = Color(0xFF3B5BDB);       // indigo — Pip's world
  static const Color brandDark = Color(0xFF2C44B0);
  static const Color brandLight = Color(0xFFEEF2FF);
  static const Color brandMid = Color(0xFF748FFC);

  // Accent — warm gold for XP / achievement
  static const Color gold = Color(0xFFF59F00);
  static const Color goldLight = Color(0xFFFFF3BF);

  // Semantic
  static const Color success = Color(0xFF2F9E44);
  static const Color successLight = Color(0xFFEBFBEE);
  static const Color successMid = Color(0xFF40C057);
  static const Color error = Color(0xFFE03131);
  static const Color errorLight = Color(0xFFFFF5F5);
  static const Color warning = Color(0xFFE67700);
  static const Color warningLight = Color(0xFFFFF3BF);

  // Neutrals — slate family, not pure gray
  static const Color bg = Color(0xFFF0F2F8);           // page background
  static const Color surface = Color(0xFFFFFFFF);      // cards
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFFE2E6F0);      // card borders
  static const Color outlineStrong = Color(0xFFCBD0DF);
  static const Color textPrimary = Color(0xFF1A1D23);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Legacy aliases kept so existing widgets don't break immediately
  static const Color skyBlue = brandMid;
  static const Color deepBlue = brand;
  static const Color sunYellow = gold;
  static const Color leafGreen = successMid;
  static const Color coralRed = error;
  static const Color softPurple = Color(0xFFAB78FF);
  static const Color warmWhite = surface;
  static const Color inkDark = textPrimary;
  static const Color cardWhite = surface;
  static const Color bgGradientTop = bg;
  static const Color bgGradientBottom = bg;
  static const Color successGreen = success;
}

// ─── Type scale ──────────────────────────────────────────────────────────────
// Four stops only: display / title / body / caption
// Nunito for display/title; system sans for body to feel native.

class PebloTextStyles {
  PebloTextStyles._();

  static TextStyle display({Color? color}) => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.5,
        color: color ?? PebloColors.textPrimary,
      );

  static TextStyle title({Color? color}) => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: color ?? PebloColors.textPrimary,
      );

  static TextStyle body({Color? color}) => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.55,
        color: color ?? PebloColors.textPrimary,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: color ?? PebloColors.textSecondary,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: color ?? PebloColors.textTertiary,
      );

  static TextStyle label({Color? color}) => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color ?? PebloColors.textPrimary,
      );
}

// ─── Spacing tokens ───────────────────────────────────────────────────────────
class PebloSpacing {
  PebloSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

// ─── Radius tokens ────────────────────────────────────────────────────────────
class PebloRadius {
  PebloRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

// ─── Shadow tokens ────────────────────────────────────────────────────────────
class PebloShadows {
  PebloShadows._();

  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF1A1D23).withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: const Color(0xFF1A1D23).withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> elevated = [
    BoxShadow(
      color: const Color(0xFF3B5BDB).withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF1A1D23).withOpacity(0.05),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
}

// ─── Theme ────────────────────────────────────────────────────────────────────
class PebloTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PebloColors.brand,
          brightness: Brightness.light,
          background: PebloColors.bg,
          surface: PebloColors.surface,
        ),
        scaffoldBackgroundColor: PebloColors.bg,
        fontFamily: GoogleFonts.nunito().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: PebloColors.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: PebloColors.brand,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: PebloSpacing.xl,
              vertical: PebloSpacing.md + 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PebloRadius.lg),
            ),
            textStyle: PebloTextStyles.label(color: Colors.white),
          ),
        ),
      );
}