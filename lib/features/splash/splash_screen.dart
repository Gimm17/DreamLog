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
  late final Animation<double> _introCurve;
  late final Animation<double> _introScale;
  late final Animation<Offset> _introSlide;
  Timer? _timer;

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
    _introCurve = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _introScale = Tween<double>(begin: 0.96, end: 1).animate(_introCurve);
    _introSlide = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(_introCurve);
    _introController.forward();
    _timer = Timer(
      const Duration(milliseconds: 2100),
      () => unawaited(_routeAfterSplash()),
    );
  }

  Future<void> _routeAfterSplash() async {
    if (!mounted) {
      return;
    }
    final profile = await ref.read(userProfileProvider.notifier).ensureLoaded();
    if (!mounted) {
      return;
    }
    context.go(profile.onboardingComplete ? '/' : '/onboarding');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _introController.dispose();
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
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
              density: 54,
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
                      size: 98,
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
                          animation: _motionController,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              minHeight: 6,
                              value: 0.35 + (_motionController.value * 0.45),
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
    );
  }
}
