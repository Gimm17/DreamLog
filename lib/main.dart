import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'core/constants/app_tokens.dart';
import 'core/router/app_router.dart';
import 'core/theme/dream_theme.dart';
import 'data/models/app_settings.dart';
import 'data/repositories/app_preferences_repository.dart';
import 'data/repositories/dream_repository.dart';
import 'shared/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: DreamColors.background,
      systemNavigationBarDividerColor: DreamColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  // Required before any zonedSchedule call; resolves WIB/WITA/WIT from the OS.
  tz_data.initializeTimeZones();
  try {
    final local = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(local.identifier));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  }
  final repository = await DreamRepository.open();
  final preferencesRepository = await AppPreferencesRepository.open();

  runApp(
    ProviderScope(
      overrides: [
        dreamRepositoryProvider.overrideWithValue(repository),
        appPreferencesRepositoryProvider
            .overrideWithValue(preferencesRepository),
      ],
      child: const DreamLogApp(),
    ),
  );
}

class DreamLogApp extends ConsumerWidget {
  const DreamLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings =
        ref.watch(appSettingsProvider).valueOrNull ?? AppSettings.defaults();

    // Puzzle: nearly every widget reads DreamColors.* statically rather than
    // through Theme.of, so swapping the palette has to happen before the tree
    // below builds. Rebuilds of this widget keep it in sync with the setting.
    DreamColors.applyTheme(settings.themeName);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'DreamLog',
      theme: switch (settings.themeName) {
        'Cosmic' => DreamTheme.cosmic(),
        'AMOLED' => DreamTheme.amoled(),
        _ => DreamTheme.dark(),
      },
      // Drives framework strings and date/number formatting. In-app copy is
      // still English-only; this is the locale plumbing, not a translation pass.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('id')],
      locale: settings.language == 'Indonesia'
          ? const Locale('id')
          : const Locale('en'),
      routerConfig: router,
    );
  }
}
