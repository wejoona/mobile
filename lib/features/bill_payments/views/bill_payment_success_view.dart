import 'dart:async';
import 'dart:convert';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/bill_payments/providers/bill_payments_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/bill_payments/bill_payments_service.dart';

/// Bill Payment Success View
/// Shows payment confirmation with receipt details
class BillPaymentSuccessView extends ConsumerWidget {
  const BillPaymentSuccessView({required this.paymentId, super.key});

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
          data: (receipt) => _buildSuccessContent(context, l10n, receipt),
          loading: () =>
              Center(child: CircularProgressIndicator(color: colors.gold)),
          error: (error, _) =>
              _buildErrorContent(context, ref, l10n, error.toString()),
        ),
      ),
    );
  }

  Widget _buildSuccessContent(
    BuildContext context,
    AppLocalizations l10n,
    BillPaymentReceipt receipt,
  ) {
    final colors = context.colors;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.sm,
            AppSpacing.screenPadding,
            AppSpacing.zero,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                color: colors.iconSecondary,
                onPressed: () => context.fsmGo('/home'),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              AppSpacing.xxl,
            ),
            child: Column(
              children: [
                _buildStatusCard(context, l10n, receipt),
                const SizedBox(height: AppSpacing.lg),
                _buildReceiptCard(context, l10n, receipt),
                const SizedBox(height: AppSpacing.xl),

                if (receipt.tokenNumber != null) ...[
                  _buildTokenCard(context, receipt.tokenNumber!, receipt.units),
                  const SizedBox(height: AppSpacing.xl),
                ],

                if (receipt.qrCode != null) ...[
                  _buildQRCode(receipt.qrCode!),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.sm,
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: l10n.action_share,
                onPressed: () => _shareReceipt(context, receipt),
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
                icon: Icons.share,
              ),
              const SizedBox(height: AppSpacing.sm),

              AppButton(
                label: l10n.action_done,
                onPressed: () => context.fsmGo('/home'),
                isFullWidth: true,
                icon: Icons.check,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    AppLocalizations l10n,
    BillPaymentReceipt receipt,
  ) {
    final colors = context.colors;
    final isCompleted = receipt.status == 'completed';

    return AppCard(
      variant: AppCardVariant.goldAccent,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Column(
        children: [
          _buildSuccessIcon(context, isCompleted),
          const SizedBox(height: AppSpacing.md),
          AppText(
            isCompleted
                ? l10n.billPayments_paymentSuccessful
                : l10n.billPayments_paymentProcessing,
            variant: AppTextVariant.titleLarge,
            color: colors.textPrimary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            '${receipt.totalAmount.toStringAsFixed(0)} ${receipt.currency}',
            variant: AppTextVariant.headlineMedium,
            color: colors.textPrimary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            isCompleted
                ? l10n.billPayments_billPaidSuccessfully
                : l10n.billPayments_paymentBeingProcessed,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon(BuildContext context, bool isCompleted) {
    final colors = context.colors;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: (isCompleted ? colors.success : colors.warning).withValues(
          alpha: colors.isDark ? 0.16 : 0.1,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCompleted ? Icons.check_rounded : Icons.schedule_rounded,
        size: 32,
        color: isCompleted ? colors.success : colors.warning,
      ),
    );
  }

  Widget _buildReceiptCard(
    BuildContext context,
    AppLocalizations l10n,
    BillPaymentReceipt receipt,
  ) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      borderRadius: AppRadius.lg,
      child: Column(
        children: [
          _buildReceiptRow(
            context,
            l10n.billPayments_receiptNumber,
            receipt.receiptNumber,
            copyable: true,
          ),
          Divider(color: colors.borderSubtle, height: AppSpacing.xl),

          _buildReceiptRow(
            context,
            l10n.billPayments_provider,
            receipt.providerName,
          ),
          const SizedBox(height: AppSpacing.md),

          _buildReceiptRow(
            context,
            l10n.billPayments_account,
            receipt.accountNumber,
          ),
          const SizedBox(height: AppSpacing.md),

          if (receipt.customerName != null) ...[
            _buildReceiptRow(
              context,
              l10n.billPayments_customer,
              receipt.customerName!,
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          Divider(color: colors.borderSubtle, height: AppSpacing.xl),

          _buildReceiptRow(
            context,
            l10n.billPayments_amount,
            '${receipt.amount.toStringAsFixed(0)} ${receipt.currency}',
          ),
          const SizedBox(height: AppSpacing.md),

          _buildReceiptRow(
            context,
            l10n.billPayments_processingFee,
            '${receipt.fee.toStringAsFixed(0)} ${receipt.currency}',
          ),
          const SizedBox(height: AppSpacing.md),

          _buildReceiptRow(
            context,
            l10n.billPayments_totalPaid,
            '${receipt.totalAmount.toStringAsFixed(0)} ${receipt.currency}',
            isHighlighted: true,
          ),

          Divider(color: colors.borderSubtle, height: AppSpacing.xl),

          _buildReceiptRow(context, 'Date', _formatDate(receipt.paidAt)),

          if (receipt.providerReference != null) ...[
            const SizedBox(height: AppSpacing.md),
            _buildReceiptRow(
              context,
              l10n.billPayments_reference,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: AppText(
            label,
            variant: AppTextVariant.labelMedium,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: AppText(
                  value,
                  variant: isHighlighted
                      ? AppTextVariant.titleSmall
                      : AppTextVariant.bodyMedium,
                  color: isHighlighted ? colors.gold : colors.textPrimary,
                  fontWeight: isHighlighted
                      ? FontWeight.bold
                      : FontWeight.normal,
                  textAlign: TextAlign.end,
                  maxLines: copyable ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (copyable) ...[
                const SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: () {
                    unawaited(Clipboard.setData(ClipboardData(text: value)));
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
            colors.gold.withValues(alpha: 0.2),
            colors.gold.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.borderGold),
      ),
      child: Column(
        children: [
          AppText(
            'Votre jeton',
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
                  unawaited(Clipboard.setData(ClipboardData(text: token)));
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
          Image.memory(imageBytes, width: 150, height: 150),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Scannez pour les détails du reçu',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String error,
  ) {
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
              'Impossible de charger le reçu',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              error,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: "Retour à l'accueil",
              onPressed: () => context.fsmGo('/home'),
            ),
          ],
        ),
      ),
    );
  }

  void _shareReceipt(BuildContext context, BillPaymentReceipt receipt) {
    final text =
        '''
Korido Bill Payment Receipt
-----------------------------
Receipt: ${receipt.receiptNumber}
Provider: ${receipt.providerName}
Account: ${receipt.accountNumber}
${receipt.customerName != null ? 'Customer: ${receipt.customerName}\n' : ''}Amount: ${receipt.totalAmount.toStringAsFixed(0)} ${receipt.currency}
${receipt.tokenNumber != null ? 'Token: ${receipt.tokenNumber}\n' : ''}Date: ${_formatDate(receipt.paidAt)}
-----------------------------
Powered by Korido
''';

    unawaited(SharePlus.instance.share(ShareParams(text: text)));
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
