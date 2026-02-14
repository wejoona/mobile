import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/bulk_payments/providers/bulk_payments_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class BulkUploadView extends ConsumerStatefulWidget {
  const BulkUploadView({super.key});

  @override
  ConsumerState<BulkUploadView> createState() => _BulkUploadViewState();
}

class _BulkUploadViewState extends ConsumerState<BulkUploadView> {
  bool _isUploading = false;
  String? _fileName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.bulkPayments_uploadTitle,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInstructions(l10n),
              SizedBox(height: AppSpacing.xl),
              _buildUploadSection(l10n),
              SizedBox(height: AppSpacing.xl),
              _buildCsvFormatSection(l10n),
              SizedBox(height: AppSpacing.xl),
              _buildExampleSection(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions(AppLocalizations l10n) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: context.colors.gold,
                size: 24,
              ),
              SizedBox(width: AppSpacing.sm),
              AppText(
                l10n.bulkPayments_instructions,
                variant: AppTextVariant.titleMedium,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          AppText(
            l10n.bulkPayments_instructionsDescription,
            variant: AppTextVariant.bodyMedium,
            color: context.colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          l10n.bulkPayments_uploadFile,
          variant: AppTextVariant.titleMedium,
        ),
        SizedBox(height: AppSpacing.md),
        InkWell(
          onTap: _isUploading ? null : _pickFile,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: context.colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: context.colors.gold.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload,
                  size: 48,
                  color: context.colors.gold,
                ),
                SizedBox(height: AppSpacing.md),
                AppText(
                  _fileName ?? l10n.bulkPayments_selectFile,
                  variant: AppTextVariant.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),
                AppText(
                  l10n.bulkPayments_csvOnly,
                  variant: AppTextVariant.bodySmall,
                  color: context.colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCsvFormatSection(AppLocalizations l10n) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.bulkPayments_csvFormat,
            variant: AppTextVariant.titleMedium,
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: context.colors.canvas,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: AppText(
              'phone,amount,description',
              variant: AppTextVariant.bodySmall,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          _buildFormatRule(
            l10n.bulkPayments_phoneFormat,
            Icons.phone,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildFormatRule(
            l10n.bulkPayments_amountFormat,
            Icons.attach_money,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildFormatRule(
            l10n.bulkPayments_descriptionFormat,
            Icons.description,
          ),
        ],
      ),
    );
  }

  Widget _buildFormatRule(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: context.colors.textSecondary,
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AppText(
            text,
            variant: AppTextVariant.bodySmall,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildExampleSection(AppLocalizations l10n) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.bulkPayments_example,
            variant: AppTextVariant.titleMedium,
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: context.colors.canvas,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: AppText(
              'phone,amount,description\n'
              '+2250701234567,50.00,Salary January\n'
              '+2250707654321,75.00,Bonus\n'
              '+2250708888888,100.00,Payment',
              variant: AppTextVariant.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    setState(() => _isUploading = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        _fileName = file.name;

        if (file.bytes != null) {
          final csvContent = utf8.decode(file.bytes!);
          final batch = await ref
              .read(bulkPaymentActionsProvider)
              .parseCsvFile(csvContent);

          if (batch != null && mounted) {
            context.push('/bulk-payments/preview');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load file: $e'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }
}
