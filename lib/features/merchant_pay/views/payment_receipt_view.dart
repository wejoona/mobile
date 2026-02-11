import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/receipts/widgets/receipt_widget.dart';
import 'package:usdc_wallet/features/receipts/models/receipt_data.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/merchant_pay/services/merchant_service.dart';

/// Payment Receipt View
/// Shows animated success and receipt after payment
class PaymentReceiptView extends ConsumerStatefulWidget {
  final PaymentResponse payment;

  const PaymentReceiptView({
    super.key,
    required this.payment,
  });

  static const String routeName = '/payment-receipt';

  @override
  ConsumerState<PaymentReceiptView> createState() => _PaymentReceiptViewState();
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

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();

    // Haptic feedback
    HapticFeedback.mediumImpact();
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

    // Convert to ReceiptData for the ReceiptWidget
    final receiptData = ReceiptData(
      transactionId: widget.payment.paymentId,
      referenceNumber: receipt.reference,
      amount: receipt.amount,
      fee: receipt.fee,
      total: receipt.amount + receipt.fee,
      currency: 'USDC',
      date: receipt.timestamp,
      status: TransactionStatus.completed,
      type: TransactionType.transferExternal,
      recipientName: receipt.merchantName,
      description: receipt.merchantCategory,
    );

    return Scaffold(
      backgroundColor: AppColors.success,
      body: SafeArea(
        child: Column(
          children: [
            // Top section with animation
            Expanded(
              flex: 2,
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Success checkmark
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.white,
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
                              Icons.check,
                              color: AppColors.success,
                              size: 56,
                            ),
                          ),
                          SizedBox(height: AppSpacing.lg),
                          AppText(
                            'Payment Successful!',
                            variant: AppTextVariant.headlineMedium,
                            color: AppColors.white,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          AppText(
                            '\$${receipt.amount.toStringAsFixed(2)} USDC',
                            variant: AppTextVariant.displaySmall,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    );
                  },
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
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
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
                              SizedBox(height: AppSpacing.xs),
                              AppText(
                                _formatCategory(receipt.merchantCategory),
                                variant: AppTextVariant.bodyMedium,
                                color: AppColors.silver,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),

                        // Divider
                        Divider(color: AppColors.charcoal.withValues(alpha: 0.2)),
                        SizedBox(height: AppSpacing.lg),

                        // Use ReceiptWidget for consistent receipt display
                        ReceiptWidget(
                          receiptData: receiptData,
                          showQrCode: false,
                        ),

                        SizedBox(height: AppSpacing.xl),

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
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              flex: 2,
                              child: AppButton(
                                label: l10n.action_done,
                                onPressed: () => context.go('/home'),
                                variant: AppButtonVariant.primary,
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

  String _formatCategory(String category) {
    return category[0].toUpperCase() + category.substring(1);
  }
}
