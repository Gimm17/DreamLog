import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class DreamCard extends StatelessWidget {
  const DreamCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
    this.color,
    this.border,
    this.onTap,
    this.radius = DreamRadii.lg,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? color;
  final BoxBorder? border;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    // Registers a theme dependency so a palette swap repaints the card even
    // though the fallback below reads DreamColors statically.
    Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? color ?? DreamColors.surface : null,
        gradient: gradient,
        border: border,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
