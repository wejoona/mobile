import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/onboarding_provider.dart';

/// KYC prompt screen
class KycPromptView extends ConsumerWidget {
  const KycPromptView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
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
                  color: AppColors.charcoal,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  size: 64,
                  color: AppColors.gold500,
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
                  color: AppColors.silver,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxl),
              // Benefits
              _buildBenefit(
                l10n.onboarding_kyc_benefit1,
                Icons.trending_up,
              ),
              SizedBox(height: AppSpacing.md),
              _buildBenefit(
                l10n.onboarding_kyc_benefit2,
                Icons.send_rounded,
              ),
              SizedBox(height: AppSpacing.md),
              _buildBenefit(
                l10n.onboarding_kyc_benefit3,
                Icons.lock_open_rounded,
              ),
              const Spacer(),
              // Verify now button
              AppButton(
                label: l10n.onboarding_kyc_verify,
                onPressed: () => _handleVerifyNow(context, ref),
                isFullWidth: true,
              ),
              SizedBox(height: AppSpacing.md),
              // Maybe later button
              TextButton(
                onPressed: () => _handleMaybeLater(context, ref),
                child: AppText(
                  l10n.onboarding_kyc_later,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.silver,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.silver.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.gold500.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: AppColors.gold500,
              size: 24,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              text,
              style: AppTypography.bodyMedium,
            ),
          ),
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 20,
          ),
        ],
      ),
    );
  }

  void _handleVerifyNow(BuildContext context, WidgetRef ref) {
    // Mark that user chose to verify (for tracking)
    ref.read(onboardingProvider.notifier).startKyc();
    // Navigate to KYC document type selection
    // After KYC submission, user will be redirected to home
    context.push('/kyc/document-type');
  }

  void _handleMaybeLater(BuildContext context, WidgetRef ref) {
    ref.read(onboardingProvider.notifier).skipKyc();
    context.go('/onboarding/success');
  }
}
