import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_tokens.dart';
import '../../data/models/dream_symbol_catalog.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/dream_card.dart';
import '../../shared/widgets/section_label.dart';
import '../../shared/widgets/symbol_icon.dart';

class SymbolsScreen extends ConsumerWidget {
  const SymbolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbols = ref.watch(symbolsProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 42),
          children: [
            Text(
              'Symbols',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Recurring dream symbols from a curated ${dreamSymbolCatalog.length}-symbol taxonomy.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            const SectionLabel('Most Frequent'),
            const SizedBox(height: 16),
            if (symbols.isEmpty)
              DreamCard(
                color: DreamColors.surfaceTwo,
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    const Icon(
                      Icons.auto_awesome_outlined,
                      color: DreamColors.borderMuted,
                      size: 58,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No symbols yet',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save dreams from your own journal to build a real symbol library.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            else
              for (final symbol in symbols) ...[
                DreamCard(
                  gradient:
                      symbol == symbols.first ? DreamGradients.card : null,
                  color: symbol == symbols.first ? null : DreamColors.surface,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: DreamColors.primary.withValues(alpha: 0.24),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                            child: SymbolIcon(name: symbol.icon, size: 28)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    symbol.name,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: DreamColors.primaryLight
                                        .withValues(alpha: 0.18),
                                    borderRadius:
                                        BorderRadius.circular(DreamRadii.pill),
                                  ),
                                  child: Text(
                                    'x${symbol.frequency}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: DreamColors.primaryLight,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              symbol.meaning,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
          ],
        ),
      ),
    );
  }
}
