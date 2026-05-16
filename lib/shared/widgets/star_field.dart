import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class StarField extends StatelessWidget {
  const StarField({super.key, this.child, this.density = 20});

  final Widget? child;
  final int density;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarFieldPainter(density),
      child: child,
    );
  }
}

class AnimatedStarField extends StatelessWidget {
  const AnimatedStarField({
    required this.animation,
    super.key,
    this.child,
    this.density = 28,
  });

  final Animation<double> animation;
  final Widget? child;
  final int density;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _AnimatedStarFieldPainter(
            density: density,
            phase: animation.value,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  _StarFieldPainter(this.density);

  final int density;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DreamColors.textPrimary.withValues(alpha: 0.22);
    final random = math.Random(14);
    for (var i = 0; i < density; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = 1.1 + random.nextDouble() * 2.4;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) {
    return oldDelegate.density != density;
  }
}

class _AnimatedStarFieldPainter extends CustomPainter {
  _AnimatedStarFieldPainter({
    required this.density,
    required this.phase,
  });

  final int density;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(31);
    for (var i = 0; i < density; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final drift = math.sin((phase * math.pi * 2) + i) * 6;
      final twinkle =
          0.12 + (math.sin((phase * math.pi * 2) + i * 0.7) + 1) * 0.12;
      final radius = 0.8 + random.nextDouble() * 2.2;
      final paint = Paint()
        ..color = DreamColors.textPrimary.withValues(alpha: twinkle);
      canvas.drawCircle(
        Offset(
            (baseX + drift) % size.width, (baseY + drift * 0.4) % size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedStarFieldPainter oldDelegate) {
    return oldDelegate.density != density || oldDelegate.phase != phase;
  }
}
