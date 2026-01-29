import 'dart:io';
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

class ReviewView extends ConsumerWidget {
  const ReviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(kycProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(l10n.kyc_reviewDocuments, variant: AppTextVariant.headlineSmall),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                l10n.kyc_review_description,
                variant: AppTextVariant.bodyLarge,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView(
                  children: [
                    // Documents section
                    AppText(
                      l10n.kyc_review_documents,
                      variant: AppTextVariant.labelLarge,
                    ),
                    SizedBox(height: AppSpacing.md),
                    ...state.capturedDocuments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final document = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildImageCard(
                          context,
                          l10n,
                          ref,
                          document.imagePath,
                          document.side.name == 'front'
                              ? l10n.kyc_review_documentFront
                              : l10n.kyc_review_documentBack,
                          () => _handleEditDocument(context, index),
                        ),
                      );
                    }),
                    SizedBox(height: AppSpacing.md),
                    // Selfie section
                    AppText(
                      l10n.kyc_review_selfie,
                      variant: AppTextVariant.labelLarge,
                    ),
                    SizedBox(height: AppSpacing.md),
                    if (state.selfiePath != null)
                      _buildImageCard(
                        context,
                        l10n,
                        ref,
                        state.selfiePath!,
                        l10n.kyc_review_yourSelfie,
                        () => _handleEditSelfie(context),
                      ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.kyc_submitForVerification,
                onPressed: state.canSubmit
                    ? () => _handleSubmit(context, ref)
                    : null,
                isLoading: state.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    String imagePath,
    String label,
    VoidCallback onEdit,
  ) {
    return AppCard(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(imagePath),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppText(
                label,
                variant: AppTextVariant.bodyMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.gold500),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }

  void _handleEditDocument(BuildContext context, int index) {
    // Remove the document and go back to capture screen
    context.go('/kyc/document-capture');
  }

  void _handleEditSelfie(BuildContext context) {
    // Go back to selfie screen
    context.go('/kyc/selfie');
  }

  Future<void> _handleSubmit(BuildContext context, WidgetRef ref) async {
    await ref.read(kycProvider.notifier).submitKyc();

    final state = ref.read(kycProvider);
    if (state.error != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    } else {
      if (context.mounted) {
        context.go('/kyc/submitted');
      }
    }
  }
}
