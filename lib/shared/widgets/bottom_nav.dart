import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class DreamBottomNav extends StatelessWidget {
  const DreamBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
    this.enabled = true,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final items = [
      const _NavItem('Home', Icons.dark_mode_outlined),
      const _NavItem('Journal', Icons.menu_book_outlined),
      const _NavItem('Insights', Icons.psychology_outlined),
      const _NavItem('Symbols', Icons.auto_awesome_motion_outlined),
      const _NavItem('Profile', Icons.settings_outlined),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: const BoxDecoration(
          color: DreamColors.surfaceHigh,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < items.length; i++)
              _NavButton(
                item: items[i],
                active: currentIndex == i,
                onTap: enabled ? () => onTap(i) : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DreamRadii.pill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
          decoration: BoxDecoration(
            color: active ? DreamColors.primary.withValues(alpha: 0.26) : null,
            borderRadius: BorderRadius.circular(DreamRadii.pill),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 1, end: active ? 1.06 : 1),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: Icon(
                    item.icon,
                    key: ValueKey('${item.label}-$active'),
                    color: active
                        ? DreamColors.primaryLight
                        : DreamColors.textSecondary,
                    size: active ? 25 : 24,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: active
                            ? const Color(0xFFD8C5FF)
                            : DreamColors.textSecondary,
                        fontSize: 10.5,
                        height: 1,
                        letterSpacing: 0,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(item.label, maxLines: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
