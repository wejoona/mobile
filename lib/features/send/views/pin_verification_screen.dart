import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/utils/formatters.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/contacts/widgets/korido_account_badge.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/features/send/widgets/pin_input_widget.dart';
import 'package:usdc_wallet/features/send/widgets/send_flow_visuals.dart';
import 'package:usdc_wallet/features/send/views/offline_queue_dialog.dart';
import 'package:usdc_wallet/services/offline/offline_queue_interceptor.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

class PinVerificationScreen extends ConsumerStatefulWidget {
  const PinVerificationScreen({super.key});

  @override
  ConsumerState<PinVerificationScreen> createState() =>
      _PinVerificationScreenState();
}

class _PinVerificationScreenState extends ConsumerState<PinVerificationScreen> {
  bool _isLoading = false;
  String? _error;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final biometricService = ref.read(biometricServiceProvider);
    final available = await biometricService.canCheckBiometrics();
    if (mounted) {
      setState(() => _biometricAvailable = available);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sendMoneyProvider);

    if (!state.canProceedToConfirm) {
      final recoveryRoute = _sendDraftRecoveryRoute(state);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.fsmGo(recoveryRoute);
        }
      });
      return Scaffold(
        backgroundColor: context.colors.canvas,
        body: SafeArea(
          child: _MissingSendAuthorizationState(
            title: localizedSendCopy(
              context,
              en: 'Transfer details needed',
              fr: 'Détails du transfert requis',
            ),
            body: localizedSendCopy(
              context,
              en: 'Choose a recipient and amount before confirming with PIN.',
              fr: 'Choisissez un destinataire et un montant avant de confirmer avec le PIN.',
            ),
            actionLabel: state.recipient == null
                ? l10n.send_selectRecipient
                : l10n.send_enterAmount,
            onAction: () => context.fsmGo(recoveryRoute),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.send_verifyPin,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
            final isKeyboardOpen = keyboardInset > 0;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.lg + keyboardInset,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: isKeyboardOpen ? AppSpacing.sm : AppSpacing.xl,
                    ),

                    SendFlowHeader(
                      icon: Icons.lock_outline,
                      title: l10n.send_enterPinToConfirm,
                      subtitle: localizedSendCopy(
                        context,
                        en: 'This is the final authorization. Confirm only after reviewing the amount and recipient.',
                        fr: 'C’est l’autorisation finale. Confirmez seulement après avoir vérifié le montant et le destinataire.',
                      ),
                      currentStep: 3,
                      metaLabel: sendStepLabel(context, 4),
                    ),
                    SizedBox(
                      height: isKeyboardOpen ? AppSpacing.md : AppSpacing.xl,
                    ),

                    if (state.canProceedToConfirm) ...[
                      _buildTransferSummary(context, l10n, state),
                      SizedBox(
                        height: isKeyboardOpen ? AppSpacing.md : AppSpacing.xl,
                      ),
                    ],

                    AppCard(
                      variant: AppCardVariant.elevated,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.xl,
                      ),
                      child: PinInputWidget(
                        length: 6,
                        onChanged: (pin) {
                          setState(() {
                            _error = null;
                          });
                        },
                        onCompleted: _handlePinComplete,
                        error: _error,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),

                    if (_biometricAvailable) ...[
                      SizedBox(height: AppSpacing.md),
                      TextButton.icon(
                        onPressed: _handleBiometric,
                        icon: Icon(
                          Icons.fingerprint,
                          color: context.colors.gold,
                        ),
                        label: AppText(
                          l10n.send_useBiometric,
                          variant: AppTextVariant.bodyMedium,
                          color: context.colors.gold,
                        ),
                      ),
                    ],

                    if (_isLoading) ...[
                      SizedBox(height: AppSpacing.md),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.colors.gold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransferSummary(
    BuildContext context,
    AppLocalizations l10n,
    SendMoneyState state,
  ) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.flat,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _summaryRow(
            l10n.send_recipient,
            state.recipient?.name ?? state.recipient?.displayIdentifier ?? '',
            colors,
            trailing: state.recipient?.isKoridoUser == true
                ? const KoridoAccountBadge(compact: true)
                : null,
          ),
          SizedBox(height: AppSpacing.sm),
          _summaryRow(
            l10n.send_amount,
            '${Formatters.formatCurrency(state.amount ?? 0)} USDC',
            colors,
            isAmount: true,
          ),
          SizedBox(height: AppSpacing.sm),
          _summaryRow(
            l10n.send_fee,
            '${Formatters.formatCurrency(state.fee)} USDC',
            colors,
          ),
          Divider(height: AppSpacing.lg, color: colors.borderSubtle),
          _summaryRow(
            l10n.send_total,
            '${Formatters.formatCurrency(state.total)} USDC',
            colors,
            isAmount: true,
          ),
          SizedBox(height: AppSpacing.md),
          SendCallout(
            icon: Icons.warning_amber_outlined,
            title: localizedSendCopy(
              context,
              en: 'Final authorization',
              fr: 'Autorisation finale',
            ),
            body: localizedSendCopy(
              context,
              en: 'Transfers cannot be reversed after PIN confirmation.',
              fr: 'Les transferts ne peuvent pas être annulés après confirmation du PIN.',
            ),
            tone: SendCalloutTone.warning,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    ThemeColors colors, {
    bool isAmount = false,
    Widget? trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: AppTextVariant.bodySmall,
          color: colors.textSecondary,
        ),
        SizedBox(width: AppSpacing.md),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: AppText(
                  value,
                  variant: isAmount
                      ? AppTextVariant.titleMedium
                      : AppTextVariant.bodyMedium,
                  color: isAmount ? colors.gold : colors.textPrimary,
                  textAlign: TextAlign.right,
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: AppSpacing.xs),
                trailing,
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handlePinComplete(String pin) async {
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sendNotifier = ref.read(sendMoneyProvider.notifier);
      final verified = await sendNotifier.verifyPin(pin);

      if (!verified) {
        final state = ref.read(sendMoneyProvider);
        setState(() {
          _error = state.error ?? l10n.error_pinIncorrect;
          _isLoading = false;
        });
        return;
      }

      // Execute transfer
      final success = await sendNotifier.executeTransfer();

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          context.fsmGo('/send/result');
        } else {
          final state = ref.read(sendMoneyProvider);
          if (await _queueOfflineTransferIfEligible(state)) return;
          setState(() {
            _error = state.error ?? l10n.error_transferFailed;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometric() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final biometricService = ref.read(biometricServiceProvider);
      final authenticatedBio = await biometricService.authenticate(
        localizedReason: l10n.send_biometricReason,
      );

      if (!authenticatedBio.success) {
        setState(() {
          _error = l10n.error_biometricFailed;
          _isLoading = false;
        });
        return;
      }

      final sendNotifier = ref.read(sendMoneyProvider.notifier);
      final hasValidToken = await sendNotifier.useExistingPinToken();
      if (!hasValidToken) {
        setState(() {
          _error = 'PIN is required';
          _isLoading = false;
        });
        return;
      }

      // Execute transfer
      final success = await sendNotifier.executeTransfer();

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          context.fsmGo('/send/result');
        } else {
          final state = ref.read(sendMoneyProvider);
          if (await _queueOfflineTransferIfEligible(state)) return;
          setState(() {
            _error = state.error ?? l10n.error_transferFailed;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _queueOfflineTransferIfEligible(SendMoneyState state) async {
    if (!isOfflineQueueableErrorMessage(state.error) ||
        state.recipient == null ||
        state.amount == null ||
        !state.recipient!.canSend) {
      return false;
    }

    setState(() => _isLoading = false);
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
    ref.read(sendMoneyProvider.notifier).clearError();
    return true;
  }
}

String _sendDraftRecoveryRoute(SendMoneyState state) {
  if (state.recipient == null) {
    return '/send';
  }
  return '/send/amount';
}

class _MissingSendAuthorizationState extends StatelessWidget {
  const _MissingSendAuthorizationState({
    required String title,
    required String body,
    required String actionLabel,
    required VoidCallback onAction,
  }) : _title = title,
       _body = body,
       _actionLabel = actionLabel,
       _onAction = onAction;

  final String _title;
  final String _body;
  final String _actionLabel;
  final VoidCallback _onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Center(
        child: AppCard(
          variant: AppCardVariant.flat,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 48, color: colors.gold),
              const SizedBox(height: AppSpacing.lg),
              AppText(
                _title,
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                _body,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: _actionLabel,
                onPressed: _onAction,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
