import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_tokens.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/dream_interpretation.dart';
import '../../data/services/speech_service.dart';
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
  const NewDreamEntryScreen({super.key, this.editingId});

  /// When set, the screen edits this saved dream instead of creating one.
  final String? editingId;

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

  /// Defaults to the app language, but stays independently switchable.
  var _recordingLanguage = AppSettings.defaults().language;
  var _didInitRecordingLanguage = false;

  /// Text already in the field when recording starts. The recognizer reports
  /// the whole session, so this prefix stops partial results from wiping what
  /// the user typed before tapping the mic.
  var _textBeforeRecording = '';

  bool get _isEditing => widget.editingId != null;

  @override
  void initState() {
    super.initState();
    final id = widget.editingId;
    if (id == null) {
      return;
    }
    // Post-frame: the journal controller may still be loading on cold start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final entry = ref.read(dreamByIdProvider(id));
      if (entry == null) {
        return;
      }
      setState(() {
        _controller.text = entry.content;
        _selectedDate = entry.createdAt;
        _clarity = entry.clarity;
      });
    });
  }

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

    if (!_didInitRecordingLanguage) {
      final appLanguage =
          ref.watch(appSettingsProvider).valueOrNull?.language;
      if (appLanguage != null && speechLocaleIds.containsKey(appLanguage)) {
        _recordingLanguage = appLanguage;
        _didInitRecordingLanguage = true;
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close, size: 32),
        ),
        title: Text(
          _isEditing ? 'Edit Dream' : 'New Dream',
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
            padding: const EdgeInsets.fromLTRB(
              DreamLayout.screenPadding,
              DreamLayout.screenTop,
              DreamLayout.screenPadding,
              DreamLayout.dockedBarBottom,
            ),
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
                  borderRadius: BorderRadius.circular(DreamRadii.xl),
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
                  // 7 rather than 9: the recording block below needs to clear
                  // the docked action bar on a short screen.
                  minLines: 7,
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
              const SizedBox(height: 34),
              Row(
                children: [
                  Expanded(
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
                  Expanded(
                      child: Divider(color: DreamColors.borderMuted)),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    // Above the mic, not below it: the docked action bar
                    // overlays the bottom of this scroll view and would cover
                    // anything placed under the button.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final language in speechLocaleIds.keys)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ChoiceChip(
                              label: Text(language),
                              selected: _recordingLanguage == language,
                              onSelected: _isRecording
                                  ? null
                                  : (_) => setState(
                                        () => _recordingLanguage = language,
                                      ),
                              backgroundColor: Colors.transparent,
                              selectedColor: DreamColors.primaryLight,
                              side: BorderSide(
                                  color: DreamColors.borderMuted),
                              showCheckmark: false,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
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
                          ? 'Recording in $_recordingLanguage... tap to stop'
                          : 'Tap to speak in $_recordingLanguage',
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
            left: DreamLayout.screenPadding,
            right: DreamLayout.screenPadding,
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
                    label: switch ((_isEditing, _isSubmitting)) {
                      (true, _) => 'Save Changes',
                      (false, true) => 'Interpreting...',
                      (false, false) => 'Interpret with AI',
                    },
                    icon: _isEditing ? Icons.check : Icons.auto_awesome,
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

    final ready = await speech.initialize(
      appLanguage: _recordingLanguage,
    );
    if (!ready) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Voice input is unavailable. Check the microphone permission.',
            ),
          ),
        );
      }
      return;
    }

    _textBeforeRecording = _controller.text;
    setState(() => _isRecording = true);
    await speech.listen(
      onText: (text) {
        if (!mounted) {
          return;
        }
        // Append rather than replace: the recognizer reports only its own
        // session, so assigning directly would delete earlier writing.
        final prefix = _textBeforeRecording;
        final separator =
            prefix.isEmpty || prefix.endsWith(' ') || text.isEmpty ? '' : ' ';
        _controller.text = '$prefix$separator$text';
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
        setState(() {});
      },
      onDone: () {
        if (mounted) {
          setState(() => _isRecording = false);
        }
      },
      onError: (error) {
        if (!mounted) {
          return;
        }
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice input stopped: $error')),
        );
      },
    );
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    final editingId = widget.editingId;
    if (editingId != null) {
      await ref.read(dreamJournalProvider.notifier).updateEntry(
            id: editingId,
            content: content,
            date: _selectedDate,
            clarity: _clarity,
          );
      if (mounted) {
        context.pop();
      }
      return;
    }

    setState(() => _isSubmitting = true);
    final service = ref.read(aiServiceProvider);
    final interpretation = await service.interpretDream(content);
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    context.push(
      '/ai-result',
      extra: DreamDraft(
        content: content,
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
