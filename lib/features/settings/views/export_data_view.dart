import 'package:usdc_wallet/design/components/primitives/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Run 378: Data export view for GDPR compliance and user data portability
class ExportDataView extends ConsumerStatefulWidget {
  const ExportDataView({super.key});

  @override
  ConsumerState<ExportDataView> createState() => _ExportDataViewState();
}

class _ExportDataViewState extends ConsumerState<ExportDataView> {
  bool _includeTransactions = true;
  bool _includeProfile = true;
  bool _includeContacts = false;
  String _format = 'pdf';
  bool _isExporting = false;

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
            message: 'Vos donnees seront exportees dans un fichier securise.',
            type: AlertVariant.info,
          ),
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(title: 'Donnees a inclure'),
          const SizedBox(height: AppSpacing.sm),
          _ExportOption(
            title: 'Historique des transactions',
            subtitle: 'Tous vos transferts, depots et retraits',
            value: _includeTransactions,
            onChanged: (v) => setState(() => _includeTransactions = v),
          ),
          _ExportOption(
            title: 'Informations du profil',
            subtitle: 'Nom, telephone, email',
            value: _includeProfile,
            onChanged: (v) => setState(() => _includeProfile = v),
          ),
          _ExportOption(
            title: 'Contacts Korido',
            subtitle: 'Liste de vos beneficiaires',
            value: _includeContacts,
            onChanged: (v) => setState(() => _includeContacts = v),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(title: 'Format'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _FormatChip(
                label: 'PDF',
                selected: _format == 'pdf',
                onTap: () => setState(() => _format = 'pdf'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _FormatChip(
                label: 'CSV',
                selected: _format == 'csv',
                onTap: () => setState(() => _format = 'csv'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _FormatChip(
                label: 'JSON',
                selected: _format == 'json',
                onTap: () => setState(() => _format = 'json'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),
          AppButton(
            label: _isExporting ? 'Exportation...' : 'Exporter',
            variant: AppButtonVariant.primary,
            isLoading: _isExporting,
            onPressed: _isExporting ? null : _export,
          ),
        ],
      ),
    );
  }

  Future<void> _export() async {
    if (!_includeTransactions && !_includeProfile && !_includeContacts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins un type de données')),
      );
      return;
    }
    setState(() => _isExporting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/account/export', data: {
        'includeTransactions': _includeTransactions,
        'includeProfile': _includeProfile,
        'includeContacts': _includeContacts,
        'format': _format,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Export demandé. Vous recevrez un email avec vos données.'),
            backgroundColor: context.colors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

class _ExportOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ExportOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(title, style: AppTextStyle.labelMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      subtitle,
                      style: AppTextStyle.bodySmall,
                      color: context.colors.textTertiary,
                    ),
                  ],
                ),
              ),
              AppToggle(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FormatChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? context.colors.gold.withValues(alpha: 0.12) : context.colors.elevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? context.colors.gold : Colors.transparent,
          ),
        ),
        child: AppText(
          label,
          style: AppTextStyle.labelMedium,
          color: selected ? context.colors.gold : context.colors.textSecondary,
        ),
      ),
    );
  }
}
