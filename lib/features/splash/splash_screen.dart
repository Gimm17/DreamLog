import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_tokens.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/dream_log_mark.dart';
import '../../shared/widgets/dream_orbit_scene.dart';
import '../../shared/widgets/star_field.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _motionController;
  late final AnimationController _introController;
  late final AnimationController _progressController;
  late final AnimationController _exitController;
  late final Animation<double> _introCurve;
  late final Animation<double> _introScale;
  late final Animation<Offset> _introSlide;
  late final Animation<double> _progressCurve;
  late final Animation<double> _exitCurve;
  Timer? _timer;
  var _routingStarted = false;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: 1,
    );
    _introCurve = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _introScale = Tween<double>(begin: 0.96, end: 1).animate(_introCurve);
    _introSlide = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(_introCurve);
    _progressCurve = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );
    _exitCurve = CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _introController.forward();
    _progressController.forward();
    _timer = Timer(
      const Duration(milliseconds: 2700),
      () => unawaited(_routeAfterSplash()),
    );
  }

  Future<void> _routeAfterSplash() async {
    if (_routingStarted) {
      return;
    }
    _routingStarted = true;
    if (!mounted) {
      return;
    }
    final profile = await ref.read(userProfileProvider.notifier).ensureLoaded();
    if (!mounted) {
      return;
    }
    if (_progressController.value < 1) {
      await _progressController.animateTo(
        1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
      );
    }
    if (!mounted) {
      return;
    }
    await _exitController.reverse();
    if (!mounted) {
      return;
    }
    context.go(profile.onboardingComplete ? '/' : '/onboarding');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _exitController.dispose();
    _progressController.dispose();
    _introController.dispose();
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: DreamColors.background,
      body: FadeTransition(
        opacity: _exitCurve,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.2, -0.25),
                  radius: 1.1,
                  colors: [
                    Color(0xFF211B4D),
                    DreamColors.background,
                    Color(0xFF08070D),
                  ],
                ),
              ),
              child: AnimatedStarField(
                animation: _motionController,
                density: 70,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: FadeTransition(
                  opacity: _introCurve,
                  child: ScaleTransition(
                    scale: _introScale,
                    child: DreamOrbitScene(
                      animation: _motionController,
                      icon: Icons.dark_mode_rounded,
                      center: const DreamLogMark(
                        size: 112,
                        background: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: _introCurve,
              child: SlideTransition(
                position: _introSlide,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(),
                        const SizedBox(height: 210),
                        AnimatedBuilder(
                          animation: _motionController,
                          builder: (context, child) {
                            final opacity = 0.82 +
                                (0.18 *
                                    Curves.easeInOut.transform(
                                      (_motionController.value - 0.5).abs() * 2,
                                    ));
                            return Opacity(opacity: opacity, child: child);
                          },
                          child: Column(
                            children: [
                              Text(
                                'DreamLog',
                                textAlign: TextAlign.center,
                                style: textTheme.displayLarge?.copyWith(
                                  fontSize: 54,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Unravel your dreams',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: DreamColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(DreamRadii.pill),
                          child: AnimatedBuilder(
                            animation: _progressCurve,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                minHeight: 6,
                                value: _progressCurve.value,
                                color: DreamColors.primaryLight,
                                backgroundColor: const Color(0xFF24222C),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 42),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
