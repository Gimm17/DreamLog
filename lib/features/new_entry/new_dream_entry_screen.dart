import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_tokens.dart';
import '../../data/models/dream_interpretation.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/gradient_button.dart';

class DreamDraft {
  const DreamDraft({
    required this.content,
    required this.date,
    required this.clarity,
    required this.interpretation,
  });

  final String content;
  final DateTime date;
  final double clarity;
  final DreamInterpretation interpretation;
}

class NewDreamEntryScreen extends ConsumerStatefulWidget {
  const NewDreamEntryScreen({super.key});

  @override
  ConsumerState<NewDreamEntryScreen> createState() =>
      _NewDreamEntryScreenState();
}

class _NewDreamEntryScreenState extends ConsumerState<NewDreamEntryScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  var _selectedDate = DateTime.now();
  var _clarity = 0.72;
  var _isRecording = false;
  var _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasContent = _controller.text.trim().isNotEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close, size: 32),
        ),
        title: Text(
          'New Dream',
          style: textTheme.titleMedium?.copyWith(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: hasContent ? _submit : null,
            child: Text(
              'Save',
              style: textTheme.labelLarge?.copyWith(
                color: hasContent
                    ? DreamColors.primaryLight
                    : DreamColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 140),
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: DreamColors.textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    '${_dateLabel(_selectedDate)}, ${DateFormat('EEE d MMM').format(_selectedDate)}',
                    style: textTheme.bodyMedium?.copyWith(fontSize: 16),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _changeDate,
                    child: Text(
                      'Change date',
                      style: textTheme.labelLarge?.copyWith(
                        color: DreamColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: DreamColors.surfaceTwo,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? DreamColors.primaryLight
                        : Colors.transparent,
                    width: 1.4,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  minLines: 9,
                  maxLines: 14,
                  onChanged: (_) => setState(() {}),
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    color: DreamColors.textPrimary,
                    height: 1.55,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText:
                        'What did you dream about last night? Describe everything you remember - people, places, feelings, symbols...',
                    hintStyle: textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                      color: const Color(0xFF596170),
                      height: 1.55,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 52),
              Row(
                children: [
                  const Expanded(
                      child: Divider(color: DreamColors.borderMuted)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Text(
                      'OR',
                      style: textTheme.labelMedium?.copyWith(
                        color: DreamColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const Expanded(
                      child: Divider(color: DreamColors.borderMuted)),
                ],
              ),
              const SizedBox(height: 28),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _toggleRecording,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: DreamColors.primaryLight,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording
                                      ? DreamColors.aurora
                                      : DreamColors.primaryLight)
                                  .withValues(alpha: 0.34),
                              blurRadius: _isRecording ? 34 : 24,
                              spreadRadius: _isRecording ? 10 : 0,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.mic, size: 32),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _isRecording
                          ? 'Recording... tap to stop'
                          : 'Tap to speak',
                      style: textTheme.bodyMedium?.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 56),
              Text(
                'How clear was this dream?',
                style: textTheme.bodyMedium?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment(
                  (_clarity * 2 - 1).clamp(-1.0, 1.0).toDouble(),
                  0,
                ),
                child: Text(
                  '${(_clarity * 100).round()}%',
                  style: textTheme.titleMedium
                      ?.copyWith(color: DreamColors.aurora),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: DreamColors.primaryLight,
                  inactiveTrackColor: DreamColors.surfaceTwo,
                  thumbColor: DreamColors.primaryLight,
                  overlayColor:
                      DreamColors.primaryLight.withValues(alpha: 0.16),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _clarity,
                  onChanged: (value) => setState(() => _clarity = value),
                ),
              ),
              Row(
                children: [
                  Text('Foggy', style: textTheme.bodyMedium),
                  const Spacer(),
                  Text('Crystal clear', style: textTheme.bodyMedium),
                ],
              ),
            ],
          ),
          Positioned(
            left: 28,
            right: 28,
            bottom: 24,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DreamColors.background.withValues(alpha: 0),
                    DreamColors.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_controller.text.length} characters',
                    style: textTheme.labelMedium?.copyWith(
                      color: DreamColors.textMuted,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GradientButton(
                    label:
                        _isSubmitting ? 'Interpreting...' : 'Interpret with AI',
                    icon: Icons.auto_awesome,
                    onPressed: hasContent && !_isSubmitting ? _submit : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleRecording() async {
    final speech = ref.read(speechServiceProvider);
    if (_isRecording) {
      await speech.stop();
      setState(() => _isRecording = false);
      return;
    }

    final ready = await speech.initialize();
    if (!ready) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Voice input permission is not available.')),
        );
      }
      return;
    }

    setState(() => _isRecording = true);
    await speech.listen(
      onText: (text) {
        _controller.text = text;
        setState(() {});
      },
      onDone: () {
        if (mounted) {
          setState(() => _isRecording = false);
        }
      },
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final service = ref.read(aiServiceProvider);
    final interpretation =
        await service.interpretDream(_controller.text.trim());
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    context.push(
      '/ai-result',
      extra: DreamDraft(
        content: _controller.text.trim(),
        date: _selectedDate,
        clarity: _clarity,
        interpretation: interpretation,
      ),
    );
  }

  Future<void> _changeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }
}

String _dateLabel(DateTime date) {
  final now = DateTime.now();
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Today';
  }
  return DateFormat('d MMM yyyy').format(date);
}
