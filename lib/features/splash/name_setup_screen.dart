import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_tokens.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/user_profile.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/dream_card.dart';
import '../../shared/widgets/gradient_button.dart';

class NameSetupScreen extends ConsumerStatefulWidget {
  const NameSetupScreen({super.key});

  @override
  ConsumerState<NameSetupScreen> createState() => _NameSetupScreenState();
}

class _NameSetupScreenState extends ConsumerState<NameSetupScreen> {
  final _controller = TextEditingController();
  var _didPrefill = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final profile =
        ref.watch(userProfileProvider).valueOrNull ?? UserProfile.defaults();
    final settings =
        ref.watch(appSettingsProvider).valueOrNull ?? AppSettings.defaults();

    if (!_didPrefill &&
        profile.name.trim().isNotEmpty &&
        profile.name != 'Dreamer') {
      _controller.text = profile.displayName;
      _didPrefill = true;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'Welcome to DreamLog',
                style: textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Personalize your journal before your first dream capture.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              DreamCard(
                color: DreamColors.surfaceTwo,
                child: TextField(
                  controller: _controller,
                  style: textTheme.titleMedium,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DreamCard(
                color: DreamColors.surface,
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Morning reminder at 06:30',
                        style: textTheme.bodyLarge?.copyWith(fontSize: 14),
                      ),
                    ),
                    Switch(
                      value: settings.reminderEnabled,
                      activeThumbColor: DreamColors.primaryLight,
                      onChanged: (value) => ref
                          .read(appSettingsProvider.notifier)
                          .updateReminderEnabled(value),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GradientButton(
                label: 'Enter DreamLog',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi nama dulu ya.')),
      );
      return;
    }
    await ref.read(userProfileProvider.notifier).completeOnboarding(name);
    if (mounted) {
      context.go('/');
    }
  }
}
