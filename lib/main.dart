import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'core/constants/app_tokens.dart';
import 'core/router/app_router.dart';
import 'core/theme/dream_theme.dart';
import 'data/repositories/app_preferences_repository.dart';
import 'data/repositories/dream_repository.dart';
import 'shared/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: DreamColors.background,
      systemNavigationBarDividerColor: DreamColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
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

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'DreamLog',
      theme: DreamTheme.dark(),
      routerConfig: router,
    );
  }
}
