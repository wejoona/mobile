// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

enum ExportFormat { csv, pdf }
enum ExportPeriod { week, month, quarter, year, custom }

class ExportTransactionsView extends ConsumerStatefulWidget {
  const ExportTransactionsView({super.key});

  @override
  ConsumerState<ExportTransactionsView> createState() => _ExportTransactionsViewState();
}

class _ExportTransactionsViewState extends ConsumerState<ExportTransactionsView> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  ExportPeriod _selectedPeriod = ExportPeriod.month;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _includeDetails = true;
  bool _includeCategories = true;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final txState = ref.watch(transactionStateMachineProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.export_title,
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Export Summary
            _buildSummaryCard(txState, colors),

            const SizedBox(height: AppSpacing.xxl),

            // Format Selection
            AppText(
              'Export Format',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildFormatOption(
                    format: ExportFormat.csv,
                    icon: Icons.table_chart_outlined,
                    title: 'CSV',
                    subtitle: 'Spreadsheet format',
                    colors: colors,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildFormatOption(
                    format: ExportFormat.pdf,
                    icon: Icons.picture_as_pdf_outlined,
                    title: 'PDF',
                    subtitle: 'Document format',
                    colors: colors,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Period Selection
            AppText(
              'Time Period',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _buildPeriodChip(ExportPeriod.week, 'Last 7 Days', colors),
                _buildPeriodChip(ExportPeriod.month, 'Last 30 Days', colors),
                _buildPeriodChip(ExportPeriod.quarter, 'Last 90 Days', colors),
                _buildPeriodChip(ExportPeriod.year, 'Last Year', colors),
                _buildPeriodChip(ExportPeriod.custom, 'Custom', colors),
              ],
            ),

            if (_selectedPeriod == ExportPeriod.custom) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildCustomDateRange(colors),
            ],

            const SizedBox(height: AppSpacing.xxl),

            // Options
            AppText(
              'Include in Export',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildToggleOption(
              title: 'Transaction Details',
              subtitle: 'Notes, descriptions, references',
              value: _includeDetails,
              onChanged: (value) => setState(() => _includeDetails = value),
              colors: colors,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildToggleOption(
              title: 'Categories',
              subtitle: 'Transaction type classifications',
              value: _includeCategories,
              onChanged: (value) => setState(() => _includeCategories = value),
              colors: colors,
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Export Button
            AppButton(
              label: _isExporting ? 'Exporting...' : 'Export Transactions',
              onPressed: _isExporting ? null : _exportTransactions,
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Share Button
            AppButton(
              label: 'Share via Email',
              onPressed: _shareViaEmail,
              variant: AppButtonVariant.secondary,
              isFullWidth: true,
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Info
            AppCard(
              variant: AppCardVariant.subtle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: context.colors.info, size: 20),
                      SizedBox(width: AppSpacing.sm),
                      AppText(
                        'About Export',
                        variant: AppTextVariant.labelMedium,
                        color: context.colors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppText(
                    'Exports include all transactions within the selected period. CSV files can be opened in Excel or Google Sheets. PDF files are formatted for printing or archiving.',
                    variant: AppTextVariant.bodySmall,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(TransactionListState txState, ThemeColors colors) {
    final transactionCount = txState.transactions.length;
    final dateRange = _getDateRangeText();

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.download,
                  color: colors.gold,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      '$transactionCount Transactions',
                      variant: AppTextVariant.titleMedium,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      dateRange,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
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

  Widget _buildFormatOption({
    required ExportFormat format,
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeColors colors,
  }) {
    final isSelected = _selectedFormat == format;

    return GestureDetector(
      onTap: () => setState(() => _selectedFormat = format),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? colors.gold.withValues(alpha: 0.1) : colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? colors.gold : colors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? colors.gold : colors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              title,
              variant: AppTextVariant.labelLarge,
              color: isSelected ? colors.gold : colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.xxs),
            AppText(
              subtitle,
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(ExportPeriod period, String label, ThemeColors colors) {
    final isSelected = _selectedPeriod == period;

    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.gold : colors.container,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? colors.gold : colors.borderSubtle,
          ),
        ),
        child: AppText(
          label,
          variant: AppTextVariant.labelSmall,
          color: isSelected ? colors.canvas : colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCustomDateRange(ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        children: [
          _buildDateSelector(
            label: 'Start Date',
            date: _customStartDate,
            onTap: () => _selectDate(isStart: true),
            colors: colors,
          ),
          Divider(color: colors.borderSubtle),
          _buildDateSelector(
            label: 'End Date',
            date: _customEndDate,
            onTap: () => _selectDate(isStart: false),
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required ThemeColors colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: colors.textSecondary, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    label,
                    variant: AppTextVariant.labelSmall,
                    color: colors.textSecondary,
                  ),
                  AppText(
                    date != null ? _formatDate(date) : 'Select date',
                    variant: AppTextVariant.bodyMedium,
                    color: date != null ? colors.textPrimary : colors.textTertiary,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeColors colors,
  }) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.labelMedium,
                  color: colors.textPrimary,
                ),
                AppText(
                  subtitle,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colors.gold,
          ),
        ],
      ),
    );
  }

  String _getDateRangeText() {
    switch (_selectedPeriod) {
      case ExportPeriod.week:
        return 'Last 7 days';
      case ExportPeriod.month:
        return 'Last 30 days';
      case ExportPeriod.quarter:
        return 'Last 90 days';
      case ExportPeriod.year:
        return 'Last 365 days';
      case ExportPeriod.custom:
        if (_customStartDate != null && _customEndDate != null) {
          return '${_formatDate(_customStartDate!)} - ${_formatDate(_customEndDate!)}';
        }
        return 'Select date range';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _selectDate({required bool isStart}) async {
    final initialDate = isStart
        ? (_customStartDate ?? DateTime.now().subtract(const Duration(days: 30)))
        : (_customEndDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final colors = context.colors;
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: colors.gold,
              surface: colors.container,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _customStartDate = picked;
        } else {
          _customEndDate = picked;
        }
      });
    }
  }

  Future<void> _exportTransactions() async {
    setState(() => _isExporting = true);

    // Simulate export
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isExporting = false);

    if (mounted) {
      final format = _selectedFormat == ExportFormat.csv ? 'CSV' : 'PDF';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.transactions_exported(format)),
          backgroundColor: context.colors.success,
          action: SnackBarAction(
            label: 'Share',
            textColor: Colors.white,
            onPressed: _shareExport,
          ),
        ),
      );
    }
  }

  void _shareExport() {
    final format = _selectedFormat == ExportFormat.csv ? 'CSV' : 'PDF';
    SharePlus.instance.share(ShareParams(text: 
      'Korido Transaction Export ($format)\n\nPeriod: ${_getDateRangeText()}\n\n[Export file would be attached]', title: 'Korido Transaction Export',
    ));
  }

  void _shareViaEmail() {
    final format = _selectedFormat == ExportFormat.csv ? 'CSV' : 'PDF';
    SharePlus.instance.share(ShareParams(text: 
      'Please find attached my Korido transaction export in $format format.\n\nPeriod: ${_getDateRangeText()}', title: 'Korido Transaction Export',
    ));
  }
}
