import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/fsm/wallet_fsm.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Wallet Frozen View
/// Shown when wallet has been frozen by compliance
class WalletFrozenView extends ConsumerWidget {
  const WalletFrozenView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final walletState = ref.watch(appFsmProvider).wallet;

    String reason = l10n.wallet_frozenReason;
    bool isPermanent = true;
    DateTime? frozenUntil;

    if (walletState is WalletFrozen) {
      reason = walletState.reason;
      isPermanent = walletState.isPermanent;
      frozenUntil = walletState.frozenUntil;
    }

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.wallet_frozen,
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
                        SizedBox(height: AppSpacing.xxl),
                        Icon(
                          Icons.ac_unit,
                          size: 80,
                          color: AppColors.error,
                        ),
                        SizedBox(height: AppSpacing.xl),
                        AppText(
                          l10n.wallet_frozenTitle,
                          variant: AppTextVariant.headlineMedium,
                          color: context.colors.textPrimary,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.md),
                        AppText(
                          reason,
                          variant: AppTextVariant.bodyLarge,
                          color: context.colors.textSecondary,
                          textAlign: TextAlign.center,
                        ),
                        if (!isPermanent && frozenUntil != null) ...[
                          SizedBox(height: AppSpacing.lg),
                          Container(
                            padding: EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: context.colors.elevated,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: context.colors.border),
                            ),
                            child: Column(
                              children: [
                                AppText(
                                  l10n.wallet_frozenUntil,
                                  variant: AppTextVariant.labelSmall,
                                  color: context.colors.textSecondary,
                                ),
                                SizedBox(height: AppSpacing.xs),
                                AppText(
                                  _formatDate(frozenUntil),
                                  variant: AppTextVariant.bodyLarge,
                                  color: context.colors.gold,
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: AppSpacing.xl),
                        AppCard(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              Icon(
                                Icons.support_agent,
                                size: 40,
                                color: context.colors.gold,
                              ),
                              SizedBox(height: AppSpacing.md),
                              AppText(
                                l10n.wallet_frozenContactSupport,
                                variant: AppTextVariant.bodyMedium,
                                color: context.colors.textPrimary,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppSpacing.sm),
                              AppText(
                                l10n.wallet_frozenContactMessage,
                                variant: AppTextVariant.bodySmall,
                                color: context.colors.textSecondary,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        AppButton(
                          label: l10n.common_contactSupport,
                          onPressed: () => _launchSupport(),
                          isFullWidth: true,
                        ),
                        SizedBox(height: AppSpacing.md),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _launchSupport() async {
    final uri = Uri.parse('mailto:support@joonapay.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
