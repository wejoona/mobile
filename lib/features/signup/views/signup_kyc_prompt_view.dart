import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/signup/providers/signup_flow_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// KYC prompt screen for explicit account signup.
class SignupKycPromptView extends ConsumerWidget {
  const SignupKycPromptView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: context.colors.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  size: 64,
                  color: context.colors.gold,
                ),
              ),
              SizedBox(height: AppSpacing.xxl),
              // Title
              AppText(
                l10n.onboarding_kyc_title,
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              // Subtitle
              AppText(
                l10n.onboarding_kyc_subtitle,
                style: AppTypography.bodyLarge.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxl),
              // Benefits
              _buildBenefit(
                context,
                l10n.onboarding_kyc_benefit1,
                Icons.trending_up,
              ),
              SizedBox(height: AppSpacing.md),
              _buildBenefit(
                context,
                l10n.onboarding_kyc_benefit2,
                Icons.send_rounded,
              ),
              SizedBox(height: AppSpacing.md),
              _buildBenefit(
                context,
                l10n.onboarding_kyc_benefit3,
                Icons.lock_open_rounded,
              ),
              const Spacer(),
              // Verify now button
              AppButton(
                label: l10n.onboarding_kyc_verify,
                onPressed: () => unawaited(_handleVerifyNow(context, ref)),
                isFullWidth: true,
              ),
              SizedBox(height: AppSpacing.md),
              // Maybe later button
              TextButton(
                onPressed: () => unawaited(_handleMaybeLater(context, ref)),
                child: AppText(
                  l10n.onboarding_kyc_later,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(BuildContext context, String text, IconData icon) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: colors.gold, size: 24),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(child: AppText(text, style: AppTypography.bodyMedium)),
          Icon(Icons.check_circle, color: colors.success, size: 20),
        ],
      ),
    );
  }

  Future<void> _handleVerifyNow(BuildContext context, WidgetRef ref) async {
    await ref.read(signupFlowProvider.notifier).startKyc();
    if (context.mounted) {
      context.fsmGo('/kyc/document-type');
    }
  }

  Future<void> _handleMaybeLater(BuildContext context, WidgetRef ref) async {
    await ref.read(signupFlowProvider.notifier).skipKyc();
    if (context.mounted) {
      context.fsmGo('/signup/success');
    }
  }
}
