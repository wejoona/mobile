import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/primitives/section_header.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/utils/share_utils.dart';
import 'package:usdc_wallet/utils/user_facing_errors.dart';

/// Run 378: Data export view for GDPR compliance and user data portability
class ExportDataView extends ConsumerStatefulWidget {
  const ExportDataView({super.key});

  @override
  ConsumerState<ExportDataView> createState() => _ExportDataViewState();
}

class _ExportDataViewState extends ConsumerState<ExportDataView> {
  bool _isExporting = false;
  String? _exportedJson;
  DateTime? _exportedAt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: const AppText(
          'Exporter mes donnees',
          style: AppTextStyle.headingSmall,
        ),
        backgroundColor: context.colors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const AlertBanner(
            message:
                'Korido exporte actuellement les donnees de votre compte au format JSON securise.',
            type: AlertVariant.info,
          ),
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(title: 'Donnees a inclure'),
          const SizedBox(height: AppSpacing.sm),
          const _IncludedSectionCard(),
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(title: 'Format'),
          const SizedBox(height: AppSpacing.sm),
          const _JsonFormatCard(),
          const SizedBox(height: AppSpacing.xxxl),
          AppButton(
            label: _isExporting ? 'Exportation...' : 'Exporter',
            variant: AppButtonVariant.primary,
            isLoading: _isExporting,
            onPressed: _isExporting ? null : _export,
            isFullWidth: true,
          ),
          if (_exportedJson != null) ...[
            const SizedBox(height: AppSpacing.xxl),
            _ExportResultCard(
              exportedAt: _exportedAt,
              exportedJson: _exportedJson!,
              onCopy: _copyExport,
              onShare: _shareExport,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _isExporting = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '/user/data-export',
        queryParameters: {
          'includeProfile': true,
          'includeTransactions': false,
          'includeContacts': false,
          'format': 'json',
        },
      );
      final prettyJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(response.data);
      final responseData = response.data;
      final exportedAt = DateTime.tryParse(
        responseData is Map ? responseData['exportedAt']?.toString() ?? '' : '',
      );
      if (mounted) {
        setState(() {
          _exportedJson = prettyJson;
          _exportedAt = exportedAt;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Export pret. Vous pouvez le copier ou le partager.',
            ),
            backgroundColor: context.colors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.common_errorFormat(
                UserFacingErrors.message(e),
              ),
            ),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _copyExport() async {
    final export = _exportedJson;
    if (export == null) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: export));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Export copie dans le presse-papiers.'),
        backgroundColor: context.colors.success,
      ),
    );
  }

  Future<void> _shareExport() async {
    final export = _exportedJson;
    if (export == null) {
      return;
    }
    await ShareUtils.shareText(export, subject: 'Export Korido');
  }
}

class _IncludedSectionCard extends StatelessWidget {
  const _IncludedSectionCard();
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.goldSubtle,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.account_circle_outlined,
                color: context.colors.gold,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'Compte et profil',
                    style: AppTextStyle.labelMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppText(
                    'Nom, telephone, email, pays, statut du compte et statut KYC.',
                    style: AppTextStyle.bodySmall,
                    color: context.colors.textTertiary,
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle_rounded, color: context.colors.success),
          ],
        ),
      ),
    );
  }
}

class _JsonFormatCard extends StatelessWidget {
  const _JsonFormatCard();
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.data_object_rounded, color: context.colors.gold),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('JSON', style: AppTextStyle.labelMedium),
                  const SizedBox(height: AppSpacing.xxs),
                  AppText(
                    'Export immediat lisible par Korido et vos outils de support.',
                    style: AppTextStyle.bodySmall,
                    color: context.colors.textTertiary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportResultCard extends StatelessWidget {
  const _ExportResultCard({
    required this.exportedJson,
    required this.onCopy,
    required this.onShare,
    this.exportedAt,
  });

  final DateTime? exportedAt;
  final String exportedJson;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final exportedAtLabel = exportedAt == null
        ? 'Maintenant'
        : '${exportedAt!.day.toString().padLeft(2, '0')}/'
              '${exportedAt!.month.toString().padLeft(2, '0')}/'
              '${exportedAt!.year} '
              '${exportedAt!.hour.toString().padLeft(2, '0')}:'
              '${exportedAt!.minute.toString().padLeft(2, '0')}';

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('Export pret', style: AppTextStyle.headingSmall),
            const SizedBox(height: AppSpacing.xs),
            AppText(
              'Genere le $exportedAtLabel',
              style: AppTextStyle.bodySmall,
              color: context.colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: context.colors.borderSubtle),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  exportedJson,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Copier',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.copy_rounded,
                    onPressed: onCopy,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: 'Partager',
                    variant: AppButtonVariant.primary,
                    icon: Icons.ios_share_rounded,
                    onPressed: onShare,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
