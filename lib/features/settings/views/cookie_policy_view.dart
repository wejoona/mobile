import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../services/legal/legal_documents_service.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Cookie Policy view screen
/// Displays the cookie policy document with proper theming and localization
class CookiePolicyView extends ConsumerWidget {
  const CookiePolicyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final documentAsync = ref.watch(cookiePolicyProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          l10n.legal_cookiePolicy,
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        centerTitle: true,
      ),
      body: documentAsync.when(
        data: (document) => _buildContent(context, document, colors, l10n),
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
                l10n.error_loadFailed,
                variant: AppTextVariant.bodyLarge,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                l10n.error_tryAgainLater,
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.action_retry,
                onPressed: () => ref.invalidate(cookiePolicyProvider),
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    LegalDocument document,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
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
                  '${l10n.legal_effectiveDate}: ${_formatDate(document.effectiveDate, l10n)}',
                  variant: AppTextVariant.bodySmall,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),

        // Cookie categories summary
        _buildCookieSummary(colors, l10n),

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
                              l10n.legal_whatsNew,
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
                    if (element.localName == 'code') {
                      return {
                        'background-color': colors.isDark ? '#2A2A2F' : '#F0F0F0',
                        'padding': '2px 6px',
                        'border-radius': '4px',
                        'font-family': 'monospace',
                      };
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Contact section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.container,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: colors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.mail_outline_rounded,
                            color: colors.gold,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          AppText(
                            l10n.legal_contactUs,
                            variant: AppTextVariant.titleSmall,
                            color: colors.textPrimary,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppText(
                        l10n.legal_cookieContactDescription,
                        variant: AppTextVariant.bodyMedium,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppText(
                        'privacy@joonapay.com',
                        variant: AppTextVariant.bodyMedium,
                        color: colors.gold,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCookieSummary(ThemeColors colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.elevated,
        border: Border(
          bottom: BorderSide(color: colors.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.legal_cookieCategories,
            variant: AppTextVariant.labelLarge,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildCookieCategoryChip(
                  icon: Icons.security_rounded,
                  label: l10n.legal_essential,
                  color: AppColors.successBase,
                  required: true,
                  colors: colors,
                  l10n: l10n,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildCookieCategoryChip(
                  icon: Icons.tune_rounded,
                  label: l10n.legal_functional,
                  color: AppColors.infoBase,
                  required: false,
                  colors: colors,
                  l10n: l10n,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildCookieCategoryChip(
                  icon: Icons.bar_chart_rounded,
                  label: l10n.legal_analytics,
                  color: AppColors.warningBase,
                  required: false,
                  colors: colors,
                  l10n: l10n,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCookieCategoryChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool required,
    required ThemeColors colors,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            label,
            variant: AppTextVariant.labelSmall,
            color: colors.textPrimary,
            textAlign: TextAlign.center,
          ),
          if (required) ...[
            const SizedBox(height: AppSpacing.xxs),
            AppText(
              l10n.legal_required,
              variant: AppTextVariant.labelSmall,
              color: colors.textTertiary,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
