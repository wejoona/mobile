import 'dart:async';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/features/kyc/models/document_type.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

class DocumentTypeView extends ConsumerStatefulWidget {
  const DocumentTypeView({super.key});

  @override
  ConsumerState<DocumentTypeView> createState() => _DocumentTypeViewState();
}

class _DocumentTypeViewState extends ConsumerState<DocumentTypeView> {
  DocumentType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.kyc_selectDocumentType,
          variant: AppTextVariant.titleLarge,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                l10n.kyc_selectDocumentType_description,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildDocumentTypeCard(
                context,
                DocumentType.nationalId,
                Icons.badge,
                l10n.kyc_documentType_nationalId,
                l10n.kyc_documentType_nationalId_description,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildDocumentTypeCard(
                context,
                DocumentType.passport,
                Icons.menu_book,
                l10n.kyc_documentType_passport,
                l10n.kyc_documentType_passport_description,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildDocumentTypeCard(
                context,
                DocumentType.driversLicense,
                Icons.credit_card,
                l10n.kyc_documentType_driversLicense,
                l10n.kyc_documentType_driversLicense_description,
              ),
              const Spacer(),
              AppButton(
                label: l10n.common_continue,
                onPressed: _selectedType != null
                    ? () => _handleContinue(context)
                    : null,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentTypeCard(
    BuildContext context,
    DocumentType type,
    IconData icon,
    String title,
    String description,
  ) {
    final colors = context.colors;
    final isSelected = _selectedType == type;

    return AppCard(
      variant: isSelected ? AppCardVariant.goldAccent : AppCardVariant.flat,
      isSelected: isSelected,
      onTap: () => setState(() => _selectedType = type),
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.lg,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: isSelected ? 0.14 : 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, size: 28, color: colors.gold),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.titleSmall,
                  color: isSelected ? colors.gold : colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  description,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.check_circle, color: colors.gold, size: 22),
          ],
        ],
      ),
    );
  }

  void _handleContinue(BuildContext context) {
    if (_selectedType == null) {
      return;
    }

    ref.read(kycProvider.notifier).selectDocumentType(_selectedType!);
    unawaited(context.fsmPush('/kyc/personal-info'));
  }
}
