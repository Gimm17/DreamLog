import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_tokens.dart';

abstract final class DreamTheme {
  static ThemeData dark() => _build();

  static ThemeData cosmic() => _build(
        scheme: const ColorScheme.dark(
          primary: DreamColors.primaryLight,
          secondary: Color(0xFF67E8F9),
          surface: Color(0xFF2E1065),
          error: DreamColors.rose,
          onPrimary: DreamColors.textPrimary,
          onSecondary: DreamColors.onAccent,
          onSurface: DreamColors.textPrimary,
        ),
      );

  static ThemeData amoled() => _build(
        scheme: const ColorScheme.dark(
          primary: DreamColors.primaryLight,
          secondary: DreamColors.aurora,
          surface: Color(0xFF0D0D0D),
          error: DreamColors.rose,
          onPrimary: DreamColors.textPrimary,
          onSecondary: DreamColors.onAccent,
          onSurface: DreamColors.textPrimary,
        ),
        cardColor: const Color(0xFF0D0D0D),
        inputFill: const Color(0xFF131313),
      );

  static ThemeData _build({
    ColorScheme? scheme,
    Color? cardColor,
    Color? inputFill,
  }) {
    final body = GoogleFonts.plusJakartaSansTextTheme();
    final display = GoogleFonts.playfairDisplayTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DreamColors.background,
      colorScheme: scheme ??
          ColorScheme.dark(
            primary: DreamColors.primaryLight,
            secondary: DreamColors.aurora,
            surface: DreamColors.surface,
            error: DreamColors.rose,
            onPrimary: DreamColors.textPrimary,
            onSecondary: DreamColors.onAccent,
            onSurface: DreamColors.textPrimary,
          ),
      textTheme: body.copyWith(
        displayLarge: display.displayLarge?.copyWith(
          color: DreamColors.textPrimary,
          fontSize: 40,
          fontStyle: FontStyle.italic,
          height: 1.15,
        ),
        headlineLarge: display.headlineLarge?.copyWith(
          color: DreamColors.textPrimary,
          fontSize: 32,
          fontStyle: FontStyle.italic,
          height: 1.2,
        ),
        headlineMedium: display.headlineMedium?.copyWith(
          color: DreamColors.textPrimary,
          fontSize: 26,
          fontStyle: FontStyle.italic,
          height: 1.25,
        ),
        titleLarge: body.titleLarge?.copyWith(
          color: DreamColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: body.titleMedium?.copyWith(
          color: DreamColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: body.bodyLarge?.copyWith(
          color: DreamColors.textPrimary,
          fontSize: 16,
          height: 1.7,
        ),
        bodyMedium: body.bodyMedium?.copyWith(
          color: DreamColors.textSecondary,
          fontSize: 14,
          height: 1.6,
        ),
        labelLarge: body.labelLarge?.copyWith(
          color: DreamColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        labelMedium: body.labelMedium?.copyWith(
          color: DreamColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: cardColor ?? DreamColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DreamRadii.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill ?? DreamColors.surfaceTwo,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DreamRadii.md),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: DreamColors.textMuted),
      ),
    );
  }
}
