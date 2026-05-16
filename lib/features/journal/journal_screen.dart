import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_tokens.dart';
import '../../data/models/dream_entry.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/clarity_bar.dart';
import '../../shared/widgets/dream_card.dart';
import '../../shared/widgets/dream_logo.dart';
import '../../shared/widgets/emotion_chip.dart';
import '../../shared/widgets/gradient_button.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  var _filter = 'All Dreams';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dreams = ref.watch(dreamJournalProvider);
    return Scaffold(
      body: SafeArea(
        child: dreams.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
          data: (entries) {
            final filtered = _filtered(entries);
            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 128),
                  children: [
                    Row(
                      children: [
                        const DreamLogo(),
                        const Spacer(),
                        IconButton(
                          onPressed: _searchFocusNode.requestFocus,
                          icon: const Icon(Icons.search, size: 32),
                        ),
                        IconButton(
                          onPressed: _showFilterSheet,
                          icon: const Icon(Icons.filter_list, size: 32),
                        ),
                      ],
                    ),
                    const SizedBox(height: 54),
                    Text(
                      'My Dreams',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search dreams...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final label in const [
                            'All Dreams',
                            'Positive',
                            'Negative',
                            'Neutral',
                            'Bookmarked',
                          ])
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: FilterChip(
                                label: Text(label),
                                selected: _filter == label,
                                onSelected: (_) =>
                                    setState(() => _filter = label),
                                backgroundColor: Colors.transparent,
                                selectedColor: DreamColors.primaryLight,
                                side: const BorderSide(
                                    color: DreamColors.borderMuted),
                                labelStyle: TextStyle(
                                  color: _filter == label
                                      ? DreamColors.textPrimary
                                      : DreamColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      DateFormat('MMMM yyyy')
                          .format(DateTime.now())
                          .toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            letterSpacing: 1.8,
                          ),
                    ),
                    const SizedBox(height: 18),
                    if (filtered.isEmpty)
                      const _EmptyJournal()
                    else
                      for (final entry in filtered) ...[
                        _DreamListCard(entry: entry),
                        const SizedBox(height: 18),
                      ],
                  ],
                ),
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: GradientButton(
                    label: 'New Dream',
                    icon: Icons.edit_outlined,
                    fullWidth: false,
                    onPressed: () => context.push('/new-dream'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showFilterSheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: DreamColors.surfaceTwo,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final label in const [
                  'All Dreams',
                  'Positive',
                  'Negative',
                  'Neutral',
                  'Bookmarked',
                ])
                  ListTile(
                    title: Text(label),
                    trailing: _filter == label ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.of(context).pop(label),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _filter = selected);
    }
  }

  List<DreamEntry> _filtered(List<DreamEntry> entries) {
    final query = _searchController.text.trim().toLowerCase();
    return entries.where((entry) {
      final matchesSearch = query.isEmpty ||
          entry.title.toLowerCase().contains(query) ||
          entry.content.toLowerCase().contains(query) ||
          entry.symbols.any((symbol) => symbol.toLowerCase().contains(query));

      final mood = entry.primaryEmotion.toLowerCase();
      final matchesFilter = switch (_filter) {
        'Positive' => mood.contains('peace') || mood.contains('joy'),
        'Negative' =>
          mood.contains('anx') || mood.contains('fear') || mood.contains('sad'),
        'Neutral' => mood.contains('neutral'),
        'Bookmarked' => entry.isBookmarked,
        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }
}

class _DreamListCard extends ConsumerWidget {
  const _DreamListCard({required this.entry});

  final DreamEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = emotionColor(entry.primaryEmotion);
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
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
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
                    Row(
                      children: [
                        Text(
                          DateFormat('dd - EEEE').format(entry.createdAt),
                          style: textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        EmotionChip(label: entry.primaryEmotion, compact: true),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineMedium?.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            size: 18, color: DreamColors.primaryLight),
                        const SizedBox(width: 6),
                        Text('${entry.symbols.length} symbols',
                            style: textTheme.bodyMedium),
                        const Spacer(),
                        ClarityBar(value: entry.clarity),
                        const Spacer(),
                        IconButton(
                          onPressed: () => ref
                              .read(dreamJournalProvider.notifier)
                              .toggleBookmark(entry.id),
                          icon: Icon(
                            entry.isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border_outlined,
                            color: DreamColors.primaryLight,
                          ),
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

class _EmptyJournal extends StatelessWidget {
  const _EmptyJournal();

  @override
  Widget build(BuildContext context) {
    return DreamCard(
      color: DreamColors.surfaceTwo,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.dark_mode_outlined,
              size: 72, color: DreamColors.borderMuted),
          const SizedBox(height: 18),
          Text(
            'Your dream journal is empty',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'Record your first dream to begin your journey.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          GradientButton(
            label: 'Record Now',
            onPressed: () => context.push('/new-dream'),
          ),
        ],
      ),
    );
  }
}
