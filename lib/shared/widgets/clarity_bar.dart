import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class ClarityBar extends StatelessWidget {
  const ClarityBar({required this.value, super.key, this.width = 70});

  final double value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DreamRadii.pill),
        child: Stack(
          children: [
            const ColoredBox(
              color: Color(0xFF282638),
              child: SizedBox.expand(),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0).toDouble(),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: DreamColors.aurora,
                  borderRadius:
                      BorderRadius.all(Radius.circular(DreamRadii.pill)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
