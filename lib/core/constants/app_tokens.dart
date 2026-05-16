import 'package:flutter/material.dart';

abstract final class DreamColors {
  static const background = Color(0xFF0F0E17);
  static const backgroundSoft = Color(0xFF14121A);
  static const surface = Color(0xFF1E1B4B);
  static const surfaceTwo = Color(0xFF1F2937);
  static const surfaceHigh = Color(0xFF2B2931);
  static const primary = Color(0xFF6B46C1);
  static const primaryLight = Color(0xFF8B5CF6);
  static const aurora = Color(0xFF6EE7B7);
  static const gold = Color(0xFFFCD34D);
  static const rose = Color(0xFFF87171);
  static const textPrimary = Color(0xFFF9FAFB);
  static const textSecondary = Color(0xFF9CA3AF);
  static const textMuted = Color(0xFF6B7280);
  static const borderMuted = Color(0xFF2D2B5E);
}

abstract final class DreamSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class DreamRadii {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const pill = 999.0;
}

abstract final class DreamGradients {
  static const primary = LinearGradient(
    colors: [DreamColors.primary, DreamColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const card = LinearGradient(
    colors: [DreamColors.surface, Color(0xFF231F56)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const aurora = LinearGradient(
    colors: [DreamColors.primary, DreamColors.aurora],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

Color emotionColor(String emotion) {
  final normalized = emotion.toLowerCase();
  if (normalized.contains('joy') || normalized.contains('happy')) {
    return DreamColors.gold;
  }
  if (normalized.contains('fear') ||
      normalized.contains('anx') ||
      normalized.contains('sad')) {
    return DreamColors.rose;
  }
  if (normalized.contains('neutral')) {
    return const Color(0xFF4B5563);
  }
  return DreamColors.aurora;
}
