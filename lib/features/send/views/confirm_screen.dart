import 'package:usdc_wallet/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/services/security/risk_based_security_service.dart';
import 'package:usdc_wallet/features/wallet/widgets/risk_step_up_dialog.dart';

class ConfirmScreen extends ConsumerWidget {
  const ConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sendMoneyProvider);
    final colors = context.colors;

    if (!state.canProceedToConfirm) {
      // Navigate back if incomplete
      Future.microtask(() => context.go('/send'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.send_confirmTransfer,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: [
                  // Summary card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recipient section
                        _buildSectionHeader(l10n.send_recipient, colors),
                        SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: colors.gold.withValues(alpha: 0.2),
                              child: Icon(
                                Icons.person_outline,
                                color: colors.gold,
                              ),
                            ),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    state.recipient!.name ??
                                        state.recipient!.phoneNumber,
                                    variant: AppTextVariant.bodyLarge,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  if (state.recipient!.name != null)
                                    AppText(
                                      state.recipient!.phoneNumber,
                                      variant: AppTextVariant.bodySmall,
                                      color: colors.textSecondary,
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                color: colors.gold,
                                size: 20,
                              ),
                              onPressed: () => context.go('/send'),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.lg),

                        // Amount section
                        _buildSectionHeader(l10n.send_amount, colors),
                        SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              '\$${Formatters.formatCurrency(state.amount!)}',
                              variant: AppTextVariant.headlineMedium,
                              color: colors.gold,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                color: colors.gold,
                                size: 20,
                              ),
                              onPressed: () => context.go('/send/amount'),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.md),

                        // Fee breakdown
                        if (state.fee > 0) ...[
                          Divider(
                            color: colors.textSecondary.withValues(alpha: 0.2),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                l10n.send_fee,
                                variant: AppTextVariant.bodyMedium,
                                color: colors.textSecondary,
                              ),
                              AppText(
                                '\$${Formatters.formatCurrency(state.fee)}',
                                variant: AppTextVariant.bodyMedium,
                                color: colors.textSecondary,
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.sm),
                        ],

                        Divider(
                          color: colors.textSecondary.withValues(alpha: 0.2),
                        ),
                        SizedBox(height: AppSpacing.sm),

                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              l10n.send_total,
                              variant: AppTextVariant.bodyLarge,
                              fontWeight: FontWeight.w600,
                            ),
                            AppText(
                              '\$${Formatters.formatCurrency(state.total)}',
                              variant: AppTextVariant.bodyLarge,
                              fontWeight: FontWeight.w600,
                              color: colors.gold,
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.lg),

                        // Note section (if provided)
                        if (state.note != null && state.note!.isNotEmpty) ...[
                          _buildSectionHeader(l10n.send_note, colors),
                          SizedBox(height: AppSpacing.sm),
                          AppText(
                            state.note!,
                            variant: AppTextVariant.bodyMedium,
                            color: colors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Info message
                  AppCard(
                    variant: AppCardVariant.subtle,
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colors.gold,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppText(
                            l10n.send_pinVerificationRequired,
                            variant: AppTextVariant.bodySmall,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom button
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: AppButton(
                label: l10n.send_confirmAndSend,
                onPressed: () async {
                  HapticFeedback.mediumImpact();

                  try {
                    // Risk-based step-up evaluation
                    final securityService = ref.read(riskBasedSecurityServiceProvider);
                    final decision = await securityService.evaluateTransaction(
                      type: 'transfer',
                      amount: state.amount!,
                      currency: 'USDC',
                      recipientId: state.recipient?.phoneNumber,
                      recipientType: 'internal',
                    );

                    if (decision.stepUpRequired) {
                      if (!context.mounted) return;
                      final passed = await RiskStepUpDialog.show(context, decision: decision);
                      if (!passed) return;
                    }
                  } catch (e) {
                    // If risk evaluation fails, still allow proceeding to PIN
                    // (PIN verification is the minimum required security)
                  }

                  if (!context.mounted) return;
                  context.push('/send/pin');
                },
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text, ThemeColors colors) {
    return AppText(
      text,
      variant: AppTextVariant.labelSmall,
      color: colors.textSecondary,
    );
  }
}
