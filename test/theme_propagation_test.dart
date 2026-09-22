import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dreamlog/core/constants/app_tokens.dart';
import 'package:dreamlog/core/theme/dream_theme.dart';
import 'package:dreamlog/data/models/app_settings.dart';
import 'package:dreamlog/data/models/user_profile.dart';
import 'package:dreamlog/data/repositories/app_preferences_repository.dart';
import 'package:dreamlog/shared/providers/app_providers.dart';

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

class _StubSettings extends AppSettingsController {
  _StubSettings() : super(_NoopPreferencesRepository());

  @override
  Future<void> load() async => state = AsyncData(AppSettings.defaults());
}

/// Reproduces the exact contract DreamLogApp relies on: it watches the settings
/// provider, applies the static palette, and rebuilds a MaterialApp whose
/// subtree paints from DreamColors. A screen that touches Theme.of (as every
/// real screen does, for textTheme) must come back with the new palette.
class _StaticColorProbe extends StatelessWidget {
  const _StaticColorProbe();

  @override
  Widget build(BuildContext context) {
    // Deliberately reads Theme.of — this is what registers the dependency.
    Theme.of(context).textTheme;
    return Container(
      key: const ValueKey('probe'),
      color: DreamColors.background,
      width: 10,
      height: 10,
    );
  }
}

class _Harness extends ConsumerWidget {
  const _Harness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(appSettingsProvider).valueOrNull ?? AppSettings.defaults();
    DreamColors.applyTheme(settings.themeName);
    return MaterialApp(
      theme: switch (settings.themeName) {
        'Cosmic' => DreamTheme.cosmic(),
        'AMOLED' => DreamTheme.amoled(),
        _ => DreamTheme.dark(),
      },
      home: const _StaticColorProbe(),
    );
  }
}

void main() {
  testWidgets('switching the theme setting repaints static-palette screens',
      (tester) async {
    DreamColors.applyTheme('Midnight');
    final container = ProviderContainer(
      overrides: [appSettingsProvider.overrideWith((ref) => _StubSettings())],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _Harness(),
      ),
    );

    expect(
      tester.widget<Container>(find.byKey(const ValueKey('probe'))).color,
      const Color(0xFF0F0E17),
      reason: 'Midnight baseline',
    );

    await container
        .read(appSettingsProvider.notifier)
        .updateThemeName('AMOLED');
    await tester.pumpAndSettle();

    expect(
      tester.widget<Container>(find.byKey(const ValueKey('probe'))).color,
      const Color(0xFF000000),
      reason: 'screen must repaint with the AMOLED palette after switching',
    );
  });
}
