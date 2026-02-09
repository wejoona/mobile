import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../router/navigation_extensions.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/theme/theme_provider.dart';
import 'package:usdc_wallet/core/haptics/haptic_service.dart';

/// Theme Settings View - Beautiful theme selection with animated preview cards
class ThemeSettingsView extends ConsumerWidget {
  const ThemeSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.settings_appearance,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.safePop(fallbackRoute: '/settings'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header description
              AppText(
                l10n.settings_selectTheme,
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppText(
                'Choose how JoonaPay looks to you',
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Light Theme Option
              _ThemePreviewCard(
                mode: AppThemeMode.light,
                currentMode: themeState.mode,
                icon: Icons.light_mode,
                label: l10n.settings_themeLight,
                description: l10n.settings_themeLightDescription,
                onTap: () {
                  hapticService.selection();
                  ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.light);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Dark Theme Option
              _ThemePreviewCard(
                mode: AppThemeMode.dark,
                currentMode: themeState.mode,
                icon: Icons.dark_mode,
                label: l10n.settings_themeDark,
                description: l10n.settings_themeDarkDescription,
                onTap: () {
                  hapticService.selection();
                  ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.dark);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // System Theme Option
              _ThemePreviewCard(
                mode: AppThemeMode.system,
                currentMode: themeState.mode,
                icon: Icons.brightness_auto,
                label: l10n.settings_themeSystem,
                description: l10n.settings_themeSystemDescription,
                onTap: () {
                  hapticService.selection();
                  ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.system);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Theme Preview Card - Shows visual preview of theme with selection state
class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard({
    required this.mode,
    required this.currentMode,
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final AppThemeMode mode;
  final AppThemeMode currentMode;
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  bool get isSelected => mode == currentMode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final previewColors = _getPreviewColors(mode);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isSelected ? colors.gold : colors.borderSubtle,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? AppShadows.goldGlow : AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon, label, and check mark
                Row(
                  children: [
                    // Icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.gold.withValues(alpha: 0.2)
                            : colors.textTertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? colors.gold : colors.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Label and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            label,
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

                    // Check mark
                    AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      scale: isSelected ? 1.0 : 0.0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isSelected ? 1.0 : 0.0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colors.gold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: AppColors.textInverse,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Visual Preview
                _ThemePreview(colors: previewColors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get preview colors based on theme mode
  _PreviewColors _getPreviewColors(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return const _PreviewColors(
          canvas: AppColorsLight.canvas,
          container: AppColorsLight.container,
          surface: AppColorsLight.surface,
          textPrimary: AppColorsLight.textPrimary,
          gold: AppColorsLight.gold500,
        );
      case AppThemeMode.dark:
        return const _PreviewColors(
          canvas: AppColors.graphite,
          container: AppColors.charcoal,
          surface: AppColors.slate,
          textPrimary: AppColors.textPrimary,
          gold: AppColors.gold500,
        );
      case AppThemeMode.system:
        // Show both light and dark in split view for system mode
        return const _PreviewColors(
          canvas: AppColors.graphite,
          container: AppColors.charcoal,
          surface: AppColors.slate,
          textPrimary: AppColors.textPrimary,
          gold: AppColors.gold500,
          isSystemMode: true,
        );
    }
  }
}

/// Preview Colors - Color scheme for theme preview
class _PreviewColors {
  final Color canvas;
  final Color container;
  final Color surface;
  final Color textPrimary;
  final Color gold;
  final bool isSystemMode;

  const _PreviewColors({
    required this.canvas,
    required this.container,
    required this.surface,
    required this.textPrimary,
    required this.gold,
    this.isSystemMode = false,
  });
}

/// Theme Preview - Visual representation of theme colors
class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.colors});

  final _PreviewColors colors;

  @override
  Widget build(BuildContext context) {
    if (colors.isSystemMode) {
      return _buildSystemPreview();
    }
    return _buildStandardPreview();
  }

  /// Standard preview for light/dark themes
  Widget _buildStandardPreview() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: colors.canvas,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Top bar with gold accent
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.gold, colors.gold.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.textPrimary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Container(
                      width: 120,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colors.textPrimary.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Card preview
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.container,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.textPrimary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.textPrimary.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colors.gold,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// System mode preview showing both light and dark
  Widget _buildSystemPreview() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Row(
          children: [
            // Light half
            Expanded(
              child: Container(
                color: AppColorsLight.canvas,
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColorsLight.gold500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColorsLight.textPrimary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColorsLight.container,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Divider
            Container(width: 1, color: colors.textPrimary.withValues(alpha: 0.2)),

            // Dark half
            Expanded(
              child: Container(
                color: AppColors.graphite,
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppColors.gold500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.charcoal,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
