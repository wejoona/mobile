import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/services/legal/legal_documents_service.dart';

/// Full-screen legal document viewer
class LegalDocumentView extends ConsumerWidget {
  const LegalDocumentView({
    super.key,
    required this.documentType,
  });

  final LegalDocumentType documentType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final documentAsync = documentType == LegalDocumentType.termsOfService
        ? ref.watch(termsOfServiceProvider)
        : ref.watch(privacyPolicyProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          documentType == LegalDocumentType.termsOfService
              ? 'Terms of Service'
              : 'Privacy Policy',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        centerTitle: true,
      ),
      body: documentAsync.when(
        data: (document) => _buildContent(context, document, colors),
        loading: () => Center(
          child: CircularProgressIndicator(
            color: colors.gold,
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: colors.error,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppText(
                'Failed to load document',
                variant: AppTextVariant.bodyLarge,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                'Please try again later',
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LegalDocument document, ThemeColors colors) {
    return Column(
      children: [
        // Version info bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          color: colors.container,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: AppText(
                  'v${document.version}',
                  variant: AppTextVariant.labelSmall,
                  color: colors.gold,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppText(
                  'Effective: ${_formatDate(document.effectiveDate)}',
                  variant: AppTextVariant.bodySmall,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary if available
                if (document.summary != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: colors.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: colors.infoText,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            AppText(
                              'What\'s New',
                              variant: AppTextVariant.labelLarge,
                              color: colors.infoText,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppText(
                          document.summary!,
                          variant: AppTextVariant.bodyMedium,
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Main content
                HtmlWidget(
                  document.contentHtml,
                  textStyle: AppTypography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    height: 1.6,
                  ),
                  customStylesBuilder: (element) {
                    // Theme-aware colors
                    final headingColor = colors.isDark ? '#F5F5F0' : '#1A1A1F';
                    final goldColor = colors.isDark ? '#C9A962' : '#B8943D';

                    if (element.localName == 'h1') {
                      return {
                        'color': headingColor,
                        'font-size': '24px',
                        'font-weight': '600',
                        'margin-top': '24px',
                        'margin-bottom': '12px',
                      };
                    }
                    if (element.localName == 'h2') {
                      return {
                        'color': headingColor,
                        'font-size': '20px',
                        'font-weight': '600',
                        'margin-top': '20px',
                        'margin-bottom': '10px',
                      };
                    }
                    if (element.localName == 'h3') {
                      return {
                        'color': headingColor,
                        'font-size': '16px',
                        'font-weight': '600',
                        'margin-top': '16px',
                        'margin-bottom': '8px',
                      };
                    }
                    if (element.localName == 'a') {
                      return {
                        'color': goldColor,
                        'text-decoration': 'underline',
                      };
                    }
                    if (element.localName == 'strong' ||
                        element.localName == 'b') {
                      return {
                        'color': headingColor,
                        'font-weight': '600',
                      };
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// Bottom sheet for accepting terms during onboarding
class LegalConsentSheet extends ConsumerStatefulWidget {
  const LegalConsentSheet({
    super.key,
    required this.onAccept,
  });

  final VoidCallback onAccept;

  @override
  ConsumerState<LegalConsentSheet> createState() => _LegalConsentSheetState();
}

class _LegalConsentSheetState extends ConsumerState<LegalConsentSheet> {
  bool _termsRead = false;
  bool _privacyRead = false;
  bool _isAccepting = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final termsAsync = ref.watch(termsOfServiceProvider);
    final privacyAsync = ref.watch(privacyPolicyProvider);

    final canAccept = _termsRead && _privacyRead;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: colors.gold,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppText(
                  'Legal Agreements',
                  variant: AppTextVariant.titleLarge,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppText(
                  'Please review and accept our terms to continue',
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          Divider(color: colors.borderSubtle, height: 1),

          // Documents list
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Terms of Service
                _buildDocumentTile(
                  title: 'Terms of Service',
                  version: termsAsync.maybeWhen(
                    data: (doc) => 'v${doc.version}',
                    orElse: () => '',
                  ),
                  isRead: _termsRead,
                  onTap: () => _openDocument(
                    context,
                    LegalDocumentType.termsOfService,
                    () => setState(() => _termsRead = true),
                  ),
                  colors: colors,
                ),
                const SizedBox(height: AppSpacing.md),

                // Privacy Policy
                _buildDocumentTile(
                  title: 'Privacy Policy',
                  version: privacyAsync.maybeWhen(
                    data: (doc) => 'v${doc.version}',
                    orElse: () => '',
                  ),
                  isRead: _privacyRead,
                  onTap: () => _openDocument(
                    context,
                    LegalDocumentType.privacyPolicy,
                    () => setState(() => _privacyRead = true),
                  ),
                  colors: colors,
                ),
              ],
            ),
          ),

          // Accept button
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              children: [
                AppText(
                  'By tapping Accept, you agree to our Terms of Service and acknowledge our Privacy Policy',
                  variant: AppTextVariant.bodySmall,
                  color: colors.textTertiary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Accept & Continue',
                  onPressed: canAccept && !_isAccepting ? _handleAccept : null,
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.large,
                  isFullWidth: true,
                  isLoading: _isAccepting,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTile({
    required String title,
    required String version,
    required bool isRead,
    required VoidCallback onTap,
    required ThemeColors colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isRead
                ? AppColors.successBase.withValues(alpha: 0.5)
                : colors.borderSubtle,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isRead
                    ? AppColors.successBase.withValues(alpha: 0.15)
                    : colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                isRead ? Icons.check_rounded : Icons.article_outlined,
                color: isRead ? AppColors.successText : colors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Title & version
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    variant: AppTextVariant.bodyLarge,
                    color: colors.textPrimary,
                  ),
                  if (version.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    AppText(
                      version,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textTertiary,
                    ),
                  ],
                ],
              ),
            ),

            // Status/Arrow
            Icon(
              isRead ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              color: isRead ? AppColors.successText : colors.textTertiary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _openDocument(
    BuildContext context,
    LegalDocumentType type,
    VoidCallback onRead,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LegalDocumentView(documentType: type),
      ),
    ).then((_) => onRead());
  }

  Future<void> _handleAccept() async {
    setState(() => _isAccepting = true);

    try {
      final service = ref.read(legalDocumentsServiceProvider);
      final terms = await ref.read(termsOfServiceProvider.future);
      final privacy = await ref.read(privacyPolicyProvider.future);

      await service.recordAllConsents(
        terms: terms,
        privacy: privacy,
      );

      widget.onAccept();
    } catch (e) {
      // Still allow proceeding even if recording fails
      widget.onAccept();
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  }
}
