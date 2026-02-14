import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/fsm/wallet_fsm.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Wallet Under Review View
/// Shown when wallet is under compliance review
class WalletUnderReviewView extends ConsumerWidget {
  const WalletUnderReviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final walletState = ref.watch(appFsmProvider).wallet;

    String reason = l10n.wallet_underReviewReason;
    DateTime? reviewStartedAt;

    if (walletState is WalletUnderReview) {
      reason = walletState.reason;
      reviewStartedAt = walletState.reviewStartedAt;
    }

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.wallet_underReview,
          variant: AppTextVariant.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: AppSpacing.xl),
                        Icon(
                          Icons.hourglass_empty,
                          size: 64,
                          color: context.colors.warning,
                        ),
                        SizedBox(height: AppSpacing.lg),
                        AppText(
                          l10n.wallet_underReviewTitle,
                          variant: AppTextVariant.headlineMedium,
                          color: context.colors.textPrimary,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        AppText(
                          reason,
                          variant: AppTextVariant.bodyMedium,
                          color: context.colors.textSecondary,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.xl),
                        AppCard(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: context.colors.gold, size: 20),
                                  SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: AppText(
                                      l10n.wallet_reviewStatus,
                                      variant: AppTextVariant.bodySmall,
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.sm),
                              _buildInfoRow(
                                l10n.wallet_reviewStarted,
                                reviewStartedAt != null ? _formatDate(reviewStartedAt) : '-',
                              ),
                              SizedBox(height: AppSpacing.xs),
                              _buildInfoRow(
                                l10n.wallet_estimatedTime,
                                l10n.wallet_reviewEstimate,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSpacing.md),
                        AppCard(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                l10n.wallet_whileUnderReview,
                                variant: AppTextVariant.bodySmall,
                                color: context.colors.textPrimary,
                              ),
                              SizedBox(height: AppSpacing.xs),
                              _buildBulletPoint(l10n.wallet_reviewRestriction1),
                              _buildBulletPoint(l10n.wallet_reviewRestriction2),
                              _buildBulletPoint(l10n.wallet_reviewRestriction3),
                            ],
                          ),
                        ),
                        const Spacer(),
                        SizedBox(height: AppSpacing.md),
                        AppButton(
                          label: l10n.wallet_checkStatus,
                          onPressed: () {
                            ref.read(appFsmProvider.notifier).dispatch(
                                  const AppWalletEvent(WalletRefresh()),
                                );
                          },
                          isFullWidth: true,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        AppButton(
                          label: l10n.common_backToHome,
                          onPressed: () => Navigator.of(context).pop(),
                          variant: AppButtonVariant.secondary,
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: AppTextVariant.bodySmall,
          color: AppColors.textSecondary,
        ),
        AppText(
          value,
          variant: AppTextVariant.bodySmall,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText('• ', variant: AppTextVariant.bodySmall, color: AppColors.gold500),
          Expanded(
            child: AppText(
              text,
              variant: AppTextVariant.bodySmall,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
