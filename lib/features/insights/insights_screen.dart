import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_tokens.dart';
import '../../data/models/dream_entry.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/dream_card.dart';
import '../../shared/widgets/section_label.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries =
        ref.watch(dreamJournalProvider).valueOrNull ?? const <DreamEntry>[];
    final report = entries.isEmpty ? null : ref.watch(weeklyReportProvider);
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 6));
    final weekRange =
        '${DateFormat('MMM d').format(weekStart)}-${DateFormat('d').format(now)}';
    final recordedDays = _daysRecordedThisWeek(entries, now);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 44),
          children: [
            Row(
              children: [
                Text('Insights',
                    style: Theme.of(context).textTheme.headlineLarge),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: DreamColors.surfaceTwo,
                    borderRadius: BorderRadius.circular(DreamRadii.pill),
                  ),
                  child: Row(
                    children: [
                      Text(DateFormat('MMMM yyyy').format(now)),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 56),
            if (entries.isEmpty)
              const _EmptyWeeklyReportCard()
            else
              report!.when(
                loading: () => const DreamCard(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) =>
                    DreamCard(child: Text(error.toString())),
                data: (value) => DreamCard(
                  gradient: DreamGradients.card,
                  radius: 22,
                  padding: EdgeInsets.zero,
                  onTap: () => context.push('/weekly-report'),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Container(
                          width: 5,
                          decoration: const BoxDecoration(
                            gradient: DreamGradients.aurora,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(22),
                              bottomLeft: Radius.circular(22),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const SectionLabel('Weekly Report'),
                                    const Spacer(),
                                    Text(
                                      weekRange,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Text(
                                  value.dominantTheme,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontSize: 32),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  value.weekSummary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontSize: 16),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Read Full Report',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: DreamColors.primaryLight,
                                        fontSize: 16,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 36),
            const SectionLabel('Top Emotions This Month'),
            const SizedBox(height: 18),
            _EmotionBars(entries: entries),
            const SizedBox(height: 36),
            const SectionLabel('Mood Calendar'),
            const SizedBox(height: 18),
            _MoodCalendar(entries: entries),
            const SizedBox(height: 36),
            const SectionLabel('Recurring Symbols'),
            const SizedBox(height: 18),
            _RecurringSymbols(),
            const SizedBox(height: 36),
            DreamCard(
              gradient: const LinearGradient(
                colors: [DreamColors.gold, DreamColors.rose],
              ),
              child: Column(
                children: [
                  Text(
                    '$recordedDays days',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontStyle: FontStyle.normal),
                  ),
                  Text(
                    recordedDays == 0
                        ? 'Record dreams this week to unlock deeper insights.'
                        : 'Recorded from your real journal this week.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              DreamColors.textPrimary.withValues(alpha: 0.78),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWeeklyReportCard extends StatelessWidget {
  const _EmptyWeeklyReportCard();

  @override
  Widget build(BuildContext context) {
    return DreamCard(
      gradient: DreamGradients.card,
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Weekly Report'),
          const SizedBox(height: 18),
          Text(
            'No report yet',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 12),
          Text(
            'Save your first dream to generate insights from real journal data.',
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _EmotionBars extends StatelessWidget {
  const _EmotionBars({required this.entries});

  final List<DreamEntry> entries;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final emotion = entry.primaryEmotion.trim();
      if (emotion.isEmpty) {
        continue;
      }
      counts.update(emotion, (value) => value + 1, ifAbsent: () => 1);
    }
    final total = counts.values.fold<int>(0, (sum, value) => sum + value);
    final rows = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (rows.isEmpty || total == 0) {
      return DreamCard(
        color: DreamColors.surfaceTwo,
        child: Text(
          'Emotion patterns will appear after you save dreams.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      children: [
        for (final row in rows.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                SizedBox(
                  width: 112,
                  child: Text(
                    row.key,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(DreamRadii.pill),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: row.value / total,
                      backgroundColor: DreamColors.surfaceTwo,
                      color: emotionColor(row.key),
                    ),
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    '${((row.value / total) * 100).round()}%',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MoodCalendar extends StatelessWidget {
  const _MoodCalendar({required this.entries});

  final List<DreamEntry> entries;

  @override
  Widget build(BuildContext context) {
    final days = List.generate(35, (index) => index + 1);
    return DreamCard(
      color: DreamColors.surfaceTwo,
      padding: const EdgeInsets.all(18),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: days.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 12,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final day = days[index];
          final entry =
              entries.where((item) => item.createdAt.day == day).firstOrNull;
          final color = entry == null
              ? Colors.transparent
              : emotionColor(entry.primaryEmotion);
          return Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: entry == null ? DreamColors.borderMuted : color,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: entry == null
                        ? DreamColors.textMuted
                        : DreamColors.background,
                    letterSpacing: 0,
                  ),
            ),
          );
        },
      ),
    );
  }
}

class _RecurringSymbols extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbols = ref.watch(symbolsProvider).take(6).toList();
    if (symbols.isEmpty) {
      return DreamCard(
        color: DreamColors.surfaceTwo,
        child: Text(
          'Recurring symbols will appear here after saved dreams are analyzed.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: symbols.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final symbol = symbols[index];
        return DreamCard(
          color: DreamColors.surfaceTwo,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: DreamColors.primaryLight),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  symbol.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Text(
                'x${symbol.frequency}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: DreamColors.primaryLight,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

int _daysRecordedThisWeek(List<DreamEntry> entries, DateTime now) {
  final start = DateTime(now.year, now.month, now.day).subtract(
    const Duration(days: 6),
  );
  final days = <String>{};
  for (final entry in entries) {
    final day = DateTime(
      entry.createdAt.year,
      entry.createdAt.month,
      entry.createdAt.day,
    );
    if (day.isBefore(start)) {
      continue;
    }
    days.add('${day.year}-${day.month}-${day.day}');
  }
  return days.length;
}
