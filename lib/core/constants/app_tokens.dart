import 'package:flutter/material.dart';

/// Surface colors that differ per theme. The accent colors (primary, aurora,
/// gold, rose) and the text ramp are theme-independent and stay const.
class DreamPalette {
  const DreamPalette({
    required this.background,
    required this.backgroundSoft,
    required this.surface,
    required this.surfaceTwo,
    required this.surfaceHigh,
    required this.borderMuted,
  });

  final Color background;
  final Color backgroundSoft;
  final Color surface;
  final Color surfaceTwo;
  final Color surfaceHigh;
  final Color borderMuted;

  // Identity equality would let a CustomPainter keep a stale cached picture
  // after a palette swap, so compare by value.
  @override
  bool operator ==(Object other) {
    return other is DreamPalette &&
        other.background == background &&
        other.backgroundSoft == backgroundSoft &&
        other.surface == surface &&
        other.surfaceTwo == surfaceTwo &&
        other.surfaceHigh == surfaceHigh &&
        other.borderMuted == borderMuted;
  }

  @override
  int get hashCode => Object.hash(
        background,
        backgroundSoft,
        surface,
        surfaceTwo,
        surfaceHigh,
        borderMuted,
      );
}

const _midnightPalette = DreamPalette(
  background: Color(0xFF0F0E17),
  backgroundSoft: Color(0xFF14121A),
  surface: Color(0xFF1E1B4B),
  surfaceTwo: Color(0xFF1F2937),
  surfaceHigh: Color(0xFF2B2931),
  borderMuted: Color(0xFF2D2B5E),
);

const _cosmicPalette = DreamPalette(
  background: Color(0xFF0A0718),
  backgroundSoft: Color(0xFF120C24),
  surface: Color(0xFF2E1065),
  surfaceTwo: Color(0xFF1E1B4B),
  surfaceHigh: Color(0xFF241C3D),
  borderMuted: Color(0xFF4C1D95),
);

const _amoledPalette = DreamPalette(
  background: Color(0xFF000000),
  backgroundSoft: Color(0xFF050505),
  surface: Color(0xFF0D0D0D),
  surfaceTwo: Color(0xFF131313),
  surfaceHigh: Color(0xFF1A1A1A),
  borderMuted: Color(0xFF2A2A2A),
);

const dreamThemeNames = ['Midnight', 'Cosmic', 'AMOLED'];

abstract final class DreamColors {
  static DreamPalette _palette = _midnightPalette;

  /// Swaps the active surface palette. Idempotent; called from the root widget
  /// so every `DreamColors.surface` read below picks up the new theme.
  static void applyTheme(String themeName) {
    _palette = switch (themeName) {
      'Cosmic' => _cosmicPalette,
      'AMOLED' => _amoledPalette,
      _ => _midnightPalette,
    };
  }

  static DreamPalette get palette => _palette;

  static Color get background => _palette.background;
  static Color get backgroundSoft => _palette.backgroundSoft;
  static Color get surface => _palette.surface;
  static Color get surfaceTwo => _palette.surfaceTwo;
  static Color get surfaceHigh => _palette.surfaceHigh;
  static Color get borderMuted => _palette.borderMuted;

  static const primary = Color(0xFF6B46C1);
  static const primaryLight = Color(0xFF8B5CF6);
  static const aurora = Color(0xFF6EE7B7);
  static const gold = Color(0xFFFCD34D);
  static const rose = Color(0xFFF87171);
  static const textPrimary = Color(0xFFF9FAFB);
  static const textSecondary = Color(0xFF9CA3AF);
  static const textMuted = Color(0xFF6B7280);

  /// Ink that sits on top of a bright accent fill. Palette-independent.
  static const onAccent = Color(0xFF0F0E17);
}

abstract final class DreamSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;

  /// Gap between a [SectionLabel] and the content under it.
  static const labelGap = 16.0;

  /// Gap between two major blocks of a scrolling screen.
  static const sectionGap = 36.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Screen-level metrics, so every top-level scroll view lines up.
abstract final class DreamLayout {
  /// Left/right inset for a screen body. One value for all screens.
  static const screenPadding = 24.0;

  /// Top inset of a screen body under its header row.
  static const screenTop = 24.0;

  /// Bottom inset for a plain tab screen that scrolls above the bottom nav.
  static const tabBottom = 40.0;

  /// Bottom inset when a floating action button or docked button bar overlays
  /// the scroll view and must not cover the last item.
  static const dockedBarBottom = 132.0;
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

  static LinearGradient get card => LinearGradient(
        colors: [
          DreamColors.surface,
          Color.lerp(DreamColors.surface, DreamColors.primary, 0.22)!,
        ],
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
