import 'package:usdc_wallet/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/send_external/providers/external_transfer_provider.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class ExternalConfirmScreen extends ConsumerStatefulWidget {
  const ExternalConfirmScreen({super.key});

  @override
  ConsumerState<ExternalConfirmScreen> createState() => _ExternalConfirmScreenState();
}

class _ExternalConfirmScreenState extends ConsumerState<ExternalConfirmScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(externalTransferProvider);

    if (!state.canProceedToConfirm) {
      // Navigate back if invalid state
      Future.microtask(() => context.go('/send-external'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.sendExternal_confirmTransfer,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Warning card
                  Container(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: context.colors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: context.colors.warning.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: context.colors.warning,
                          size: 24,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                l10n.sendExternal_warningTitle,
                                variant: AppTextVariant.bodyMedium,
                                fontWeight: FontWeight.w600,
                                color: context.colors.warning,
                              ),
                              SizedBox(height: AppSpacing.xs),
                              AppText(
                                l10n.sendExternal_warningMessage,
                                variant: AppTextVariant.bodySmall,
                                color: context.colors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl),

                  // Transfer summary
                  AppText(
                    l10n.sendExternal_transferSummary,
                    variant: AppTextVariant.labelLarge,
                    color: context.colors.textSecondary,
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // Details card
                  AppCard(
                    child: Column(
                      children: [
                        // Recipient address
                        _buildDetailRow(
                          l10n.sendExternal_recipientAddress,
                          state.address!,
                          isCopyable: true,
                          isMonospace: true,
                        ),
                        Divider(
                          height: AppSpacing.lg * 2,
                          color: context.colors.textSecondary.withValues(alpha: 0.2),
                        ),

                        // Network
                        _buildDetailRow(
                          l10n.sendExternal_network,
                          state.selectedNetwork.displayName,
                        ),
                        Divider(
                          height: AppSpacing.lg * 2,
                          color: context.colors.textSecondary.withValues(alpha: 0.2),
                        ),

                        // Amount
                        _buildDetailRow(
                          l10n.sendExternal_amount,
                          '\$${Formatters.formatCurrency(state.amount!)}',
                          isHighlighted: true,
                        ),
                        Divider(
                          height: AppSpacing.lg * 2,
                          color: context.colors.textSecondary.withValues(alpha: 0.2),
                        ),

                        // Network fee
                        _buildDetailRow(
                          l10n.sendExternal_networkFee,
                          '\$${Formatters.formatCurrency(state.estimatedFee)}',
                        ),
                        Divider(
                          height: AppSpacing.lg * 2,
                          color: context.colors.textSecondary.withValues(alpha: 0.2),
                        ),

                        // Total
                        _buildDetailRow(
                          l10n.sendExternal_totalDeducted,
                          '\$${Formatters.formatCurrency(state.total)}',
                          isHighlighted: true,
                          isLarge: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // Estimated time card
                  AppCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: context.colors.gold,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                l10n.sendExternal_estimatedTime,
                                variant: AppTextVariant.bodySmall,
                                color: context.colors.textSecondary,
                              ),
                              AppText(
                                state.selectedNetwork.estimatedTime,
                                variant: AppTextVariant.bodyMedium,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Error message
            if (state.error != null)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.colors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: context.colors.error,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppText(
                          state.error!,
                          variant: AppTextVariant.bodySmall,
                          color: context.colors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom button
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: AppButton(
                label: l10n.sendExternal_confirmAndSend,
                onPressed: _handleConfirm,
                isLoading: _isLoading,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlighted = false,
    bool isLarge = false,
    bool isCopyable = false,
    bool isMonospace = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: isLarge ? AppTextVariant.bodyLarge : AppTextVariant.bodyMedium,
          color: context.colors.textSecondary,
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: AppText(
                  value,
                  variant: isMonospace
                      ? (isLarge ? AppTextVariant.monoLarge : AppTextVariant.monoMedium)
                      : (isLarge ? AppTextVariant.bodyLarge : AppTextVariant.bodyMedium),
                  fontWeight: isHighlighted || isLarge ? FontWeight.w600 : FontWeight.normal,
                  color: isHighlighted ? context.colors.gold : context.colors.textPrimary,
                  textAlign: TextAlign.right,
                ),
              ),
              if (isCopyable) ...[
                SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: () => _copyToClipboard(value),
                  child: Icon(
                    Icons.copy,
                    size: 16,
                    color: context.colors.gold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.sendExternal_addressCopied),
        backgroundColor: context.colors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleConfirm() async {
    // Require PIN/biometric verification before executing irreversible blockchain transfer
    final verified = await _verifyIdentity();
    if (!verified || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final success = await ref.read(externalTransferProvider.notifier).executeTransfer();

      if (mounted) {
        if (success) {
          context.go('/send-external/result');
        } else {
          // Error is already set in state and displayed
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Verify user identity via PIN or biometric before executing external transfer
  Future<bool> _verifyIdentity() async {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    // Try biometric first if available
    final biometricService = ref.read(biometricServiceProvider);
    final biometricAvailable = await biometricService.canCheckBiometrics();
    final biometricEnabled = await biometricService.isBiometricEnabled();

    if (biometricAvailable && biometricEnabled) {
      final result = await biometricService.authenticate(
        localizedReason: l10n.send_biometricReason,
      );
      if (result.success) return true;
      // Fall through to PIN if biometric fails/cancelled
    }

    // Show PIN dialog
    if (!mounted) return false;
    final pinResult = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PinVerificationDialog(ref: ref),
    );

    return pinResult == true;
  }
}

/// PIN verification dialog for external transfers
class _PinVerificationDialog extends StatefulWidget {
  final WidgetRef ref;

  const _PinVerificationDialog({required this.ref});

  @override
  State<_PinVerificationDialog> createState() => _PinVerificationDialogState();
}

class _PinVerificationDialogState extends State<_PinVerificationDialog> {
  final _pinController = TextEditingController();
  bool _isVerifying = false;
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      title: Row(
        children: [
          Icon(Icons.lock_outline, color: colors.gold, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              l10n.send_verifyPin,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            l10n.send_enterPinToConfirm,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium.copyWith(
              color: colors.textPrimary,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••••',
              hintStyle: TextStyle(color: colors.textTertiary, letterSpacing: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: colors.gold, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: colors.error),
              ),
              errorText: _error,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onChanged: (value) {
              if (_error != null) setState(() => _error = null);
              if (value.length == 6) _verifyPin(value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.pop(context, false),
          child: AppText(
            l10n.action_cancel,
            variant: AppTextVariant.labelMedium,
            color: colors.textSecondary,
          ),
        ),
        if (_isVerifying)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: colors.gold),
            ),
          ),
      ],
    );
  }

  Future<void> _verifyPin(String pin) async {
    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final pinService = widget.ref.read(pinServiceProvider);
      final result = await pinService.verifyPinLocally(pin);

      if (mounted) {
        if (result.success) {
          Navigator.pop(context, true);
        } else {
          setState(() {
            _error = result.message ?? 'PIN incorrect';
            _isVerifying = false;
            _pinController.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isVerifying = false;
          _pinController.clear();
        });
      }
    }
  }
}
