/// Example usage patterns for liveness check integration
/// This file demonstrates how to integrate liveness checks in various flows

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design/tokens/index.dart';
import '../../design/components/primitives/index.dart';
import '../../services/liveness/liveness_service.dart';
import '../../services/security/security_guard_service.dart';
import 'widgets/liveness_check_widget.dart';

// ============================================================================
// Example 1: Account Recovery with Liveness Check
// ============================================================================

class AccountRecoveryExample extends ConsumerWidget {
  const AccountRecoveryExample({super.key});

  Future<void> _startRecoveryWithLiveness(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // Use security guard to require liveness
      final securityGuard = ref.read(securityGuardServiceProvider);
      await securityGuard.guardAccountRecovery();

      // Show liveness check dialog
      final result = await showDialog<LivenessResult>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: LivenessCheckWidget(
            purpose: 'recovery',
            onCancel: () => Navigator.of(context).pop(),
            onComplete: (result) => Navigator.of(context).pop(result),
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  backgroundColor: AppColors.errorBase,
                ),
              );
            },
          ),
        ),
      );

      if (result != null && result.isLive) {
        // Proceed with account recovery
        await _processRecovery(result.sessionId);
      }
    } catch (e) {
      // Handle error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recovery failed: $e'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    }
  }

  Future<void> _processRecovery(String livenessSessionId) async {
    // Call recovery API with liveness session ID
    // POST /auth/recover { livenessSessionId }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Recovery')),
      body: Center(
        child: AppButton(
          label: 'Start Recovery',
          onPressed: () => _startRecoveryWithLiveness(context, ref),
          variant: AppButtonVariant.primary,
        ),
      ),
    );
  }
}

// ============================================================================
// Example 2: High-Value Transfer with Biometric + Liveness
// ============================================================================

class HighValueTransferExample extends ConsumerStatefulWidget {
  final double amount;
  final String recipientAddress;

  const HighValueTransferExample({
    super.key,
    required this.amount,
    required this.recipientAddress,
  });

  @override
  ConsumerState<HighValueTransferExample> createState() =>
      _HighValueTransferExampleState();
}

class _HighValueTransferExampleState
    extends ConsumerState<HighValueTransferExample> {
  bool _isProcessing = false;
  String? _livenessSessionId;

  Future<void> _initiateTransfer() async {
    setState(() => _isProcessing = true);

    try {
      final securityGuard = ref.read(securityGuardServiceProvider);

      // For transfers > $500, this requires both biometric AND liveness
      await securityGuard.guardExternalTransfer(widget.amount);

      // If amount requires liveness, show the check
      if (widget.amount >= SecurityGuardService.highValueTransferThreshold) {
        await _showLivenessCheck();
      }

      if (widget.amount >= SecurityGuardService.highValueTransferThreshold &&
          _livenessSessionId == null) {
        // User cancelled liveness check
        return;
      }

      // Process transfer
      await _executeTransfer();
    } on BiometricAuthenticationFailedException catch (e) {
      _showError('Biometric authentication required: $e');
    } on LivenessCheckFailedException catch (e) {
      _showError('Liveness check failed: $e');
    } catch (e) {
      _showError('Transfer failed: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _showLivenessCheck() async {
    final result = await showDialog<LivenessResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: LivenessCheckWidget(
          purpose: 'withdrawal',
          onCancel: () => Navigator.of(context).pop(),
          onComplete: (result) => Navigator.of(context).pop(result),
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: AppColors.errorBase,
              ),
            );
          },
        ),
      ),
    );

    if (result != null && result.isLive) {
      setState(() {
        _livenessSessionId = result.sessionId;
      });
    }
  }

  Future<void> _executeTransfer() async {
    // Call transfer API
    // POST /transfers/external {
    //   recipientAddress,
    //   amount,
    //   livenessSessionId (if required)
    // }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.errorBase,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Transfer')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            AppText(
              'Transfer \$${widget.amount.toStringAsFixed(2)}',
              variant: AppTextVariant.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              'To: ${widget.recipientAddress}',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
            ),
            const Spacer(),
            if (widget.amount >= SecurityGuardService.highValueTransferThreshold)
              const AppCard(
                variant: AppCardVariant.subtle,
                child: Row(
                  children: [
                    Icon(Icons.security, color: AppColors.infoBase),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        'High-value transfer requires biometric and liveness verification',
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Confirm Transfer',
              onPressed: _isProcessing ? null : _initiateTransfer,
              variant: AppButtonVariant.primary,
              isLoading: _isProcessing,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Example 3: First Withdrawal to New Address
// ============================================================================

class FirstWithdrawalExample extends ConsumerStatefulWidget {
  final String newAddress;
  final double amount;

  const FirstWithdrawalExample({
    super.key,
    required this.newAddress,
    required this.amount,
  });

  @override
  ConsumerState<FirstWithdrawalExample> createState() =>
      _FirstWithdrawalExampleState();
}

class _FirstWithdrawalExampleState
    extends ConsumerState<FirstWithdrawalExample> {
  Future<void> _confirmFirstWithdrawal() async {
    try {
      final securityGuard = ref.read(securityGuardServiceProvider);

      // Require biometric for first withdrawal to new address
      await securityGuard.guardFirstWithdrawal(
        recipientAddress: widget.newAddress,
        amount: widget.amount,
      );

      // Process withdrawal
      await _processWithdrawal();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Withdrawal successful'),
            backgroundColor: AppColors.successBase,
          ),
        );
      }
    } on BiometricAuthenticationFailedException catch (e) {
      _showError('Biometric verification required: $e');
    } catch (e) {
      _showError('Withdrawal failed: $e');
    }
  }

  Future<void> _processWithdrawal() async {
    // Process the withdrawal
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.errorBase,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Withdrawal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.new_releases,
              color: AppColors.warningBase,
              size: 64,
            ),
            const SizedBox(height: AppSpacing.xl),
            const AppText(
              'First Withdrawal to New Address',
              variant: AppTextVariant.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            const AppText(
              'Biometric verification required for security',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Verify & Withdraw',
              onPressed: _confirmFirstWithdrawal,
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Example 4: Standalone Liveness Check (Reusable Pattern)
// ============================================================================

/// Helper function to show liveness check and return result
Future<LivenessResult?> showLivenessCheckDialog(
  BuildContext context, {
  required String purpose,
}) async {
  return showDialog<LivenessResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: LivenessCheckWidget(
        purpose: purpose,
        onCancel: () => Navigator.of(context).pop(),
        onComplete: (result) => Navigator.of(context).pop(result),
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: AppColors.errorBase,
            ),
          );
        },
      ),
    ),
  );
}

// Usage:
// final result = await showLivenessCheckDialog(context, purpose: 'kyc');
// if (result?.isLive == true) {
//   // Proceed
// }
