import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/merchant_pay/services/merchant_service.dart';
import 'package:usdc_wallet/features/receipts/models/receipt_data.dart';
import 'package:usdc_wallet/features/receipts/widgets/receipt_widget.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Payment Receipt View
/// Shows animated success and receipt after payment
class PaymentReceiptView extends ConsumerStatefulWidget {
  const PaymentReceiptView({required this.payment, super.key});

  final PaymentResponse payment;

  static const String routeName = '/payment-receipt';

  @override
  ConsumerState<PaymentReceiptView> createState() => _PaymentReceiptViewState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PaymentResponse>('payment', payment));
  }
}

class _PaymentReceiptViewState extends ConsumerState<PaymentReceiptView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1, curve: Curves.easeIn),
      ),
    );

    unawaited(_animationController.forward());

    // Haptic feedback
    unawaited(HapticFeedback.mediumImpact());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final receipt = widget.payment.receipt;
    final paymentStatus = _paymentStatus(widget.payment.status);
    final statusColor = _statusColor(context, paymentStatus);

    // Convert to ReceiptData for the ReceiptWidget
    final receiptData = ReceiptData(
      transactionId: widget.payment.paymentId,
      referenceNumber: receipt.reference,
      amount: receipt.amount,
      fee: receipt.fee,
      total: receipt.amount + receipt.fee,
      currency: 'USDC',
      date: receipt.timestamp,
      status: paymentStatus,
      type: TransactionType.transferExternal,
      recipientName: receipt.merchantName,
      description: receipt.merchantCategory,
    );

    return Scaffold(
      backgroundColor: statusColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top section with animation
            Expanded(
              flex: 2,
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Success checkmark
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: context.colors.textPrimary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            _statusIcon(paymentStatus),
                            color: statusColor,
                            size: 56,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppText(
                          _statusTitle(paymentStatus),
                          variant: AppTextVariant.headlineMedium,
                          color: context.colors.textPrimary,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppText(
                          '\$${receipt.amount.toStringAsFixed(2)} USDC',
                          variant: AppTextVariant.displaySmall,
                          color: context.colors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Receipt card
            Expanded(
              flex: 3,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.colors.textPrimary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xxl),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Merchant name
                        Center(
                          child: Column(
                            children: [
                              AppText(
                                receipt.merchantName,
                                variant: AppTextVariant.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              AppText(
                                _merchantCategoryLabel(
                                  receipt.merchantCategory,
                                  receipt.merchantMcc,
                                ),
                                color: context.colors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Divider
                        Divider(
                          color: context.colors.elevated.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Use ReceiptWidget for consistent receipt display
                        ReceiptWidget(
                          receiptData: receiptData,
                          showQrCode: false,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: l10n.action_share,
                                onPressed: () {
                                  // Share functionality
                                },
                                variant: AppButtonVariant.secondary,
                                icon: Icons.share,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              flex: 2,
                              child: AppButton(
                                label: l10n.action_done,
                                onPressed: () => context.fsmGo('/home'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCategory(String category) =>
      category[0].toUpperCase() + category.substring(1);

  TransactionStatus _paymentStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'completed':
      case 'success':
      case 'succeeded':
        return TransactionStatus.completed;
      case 'processing':
      case 'in_progress':
        return TransactionStatus.processing;
      case 'cancelled':
      case 'canceled':
        return TransactionStatus.cancelled;
      case 'failed':
      case 'rejected':
      case 'error':
        return TransactionStatus.failed;
      case 'pending':
      case 'submitted':
      default:
        return TransactionStatus.pending;
    }
  }

  Color _statusColor(BuildContext context, TransactionStatus status) {
    final colors = context.colors;
    return switch (status) {
      TransactionStatus.completed => colors.success,
      TransactionStatus.failed || TransactionStatus.cancelled => colors.error,
      TransactionStatus.processing || TransactionStatus.pending => colors.gold,
    };
  }

  IconData _statusIcon(TransactionStatus status) => switch (status) {
    TransactionStatus.completed => Icons.check,
    TransactionStatus.failed || TransactionStatus.cancelled => Icons.close,
    TransactionStatus.processing ||
    TransactionStatus.pending => Icons.hourglass_top_rounded,
  };

  String _statusTitle(TransactionStatus status) => switch (status) {
    TransactionStatus.completed => 'Payment Successful',
    TransactionStatus.failed => 'Payment Failed',
    TransactionStatus.cancelled => 'Payment Cancelled',
    TransactionStatus.processing => 'Payment Processing',
    TransactionStatus.pending => 'Payment Pending',
  };

  String _merchantCategoryLabel(String category, String? mcc) {
    final label = _formatCategory(category);
    return mcc == null || mcc.isEmpty ? label : '$label • MCC $mcc';
  }
}
