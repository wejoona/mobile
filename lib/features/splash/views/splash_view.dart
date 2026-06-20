import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/core/constants/preference_keys.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart' as auth;
import 'package:usdc_wallet/features/auth/widgets/auth_screen_chrome.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<double> _taglineFade;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    // Continuous pulse glow
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shimmer sweep on text
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _logoController.forward();
    _waitForAnimationThenListen();
  }

  Future<void> _waitForAnimationThenListen() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted || _hasNavigated) return;

    // Returning users skip onboarding
    final currentState = ref.read(auth.authProvider);
    if (currentState.isAuthenticated || currentState.isLocked) {
      if (_tryNavigate(currentState)) return;
    }

    // New users should land on login. Product intro/onboarding stays opt-in from
    // explicit signup actions so registration never becomes the default door.
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted =
        prefs.getBool(PreferenceKeys.productIntroCompleted) ?? false;

    if (!mounted || _hasNavigated) return;

    if (!onboardingCompleted &&
        !currentState.isAuthenticated &&
        !currentState.isLocked) {
      _hasNavigated = true;
      context.fsmGo('/login');
      return;
    }

    if (_tryNavigate(currentState)) return;

    ref.listenManual(auth.authProvider, (_, next) {
      _tryNavigate(next);
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      context.fsmGo('/login');
    });
  }

  bool _tryNavigate(auth.AuthState authState) {
    if (_hasNavigated || !mounted) return true;
    if (authState.status == auth.AuthStatus.initial ||
        authState.status == auth.AuthStatus.loading) {
      return false;
    }
    _hasNavigated = true;
    if (authState.isAuthenticated) {
      context.fsmEnterAuthenticatedApp();
    } else if (authState.isLocked) {
      context.fsmGo('/session-locked');
    } else {
      context.fsmGo('/login');
    }
    return true;
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: Stack(
        children: [
          // Subtle radial gradient background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, _) {
                return CustomPaint(
                  painter: _RadialGlowPainter(
                    color: colors.gold,
                    opacity: _pulseAnimation.value * 0.15,
                    center: Offset(size.width / 2, size.height * 0.4),
                  ),
                );
              },
            ),
          ),

          // Floating particles
          ...List.generate(
            6,
            (i) => _FloatingParticle(
              colors: colors,
              index: i,
              screenSize: size,
              pulseController: _pulseController,
            ),
          ),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _logoController,
                _pulseController,
                _shimmerController,
              ]),
              builder: (context, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with glow
                    Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoFade.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(34),
                            boxShadow: [
                              BoxShadow(
                                color: colors.gold.withValues(
                                  alpha: _pulseAnimation.value,
                                ),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                              BoxShadow(
                                color: colors.gold.withValues(
                                  alpha: _pulseAnimation.value * 0.5,
                                ),
                                blurRadius: 80,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                          child: const KoridoMark(size: 120),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // "Korido" with shimmer
                    Opacity(
                      opacity: _textFade.value,
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              colors.gold,
                              colors.gold.withValues(alpha: 0.5),
                              Colors.white,
                              colors.gold.withValues(alpha: 0.5),
                              colors.gold,
                            ],
                            stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                            begin: Alignment(_shimmerAnimation.value - 1, 0),
                            end: Alignment(_shimmerAnimation.value, 0),
                          ).createShader(bounds);
                        },
                        child: const AppText(
                          'Korido',
                          variant: AppTextVariant.headlineLarge,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tagline
                    Opacity(
                      opacity: _taglineFade.value,
                      child: AppText(
                        l10n.splash_tagline,
                        variant: AppTextVariant.bodyLarge,
                        color: colors.textSecondary.withValues(alpha: 0.8),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 80),

                    // Minimal loading dots
                    Opacity(
                      opacity: _taglineFade.value,
                      child: _LoadingDots(colors: colors),
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom branding
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _taglineFade,
              builder: (context, _) => Opacity(
                opacity: _taglineFade.value * 0.5,
                child: AppText(
                  l10n.splash_poweredBy,
                  textAlign: TextAlign.center,
                  variant: AppTextVariant.labelMedium,
                  color: colors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated loading dots (3 dots pulsing in sequence)
class _LoadingDots extends StatefulWidget {
  const _LoadingDots({required this.colors});
  final ThemeColors colors;

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final value = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 0.5 + 0.5 * math.sin(value * math.pi);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.colors.gold.withValues(alpha: 0.3 + 0.7 * scale),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Floating ambient particle
class _FloatingParticle extends StatelessWidget {
  const _FloatingParticle({
    required this.colors,
    required this.index,
    required this.screenSize,
    required this.pulseController,
  });

  final ThemeColors colors;
  final int index;
  final Size screenSize;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    final random = math.Random(index * 42);
    final startX = random.nextDouble() * screenSize.width;
    final startY = random.nextDouble() * screenSize.height;
    final size = 3.0 + random.nextDouble() * 4;

    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, _) {
        final phase = (pulseController.value + index * 0.15) % 1.0;
        final yOffset = math.sin(phase * math.pi * 2) * 20;
        final opacity = 0.1 + 0.15 * math.sin(phase * math.pi);

        return Positioned(
          left: startX,
          top: startY + yOffset,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.gold.withValues(alpha: opacity),
            ),
          ),
        );
      },
    );
  }
}

/// Radial glow painter for background ambience
class _RadialGlowPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final Offset center;

  _RadialGlowPainter({
    required this.color,
    required this.opacity,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: opacity * 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.6));

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _RadialGlowPainter old) =>
      opacity != old.opacity;
}
