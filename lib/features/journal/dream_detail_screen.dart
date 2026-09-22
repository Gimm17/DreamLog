import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_tokens.dart';
import '../../data/models/dream_entry.dart';
import '../../data/services/export_service.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/dream_card.dart';
import '../../shared/widgets/emotion_chip.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/section_label.dart';
import '../../shared/widgets/symbol_icon.dart';

class DreamDetailScreen extends ConsumerWidget {
  const DreamDetailScreen({required this.dreamId, super.key});

  final String dreamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(dreamByIdProvider(dreamId));
    if (entry == null) {
      return const Scaffold(body: Center(child: Text('Dream not found')));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            actions: [
              IconButton(
                onPressed: () => ref
                    .read(dreamJournalProvider.notifier)
                    .toggleBookmark(entry.id),
                icon: Icon(
                  entry.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                ),
              ),
              IconButton(
                onPressed: () => _showShareOptions(context, ref, entry),
                icon: const Icon(Icons.share_outlined),
              ),
              IconButton(
                onPressed: () => context.push('/dream/${entry.id}/edit'),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: () => _confirmDelete(context, ref, entry),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                entry.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DreamColors.background,
                      DreamColors.surface,
                      const Color(0x336B46C1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.dark_mode_outlined,
                    color: DreamColors.primaryLight,
                    size: 88,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DreamLayout.screenPadding,
                DreamLayout.screenTop,
                DreamLayout.screenPadding,
                DreamLayout.tabBottom,
              ),
              child: _DetailContent(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.entry});

  final DreamEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final interpretation = entry.interpretation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.title,
          style: textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '${DateFormat('EEEE, d MMM - hh:mm a').format(entry.createdAt)} - Clarity ${(entry.clarity * 100).round()}%',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        EmotionChip(label: entry.primaryEmotion),
        const SizedBox(height: 28),
        DreamCard(
          gradient: DreamGradients.card,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('The Dream'),
              const SizedBox(height: 16),
              Text(
                entry.content,
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        DreamCard(
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
                  height: 1.75,
                ),
              ),
              const SizedBox(height: 18),
              Divider(color: DreamColors.borderMuted),
              const SizedBox(height: 12),
              Text(
                interpretation.reflectionQuestion,
                style:
                    textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const SectionLabel('Detected Symbols'),
        const SizedBox(height: DreamSpacing.labelGap),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: entry.symbols.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final symbol = entry.symbols[index];
              return SizedBox(
                width: 96,
                child: DreamCard(
                  color: DreamColors.surfaceTwo,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SymbolIcon(name: symbol, size: 34),
                      const SizedBox(height: 12),
                      Text(
                        symbol,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 26),
        const SectionLabel('Emotions'),
        const SizedBox(height: DreamSpacing.labelGap),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            EmotionChip(label: entry.primaryEmotion),
            for (final emotion in interpretation.secondaryEmotions)
              EmotionChip(label: emotion, compact: true),
          ],
        ),
        const SizedBox(height: 26),
        DreamCard(
          color: DreamColors.surfaceTwo,
          child: Row(
            children: [
              const Icon(Icons.ios_share_outlined,
                  color: DreamColors.primaryLight),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Enhance this dream into a social card or story image',
                  style: textTheme.bodyLarge?.copyWith(fontSize: 14),
                ),
              ),
              GradientButton(
                label: 'Share',
                fullWidth: false,
                height: 44,
                onPressed: () async {
                  await _showShareOptions(context, ref, entry);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _showShareOptions(
  BuildContext context,
  WidgetRef ref,
  DreamEntry entry,
) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: DreamColors.surfaceTwo,
    builder: (sheetContext) {
      void closeAndRun(Future<void> Function() action) {
        Navigator.of(sheetContext).pop();
        unawaited(
          Future<void>.delayed(const Duration(milliseconds: 180), () async {
            if (!context.mounted) {
              return;
            }
            await action();
          }),
        );
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: DreamColors.borderMuted,
                  borderRadius: BorderRadius.circular(DreamRadii.pill),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('Enhance for Story'),
                subtitle: const Text(
                    '9:16 PNG for Instagram, WhatsApp, Facebook stories'),
                onTap: () => closeAndRun(
                  () => _shareDreamImage(
                    context,
                    ref,
                    entry,
                    format: DreamShareFormat.story,
                    chooserTitle: 'Share DreamLog story',
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.grid_view_outlined),
                title: const Text('Share Social Card'),
                subtitle: const Text('4:5 PNG for feeds and posts'),
                onTap: () => closeAndRun(
                  () => _shareDreamImage(
                    context,
                    ref,
                    entry,
                    format: DreamShareFormat.socialCard,
                    chooserTitle: 'Share DreamLog card',
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Share PDF'),
                subtitle: const Text('Full dream text and AI interpretation'),
                onTap: () => closeAndRun(
                  () => _shareDreamPdf(context, ref, entry),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _shareDreamImage(
  BuildContext context,
  WidgetRef ref,
  DreamEntry entry, {
  required DreamShareFormat format,
  required String chooserTitle,
}) async {
  _showShareSnackBar(
    context,
    'Preparing share image...',
    duration: const Duration(seconds: 30),
  );

  File? file;
  try {
    file = await ref
        .read(exportServiceProvider)
        .createDreamShareImage(entry, format: format)
        .timeout(const Duration(seconds: 20));
    await ref
        .read(shareServiceProvider)
        .shareFile(
          file: file,
          mimeType: 'image/png',
          chooserTitle: chooserTitle,
          text: '${entry.title} - shared from DreamLog',
        )
        .timeout(const Duration(seconds: 12));
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    final savedPath = file == null ? '' : '\nSaved image: ${file.path}';
    _showShareSnackBar(
      context,
      'Share image failed: ${_shareErrorMessage(error)}$savedPath',
    );
  }
}

Future<void> _shareDreamPdf(
  BuildContext context,
  WidgetRef ref,
  DreamEntry entry,
) async {
  _showShareSnackBar(
    context,
    'Preparing PDF...',
    duration: const Duration(seconds: 30),
  );

  File? file;
  try {
    file = await ref
        .read(exportServiceProvider)
        .shareDreamPdf(entry)
        .timeout(const Duration(seconds: 20));
    await ref
        .read(shareServiceProvider)
        .shareFile(
          file: file,
          mimeType: 'application/pdf',
          chooserTitle: 'Share DreamLog PDF',
          text: '${entry.title} - shared from DreamLog',
        )
        .timeout(const Duration(seconds: 12));
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    final savedPath = file == null ? '' : '\nSaved PDF: ${file.path}';
    _showShareSnackBar(
      context,
      'Share PDF failed: ${_shareErrorMessage(error)}$savedPath',
    );
  }
}

void _showShareSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 6),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
    ),
  );
}

String _shareErrorMessage(Object error) {
  if (error is TimeoutException) {
    return 'Share sheet took too long to respond.';
  }
  if (error is PlatformException) {
    return error.message ?? error.code;
  }
  final message = error.toString().replaceFirst('Exception: ', '');
  return message.isEmpty ? 'Unknown error.' : message;
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  DreamEntry entry,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete this dream?'),
      content: Text(
        '"${entry.title}" will be removed from this device. This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed != true) {
    return;
  }
  await ref.read(dreamJournalProvider.notifier).deleteEntry(entry.id);
  if (context.mounted) {
    context.pop();
  }
}

