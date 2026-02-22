import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart' as auth;
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _waitForAnimationThenListen();
  }

  Future<void> _waitForAnimationThenListen() async {
    // Wait for splash animation
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted || _hasNavigated) return;

    // Check onboarding status first
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (!mounted || _hasNavigated) return;

    if (!onboardingCompleted) {
      _hasNavigated = true;
      context.go('/onboarding');
      return;
    }

    // Check current auth state — if already resolved, navigate immediately
    final currentState = ref.read(auth.authProvider);
    if (_tryNavigate(currentState)) return;

    // Listen reactively for auth state changes (no polling loop)
    ref.listenManual(auth.authProvider, (_, next) {
      _tryNavigate(next);
    });

    // Safety timeout — if auth never resolves in 5s, go to login
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      context.go('/login');
    });
  }

  bool _tryNavigate(auth.AuthState authState) {
    if (_hasNavigated || !mounted) return true;
    if (authState.status == auth.AuthStatus.initial ||
        authState.status == auth.AuthStatus.loading) {
      return false; // Still loading
    }

    _hasNavigated = true;
    if (authState.isAuthenticated) {
      context.go('/home');
    } else if (authState.isLocked) {
      context.go('/session-locked');
    } else {
      context.go('/login');
    }
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: context.colors.goldGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: colors.gold.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'K',
                          style: TextStyle(
                            color: colors.canvas,
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // App name
                    AppText(
                      'Korido',
                      variant: AppTextVariant.headlineLarge,
                      color: colors.gold,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Tagline
                    AppText(
                      'Send Money Home',
                      variant: AppTextVariant.bodyLarge,
                      color: colors.textSecondary,
                    ),

                    const SizedBox(height: AppSpacing.xxxl * 2),

                    // Loading indicator
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: colors.gold,
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
