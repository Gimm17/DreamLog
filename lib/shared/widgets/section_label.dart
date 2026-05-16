import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: DreamColors.textSecondary,
            letterSpacing: 1.8,
          ),
    );
  }
}
