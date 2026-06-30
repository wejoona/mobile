import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/contacts/widgets/korido_account_badge.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/features/send/views/offline_queue_dialog.dart';
import 'package:usdc_wallet/features/send/widgets/send_flow_visuals.dart';
import 'package:usdc_wallet/features/wallet/widgets/risk_step_up_dialog.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/connectivity/connectivity_provider.dart';
import 'package:usdc_wallet/services/security/risk_based_security_service.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

class ConfirmScreen extends ConsumerStatefulWidget {
  const ConfirmScreen({super.key});

  @override
  ConsumerState<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends ConsumerState<ConfirmScreen> {
  bool _isAuthorizing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sendMoneyProvider);
    final colors = context.colors;

    if (!state.canProceedToConfirm) {
      // Navigate back if incomplete
      Future.microtask(() => context.fsmGo('/send'));
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
                  SendFlowHeader(
                    icon: Icons.verified_outlined,
                    title: l10n.send_confirmTransfer,
                    subtitle: localizedSendCopy(
                      context,
                      en: 'Review carefully. Money leaves only after PIN approval.',
                      fr: 'Vérifiez attentivement. L’argent part uniquement après validation du PIN.',
                    ),
                    currentStep: 2,
                    metaLabel: sendStepLabel(context, 3),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Summary card
                  AppCard(
                    variant: AppCardVariant.elevated,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SendSectionTitle(l10n.send_recipient),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            UserAvatar(
                              firstName:
                                  state.recipient!.name?.split(' ').first ??
                                  state.recipient!.displayIdentifier,
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
                                              state
                                                  .recipient!
                                                  .displayIdentifier,
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
                                      state.recipient!.displayIdentifier,
                                      variant: AppTextVariant.bodySmall,
                                      color: colors.textSecondary,
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: localizedSendCopy(
                                context,
                                en: 'Edit recipient',
                                fr: 'Modifier le destinataire',
                              ),
                              icon: Icon(
                                Icons.edit_outlined,
                                color: colors.gold,
                                size: 20,
                              ),
                              onPressed: () => context.fsmGo('/send'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Amount section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: colors.elevated,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: colors.borderSubtle),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    l10n.send_amount,
                                    variant: AppTextVariant.bodySmall,
                                    color: colors.textSecondary,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  AmountText.fromText(
                                    formatUsdc(state.amount!),
                                    size: AmountTextSize.large,
                                    color: colors.gold,
                                  ),
                                ],
                              ),
                              IconButton(
                                tooltip: localizedSendCopy(
                                  context,
                                  en: 'Edit amount',
                                  fr: 'Modifier le montant',
                                ),
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: colors.gold,
                                  size: 20,
                                ),
                                onPressed: () => context.fsmGo('/send/amount'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        AppCard(
                          variant: AppCardVariant.flat,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          borderRadius: AppRadius.lg,
                          child: Column(
                            children: [
                              SendDetailRow(
                                label: l10n.send_fee,
                                value: '',
                                valueWidget: AmountText.fromText(
                                  formatUsdc(state.fee),
                                  size: AmountTextSize.small,
                                  color: colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              SendDetailRow(
                                label: l10n.send_total,
                                value: '',
                                valueWidget: AmountText.fromText(
                                  formatUsdc(state.total),
                                  size: AmountTextSize.small,
                                  color: colors.gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Note section (if provided)
                        if (state.note != null && state.note!.isNotEmpty) ...[
                          SendSectionTitle(l10n.send_note),
                          const SizedBox(height: AppSpacing.sm),
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

                  SendCallout(
                    icon: Icons.lock_outline,
                    title: l10n.send_pinVerificationRequired,
                    body: localizedSendCopy(
                      context,
                      en: 'No transfer is executed on this screen. The next step asks for your PIN.',
                      fr: 'Aucun transfert n’est exécuté sur cet écran. L’étape suivante demande votre PIN.',
                    ),
                    tone: SendCalloutTone.warning,
                  ),
                ],
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: AppButton(
                label: _isAuthorizing
                    ? localizedSendCopy(
                        context,
                        en: 'Checking security...',
                        fr: 'Vérification en cours...',
                      )
                    : localizedSendCopy(
                        context,
                        en: 'Continue to PIN',
                        fr: 'Continuer vers le PIN',
                      ),
                icon: Icons.lock_outline,
                onPressed: _isAuthorizing
                    ? null
                    : () => _continueToPin(context),
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continueToPin(BuildContext context) async {
    if (_isAuthorizing) {
      return;
    }

    setState(() => _isAuthorizing = true);
    unawaited(HapticFeedback.mediumImpact());

    try {
      final latestState = ref.read(sendMoneyProvider);
      if (await _queueDraftIfOffline(context, ref, latestState)) {
        return;
      }

      try {
        final sendNotifier = ref.read(sendMoneyProvider.notifier);
        sendNotifier.clearStepUpAuthorization();

        // Risk-based step-up evaluation.
        final securityService = ref.read(riskBasedSecurityServiceProvider);
        final riskRecipientId =
            latestState.recipient?.userId ??
            latestState.recipient?.username ??
            latestState.recipient?.phoneNumber;
        final amount = latestState.amount;
        if (amount == null || amount <= 0) {
          return;
        }

        final decision = await securityService.evaluateTransaction(
          type: 'transfer',
          amount: amount,
          currency: 'USDC',
          recipientId: riskRecipientId,
          recipientType: 'internal',
        );

        if (decision.stepUpRequired) {
          if (decision.stepUpType == StepUpType.manualReview) {
            if (!context.mounted) {
              return;
            }
            unawaited(HapticFeedback.heavyImpact());
            await RiskStepUpDialog.show(context, decision: decision);
            return;
          }

          if (!context.mounted) {
            return;
          }
          final passed = await RiskStepUpDialog.show(
            context,
            decision: decision,
          );
          if (!passed) {
            return;
          }
          final stepUpToken = decision.challengeToken?.trim();
          if (stepUpToken == null || stepUpToken.isEmpty) {
            if (!context.mounted) {
              return;
            }
            unawaited(HapticFeedback.heavyImpact());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  localizedSendCopy(
                    context,
                    en: 'Security challenge is incomplete. Please try again before sending money.',
                    fr: 'La vérification de sécurité est incomplète. Réessayez avant d’envoyer de l’argent.',
                  ),
                ),
                backgroundColor: context.colors.error,
              ),
            );
            return;
          }
          sendNotifier.markStepUpAuthorized(stepUpToken);
        }
      } on Object catch (_) {
        if (!context.mounted) {
          return;
        }
        unawaited(HapticFeedback.heavyImpact());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizedSendCopy(
                context,
                en: 'Security check unavailable. Please try again before sending money.',
                fr: 'La vérification de sécurité est indisponible. Réessayez avant d’envoyer de l’argent.',
              ),
            ),
            backgroundColor: context.colors.error,
          ),
        );
        return;
      }

      if (!context.mounted) {
        return;
      }
      unawaited(context.fsmPush('/send/pin'));
    } finally {
      if (mounted) {
        setState(() => _isAuthorizing = false);
      }
    }
  }

  Future<bool> _queueDraftIfOffline(
    BuildContext context,
    WidgetRef ref,
    SendMoneyState state,
  ) async {
    if (ref.read(connectivityProvider).isOnline ||
        state.recipient == null ||
        state.amount == null ||
        !state.recipient!.canSend) {
      return false;
    }

    if (mounted && _isAuthorizing) {
      setState(() => _isAuthorizing = false);
    }

    await OfflineQueueDialog.show(
      context,
      ref,
      recipientName: state.recipient!.name,
      recipientPhone: state.recipient!.phoneNumber,
      recipientId: state.recipient!.userId,
      recipientUsername: state.recipient!.username,
      amount: state.amount!,
      description: state.note,
    );
    return true;
  }
}
