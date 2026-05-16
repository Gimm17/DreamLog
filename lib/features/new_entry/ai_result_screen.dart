import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_tokens.dart';
import '../../data/models/dream_interpretation.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/dream_card.dart';
import '../../shared/widgets/emotion_chip.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/section_label.dart';
import '../../shared/widgets/symbol_icon.dart';
import 'new_dream_entry_screen.dart';

class AIResultScreen extends ConsumerWidget {
  const AIResultScreen({required this.draft, super.key});

  final DreamDraft? draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedDraft = draft;
    if (resolvedDraft == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/new-dream'),
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('AI Result'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: DreamCard(
              color: DreamColors.surfaceTwo,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.edit_note_outlined,
                    color: DreamColors.primaryLight,
                    size: 58,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No dream draft found',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Write a dream first to generate an interpretation.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 22),
                  GradientButton(
                    label: 'Write Dream',
                    onPressed: () => context.go('/new-dream'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final interpretation = resolvedDraft.interpretation;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 132),
              children: [
                IconButton(
                  alignment: Alignment.centerLeft,
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [DreamColors.surface, DreamColors.background],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Interpreted just now',
                        style: textTheme.labelMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _titleFor(interpretation),
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(fontSize: 30),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${DateFormat('EEEE, d MMM yyyy').format(resolvedDraft.date)} - Clarity ${(resolvedDraft.clarity * 100).round()}%',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 18),
                      EmotionChip(label: interpretation.primaryEmotion),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _InterpretationCard(interpretation: interpretation),
                const SizedBox(height: 18),
                _SymbolsCard(symbols: interpretation.symbols),
                const SizedBox(height: 18),
                _SecondaryEmotions(emotions: interpretation.secondaryEmotions),
                const SizedBox(height: 18),
                DreamCard(
                  color: DreamColors.background,
                  border: Border.all(
                      color: DreamColors.aurora.withValues(alpha: 0.7)),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.help_outline,
                        color: DreamColors.primaryLight,
                        size: 44,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        interpretation.reflectionQuestion,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          fontSize: 20,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 20,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: DreamColors.primaryLight),
                        minimumSize: const Size.fromHeight(54),
                      ),
                      child: const Text('Back to Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      label: 'Save Dream',
                      fullWidth: true,
                      onPressed: () async {
                        await ref
                            .read(dreamJournalProvider.notifier)
                            .addInterpretedDream(
                              content: resolvedDraft.content,
                              date: resolvedDraft.date,
                              clarity: resolvedDraft.clarity,
                              interpretation: resolvedDraft.interpretation,
                            );
                        if (context.mounted) {
                          context.go('/journal');
                        }
                      },
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

class _InterpretationCard extends StatelessWidget {
  const _InterpretationCard({required this.interpretation});

  final DreamInterpretation interpretation;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DreamCard(
      gradient: DreamGradients.card,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('AI Interpretation'),
          const SizedBox(height: 16),
          Text(
            interpretation.interpretation,
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 18,
              height: 1.72,
            ),
          ),
          const SizedBox(height: 22),
          Container(
              height: 1, color: DreamColors.aurora.withValues(alpha: 0.55)),
          const SizedBox(height: 16),
          Text(
            'Reflection question: ${interpretation.reflectionQuestion}',
            style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _SymbolsCard extends StatelessWidget {
  const _SymbolsCard({required this.symbols});

  final List<String> symbols;

  @override
  Widget build(BuildContext context) {
    return DreamCard(
      color: DreamColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Symbols Detected'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final symbol in symbols)
                ActionChip(
                  backgroundColor: DreamColors.surfaceTwo,
                  side: BorderSide.none,
                  avatar: SymbolIcon(name: symbol, size: 18),
                  label: Text(symbol),
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: DreamColors.surfaceTwo,
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '$symbol points to a recurring subconscious image worth tracking across future dreams.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecondaryEmotions extends StatelessWidget {
  const _SecondaryEmotions({required this.emotions});

  final List<String> emotions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Also detected:', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final emotion in emotions) ...[
                  EmotionChip(label: emotion, compact: true),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _titleFor(DreamInterpretation interpretation) {
  if (interpretation.symbols.isEmpty) {
    return 'Dream Analysis';
  }
  return 'The ${interpretation.symbols.first} Dream';
}
