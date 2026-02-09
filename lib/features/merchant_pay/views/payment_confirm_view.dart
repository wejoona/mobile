import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/index.dart';
import '../../../design/components/composed/pin_confirmation_sheet.dart';
import '../../../services/pin/pin_service.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../providers/merchant_provider.dart';
import '../services/merchant_service.dart';

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
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Merchant info
              _buildMerchantInfo(theme),
              const SizedBox(height: 24),

              // Amount section
              _buildAmountSection(theme),
              const SizedBox(height: 24),

              // Error message
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isProcessing ? null : widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _canProceed && !_isProcessing
                          ? _showPinConfirmation
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text(
                              'Pay Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMerchantInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Merchant logo/icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: widget.merchant.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.merchant.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.merchant.isVerified) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.verified,
                        color: Colors.blue.shade600,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCategory(widget.merchant.category),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(ThemeData theme) {
    if (widget.merchant.isDynamicQr && widget.merchant.amount != null) {
      // Dynamic QR - show fixed amount
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            const Text(
              'Amount to Pay',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${widget.merchant.amount!.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'USDC',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
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
        const Text(
          'Enter Amount',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                      color: Colors.grey.shade400,
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
        const SizedBox(height: 8),
        Text(
          'Min: \$0.01 | Max: \$10,000',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
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

