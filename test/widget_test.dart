import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dreamlog/core/constants/app_tokens.dart';
import 'package:dreamlog/data/models/app_settings.dart';
import 'package:dreamlog/data/models/user_profile.dart';
import 'package:dreamlog/data/repositories/app_preferences_repository.dart';
import 'package:dreamlog/main.dart';
import 'package:dreamlog/shared/providers/app_providers.dart';

/// Repository shape with no storage behind it. Only `loadSettings` is reached
/// because the stub controller overrides `load`.
class _NoopPreferencesRepository implements AppPreferencesRepository {
  @override
  Future<AppSettings> loadSettings() async => AppSettings.defaults();

  @override
  Future<UserProfile> loadProfile() async => UserProfile.defaults();

  @override
  Future<void> saveProfile(UserProfile profile) async {}

  @override
  Future<void> saveSettings(AppSettings settings) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} is not stubbed');
}

/// Stands in for [AppSettingsController] so the root widget can be pumped
/// without Hive or path_provider behind it. Never touches the repository.
class _StubSettings extends AppSettingsController {
  _StubSettings() : super(_NoopPreferencesRepository());

  @override
  Future<void> load() async => state = AsyncData(AppSettings.defaults());
}

void main() {
  testWidgets('DreamLog boots to the splash screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((ref) => _StubSettings()),
        ],
        child: const DreamLogApp(),
      ),
    );

    expect(find.text('DreamLog'), findsOneWidget);
  });

  test('applyTheme swaps only the surface palette', () {
    DreamColors.applyTheme('AMOLED');
    expect(DreamColors.background, const Color(0xFF000000));
    expect(DreamColors.surface, const Color(0xFF0D0D0D));
    // Accents are theme-independent and must survive the swap.
    expect(DreamColors.aurora, const Color(0xFF6EE7B7));

    DreamColors.applyTheme('Midnight');
    expect(DreamColors.background, const Color(0xFF0F0E17));
  });
}
