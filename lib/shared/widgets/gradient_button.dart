import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.height = 56,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final labelWidget = Text(
      label,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: DreamColors.textPrimary,
            fontSize: 15,
          ),
    );

    return Opacity(
      opacity: disabled ? 0.48 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: disabled ? null : DreamGradients.primary,
          color: disabled ? DreamColors.surfaceTwo : null,
          borderRadius: BorderRadius.circular(DreamRadii.pill),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: DreamColors.primary.withValues(alpha: 0.34),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(DreamRadii.pill),
            child: SizedBox(
              width: fullWidth ? double.infinity : null,
              height: height,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: fullWidth ? 0 : 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: DreamColors.textPrimary, size: 20),
                      const SizedBox(width: 10),
                    ],
                    if (fullWidth)
                      Flexible(child: labelWidget)
                    else
                      labelWidget,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
