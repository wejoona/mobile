import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/index.dart';
import 'package:usdc_wallet/features/onboarding/providers/onboarding_progress_provider.dart';

/// Welcome screen shown after successful registration
class WelcomePostLoginView extends ConsumerStatefulWidget {
  const WelcomePostLoginView({super.key});

  @override
  ConsumerState<WelcomePostLoginView> createState() => _WelcomePostLoginViewState();
}

class _WelcomePostLoginViewState extends ConsumerState<WelcomePostLoginView>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _animationController.forward();
    _confettiController.play();

    // Mark first login
    Future.microtask(() {
      ref.read(onboardingProgressProvider.notifier).setFirstLogin();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final userName = ref.watch(userDisplayNameProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      body: Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Color(0xFFD4AF37),
                Color(0xFF4CAF50),
                Color(0xFF2196F3),
                Color(0xFF9C27B0),
              ],
            ),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Animated checkmark
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.goldGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.goldGlow,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 60,
                          color: colors.textInverse,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.giant),

                    // Welcome message
                    AppText(
                      l10n.welcome_title(userName),
                      variant: AppTextVariant.headlineLarge,
                      color: colors.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    AppText(
                      l10n.welcome_subtitle,
                      variant: AppTextVariant.bodyLarge,
                      color: colors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Quick stats
                    _buildQuickStats(l10n, colors),

                    const Spacer(flex: 3),

                    // Action buttons
                    AppButton(
                      label: l10n.welcome_addFunds,
                      onPressed: () => context.go('/deposit'),
                      variant: AppButtonVariant.primary,
                      size: AppButtonSize.large,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppButton(
                      label: l10n.welcome_exploreDashboard,
                      onPressed: () => context.go('/home'),
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.large,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AppLocalizations l10n, ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        children: [
          _buildStatRow(
            Icons.account_balance_wallet_rounded,
            l10n.welcome_stat_wallet,
            l10n.welcome_stat_wallet_desc,
            colors,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStatRow(
            Icons.flash_on_rounded,
            l10n.welcome_stat_instant,
            l10n.welcome_stat_instant_desc,
            colors,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStatRow(
            Icons.verified_user_rounded,
            l10n.welcome_stat_secure,
            l10n.welcome_stat_secure_desc,
            colors,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    IconData icon,
    String title,
    String description,
    ThemeColors colors,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.goldGradient),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: colors.textInverse, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                variant: AppTextVariant.labelLarge,
                color: colors.textPrimary,
              ),
              AppText(
                description,
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
