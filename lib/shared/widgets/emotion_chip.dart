import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class EmotionChip extends StatelessWidget {
  const EmotionChip({
    required this.label,
    super.key,
    this.compact = false,
  });

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = emotionColor(label);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 156 : 220),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 5 : 8,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          border: Border.all(color: color.withValues(alpha: 0.45)),
          borderRadius: BorderRadius.circular(DreamRadii.pill),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontSize: compact ? 12 : 13,
              ),
        ),
      ),
    );
  }
}
