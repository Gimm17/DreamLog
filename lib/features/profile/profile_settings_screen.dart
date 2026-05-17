import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_tokens.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/dream_entry.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/import_service.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/dream_card.dart';
import '../../shared/widgets/profile_avatar.dart';
import '../../shared/widgets/section_label.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final profile =
        ref.watch(userProfileProvider).valueOrNull ?? UserProfile.defaults();
    final settings =
        ref.watch(appSettingsProvider).valueOrNull ?? AppSettings.defaults();
    final entries = ref.watch(dreamJournalProvider).valueOrNull ?? const [];
    final symbolCount = entries.fold<int>(
      0,
      (total, entry) => total + entry.symbols.length,
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 42),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [DreamColors.background, Color(0xFF1A1730)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        ProfileAvatar(profile: profile, radius: 42),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: DreamColors.surfaceTwo,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _editName(profile),
                    child: Text(
                      profile.displayName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dream Explorer - ${_streakDays(entries)} day streak',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _StatCard(value: '${entries.length}', label: 'Total Dreams'),
                const SizedBox(width: 10),
                _StatCard(value: '$symbolCount', label: 'Symbols Found'),
                const SizedBox(width: 10),
                _StatCard(
                    value: '${_weeksTracked(entries)}', label: 'Weeks Tracked'),
              ],
            ),
            const SizedBox(height: 30),
            const SectionLabel('Reminders'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: 'Morning Reminder',
              trailing: Switch(
                value: settings.reminderEnabled,
                activeThumbColor: DreamColors.primaryLight,
                onChanged: _toggleReminder,
              ),
            ),
            _SettingsTile(
              icon: Icons.schedule_outlined,
              title: 'Reminder Time',
              value: _formatTime(settings.reminderTime),
              onTap: () => _selectReminderTime(settings),
            ),
            const SizedBox(height: 24),
            const SectionLabel('Preferences'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.language_outlined,
              title: 'Language',
              value: settings.language,
              onTap: () => _selectLanguage(settings),
            ),
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'App Theme',
              value: settings.themeName,
              onTap: () => _selectTheme(settings),
            ),
            _SettingsTile(
              icon: Icons.key_outlined,
              title: 'TokenRouter API Key',
              value: ref.watch(effectiveAiApiKeyProvider).isNotEmpty
                  ? 'Configured'
                  : 'Not set',
              valueColor: ref.watch(effectiveAiApiKeyProvider).isNotEmpty
                  ? DreamColors.aurora
                  : DreamColors.textSecondary,
              onTap: () => _editApiKey(settings),
            ),
            _SettingsTile(
              icon: Icons.smart_toy_outlined,
              title: 'AI Model',
              value: settings.selectedModel.split('/').last,
              onTap: () => _selectModel(settings),
            ),
            const SizedBox(height: 24),
            const SectionLabel('Data'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.upload_file_outlined,
              title: 'Export Data',
              value: 'PDF / Backup',
              onTap: _exportAllDreams,
            ),
            _SettingsTile(
              icon: Icons.download_for_offline_outlined,
              title: 'Import Backup',
              value: 'JSON',
              onTap: _importBackup,
            ),
            _SettingsTile(
              icon: Icons.delete_outline,
              title: 'Clear All Dreams',
              value: 'Danger',
              valueColor: DreamColors.rose,
              onTap: _clearAllDreams,
            ),
            const SizedBox(height: 24),
            const SectionLabel('About'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'About DreamLog',
              value: 'v1.0.0',
              onTap: _showAbout,
            ),
            const _SettingsTile(
              icon: Icons.favorite_border,
              title: 'Built with TokenRouter AI',
              value: 'Gimora Digital',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image == null) {
      return;
    }
    await ref.read(userProfileProvider.notifier).updateAvatarPath(image.path);
  }

  Future<void> _editName(UserProfile profile) async {
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NameSheet(
        initialValue: profile.displayName,
      ),
    );

    if (name != null) {
      await ref.read(userProfileProvider.notifier).updateName(name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile name updated.')),
        );
      }
    }
  }

  Future<void> _editApiKey(AppSettings settings) async {
    final apiKey = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ApiKeySheet(
        initialValue: settings.tokenRouterApiKey,
      ),
    );

    if (apiKey != null) {
      await ref.read(appSettingsProvider.notifier).updateApiKey(apiKey);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                apiKey.trim().isEmpty ? 'API key cleared.' : 'API key saved.'),
          ),
        );
      }
    }
  }

  Future<void> _selectModel(AppSettings settings) async {
    final model = await _optionSheet(
      title: 'AI Model',
      options: AppSettings.availableModels,
      selected: settings.selectedModel,
    );
    if (model != null) {
      await ref.read(appSettingsProvider.notifier).updateSelectedModel(model);
    }
  }

  Future<void> _selectLanguage(AppSettings settings) async {
    final language = await _optionSheet(
      title: 'Language',
      options: const ['Indonesia', 'English'],
      selected: settings.language,
    );
    if (language != null) {
      await ref.read(appSettingsProvider.notifier).updateLanguage(language);
    }
  }

  Future<void> _selectTheme(AppSettings settings) async {
    final theme = await _optionSheet(
      title: 'App Theme',
      options: const ['Midnight', 'Cosmic', 'AMOLED'],
      selected: settings.themeName,
    );
    if (theme != null) {
      await ref.read(appSettingsProvider.notifier).updateThemeName(theme);
    }
  }

  Future<String?> _optionSheet({
    required String title,
    required List<String> options,
    required String selected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OptionSheet(
        title: title,
        options: options,
        selected: selected,
      ),
    );
  }

  Future<void> _selectReminderTime(AppSettings settings) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(settings.reminderTime),
    );
    if (picked == null) {
      return;
    }
    final value =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await ref.read(appSettingsProvider.notifier).updateReminderTime(value);
  }

  Future<void> _toggleReminder(bool enabled) async {
    await ref.read(appSettingsProvider.notifier).updateReminderEnabled(enabled);
    if (enabled) {
      final notification = ref.read(notificationServiceProvider);
      await notification.initialize();
      await notification.showMorningReminderPreview();
    }
  }

  Future<void> _exportAllDreams() async {
    final entries = ref.read(dreamJournalProvider).valueOrNull ?? const [];
    final profile =
        ref.read(userProfileProvider).valueOrNull ?? UserProfile.defaults();
    final settings =
        ref.read(appSettingsProvider).valueOrNull ?? AppSettings.defaults();
    final format = await _optionSheet(
      title: 'Export format',
      options: const ['PDF', 'Backup JSON'],
      selected: 'PDF',
    );
    if (format == null || !mounted) {
      return;
    }

    final service = ref.read(exportServiceProvider);
    final file = format == 'Backup JSON'
        ? await service.exportDreamLogBackupJson(
            entries: entries,
            profile: profile,
            settings: settings,
          )
        : await service.exportDreamsPdf(entries);
    if (format == 'Backup JSON') {
      try {
        await ref.read(shareServiceProvider).shareFile(
              file: file,
              mimeType: 'application/json',
              chooserTitle: 'Save or send DreamLog backup',
              text: 'DreamLog backup JSON',
            );
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Backup saved: ${file.path}')),
          );
        }
      }
      return;
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export saved: ${file.path}')),
    );
  }

  Future<void> _importBackup() async {
    final importService = ref.read(importServiceProvider);
    final picked = await importService.pickJsonFile();
    if (picked == null || !mounted) {
      return;
    }

    late final DreamBackup backup;
    try {
      backup = importService.parseBackup(picked.content);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $error')),
        );
      }
      return;
    }

    if (backup.dreams.isEmpty &&
        backup.profile == null &&
        backup.settings == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No importable DreamLog data found.')),
      );
      return;
    }

    final mode = await _confirmImportBackup(
      fileName: picked.name,
      dreamCount: backup.dreams.length,
      skippedCount: backup.skippedDreams,
      hasProfile: backup.profile != null,
      hasSettings: backup.settings != null,
    );
    if (mode == null || !mounted) {
      return;
    }

    try {
      final restoredAvatarPath =
          await importService.restoreAvatar(backup.avatar);
      final importedBackupProfile = backup.profile;
      if (importedBackupProfile != null) {
        final currentProfile =
            await ref.read(userProfileProvider.notifier).ensureLoaded();
        final importedProfile = importedBackupProfile.copyWith(
          avatarPath: restoredAvatarPath ?? currentProfile.avatarPath,
        );
        await ref
            .read(userProfileProvider.notifier)
            .importProfile(importedProfile);
      }
      final importedBackupSettings = backup.settings;
      if (importedBackupSettings != null) {
        await ref.read(appSettingsProvider.notifier).importSettings(
              importedBackupSettings,
            );
      }
      if (backup.dreams.isNotEmpty || mode == _ImportMode.replace) {
        await ref.read(dreamJournalProvider.notifier).importDreams(
              backup.dreams,
              replace: mode == _ImportMode.replace,
            );
      }
      ref.invalidate(weeklyReportProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imported ${backup.dreams.length} dreams'
              '${backup.skippedDreams > 0 ? ' (${backup.skippedDreams} skipped)' : ''}.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $error')),
        );
      }
    }
  }

  Future<_ImportMode?> _confirmImportBackup({
    required String fileName,
    required int dreamCount,
    required int skippedCount,
    required bool hasProfile,
    required bool hasSettings,
  }) {
    return showDialog<_ImportMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import DreamLog backup?'),
        content: Text(
          'File: $fileName\n'
          'Dreams: $dreamCount\n'
          '${hasProfile ? 'Profile: included\n' : ''}'
          '${hasSettings ? 'Settings: included, API key not imported\n' : ''}'
          '${skippedCount > 0 ? 'Skipped invalid dreams: $skippedCount\n' : ''}\n'
          'Merge keeps current dreams and overwrites matching IDs. Replace clears current dreams first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_ImportMode.merge),
            child: const Text('Merge'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_ImportMode.replace),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllDreams() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all dreams?'),
        content: const Text('This removes every saved dream from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(dreamJournalProvider.notifier).clearAll();
    }
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'DreamLog',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Gimora Digital',
    );
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      return const TimeOfDay(hour: 6, minute: 30);
    }
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 6,
      minute: int.tryParse(parts[1]) ?? 30,
    );
  }

  String _formatTime(String value) {
    return _parseTime(value).format(context);
  }

  int _weeksTracked(List<DreamEntry> entries) {
    if (entries.isEmpty) {
      return 0;
    }
    final first = entries.last.createdAt;
    final last = entries.first.createdAt;
    return (last.difference(first).inDays / 7).ceil().clamp(1, 999).toInt();
  }

  int _streakDays(List<DreamEntry> entries) {
    if (entries.isEmpty) {
      return 0;
    }
    var streak = 0;
    var cursor = DateTime.now();
    while (entries.any((entry) => _sameDay(entry.createdAt, cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DreamCard(
        color: DreamColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    letterSpacing: 0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.value,
    this.trailing,
    this.valueColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final Widget? trailing;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DreamCard(
        color: DreamColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: DreamColors.aurora),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            if (trailing != null)
              trailing!
            else ...[
              Flexible(
                child: Text(
                  value ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: valueColor ?? DreamColors.textSecondary,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: DreamColors.textSecondary),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionSheet extends StatelessWidget {
  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final List<String> options;
  final String selected;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.76;

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: DreamColors.surfaceTwo,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(DreamRadii.xl),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: DreamColors.borderMuted,
                        borderRadius: BorderRadius.circular(DreamRadii.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final isSelected = option == selected;
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DreamRadii.md),
                          ),
                          selected: isSelected,
                          selectedTileColor:
                              DreamColors.primary.withValues(alpha: 0.14),
                          title: Text(
                            option,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check,
                                  color: DreamColors.textPrimary)
                              : null,
                          onTap: () => Navigator.of(context).pop(option),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApiKeySheet extends StatefulWidget {
  const _ApiKeySheet({required this.initialValue});

  final String initialValue;

  @override
  State<_ApiKeySheet> createState() => _ApiKeySheetState();
}

class _ApiKeySheetState extends State<_ApiKeySheet> {
  late final TextEditingController _controller;
  var _obscure = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.82,
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: DreamColors.surfaceTwo,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(DreamRadii.xl),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: DreamColors.borderMuted,
                        borderRadius: BorderRadius.circular(DreamRadii.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'TokenRouter API Key',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Disimpan lokal di HP ini, tidak ditulis ke source code.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    obscureText: _obscure,
                    autocorrect: false,
                    enableSuggestions: false,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'API key',
                      hintText: 'sk-...',
                      prefixIcon: const Icon(Icons.key_outlined),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    onSubmitted: (value) => Navigator.of(context).pop(value),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(''),
                        child: const Text('Clear'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () =>
                            Navigator.of(context).pop(_controller.text),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NameSheet extends StatefulWidget {
  const _NameSheet({required this.initialValue});

  final String initialValue;

  @override
  State<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<_NameSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: DreamColors.surfaceTwo,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(DreamRadii.xl),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: DreamColors.borderMuted,
                      borderRadius: BorderRadius.circular(DreamRadii.pill),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Edit profile name',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Nama ini dipakai untuk greeting dan halaman Profile.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  onSubmitted: (value) => Navigator.of(context).pop(value),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_controller.text),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

enum _ImportMode {
  merge,
  replace,
}
