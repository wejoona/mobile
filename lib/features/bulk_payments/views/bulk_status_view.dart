import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/bulk_payments/providers/bulk_payments_provider.dart';
import 'package:usdc_wallet/features/bulk_payments/models/bulk_batch.dart';
import 'package:usdc_wallet/utils/formatting.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class BulkStatusView extends ConsumerStatefulWidget {
  final String batchId;

  const BulkStatusView({
    super.key,
    required this.batchId,
  });

  @override
  ConsumerState<BulkStatusView> createState() => _BulkStatusViewState();
}

class _BulkStatusViewState extends ConsumerState<BulkStatusView> {
  @override
  void initState() {
    super.initState();
    _loadBatchStatus();
  }

  Future<void> _loadBatchStatus() async {
    await ref
        .read(bulkPaymentActionsProvider)
        .getBatchStatus(widget.batchId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final batchAsync = ref.watch(batchDetailProvider(widget.batchId));

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.bulkPayments_batchStatus,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: batchAsync.when(
          data: (batch) {
            if (batch == null) {
              return _buildError(l10n, 'Batch not found');
            }
            return _buildContent(l10n, batch);
          },
          loading: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.gold),
            ),
          ),
          error: (error, _) => _buildError(l10n, error.toString()),
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, BulkBatch batch) {
    return RefreshIndicator(
      color: context.colors.gold,
      backgroundColor: context.colors.container,
      onRefresh: _loadBatchStatus,
      child: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          _buildStatusCard(l10n, batch),
          SizedBox(height: AppSpacing.md),
          _buildProgressCard(l10n, batch),
          SizedBox(height: AppSpacing.md),
          _buildDetailsCard(l10n, batch),
          if (batch.failedCount > 0) ...[
            SizedBox(height: AppSpacing.md),
            _buildFailedPaymentsCard(l10n, batch),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(AppLocalizations l10n, BulkBatch batch) {
    final statusColor = _getStatusColor(batch.status);
    final statusIcon = _getStatusIcon(batch.status);

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 32,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      batch.name,
                      variant: AppTextVariant.titleMedium,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    AppText(
                      _getStatusText(l10n, batch.status),
                      variant: AppTextVariant.bodyMedium,
                      color: statusColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(AppLocalizations l10n, BulkBatch batch) {
    final progress = batch.totalCount > 0
        ? (batch.successCount + batch.failedCount) / batch.totalCount
        : 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.bulkPayments_progress,
            variant: AppTextVariant.titleMedium,
          ),
          SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.colors.container,
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.gold),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat(
                l10n.bulkPayments_successful,
                batch.successCount,
                context.colors.success,
              ),
              _buildProgressStat(
                l10n.bulkPayments_failed,
                batch.failedCount,
                context.colors.error,
              ),
              _buildProgressStat(
                l10n.bulkPayments_pending,
                batch.totalCount - batch.successCount - batch.failedCount,
                context.colors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, int count, Color color) {
    return Column(
      children: [
        AppText(
          '$count',
          variant: AppTextVariant.headlineMedium,
          color: color,
        ),
        AppText(
          label,
          variant: AppTextVariant.bodySmall,
          color: context.colors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildDetailsCard(AppLocalizations l10n, BulkBatch batch) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.bulkPayments_details,
            variant: AppTextVariant.titleMedium,
          ),
          SizedBox(height: AppSpacing.md),
          _buildDetailRow(
            l10n.bulkPayments_totalAmount,
            Formatting.formatCurrency(batch.totalAmount),
          ),
          SizedBox(height: AppSpacing.sm),
          _buildDetailRow(
            l10n.bulkPayments_totalPayments,
            '${batch.totalCount}',
          ),
          SizedBox(height: AppSpacing.sm),
          _buildDetailRow(
            l10n.bulkPayments_createdAt,
            Formatting.formatDateTime(batch.createdAt),
          ),
          if (batch.processedAt != null) ...[
            SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              l10n.bulkPayments_processedAt,
              Formatting.formatDateTime(batch.processedAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: AppTextVariant.bodyMedium,
          color: context.colors.textSecondary,
        ),
        AppText(
          value,
          variant: AppTextVariant.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildFailedPaymentsCard(AppLocalizations l10n, BulkBatch batch) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.bulkPayments_failedPayments,
            variant: AppTextVariant.titleMedium,
            color: context.colors.error,
          ),
          SizedBox(height: AppSpacing.sm),
          AppText(
            l10n.bulkPayments_failedDescription,
            variant: AppTextVariant.bodySmall,
            color: context.colors.textSecondary,
          ),
          SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.bulkPayments_downloadReport,
            onPressed: () => _downloadFailedReport(batch),
            variant: AppButtonVariant.secondary,
            icon: Icons.download,
          ),
        ],
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.colors.error,
            ),
            SizedBox(height: AppSpacing.md),
            AppText(
              error,
              variant: AppTextVariant.bodyMedium,
              textAlign: TextAlign.center,
              color: context.colors.error,
            ),
            SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.action_retry,
              onPressed: _loadBatchStatus,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFailedReport(BulkBatch batch) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final csvContent = await ref
          .read(bulkPaymentActionsProvider)
          .downloadFailedPayments(batch.id);

      if (csvContent == null || !mounted) return; // ignore: unnecessary_null_comparison

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/failed_payments_${batch.id}.csv');
      await file.writeAsString(csvContent);

      // Share the file
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], title: l10n.bulkPayments_failedReportTitle,
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bulkPayments_downloadFailed),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  Color _getStatusColor(BatchStatus status) {
    switch (status) {
      case BatchStatus.draft:
        return context.colors.textSecondary;
      case BatchStatus.pending:
        return context.colors.warning;
      case BatchStatus.processing:
        return context.colors.gold;
      case BatchStatus.completed:
        return context.colors.success;
      case BatchStatus.partiallyCompleted:
        return context.colors.warning;
      case BatchStatus.failed:
        return context.colors.error;
    }
  }

  IconData _getStatusIcon(BatchStatus status) {
    switch (status) {
      case BatchStatus.draft:
        return Icons.drafts;
      case BatchStatus.pending:
        return Icons.schedule;
      case BatchStatus.processing:
        return Icons.sync;
      case BatchStatus.completed:
        return Icons.check_circle;
      case BatchStatus.partiallyCompleted:
        return Icons.warning;
      case BatchStatus.failed:
        return Icons.error;
    }
  }

  String _getStatusText(AppLocalizations l10n, BatchStatus status) {
    switch (status) {
      case BatchStatus.draft:
        return l10n.bulkPayments_statusDraft;
      case BatchStatus.pending:
        return l10n.bulkPayments_statusPending;
      case BatchStatus.processing:
        return l10n.bulkPayments_statusProcessing;
      case BatchStatus.completed:
        return l10n.bulkPayments_statusCompleted;
      case BatchStatus.partiallyCompleted:
        return l10n.bulkPayments_statusPartial;
      case BatchStatus.failed:
        return l10n.bulkPayments_statusFailed;
    }
  }
}
