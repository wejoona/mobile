import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final receiptAsync = ref.watch(billPaymentReceiptProvider(paymentId));

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: receiptAsync.when(
          data: (receipt) => _buildSuccessContent(context, ref, l10n, receipt),
          loading: () => Center(
            child: CircularProgressIndicator(color: colors.gold),
          ),
          error: (error, _) => _buildErrorContent(context, ref, l10n, error.toString()),
        ),
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context, WidgetRef ref, AppLocalizations l10n, dynamic receipt) {
    final colors = context.colors;
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
                color: colors.iconSecondary,
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
                _buildSuccessIcon(context, receipt.status == 'completed'),
                const SizedBox(height: AppSpacing.xl),

                // Status Text
                AppText(
                  receipt.status == 'completed'
                      ? l10n.billPayments_paymentSuccessful
                      : l10n.billPayments_paymentProcessing,
                  variant: AppTextVariant.headlineMedium,
                  color: colors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),

                AppText(
                  receipt.status == 'completed'
                      ? l10n.billPayments_billPaidSuccessfully
                      : l10n.billPayments_paymentBeingProcessed,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Receipt Card
                _buildReceiptCard(context, l10n, receipt),
                const SizedBox(height: AppSpacing.xl),

                // Token Display (for prepaid utilities)
                if (receipt.tokenNumber != null) ...[
                  _buildTokenCard(context, receipt.tokenNumber!, receipt.units),
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
                label: l10n.action_share,
                onPressed: () => _shareReceipt(context, receipt),
                variant: AppButtonVariant.secondary,
                icon: Icons.share,
              ),
              const SizedBox(height: AppSpacing.md),

              // Done Button
              AppButton(
                label: l10n.action_done,
                onPressed: () => context.go('/home'),
                icon: Icons.check,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessIcon(BuildContext context, bool isCompleted) {
    final colors = context.colors;
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isCompleted ? colors.successBg : colors.warningBg,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCompleted ? Icons.check_circle : Icons.schedule,
        size: 60,
        color: isCompleted ? colors.successText : colors.warningText,
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context, AppLocalizations l10n, dynamic receipt) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.borderSubtle, width: 1),
      ),
      child: Column(
        children: [
          // Receipt Number
          _buildReceiptRow(
            context,
            'Receipt Number',
            receipt.receiptNumber,
            copyable: true,
          ),
          Divider(color: colors.borderSubtle, height: AppSpacing.xl),

          // Provider
          _buildReceiptRow(context, 'Provider', receipt.providerName),
          const SizedBox(height: AppSpacing.md),

          // Account
          _buildReceiptRow(context, 'Account', receipt.accountNumber),
          const SizedBox(height: AppSpacing.md),

          // Customer Name
          if (receipt.customerName != null) ...[
            _buildReceiptRow(context, 'Customer', receipt.customerName!),
            const SizedBox(height: AppSpacing.md),
          ],

          Divider(color: colors.borderSubtle, height: AppSpacing.xl),

          // Amount
          _buildReceiptRow(context, l10n.billPayments_amount, '${receipt.amount.toStringAsFixed(0)} ${receipt.currency}'),
          const SizedBox(height: AppSpacing.md),

          // Fee
          _buildReceiptRow(context, l10n.billPayments_processingFee, '${receipt.fee.toStringAsFixed(0)} ${receipt.currency}'),
          const SizedBox(height: AppSpacing.md),

          // Total
          _buildReceiptRow(
            context,
            'Total Paid',
            '${receipt.totalAmount.toStringAsFixed(0)} ${receipt.currency}',
            isHighlighted: true,
          ),

          Divider(color: colors.borderSubtle, height: AppSpacing.xl),

          // Date
          _buildReceiptRow(
            context,
            'Date',
            _formatDate(receipt.paidAt),
          ),

          // Provider Reference
          if (receipt.providerReference != null) ...[
            const SizedBox(height: AppSpacing.md),
            _buildReceiptRow(
              context,
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
    BuildContext context,
    String label,
    String value, {
    bool isHighlighted = false,
    bool copyable = false,
  }) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              value,
              variant: isHighlighted
                  ? AppTextVariant.titleSmall
                  : AppTextVariant.bodyMedium,
              color: isHighlighted ? colors.gold : colors.textPrimary,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
            if (copyable) ...[
              const SizedBox(width: AppSpacing.xs),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                },
                child: Icon(
                  Icons.copy,
                  size: 16,
                  color: colors.iconSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTokenCard(BuildContext context, String token, String? units) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.gold.withOpacity(0.2),
            colors.gold.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.borderGold, width: 1),
      ),
      child: Column(
        children: [
          AppText(
            'Your Token',
            variant: AppTextVariant.labelMedium,
            color: colors.gold,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: AppText(
                  token,
                  variant: AppTextVariant.titleMedium,
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                color: colors.gold,
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
              color: colors.textSecondary,
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
          Text(
            'Scan for receipt details',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, WidgetRef ref, AppLocalizations l10n, String error) {
    final colors = context.colors;
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
                color: colors.errorBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: colors.errorText,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppText(
              'Failed to Load Receipt',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              error,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
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
