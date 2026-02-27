import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/index.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/features/merchant_pay/providers/merchant_provider.dart';
import 'package:usdc_wallet/features/merchant_pay/services/merchant_service.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Payment Confirm View
/// Bottom sheet for confirming merchant payment
class PaymentConfirmView extends ConsumerStatefulWidget {
  final String qrData;
  final QrDecodeResponse merchant;
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const PaymentConfirmView({
    super.key,
    required this.qrData,
    required this.merchant,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  ConsumerState<PaymentConfirmView> createState() => _PaymentConfirmViewState();
}

class _PaymentConfirmViewState extends ConsumerState<PaymentConfirmView> {
  final _amountController = TextEditingController();
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // If dynamic QR, pre-fill the amount
    if (widget.merchant.isDynamicQr && widget.merchant.amount != null) {
      _amountController.text = widget.merchant.amount!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _amount {
    if (widget.merchant.isDynamicQr) {
      return widget.merchant.amount;
    }
    return double.tryParse(_amountController.text);
  }

  bool get _canProceed {
    final amount = _amount;
    return amount != null && amount > 0 && amount <= 10000;
  }

  void _showPinConfirmation() async {
    final amount = _amount;
    if (amount == null) return;

    final result = await PinConfirmationSheet.show(
      context: context,
      title: 'Confirm Payment',
      subtitle: 'Enter your PIN to pay ${widget.merchant.displayName}',
      amount: amount,
      recipient: widget.merchant.displayName,
      onConfirm: (pin) async {
        final pinService = ref.read(pinServiceProvider);
        final result = await pinService.verifyPinWithBackend(pin);
        return result.success;
      },
    );

    if (result == PinConfirmationResult.success && mounted) {
      _processPayment();
    }
  }

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    final notifier = ref.read(scanToPayProvider.notifier);
    final success = await notifier.processPayment(
      qrData: widget.qrData,
      amount: widget.merchant.isStaticQr ? _amount : null,
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      if (success) {
        // Invalidate wallet balance to refresh
        ref.invalidate(walletBalanceProvider);
        widget.onSuccess();
      } else {
        final state = ref.read(scanToPayProvider);
        setState(() {
          _error = state.error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Merchant info
              _buildMerchantInfo(context),
              const SizedBox(height: AppSpacing.xxl),

              // Amount section
              _buildAmountSection(context),
              const SizedBox(height: AppSpacing.xxl),

              // Error message
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.errorBg,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    border: Border.all(color: context.colors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: context.colors.error, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.colors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: AppLocalizations.of(context)!.action_cancel,
                      onPressed: _isProcessing ? null : widget.onCancel,
                      variant: AppButtonVariant.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: 'Pay Now',
                      onPressed: _canProceed && !_isProcessing ? _showPinConfirmation : null,
                      isLoading: _isProcessing,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMerchantInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          // Merchant logo/icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: widget.merchant.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Image.network(
                      widget.merchant.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        _getCategoryIcon(widget.merchant.category),
                        color: theme.primaryColor,
                        size: 28,
                      ),
                    ),
                  )
                : Icon(
                    _getCategoryIcon(widget.merchant.category),
                    color: theme.primaryColor,
                    size: 28,
                  ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.merchant.displayName,
                        style: AppTypography.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.merchant.isVerified) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        Icons.verified,
                        color: Colors.blue.shade600,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatCategory(widget.merchant.category),
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.merchant.isDynamicQr && widget.merchant.amount != null) {
      // Dynamic QR - show fixed amount
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              'Amount to Pay',
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '\$${widget.merchant.amount!.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'USDC',
              style: AppTypography.bodyLarge.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Static QR - user enters amount
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Amount',
          style: AppTypography.titleSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
          child: Row(
            children: [
              Text(
                '\$ ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: context.colors.textSecondary.withValues(alpha: 0.5),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Min: \$0.01 | Max: \$10,000',
          style: AppTypography.labelMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'restaurant':
        return Icons.restaurant;
      case 'retail':
        return Icons.store;
      case 'grocery':
        return Icons.shopping_cart;
      case 'transport':
        return Icons.directions_car;
      case 'services':
        return Icons.handyman;
      case 'healthcare':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.business;
    }
  }

  String _formatCategory(String category) {
    return category[0].toUpperCase() + category.substring(1);
  }
}
