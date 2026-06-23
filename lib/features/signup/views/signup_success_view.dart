import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/signup/providers/signup_flow_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Success screen for explicit account signup.
class SignupSuccessView extends ConsumerWidget {
  const SignupSuccessView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(signupFlowProvider);

    return Scaffold(
      backgroundColor: context.colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              // Success icon with animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: context.colors.goldGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 64,
                        color: context.colors.textInverse,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: AppSpacing.xxl),
              // Title
              AppText(
                l10n.onboarding_success_title,
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              // Subtitle with name
              AppText(
                l10n.onboarding_success_subtitle(state.firstName ?? 'User'),
                style: AppTypography.bodyLarge.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxl),
              // Success message
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.colors.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: context.colors.gold),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 48,
                      color: context.colors.gold,
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppText(
                      _copy(context, en: 'Account ready', fr: 'Compte prêt'),
                      style: AppTypography.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AppText(
                      _copy(
                        context,
                        en: 'Your Korido account is active. Wallet setup will finish automatically when you enter the app.',
                        fr: 'Votre compte Korido est actif. La configuration du portefeuille se terminera automatiquement dans l’application.',
                      ),
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Continue button
              AppButton(
                label: l10n.onboarding_success_continue,
                onPressed: () => _handleContinue(context, ref),
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContinue(BuildContext context, WidgetRef ref) {
    ref.read(signupFlowProvider.notifier).completeSignupFlow();
    context.fsmEnterAuthenticatedApp();
  }

  String _copy(BuildContext context, {required String en, required String fr}) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'fr' ? fr : en;
  }
}
