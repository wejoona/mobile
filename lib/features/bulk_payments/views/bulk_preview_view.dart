import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/bulk_payments/providers/bulk_payments_provider.dart';
import 'package:usdc_wallet/features/bulk_payments/widgets/payment_row.dart';
import 'package:usdc_wallet/utils/formatting.dart';

class BulkPreviewView extends ConsumerStatefulWidget {
  const BulkPreviewView({super.key});

  @override
  ConsumerState<BulkPreviewView> createState() => _BulkPreviewViewState();
}

class _BulkPreviewViewState extends ConsumerState<BulkPreviewView> {
  bool _showInvalidOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(bulkPaymentsProvider);
    final batch = state.value?.isNotEmpty == true ? state.value!.first : null;

    if (batch == null) {
      Future.microtask(() => context.go('/bulk-payments'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(
          l10n.bulkPayments_preview,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSummaryCard(l10n, batch),
            if (batch.hasErrors) _buildErrorBanner(l10n, batch),
            _buildFilterToggle(l10n, batch),
            Expanded(
              child: _buildPaymentsList(l10n, batch),
            ),
            _buildBottomBar(l10n, batch, state),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations l10n, batch) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.bulkPayments_totalPayments,
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                  AppText(
                    '${batch.totalCount}',
                    variant: AppTextVariant.headlineMedium,
                    color: AppColors.gold500,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(
                    l10n.bulkPayments_totalAmount,
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                  AppText(
                    Formatting.formatCurrency(batch.totalAmount),
                    variant: AppTextVariant.headlineMedium,
                    color: AppColors.gold500,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(AppLocalizations l10n, batch) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 24,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.bulkPayments_errorsFound(batch.errorCount),
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.error,
                ),
                AppText(
                  l10n.bulkPayments_fixErrors,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle(AppLocalizations l10n, dynamic batch) {
    if (!(batch.hasErrors as bool)) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            l10n.bulkPayments_showInvalidOnly,
            variant: AppTextVariant.bodyMedium,
          ),
          Switch(
            value: _showInvalidOnly,
            onChanged: (value) => setState(() => _showInvalidOnly = value),
            activeColor: AppColors.gold500,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(AppLocalizations l10n, batch) {
    final payments = _showInvalidOnly ? batch.invalidPayments : batch.payments;

    if ((payments as List).isEmpty) {
      return Center(
        child: AppText(
          l10n.bulkPayments_noPayments,
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        return PaymentRow(
          payment: payments[index],
          index: index + 1,
        );
      },
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n, batch, state) {
    final canSubmit = !(batch.hasErrors as bool) && (batch.totalCount as int) > 0;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: l10n.action_cancel,
              onPressed: () => context.pop(),
              variant: AppButtonVariant.secondary,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: AppButton(
              label: l10n.bulkPayments_submitBatch,
              onPressed: canSubmit ? () => _submitBatch(batch) : null,
              isLoading: state.isProcessing,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitBatch(batch) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: AppText(
          l10n.bulkPayments_confirmSubmit,
          variant: AppTextVariant.headlineSmall,
        ),
        content: AppText(
          l10n.bulkPayments_confirmMessage(
            batch.totalCount,
            Formatting.formatCurrency(batch.totalAmount),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText(l10n.action_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: AppText(
              l10n.action_confirm,
              color: AppColors.gold500,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: submitBatch expects BulkBatch, not BulkPayment
      await ref.read(bulkPaymentActionsProvider).submitBatch(batch as dynamic);

      if (mounted) {
        context.go('/bulk-payments');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bulkPayments_submitSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
