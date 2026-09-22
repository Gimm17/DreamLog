import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_tokens.dart';
import '../../data/models/dream_entry.dart';
import '../../data/models/dream_symbol.dart';
import '../../data/models/user_profile.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/dream_card.dart';
import '../../shared/widgets/emotion_chip.dart';
import '../../shared/widgets/profile_avatar.dart';
import '../../shared/widgets/section_label.dart';
import '../../shared/widgets/symbol_icon.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dreams = ref.watch(dreamJournalProvider);
    final profile =
        ref.watch(userProfileProvider).valueOrNull ?? UserProfile.defaults();
    final symbols = ref.watch(symbolsProvider);

    return Scaffold(
      body: dreams.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        data: (entries) => _HomeContent(
          entries: entries,
          profile: profile,
          topSymbol: symbols.isEmpty ? null : symbols.first,
          onReminderTap: () async {
            final notification = ref.read(notificationServiceProvider);
            await notification.initialize();
            await notification.showMorningReminderPreview();
          },
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.entries,
    required this.profile,
    required this.topSymbol,
    required this.onReminderTap,
  });

  final List<DreamEntry> entries;
  final UserProfile profile;
  final DreamSymbol? topSymbol;
  final VoidCallback onReminderTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lastDream = entries.isEmpty ? null : entries.first;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          DreamLayout.screenPadding,
          DreamLayout.screenTop,
          DreamLayout.screenPadding,
          DreamLayout.tabBottom,
        ),
        children: [
          Row(
            children: [
              ProfileAvatar(profile: profile, radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Good morning, ${profile.displayName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(
                    color: DreamColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: onReminderTap,
                icon: const Icon(Icons.notifications_none_outlined, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 42),
          Text(
            'Ready to explore your subconscious?',
            style: textTheme.headlineLarge?.copyWith(fontSize: 44),
          ),
          const SizedBox(height: 6),
          Text(
            'Ready to explore your subconscious?',
            style: textTheme.bodyMedium?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 36),
          DreamCard(
            gradient: DreamGradients.primary,
            radius: DreamRadii.xl,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 34),
            onTap: () => context.push('/new-dream'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.dark_mode_outlined,
                  color: DreamColors.textPrimary,
                  size: 42,
                ),
                const SizedBox(height: 34),
                Text(
                  "Record Last Night's Dream",
                  style: textTheme.headlineMedium?.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to capture before it fades',
                  style: textTheme.bodyMedium?.copyWith(
                    color: DreamColors.textPrimary.withValues(alpha: 0.72),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          const SectionLabel('Last Dream'),
          const SizedBox(height: DreamSpacing.labelGap),
          if (lastDream == null)
            const _EmptyLastDreamCard()
          else
            _LastDreamCard(entry: lastDream),
          const SizedBox(height: 36),
          const SectionLabel('Weekly Mood'),
          const SizedBox(height: DreamSpacing.labelGap),
          _WeeklyMoodStrip(entries: entries),
          const SizedBox(height: 36),
          if (topSymbol == null)
            const _EmptySymbolCard()
          else
            _SymbolOfTheDayCard(symbol: topSymbol!),
        ],
      ),
    );
  }
}

class _LastDreamCard extends StatelessWidget {
  const _LastDreamCard({required this.entry});

  final DreamEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DreamCard(
      gradient: DreamGradients.card,
      padding: EdgeInsets.zero,
      onTap: () => context.push('/dream/${entry.id}'),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: DreamColors.aurora,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(DreamRadii.lg),
                  bottomLeft: Radius.circular(DreamRadii.lg),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineMedium?.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      entry.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        EmotionChip(label: entry.primaryEmotion, compact: true),
                        _InfoPill(
                          icon: Icons.auto_awesome,
                          label: '${entry.symbols.length} symbols',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLastDreamCard extends StatelessWidget {
  const _EmptyLastDreamCard();

  @override
  Widget build(BuildContext context) {
    return DreamCard(
      color: DreamColors.surface,
      child: Text(
        'Your journal is ready for the first dream you remember.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _WeeklyMoodStrip extends StatelessWidget {
  const _WeeklyMoodStrip({required this.entries});

  final List<DreamEntry> entries;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final days =
        List.generate(7, (index) => weekStart.add(Duration(days: index)));

    return DreamCard(
      color: DreamColors.surfaceHigh,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final day in days) _MoodDay(day: day, entries: entries),
        ],
      ),
    );
  }
}

class _MoodDay extends StatelessWidget {
  const _MoodDay({required this.day, required this.entries});

  final DateTime day;
  final List<DreamEntry> entries;

  @override
  Widget build(BuildContext context) {
    final entry = _entryForDay(entries, day);
    final isToday = _sameDate(DateTime.now(), day);
    final color = entry == null
        ? DreamColors.surfaceTwo
        : emotionColor(entry.primaryEmotion);

    return Column(
      children: [
        Text(
          DateFormat.E().format(day).substring(0, 1),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isToday
                    ? DreamColors.textPrimary
                    : DreamColors.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          width: isToday ? 42 : 36,
          height: isToday ? 42 : 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isToday ? DreamColors.textPrimary : DreamColors.borderMuted,
              width: isToday ? 2 : 1,
            ),
            boxShadow: entry == null
                ? null
                : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.28),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
          ),
        ),
      ],
    );
  }
}

class _SymbolOfTheDayCard extends StatelessWidget {
  const _SymbolOfTheDayCard({required this.symbol});

  final DreamSymbol symbol;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DreamCard(
      gradient: DreamGradients.card,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: DreamColors.textSecondary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Center(child: SymbolIcon(name: symbol.icon, size: 30)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Symbol of the Day'),
                    const SizedBox(height: 6),
                    Text(
                      'The ${symbol.name}',
                      style: textTheme.titleMedium?.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            symbol.meaning,
            style: textTheme.bodyMedium?.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _EmptySymbolCard extends StatelessWidget {
  const _EmptySymbolCard();

  @override
  Widget build(BuildContext context) {
    return DreamCard(
      gradient: DreamGradients.card,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Symbol Tracker'),
          const SizedBox(height: DreamSpacing.labelGap),
          Text(
            'Your most frequent symbols will appear here after you save dreams.',
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: DreamColors.surfaceHigh,
        borderRadius: BorderRadius.circular(DreamRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: DreamColors.primaryLight),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

bool _sameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

DreamEntry? _entryForDay(List<DreamEntry> entries, DateTime day) {
  for (final entry in entries) {
    if (_sameDate(entry.createdAt, day)) {
      return entry;
    }
  }
  return null;
}
