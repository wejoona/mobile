import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';
import 'package:usdc_wallet/features/kyc/models/document_type.dart';

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
        title: AppText(l10n.kyc_selectDocumentType, variant: AppTextVariant.headlineSmall),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                l10n.kyc_selectDocumentType_description,
                variant: AppTextVariant.bodyLarge,
                color: colors.textSecondary,
              ),
              SizedBox(height: AppSpacing.xxl),
              _buildDocumentTypeCard(
                context,
                l10n,
                DocumentType.nationalId,
                Icons.badge,
                l10n.kyc_documentType_nationalId,
                l10n.kyc_documentType_nationalId_description,
              ),
              SizedBox(height: AppSpacing.lg),
              _buildDocumentTypeCard(
                context,
                l10n,
                DocumentType.passport,
                Icons.menu_book,
                l10n.kyc_documentType_passport,
                l10n.kyc_documentType_passport_description,
              ),
              SizedBox(height: AppSpacing.lg),
              _buildDocumentTypeCard(
                context,
                l10n,
                DocumentType.driversLicense,
                Icons.credit_card,
                l10n.kyc_documentType_driversLicense,
                l10n.kyc_documentType_driversLicense_description,
              ),
              const Spacer(),
              AppButton(
                label: l10n.common_continue,
                onPressed: _selectedType != null ? () => _handleContinue(context) : null,
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
    AppLocalizations l10n,
    DocumentType type,
    IconData icon,
    String title,
    String description,
  ) {
    final colors = context.colors;
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isSelected ? colors.gold : colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: AppCard(
          variant: isSelected ? AppCardVariant.goldAccent : AppCardVariant.elevated,
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (isSelected ? colors.gold : colors.textSecondary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isSelected ? colors.gold : colors.textSecondary,
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      variant: AppTextVariant.labelLarge,
                      color: isSelected ? colors.gold : colors.textPrimary,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    AppText(
                      description,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colors.gold,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContinue(BuildContext context) {
    if (_selectedType == null) return;

    ref.read(kycProvider.notifier).selectDocumentType(_selectedType!);
    context.push('/kyc/personal-info');
  }
}
