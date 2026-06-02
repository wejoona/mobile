import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/contacts/widgets/korido_account_badge.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/features/send/views/offline_queue_dialog.dart';
import 'package:usdc_wallet/features/wallet/widgets/risk_step_up_dialog.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/connectivity/connectivity_provider.dart';
import 'package:usdc_wallet/services/security/risk_based_security_service.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

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
          variant: AppTextVariant.titleLarge,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                children: [
                  // Summary card
                  AppCard(
                    variant: AppCardVariant.flat,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recipient section
                        _buildSectionHeader(l10n.send_recipient, colors),
                        SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            UserAvatar(
                              firstName:
                                  state.recipient!.name?.split(' ').first ??
                                  state.recipient!.phoneNumber,
                              lastName:
                                  state.recipient!.name != null &&
                                      state.recipient!.name!.split(' ').length >
                                          1
                                  ? state.recipient!.name!.split(' ').last
                                  : null,
                              size: 40,
                              showBorder: state.recipient!.isKoridoUser,
                              borderColor: colors.gold,
                            ),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: AppText(
                                          state.recipient!.name ??
                                              state.recipient!.phoneNumber,
                                          variant: AppTextVariant.bodyLarge,
                                          fontWeight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (state.recipient!.isKoridoUser) ...[
                                        SizedBox(width: AppSpacing.xs),
                                        const KoridoAccountBadge(),
                                      ],
                                    ],
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
                            AmountText.fromText(
                              formatUsdc(state.amount!),
                              size: AmountTextSize.large,
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
                              AmountText.fromText(
                                formatUsdc(state.fee),
                                size: AmountTextSize.small,
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
                            AmountText.fromText(
                              formatUsdc(state.total),
                              size: AmountTextSize.small,
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
                    variant: AppCardVariant.flat,
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: colors.gold, size: 20),
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
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: AppButton(
                label: l10n.send_confirmAndSend,
                onPressed: () async {
                  HapticFeedback.mediumImpact();

                  final latestState = ref.read(sendMoneyProvider);
                  if (await _queueDraftIfOffline(context, ref, latestState)) {
                    return;
                  }

                  try {
                    // Risk-based step-up evaluation
                    final securityService = ref.read(
                      riskBasedSecurityServiceProvider,
                    );
                    final decision = await securityService.evaluateTransaction(
                      type: 'transfer',
                      amount: state.amount!,
                      currency: 'USDC',
                      recipientId: state.recipient?.phoneNumber,
                      recipientType: 'internal',
                    );

                    if (decision.stepUpRequired) {
                      if (!context.mounted) return;
                      final passed = await RiskStepUpDialog.show(
                        context,
                        decision: decision,
                      );
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

  Future<bool> _queueDraftIfOffline(
    BuildContext context,
    WidgetRef ref,
    SendMoneyState state,
  ) async {
    if (ref.read(connectivityProvider).isOnline ||
        state.recipient == null ||
        state.amount == null) {
      return false;
    }

    await OfflineQueueDialog.show(
      context,
      ref,
      recipientName: state.recipient!.name,
      recipientPhone: state.recipient!.phoneNumber,
      amount: state.amount!,
      description: state.note,
    );
    return true;
  }
}
