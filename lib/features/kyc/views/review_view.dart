import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

class ReviewView extends ConsumerWidget {
  const ReviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(kycProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.kyc_reviewDocuments,
          variant: AppTextVariant.headlineSmall,
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
                l10n.kyc_review_description,
                variant: AppTextVariant.bodyLarge,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: ListView(
                  children: [
                    _buildReadinessSummary(context, state),
                    const SizedBox(height: AppSpacing.xxl),
                    // Documents section
                    AppText(
                      l10n.kyc_review_documents,
                      variant: AppTextVariant.titleMedium,
                      color: colors.gold,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...state.capturedDocuments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final document = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
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
                    if (state.capturedDocuments.isEmpty)
                      _buildMissingCard(
                        context,
                        title: _copy(
                          context,
                          'Document photo',
                          'Photo du document',
                        ),
                        subtitle: _copy(
                          context,
                          'Add a clear photo of your ID document.',
                          'Ajoutez une photo nette de votre pièce d’identité.',
                        ),
                        icon: Icons.badge_outlined,
                        actionLabel: _copy(
                          context,
                          'Add document',
                          'Ajouter le document',
                        ),
                        onAction: () => _handleEditDocument(context, 0),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    // Selfie section
                    AppText(
                      l10n.kyc_review_selfie,
                      variant: AppTextVariant.titleMedium,
                      color: colors.gold,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (state.selfiePath != null)
                      _buildImageCard(
                        context,
                        l10n,
                        ref,
                        state.selfiePath!,
                        l10n.kyc_review_yourSelfie,
                        () => _handleEditSelfie(context),
                      ),
                    if (state.selfiePath == null)
                      _buildMissingCard(
                        context,
                        title: l10n.kyc_review_yourSelfie,
                        subtitle: _copy(
                          context,
                          'Take a selfie so we can match you to your document.',
                          'Prenez un selfie pour confirmer qu’il correspond au document.',
                        ),
                        icon: Icons.face_retouching_natural_outlined,
                        actionLabel: _copy(
                          context,
                          'Add selfie',
                          'Ajouter le selfie',
                        ),
                        onAction: () => _handleEditSelfie(context),
                      ),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildKycConsentCard(context, ref, state),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.kyc_submitForVerification,
                onPressed: state.canSubmit
                    ? () => _handleSubmit(context, ref)
                    : null,
                isLoading: state.isLoading,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadinessSummary(BuildContext context, KycFlowState state) {
    final colors = context.colors;
    final completedCount =
        (state.capturedDocuments.isNotEmpty ? 1 : 0) +
        (state.selfiePath != null ? 1 : 0) +
        (state.hasRequiredPersonalInfo ? 1 : 0) +
        (state.kycConsentAccepted ? 1 : 0);
    final isReady = state.canSubmit;

    return AppCard(
      variant: AppCardVariant.goldAccent,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isReady ? colors.goldSubtle : colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isReady ? colors.borderGold : colors.borderSubtle,
              ),
            ),
            child: Icon(
              isReady ? Icons.verified_outlined : Icons.fact_check_outlined,
              color: isReady ? colors.gold : colors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  isReady
                      ? _copy(context, 'Ready to submit', 'Prêt à soumettre')
                      : _copy(
                          context,
                          'Complete your verification',
                          'Complétez votre vérification',
                        ),
                  variant: AppTextVariant.bodyLarge,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  isReady
                      ? _copy(
                          context,
                          'Everything needed for review is attached.',
                          'Tous les éléments nécessaires sont joints.',
                        )
                      : _copy(
                          context,
                          '$completedCount of 4 required items are ready.',
                          '$completedCount élément(s) sur 4 sont prêts.',
                        ),
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycConsentCard(
    BuildContext context,
    WidgetRef ref,
    KycFlowState state,
  ) {
    final colors = context.colors;
    final accepted = state.kycConsentAccepted;

    return AppCard(
      variant: AppCardVariant.flat,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor: accepted ? colors.borderGold : colors.borderSubtle,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: state.isLoading
            ? null
            : () => ref
                  .read(kycProvider.notifier)
                  .setKycConsentAccepted(accepted: !accepted),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: accepted,
              activeColor: colors.gold,
              checkColor: colors.onGold,
              side: BorderSide(color: colors.border),
              onChanged: state.isLoading
                  ? null
                  : (value) => ref
                        .read(kycProvider.notifier)
                        .setKycConsentAccepted(accepted: value ?? false),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    _copy(
                      context,
                      'Identity verification consent',
                      'Consentement de vérification d’identité',
                    ),
                    variant: AppTextVariant.bodyLarge,
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    _copy(
                      context,
                      'I agree that Korido may process my identity data, share it with verification providers, and run AML/sanctions screening for account verification.',
                      'J’autorise Korido à traiter mes données d’identité, les partager avec ses prestataires de vérification, et effectuer les contrôles AML/sanctions nécessaires.',
                    ),
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.flat,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: colors.borderSubtle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: colors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.bodyLarge,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  subtitle,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            tooltip: actionLabel,
            icon: Icon(Icons.add_circle_outline, color: colors.gold),
            onPressed: onAction,
          ),
        ],
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
    final colors = context.colors;
    final file = File(imagePath);
    return AppCard(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.border, width: 1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: file.existsSync()
                  ? Image.file(file, width: 80, height: 80, fit: BoxFit.cover)
                  : Container(
                      width: 80,
                      height: 80,
                      color: colors.elevated,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: colors.textTertiary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: AppText(label, variant: AppTextVariant.bodyLarge)),
          IconButton(
            icon: Icon(Icons.edit, color: colors.gold, size: 24),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  void _handleEditDocument(BuildContext context, int index) {
    // Remove the document and go back to capture screen
    context.fsmGo('/kyc/document-capture');
  }

  void _handleEditSelfie(BuildContext context) {
    // Go back to selfie screen
    context.fsmGo('/kyc/selfie');
  }

  Future<void> _handleSubmit(BuildContext context, WidgetRef ref) async {
    // Submit KYC (existing flow: upload docs + personal info)
    await ref.read(kycProvider.notifier).submitKyc();

    final state = ref.read(kycProvider);
    if (state.error != null && state.error!.isNotEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: context.colors.error,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      final flow = ref.read(kycProvider);
      context.fsmGo(_submittedRoute(flow));
    }
  }

  String _submittedRoute(KycFlowState flow) {
    final intent = flow.returnIntent?.trim();
    final returnTo = flow.returnTo?.trim();
    if ((intent == null || intent.isEmpty) ||
        (returnTo == null || !returnTo.startsWith('/'))) {
      return '/kyc/submitted';
    }

    return '/kyc/submitted?intent=${Uri.encodeComponent(intent)}'
        '&returnTo=${Uri.encodeComponent(returnTo)}';
  }

  String _copy(BuildContext context, String en, String fr) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'fr' ? fr : en;
  }
}
