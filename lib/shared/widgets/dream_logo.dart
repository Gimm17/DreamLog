import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';
import 'dream_log_mark.dart';

class DreamLogo extends StatelessWidget {
  const DreamLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DreamLogMark(size: compact ? 28 : 36),
        const SizedBox(width: 10),
        Text(
          'DreamLog',
          style: (compact ? textTheme.headlineMedium : textTheme.headlineLarge)
              ?.copyWith(color: DreamColors.textPrimary),
        ),
      ],
    );
  }
}
