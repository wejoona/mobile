import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/components/primitives/app_button.dart';
import '../../../design/components/primitives/app_text.dart';
import '../../../design/components/primitives/app_card.dart';
import '../providers/kyc_provider.dart';
import '../models/document_type.dart';

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

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(l10n.kyc_selectDocumentType, variant: AppTextVariant.headlineSmall),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                l10n.kyc_selectDocumentType_description,
                variant: AppTextVariant.bodyLarge,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: AppSpacing.xl),
              _buildDocumentTypeCard(
                context,
                l10n,
                DocumentType.nationalId,
                Icons.badge,
                l10n.kyc_documentType_nationalId,
                l10n.kyc_documentType_nationalId_description,
              ),
              SizedBox(height: AppSpacing.md),
              _buildDocumentTypeCard(
                context,
                l10n,
                DocumentType.passport,
                Icons.menu_book,
                l10n.kyc_documentType_passport,
                l10n.kyc_documentType_passport_description,
              ),
              SizedBox(height: AppSpacing.md),
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
                label: l10n.action_continue,
                onPressed: _selectedType != null ? () => _handleContinue(context) : null,
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
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AppCard(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.gold500 : Colors.transparent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: (isSelected ? AppColors.gold500 : AppColors.textSecondary)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: isSelected ? AppColors.gold500 : AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        title,
                        variant: AppTextVariant.labelLarge,
                        color: isSelected ? AppColors.gold500 : AppColors.textPrimary,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      AppText(
                        description,
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.gold500,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue(BuildContext context) {
    if (_selectedType == null) return;

    ref.read(kycProvider.notifier).selectDocumentType(_selectedType!);
    context.push('/kyc/document-capture');
  }
}
