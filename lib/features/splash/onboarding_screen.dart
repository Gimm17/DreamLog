import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_tokens.dart';
import '../../shared/widgets/dream_orbit_scene.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/star_field.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  late final AnimationController _motionController;
  var _index = 0;

  static const _slides = [
    _OnboardingSlide(
      title: 'Capture Before It Fades',
      body:
          'Record your dreams the moment you wake up with voice or text, in seconds.',
      icon: Icons.nights_stay_outlined,
    ),
    _OnboardingSlide(
      title: 'AI Reads Between the Symbols',
      body:
          'DreamLog AI interprets hidden emotions, recurring symbols, and psychological patterns.',
      icon: Icons.auto_awesome_motion_outlined,
    ),
    _OnboardingSlide(
      title: 'Discover Your Inner World',
      body:
          'Weekly reports reveal your emotional journey and the themes your subconscious returns to.',
      icon: Icons.insights_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF171225),
                  DreamColors.background,
                  Color(0xFF08070D),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedStarField(
              animation: _motionController,
              density: 62,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
              child: Column(
                children: [
                  SizedBox(
                    height: 46,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedSlide(
                        offset:
                            _index == 0 ? const Offset(-0.18, 0) : Offset.zero,
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        child: AnimatedOpacity(
                          opacity: _index == 0 ? 0 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: IconButton(
                            onPressed: _index == 0
                                ? null
                                : () => _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 360),
                                      curve: Curves.easeOutCubic,
                                    ),
                            icon: const Icon(Icons.arrow_back),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (value) => setState(() => _index = value),
                      itemBuilder: (context, index) => _SlideView(
                        slide: _slides[index],
                        animation: _motionController,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          width: i == _index ? 26 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: i == _index
                                ? DreamColors.primaryLight
                                : DreamColors.borderMuted,
                            borderRadius:
                                BorderRadius.circular(DreamRadii.pill),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: GradientButton(
                      key: ValueKey(_index == _slides.length - 1),
                      label:
                          _index == _slides.length - 1 ? 'Get Started' : 'Next',
                      onPressed: () {
                        if (_index == _slides.length - 1) {
                          context.go('/name');
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 360),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
    required this.animation,
  });

  final _OnboardingSlide slide;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          child: DreamOrbitScene(
            animation: animation,
            icon: slide.icon,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: Column(
            key: ValueKey(slide.title),
            children: [
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(fontSize: 30),
              ),
              const SizedBox(height: 14),
              Text(
                slide.body,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}
