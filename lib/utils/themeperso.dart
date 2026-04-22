import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

abstract class ThemePerso {

  // ── Palette ─────────────────────────────────────────────────────────────
  static const Color teal        = Color(0xFF42B998);
  static const Color vert        = Color(0xFF005B4A);
  static const Color rouge       = Color(0xE6FD1010);
  static const Color bleu        = Color(0xFF1A73E8);

  static const Color black       = Color(0xFF0D1318);
  static const Color black2      = Color(0xE6252525);
  static const Color black3      = Color(0xDF444444);
  static const Color dark        = Color(0xFF2B3940);

  static const Color white       = Color(0xFFFFFFFF);
  static const Color whiteVert   = Color(0xD1F8FCF7);
  static const Color white2      = Color(0xFFEFEFEF);
  static const Color white3      = Color(0xFFEBEBEB);
  static const Color whiteSombre = Color(0xB4EFEFEF);

  static const Color hint        = Color(0x3D444444);
  static const Color hintSombre  = Color(0x3DFBF8F8);
  static const Color separator   = Color(0x6DAAAAAA);
  static const Color transparent = Color(0x00FFFFFF);

  // ── TextTheme Claire ────────────────────────────────────────────────────
  static const TextTheme _textThemeClaire = TextTheme(
    // ── Display : grands titres héroïques ──
    displayLarge: TextStyle(
      fontSize: 57, fontWeight: FontWeight.w400,
      letterSpacing: -0.25, color: black, height: 1.12,
    ),
    displayMedium: TextStyle(
      fontSize: 45, fontWeight: FontWeight.w400,
      letterSpacing: 0, color: black, height: 1.16,
    ),
    displaySmall: TextStyle(
      fontSize: 36, fontWeight: FontWeight.w400,
      letterSpacing: 0, color: black, height: 1.22,
    ),

    // ── Headline : titres de section ──
    headlineLarge: TextStyle(
      fontSize: 32, fontWeight: FontWeight.w600,
      letterSpacing: 0, color: black, height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 28, fontWeight: FontWeight.w600,
      letterSpacing: 0, color: black, height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontSize: 24, fontWeight: FontWeight.w600,
      letterSpacing: 0, color: black, height: 1.33,
    ),

    // ── Title : titres de composants (AppBar, Card…) ──
    titleLarge: TextStyle(
      fontSize: 22, fontWeight: FontWeight.w600,
      letterSpacing: 0, color: black, height: 1.27,
    ),
    titleMedium: TextStyle(
      fontSize: 16, fontWeight: FontWeight.w500,
      letterSpacing: 0.15, color: black, height: 1.50,
    ),
    titleSmall: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w500,
      letterSpacing: 0.1, color: black2, height: 1.43,
    ),

    // ── Label : boutons, chips, badges ──
    labelLarge: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600,
      letterSpacing: 0.1, color: black, height: 1.43,
    ),
    labelMedium: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w500,
      letterSpacing: 0.5, color: black2, height: 1.33,
    ),
    labelSmall: TextStyle(
      fontSize: 11, fontWeight: FontWeight.w500,
      letterSpacing: 0.5, color: black3, height: 1.45,
    ),

    // ── Body : texte courant ──
    bodyLarge: TextStyle(
      fontSize: 16, fontWeight: FontWeight.w400,
      letterSpacing: 0.5, color: black, height: 1.50,
    ),
    bodyMedium: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400,
      letterSpacing: 0.25, color: black2, height: 1.43,
    ),
    bodySmall: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w400,
      letterSpacing: 0.4, color: black3, height: 1.33,
    ),
  );

  // ── TextTheme Sombre ─────────────────────────────────────────────────────
  static const TextTheme _textThemeSombre = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57, fontWeight: FontWeight.w400,
      letterSpacing: -0.25, color: white, height: 1.12,
    ),
    displayMedium: TextStyle(
      fontSize: 45, fontWeight: FontWeight.w400,
      letterSpacing: 0, color: white, height: 1.16,
    ),
    displaySmall: TextStyle(
      fontSize: 36, fontWeight: FontWeight.w400,
      letterSpacing: 0, color: white, height: 1.22,
    ),

    headlineLarge: TextStyle(
      fontSize: 32, fontWeight: FontWeight.w600,
      letterSpacing: 0, color: white, height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 28, fontWeight: FontWeight.w600,
      letterSpacing: 0, color: white, height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontSize: 24, fontWeight: FontWeight.w600,
      letterSpacing: 0, color: white, height: 1.33,
    ),

    titleLarge: TextStyle(
      fontSize: 22, fontWeight: FontWeight.w600,
      letterSpacing: 0, color: white, height: 1.27,
    ),
    titleMedium: TextStyle(
      fontSize: 16, fontWeight: FontWeight.w500,
      letterSpacing: 0.15, color: white, height: 1.50,
    ),
    titleSmall: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w500,
      letterSpacing: 0.1, color: whiteSombre, height: 1.43,
    ),

    labelLarge: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600,
      letterSpacing: 0.1, color: white, height: 1.43,
    ),
    labelMedium: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w500,
      letterSpacing: 0.5, color: whiteSombre, height: 1.33,
    ),
    labelSmall: TextStyle(
      fontSize: 11, fontWeight: FontWeight.w500,
      letterSpacing: 0.5, color: white3, height: 1.45,
    ),

    bodyLarge: TextStyle(
      fontSize: 16, fontWeight: FontWeight.w400,
      letterSpacing: 0.5, color: white, height: 1.50,
    ),
    bodyMedium: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400,
      letterSpacing: 0.25, color: whiteSombre, height: 1.43,
    ),
    bodySmall: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w400,
      letterSpacing: 0.4, color: white3, height: 1.33,
    ),
  );

  // ── Mode Claire ──────────────────────────────────────────────────────────
  static final ThemeData ModeClaire = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: bleu,
      primary: bleu,
      secondary: teal,
      error: rouge,
      brightness: Brightness.light,
      surface: white,
    ),
    scaffoldBackgroundColor: white2,
    textTheme: _textThemeClaire,

    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: black,
      surfaceTintColor: transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: black),
      titleTextStyle: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600,
        color: black, letterSpacing: 0,
      ),
    ),

    cardTheme: CardThemeData(
      color: white,
      surfaceTintColor: transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: separator),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: separator,
      thickness: 1,
    ),
/*
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white3,
      hintStyle: const TextStyle(
        fontSize: 14, color: hint,
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: bleu, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 14,
      ),
    ),
*/
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bleu,
        foregroundColor: white,
        textStyle: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24, vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  );

  // ── Mode Sombre ──────────────────────────────────────────────────────────
  static final ThemeData ModeSombre = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: teal,
      primary: teal,
      secondary: vert,
      error: rouge,
      brightness: Brightness.dark,
      surface: dark,
    ),
    scaffoldBackgroundColor: black,
    textTheme: _textThemeSombre,

    appBarTheme: const AppBarTheme(
      backgroundColor: dark,
      foregroundColor: white,
      surfaceTintColor: transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: white),
      titleTextStyle: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600,
        color: white, letterSpacing: 0,
      ),
    ),

    cardTheme: CardThemeData(
      color: dark,
      surfaceTintColor: transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: separator),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: separator,
      thickness: 1,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: black2,
      hintStyle: const TextStyle(
        fontSize: 14, color: hintSombre,
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: teal, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 14,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: teal,
        foregroundColor: white,
        textStyle: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24, vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  );
}