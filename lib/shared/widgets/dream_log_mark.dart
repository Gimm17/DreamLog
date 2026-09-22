import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class DreamLogMark extends StatelessWidget {
  const DreamLogMark({
    super.key,
    this.size = 36,
    this.background = true,
  });

  final double size;
  final bool background;

  @override
  Widget build(BuildContext context) {
    // The painter reads DreamColors statically, which is invisible to Flutter's
    // dependency system, so the palette is threaded in as a repaint key.
    Theme.of(context);
    return CustomPaint(
      size: Size.square(size),
      painter: _DreamLogMarkPainter(
        background: background,
        palette: DreamColors.palette,
      ),
    );
  }
}

class _DreamLogMarkPainter extends CustomPainter {
  const _DreamLogMarkPainter({
    required this.background,
    required this.palette,
  });

  final bool background;
  final DreamPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shortest = math.min(size.width, size.height);

    if (background) {
      final radius = shortest * 0.27;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        Paint()
          ..shader = LinearGradient(
            colors: [
              palette.surface,
              palette.background,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(rect),
      );
    }

    final center = rect.center;
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = shortest * 0.045
      ..strokeCap = StrokeCap.round
      ..color = DreamColors.aurora.withValues(alpha: 0.86);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.58);
    final orbitRect = Rect.fromCenter(
      center: Offset.zero,
      width: shortest * 0.74,
      height: shortest * 0.42,
    );
    canvas.drawArc(orbitRect, -0.10, math.pi * 1.34, false, orbitPaint);
    canvas.restore();

    final moonOuter = Path()
      ..addOval(
        Rect.fromCircle(
          center: center.translate(-shortest * 0.04, -shortest * 0.01),
          radius: shortest * 0.22,
        ),
      );
    final moonCut = Path()
      ..addOval(
        Rect.fromCircle(
          center: center.translate(shortest * 0.07, -shortest * 0.05),
          radius: shortest * 0.22,
        ),
      );
    final crescent = Path.combine(PathOperation.difference, moonOuter, moonCut);

    canvas.drawPath(
      crescent,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            DreamColors.textPrimary,
            Color(0xFFD8C5FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );

    _drawSpark(
      canvas,
      center.translate(shortest * 0.25, -shortest * 0.27),
      shortest * 0.075,
      DreamColors.gold,
    );
    _drawSpark(
      canvas,
      center.translate(-shortest * 0.25, shortest * 0.24),
      shortest * 0.050,
      DreamColors.primaryLight,
    );
  }

  void _drawSpark(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (var index = 0; index < 8; index++) {
      final angle = (math.pi / 4) * index;
      final distance = index.isEven ? radius : radius * 0.32;
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _DreamLogMarkPainter oldDelegate) {
    return oldDelegate.background != background ||
        oldDelegate.palette != palette;
  }
}
