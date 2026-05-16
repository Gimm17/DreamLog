import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class DreamOrbitScene extends StatelessWidget {
  const DreamOrbitScene({
    required this.animation,
    required this.icon,
    super.key,
    this.compact = false,
    this.center,
  });

  final Animation<double> animation;
  final IconData icon;
  final bool compact;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final phase = animation.value;
        return CustomPaint(
          painter: _DreamOrbitPainter(phase: phase),
          child: Center(
            child: Transform.translate(
              offset: Offset(0, math.sin(phase * math.pi * 2) * 8),
              child: Transform.scale(
                scale: 1 + math.sin(phase * math.pi * 2) * 0.035,
                child: Container(
                  width: compact ? 116 : 154,
                  height: compact ? 116 : 154,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        DreamColors.primaryLight.withValues(alpha: 0.46),
                        DreamColors.primary.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: DreamColors.primaryLight.withValues(alpha: 0.34),
                        blurRadius: 56,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: center ??
                      Icon(
                        icon,
                        color: const Color(0xFFD8C5FF),
                        size: compact ? 68 : 92,
                      ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DreamOrbitPainter extends CustomPainter {
  _DreamOrbitPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final shortest = math.min(size.width, size.height);
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = DreamColors.borderMuted.withValues(alpha: 0.42);

    for (final radius in [shortest * 0.28, shortest * 0.38]) {
      canvas.drawCircle(center, radius, orbitPaint);
    }

    final symbols =
        <({IconData icon, Color color, double radius, double offset})>[
      (
        icon: Icons.vpn_key_outlined,
        color: DreamColors.gold,
        radius: shortest * 0.28,
        offset: 0
      ),
      (
        icon: Icons.water_drop_outlined,
        color: DreamColors.aurora,
        radius: shortest * 0.38,
        offset: 1.25
      ),
      (
        icon: Icons.meeting_room_outlined,
        color: DreamColors.primaryLight,
        radius: shortest * 0.32,
        offset: 2.45
      ),
      (
        icon: Icons.schedule_outlined,
        color: DreamColors.rose,
        radius: shortest * 0.36,
        offset: 3.7
      ),
      (
        icon: Icons.visibility_outlined,
        color: const Color(0xFFD8C5FF),
        radius: shortest * 0.30,
        offset: 4.9
      ),
    ];

    for (final symbol in symbols) {
      final angle = phase * math.pi * 2 + symbol.offset;
      final position =
          center + Offset(math.cos(angle), math.sin(angle)) * symbol.radius;
      final glowPaint = Paint()
        ..color = symbol.color.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(position, 18, glowPaint);
      _drawIcon(canvas, symbol.icon, position, symbol.color);
    }
  }

  void _drawIcon(Canvas canvas, IconData icon, Offset center, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: color,
          fontSize: 22,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
        canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _DreamOrbitPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
