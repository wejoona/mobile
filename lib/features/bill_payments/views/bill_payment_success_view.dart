import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/bill_payments_provider.dart';

/// Bill Payment Success View
/// Shows payment confirmation with receipt details
class BillPaymentSuccessView extends ConsumerWidget {
  const BillPaymentSuccessView({
    super.key,
    required this.paymentId,
  });

  final String paymentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptAsync = ref.watch(billPaymentReceiptProvider(paymentId));

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: receiptAsync.when(
          data: (receipt) => _buildSuccessContent(context, ref, receipt),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold500),
          ),
          error: (error, _) => _buildErrorContent(context, ref, error.toString()),
        ),
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context, WidgetRef ref, dynamic receipt) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                color: AppColors.textSecondary,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: Column(
              children: [
                // Success Animation
                _buildSuccessIcon(receipt.status == 'completed'),
                const SizedBox(height: AppSpacing.xl),

                // Status Text
                AppText(
                  receipt.status == 'completed'
                      ? 'Payment Successful!'
                      : 'Payment Processing',
                  variant: AppTextVariant.headlineMedium,
                  color: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),

                AppText(
                  receipt.status == 'completed'
                      ? 'Your bill has been paid successfully'
                      : 'Your payment is being processed',
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Receipt Card
                _buildReceiptCard(receipt),
                const SizedBox(height: AppSpacing.xl),

                // Token Display (for prepaid utilities)
                if (receipt.tokenNumber != null) ...[
                  _buildTokenCard(receipt.tokenNumber!, receipt.units),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // QR Code
                if (receipt.qrCode != null) ...[
                  _buildQRCode(receipt.qrCode!),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ],
            ),
          ),
        ),

        // Bottom Actions
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              // Share Button
              AppButton(
                label: 'Share Receipt',
                onPressed: () => _shareReceipt(context, receipt),
                variant: AppButtonVariant.secondary,
                icon: Icons.share,
              ),
              const SizedBox(height: AppSpacing.md),

              // Done Button
              AppButton(
                label: 'Done',
                onPressed: () => context.go('/home'),
                icon: Icons.check,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessIcon(bool isCompleted) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.successBase.withOpacity(0.1)
            : AppColors.warningBase.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCompleted ? Icons.check_circle : Icons.schedule,
        size: 60,
        color: isCompleted ? AppColors.successText : AppColors.warningText,
      ),
    );
  }

  Widget _buildReceiptCard(dynamic receipt) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        children: [
          // Receipt Number
          _buildReceiptRow(
            'Receipt Number',
            receipt.receiptNumber,
            copyable: true,
          ),
          const Divider(color: AppColors.borderSubtle, height: AppSpacing.xl),

          // Provider
          _buildReceiptRow('Provider', receipt.providerName),
          const SizedBox(height: AppSpacing.md),

          // Account
          _buildReceiptRow('Account', receipt.accountNumber),
          const SizedBox(height: AppSpacing.md),

          // Customer Name
          if (receipt.customerName != null) ...[
            _buildReceiptRow('Customer', receipt.customerName!),
            const SizedBox(height: AppSpacing.md),
          ],

          const Divider(color: AppColors.borderSubtle, height: AppSpacing.xl),

          // Amount
          _buildReceiptRow('Amount', '${receipt.amount.toStringAsFixed(0)} ${receipt.currency}'),
          const SizedBox(height: AppSpacing.md),

          // Fee
          _buildReceiptRow('Fee', '${receipt.fee.toStringAsFixed(0)} ${receipt.currency}'),
          const SizedBox(height: AppSpacing.md),

          // Total
          _buildReceiptRow(
            'Total Paid',
            '${receipt.totalAmount.toStringAsFixed(0)} ${receipt.currency}',
            isHighlighted: true,
          ),

          const Divider(color: AppColors.borderSubtle, height: AppSpacing.xl),

          // Date
          _buildReceiptRow(
            'Date',
            _formatDate(receipt.paidAt),
          ),

          // Provider Reference
          if (receipt.providerReference != null) ...[
            const SizedBox(height: AppSpacing.md),
            _buildReceiptRow(
              'Reference',
              receipt.providerReference!,
              copyable: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isHighlighted = false,
    bool copyable = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: AppTextVariant.labelMedium,
          color: AppColors.textSecondary,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              value,
              variant: isHighlighted
                  ? AppTextVariant.titleSmall
                  : AppTextVariant.bodyMedium,
              color: isHighlighted ? AppColors.gold500 : AppColors.textPrimary,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
            if (copyable) ...[
              const SizedBox(width: AppSpacing.xs),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                },
                child: const Icon(
                  Icons.copy,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTokenCard(String token, String? units) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold500.withOpacity(0.2),
            AppColors.gold700.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderGold, width: 1),
      ),
      child: Column(
        children: [
          const AppText(
            'Your Token',
            variant: AppTextVariant.labelMedium,
            color: AppColors.gold500,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: AppText(
                  token,
                  variant: AppTextVariant.titleMedium,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                color: AppColors.gold500,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: token));
                },
              ),
            ],
          ),
          if (units != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppText(
              units,
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQRCode(String qrCodeData) {
    // QR code is base64 encoded image
    if (!qrCodeData.startsWith('data:image')) {
      return const SizedBox.shrink();
    }

    final base64String = qrCodeData.split(',').last;
    final imageBytes = base64Decode(base64String);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Image.memory(
            imageBytes,
            width: 150,
            height: 150,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Scan for receipt details',
            style: TextStyle(
              color: AppColors.obsidian,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.errorBase.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.errorText,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const AppText(
              'Failed to Load Receipt',
              variant: AppTextVariant.titleMedium,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              error,
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Return Home',
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }

  void _shareReceipt(BuildContext context, dynamic receipt) {
    final text = '''
JoonaPay Bill Payment Receipt
-----------------------------
Receipt: ${receipt.receiptNumber}
Provider: ${receipt.providerName}
Account: ${receipt.accountNumber}
${receipt.customerName != null ? 'Customer: ${receipt.customerName}\n' : ''}Amount: ${receipt.totalAmount.toStringAsFixed(0)} ${receipt.currency}
${receipt.tokenNumber != null ? 'Token: ${receipt.tokenNumber}\n' : ''}Date: ${_formatDate(receipt.paidAt)}
-----------------------------
Powered by JoonaPay
''';

    Share.share(text);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
