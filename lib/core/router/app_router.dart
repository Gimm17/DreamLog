import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home_screen.dart';
import '../../features/insights/insights_screen.dart';
import '../../features/insights/weekly_report_screen.dart';
import '../../features/journal/dream_detail_screen.dart';
import '../../features/journal/journal_screen.dart';
import '../../features/new_entry/ai_result_screen.dart';
import '../../features/new_entry/new_dream_entry_screen.dart';
import '../../features/profile/profile_settings_screen.dart';
import '../../features/splash/name_setup_screen.dart';
import '../../features/splash/onboarding_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/symbols/symbols_screen.dart';
import '../../shared/widgets/bottom_nav.dart';

final _branchDisplayState = ValueNotifier<_BranchDisplayState>(
  const _BranchDisplayState(),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _fadePage(
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/name',
        pageBuilder: (context, state) => _slidePage(
          state,
          const NameSetupScreen(),
        ),
      ),
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return _DreamShell(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return _AnimatedBranchContainer(
            currentIndex: navigationShell.currentIndex,
            children: children,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journal',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: JournalScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: InsightsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/symbols',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SymbolsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileSettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/dream/:id',
        pageBuilder: (context, state) => _slidePage(
          state,
          DreamDetailScreen(
            dreamId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '/new-dream',
        pageBuilder: (context, state) => _slidePage(
          state,
          const NewDreamEntryScreen(),
        ),
      ),
      GoRoute(
        path: '/dream/:id/edit',
        pageBuilder: (context, state) => _slidePage(
          state,
          NewDreamEntryScreen(editingId: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: '/ai-result',
        pageBuilder: (context, state) => _slidePage(
          state,
          AIResultScreen(
            draft: state.extra as DreamDraft?,
          ),
        ),
      ),
      GoRoute(
        path: '/weekly-report',
        pageBuilder: (context, state) => _slidePage(
          state,
          const WeeklyReportScreen(),
        ),
      ),
    ],
  );
});

Page<dynamic> _fadePage(
  GoRouterState state,
  Widget child, {
  Duration duration = const Duration(milliseconds: 340),
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 240),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: child,
      );
    },
  );
}

Page<dynamic> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _DreamShell extends StatefulWidget {
  const _DreamShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<_DreamShell> createState() => _DreamShellState();
}

class _DreamShellState extends State<_DreamShell> {
  var _prewarmStarted = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _prewarmBranches();
    });
  }

  Future<void> _prewarmBranches() async {
    if (_prewarmStarted || !mounted) {
      return;
    }
    _prewarmStarted = true;

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) {
      return;
    }

    final originalIndex = widget.navigationShell.currentIndex;
    final branchCount = widget.navigationShell.route.branches.length;
    if (branchCount <= 1) {
      return;
    }

    _branchDisplayState.value = _BranchDisplayState(
      overrideIndex: originalIndex,
      prewarming: true,
    );

    try {
      for (var index = 0; index < branchCount; index++) {
        if (!mounted || index == originalIndex) {
          continue;
        }
        widget.navigationShell.goBranch(index);
        await SchedulerBinding.instance.endOfFrame;
        await SchedulerBinding.instance.endOfFrame;
      }

      if (mounted) {
        widget.navigationShell.goBranch(originalIndex);
        await SchedulerBinding.instance.endOfFrame;
      }
    } finally {
      _branchDisplayState.value = const _BranchDisplayState();
    }
  }

  @override
  void dispose() {
    _branchDisplayState.value = const _BranchDisplayState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_BranchDisplayState>(
      valueListenable: _branchDisplayState,
      builder: (context, displayState, child) {
        final visibleIndex =
            displayState.overrideIndex ?? widget.navigationShell.currentIndex;
        return Scaffold(
          body: IgnorePointer(
            ignoring: displayState.prewarming,
            child: widget.navigationShell,
          ),
          bottomNavigationBar: DreamBottomNav(
            currentIndex: visibleIndex,
            enabled: !displayState.prewarming,
            onTap: (index) {
              widget.navigationShell.goBranch(
                index,
                initialLocation: index == widget.navigationShell.currentIndex,
              );
            },
          ),
        );
      },
    );
  }
}

class _AnimatedBranchContainer extends StatelessWidget {
  const _AnimatedBranchContainer({
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_BranchDisplayState>(
      valueListenable: _branchDisplayState,
      builder: (context, displayState, child) {
        final visibleIndex = displayState.overrideIndex ?? currentIndex;
        final indexes = List<int>.generate(children.length, (index) => index)
          ..sort((a, b) {
            if (a == visibleIndex) {
              return 1;
            }
            if (b == visibleIndex) {
              return -1;
            }
            return a.compareTo(b);
          });

        return Stack(
          fit: StackFit.expand,
          children: [
            for (final index in indexes)
              _AnimatedBranch(
                key: ValueKey('dream-branch-$index'),
                active: index == visibleIndex,
                prewarmPaint: displayState.prewarming && index != visibleIndex,
                child: children[index],
              ),
          ],
        );
      },
    );
  }
}

class _AnimatedBranch extends StatelessWidget {
  const _AnimatedBranch({
    super.key,
    required this.active,
    required this.prewarmPaint,
    required this.child,
  });

  final bool active;
  final bool prewarmPaint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !active,
        child: AnimatedOpacity(
          opacity: active ? 1 : (prewarmPaint ? 0.001 : 0),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          child: AnimatedScale(
            scale: active ? 1 : 0.985,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: TickerMode(
              enabled: active,
              child: ExcludeSemantics(
                excluding: !active,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BranchDisplayState {
  const _BranchDisplayState({
    this.overrideIndex,
    this.prewarming = false,
  });

  final int? overrideIndex;
  final bool prewarming;
}
