import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/utils/formatters.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/contacts/widgets/korido_account_badge.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/features/send/widgets/pin_input_widget.dart';
import 'package:usdc_wallet/features/send/views/offline_queue_dialog.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/services/offline/offline_queue_interceptor.dart';

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

                    if (!isKeyboardOpen) ...[
                      Container(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: context.colors.gold.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: 48,
                          color: context.colors.gold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                    ],

                    AppText(
                      l10n.send_enterPinToConfirm,
                      variant: AppTextVariant.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.sm),

                    AppText(
                      l10n.send_pinVerificationDescription,
                      variant: AppTextVariant.bodyMedium,
                      color: context.colors.textSecondary,
                      textAlign: TextAlign.center,
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

                    PinInputWidget(
                      length: 6,
                      onChanged: (pin) {
                        setState(() {
                          _error = null;
                        });
                      },
                      onCompleted: _handlePinComplete,
                      error: _error,
                    ),
                    SizedBox(height: AppSpacing.lg),

                    if (_error != null)
                      AppText(
                        _error!,
                        variant: AppTextVariant.bodySmall,
                        color: context.colors.error,
                        textAlign: TextAlign.center,
                      ),

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
      variant: AppCardVariant.subtle,
      child: Column(
        children: [
          _summaryRow(
            l10n.send_recipient,
            state.recipient?.name ?? state.recipient?.phoneNumber ?? '',
            colors,
            trailing: state.recipient?.isKoridoUser == true
                ? const KoridoAccountBadge(compact: true)
                : null,
          ),
          SizedBox(height: AppSpacing.sm),
          _summaryRow(
            l10n.send_amount,
            '\$${Formatters.formatCurrency(state.amount ?? 0)}',
            colors,
            isAmount: true,
          ),
          SizedBox(height: AppSpacing.sm),
          _summaryRow(
            l10n.send_fee,
            '\$${Formatters.formatCurrency(state.fee)}',
            colors,
          ),
          Divider(height: AppSpacing.lg, color: colors.borderSubtle),
          _summaryRow(
            l10n.send_total,
            '\$${Formatters.formatCurrency(state.total)}',
            colors,
            isAmount: true,
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: colors.warningText),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText(
                  'Transfers cannot be reversed after confirmation.',
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ),
            ],
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
          context.go('/send/result');
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
          context.go('/send/result');
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
        state.amount == null) {
      return false;
    }

    setState(() => _isLoading = false);
    await OfflineQueueDialog.show(
      context,
      ref,
      recipientName: state.recipient!.name,
      recipientPhone: state.recipient!.phoneNumber,
      amount: state.amount!,
      description: state.note,
    );
    ref.read(sendMoneyProvider.notifier).clearError();
    return true;
  }
}
