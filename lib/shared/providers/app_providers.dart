import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_settings.dart';
import '../../data/models/dream_entry.dart';
import '../../data/models/dream_interpretation.dart';
import '../../data/models/dream_symbol.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/weekly_report.dart';
import '../../data/repositories/app_preferences_repository.dart';
import '../../data/repositories/dream_repository.dart';
import '../../data/services/ai_service.dart';
import '../../data/services/export_service.dart';
import '../../data/services/import_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/share_service.dart';
import '../../data/services/speech_service.dart';

final dreamRepositoryProvider = Provider<DreamRepository>((ref) {
  throw UnimplementedError('DreamRepository must be overridden in main.dart');
});

final appPreferencesRepositoryProvider =
    Provider<AppPreferencesRepository>((ref) {
  throw UnimplementedError(
    'AppPreferencesRepository must be overridden in main.dart',
  );
});

final userProfileProvider =
    StateNotifierProvider<UserProfileController, AsyncValue<UserProfile>>(
  (ref) => UserProfileController(ref.watch(appPreferencesRepositoryProvider))
    ..load(),
);

final appSettingsProvider =
    StateNotifierProvider<AppSettingsController, AsyncValue<AppSettings>>(
  (ref) => AppSettingsController(ref.watch(appPreferencesRepositoryProvider))
    ..load(),
);

final effectiveAiApiKeyProvider = Provider<String>((ref) {
  const envKey = String.fromEnvironment('TOKENROUTER_API_KEY');
  final storedKey =
      ref.watch(appSettingsProvider).valueOrNull?.tokenRouterApiKey.trim() ??
          '';
  return storedKey.isNotEmpty ? storedKey : envKey;
});

final aiServiceProvider = Provider<AiService>((ref) {
  final settings =
      ref.watch(appSettingsProvider).valueOrNull ?? AppSettings.defaults();
  return AiService(
    apiKey: ref.watch(effectiveAiApiKeyProvider),
    model: settings.selectedModel,
  );
});

final speechServiceProvider = Provider<SpeechService>((ref) => SpeechService());
final exportServiceProvider = Provider<ExportService>((ref) => ExportService());
final importServiceProvider = Provider<ImportService>((ref) => ImportService());
final shareServiceProvider = Provider<ShareService>((ref) => ShareService());
final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final dreamJournalProvider =
    StateNotifierProvider<DreamJournalController, AsyncValue<List<DreamEntry>>>(
  (ref) => DreamJournalController(ref.watch(dreamRepositoryProvider))..load(),
);

final dreamByIdProvider = Provider.family<DreamEntry?, String>((ref, id) {
  final journal = ref.watch(dreamJournalProvider);
  return journal.maybeWhen(
    data: (entries) => entries.where((entry) => entry.id == id).firstOrNull,
    orElse: () => null,
  );
});

final weeklyReportProvider = FutureProvider<WeeklyReport>((ref) async {
  final service = ref.watch(aiServiceProvider);
  final repository = ref.watch(dreamRepositoryProvider);
  final entries =
      ref.watch(dreamJournalProvider).valueOrNull ?? await repository.all();
  return service.generateWeeklyReport(entries.take(7).toList());
});

final symbolsProvider = Provider<List<DreamSymbol>>((ref) {
  final entries =
      ref.watch(dreamJournalProvider).valueOrNull ?? const <DreamEntry>[];
  final counts = <String, int>{};
  for (final entry in entries) {
    for (final symbol in entry.symbols) {
      counts.update(symbol, (value) => value + 1, ifAbsent: () => 1);
    }
  }

  final symbols = counts.entries
      .map(
        (entry) => DreamSymbol(
          name: entry.key,
          icon: _symbolIcon(entry.key),
          meaning: _symbolMeaning(entry.key),
          frequency: entry.value,
        ),
      )
      .toList()
    ..sort((a, b) => b.frequency.compareTo(a.frequency));

  return symbols;
});

class DreamJournalController
    extends StateNotifier<AsyncValue<List<DreamEntry>>> {
  DreamJournalController(this._repository) : super(const AsyncLoading());

  final DreamRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.all);
  }

  Future<void> addInterpretedDream({
    required String content,
    required DateTime date,
    required double clarity,
    required DreamInterpretation interpretation,
  }) async {
    final entry = DreamEntry(
      id: 'dream-${DateTime.now().microsecondsSinceEpoch}',
      title: _titleFromDream(content, interpretation),
      content: content,
      createdAt: date,
      clarity: clarity,
      interpretation: interpretation,
    );

    await _repository.save(entry);
    await load();
  }

  Future<void> toggleBookmark(String id) async {
    await _repository.toggleBookmark(id);
    await load();
  }

  Future<void> clearAll() async {
    await _repository.clear();
    await load();
  }

  Future<void> importDreams(
    List<DreamEntry> entries, {
    required bool replace,
  }) async {
    await _repository.saveAll(entries, replace: replace);
    await load();
  }

  String _titleFromDream(
    String content,
    DreamInterpretation interpretation,
  ) {
    if (interpretation.symbols.isNotEmpty) {
      return 'The ${interpretation.symbols.first} Dream';
    }

    final words = content
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(5)
        .join(' ');
    return words.isEmpty ? 'Untitled Dream' : words;
  }
}

class UserProfileController extends StateNotifier<AsyncValue<UserProfile>> {
  UserProfileController(this._repository) : super(const AsyncLoading());

  final AppPreferencesRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.loadProfile);
  }

  Future<UserProfile> ensureLoaded() async {
    final current = state.valueOrNull;
    if (current != null) {
      return current;
    }
    final profile = await _repository.loadProfile();
    state = AsyncData(profile);
    return profile;
  }

  Future<void> updateName(String name) async {
    final profile = await ensureLoaded();
    final updated =
        profile.copyWith(name: name.trim().isEmpty ? 'Dreamer' : name.trim());
    await _repository.saveProfile(updated);
    state = AsyncData(updated);
  }

  Future<void> completeOnboarding(String name) async {
    final profile = await ensureLoaded();
    final updated = profile.copyWith(
      name: name.trim().isEmpty ? profile.displayName : name.trim(),
      onboardingComplete: true,
    );
    await _repository.saveProfile(updated);
    state = AsyncData(updated);
  }

  Future<void> updateAvatarPath(String path) async {
    final profile = await ensureLoaded();
    final updated = profile.copyWith(avatarPath: path);
    await _repository.saveProfile(updated);
    state = AsyncData(updated);
  }

  Future<void> importProfile(UserProfile profile) async {
    await _repository.saveProfile(profile);
    state = AsyncData(profile);
  }
}

class AppSettingsController extends StateNotifier<AsyncValue<AppSettings>> {
  AppSettingsController(this._repository) : super(const AsyncLoading());

  final AppPreferencesRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.loadSettings);
  }

  Future<AppSettings> ensureLoaded() async {
    final current = state.valueOrNull;
    if (current != null) {
      return current;
    }
    final settings = await _repository.loadSettings();
    state = AsyncData(settings);
    return settings;
  }

  Future<void> updateApiKey(String apiKey) async {
    await _save(
        (settings) => settings.copyWith(tokenRouterApiKey: apiKey.trim()));
  }

  Future<void> updateSelectedModel(String model) async {
    await _save((settings) => settings.copyWith(selectedModel: model));
  }

  Future<void> updateLanguage(String language) async {
    await _save((settings) => settings.copyWith(language: language));
  }

  Future<void> updateThemeName(String themeName) async {
    await _save((settings) => settings.copyWith(themeName: themeName));
  }

  Future<void> updateReminderEnabled(bool enabled) async {
    await _save((settings) => settings.copyWith(reminderEnabled: enabled));
  }

  Future<void> updateReminderTime(String reminderTime) async {
    await _save((settings) => settings.copyWith(reminderTime: reminderTime));
  }

  Future<void> importSettings(AppSettings settings) async {
    final current = await ensureLoaded();
    final updated = settings.copyWith(
      tokenRouterApiKey: current.tokenRouterApiKey,
    );
    await _repository.saveSettings(updated);
    state = AsyncData(updated);
  }

  Future<void> _save(AppSettings Function(AppSettings settings) update) async {
    final current = await ensureLoaded();
    final updated = update(current);
    await _repository.saveSettings(updated);
    state = AsyncData(updated);
  }
}

String _symbolIcon(String symbol) {
  final normalized = symbol.toLowerCase();
  if (normalized.contains('ocean') || normalized.contains('water')) {
    return 'water';
  }
  if (normalized.contains('moon')) {
    return 'moon';
  }
  if (normalized.contains('clock')) {
    return 'clock';
  }
  if (normalized.contains('door')) {
    return 'door';
  }
  if (normalized.contains('city')) {
    return 'city';
  }
  return 'key';
}

String _symbolMeaning(String symbol) {
  final normalized = symbol.toLowerCase();
  if (normalized.contains('ocean') || normalized.contains('water')) {
    return 'Emotional depth, surrender, memory, and the subconscious mind.';
  }
  if (normalized.contains('door')) {
    return 'A threshold, possible change, or choice that is not fully opened yet.';
  }
  if (normalized.contains('clock')) {
    return 'Pressure, timing, old expectations, or a changed relationship to urgency.';
  }
  if (normalized.contains('moon')) {
    return 'Intuition, hidden cycles, and feelings that become visible gradually.';
  }
  return 'Opportunity, hidden access, secrets, and new beginnings.';
}

extension FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}
