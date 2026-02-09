import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/catalog/sections/button_catalog.dart';
import 'package:usdc_wallet/catalog/sections/card_catalog.dart';
import 'package:usdc_wallet/catalog/sections/color_catalog.dart';
import 'package:usdc_wallet/catalog/sections/input_catalog.dart';
import 'package:usdc_wallet/catalog/sections/select_catalog.dart';
import 'package:usdc_wallet/catalog/sections/skeleton_catalog.dart';
import 'package:usdc_wallet/catalog/sections/spacing_catalog.dart';
import 'package:usdc_wallet/catalog/sections/text_catalog.dart';
import 'package:usdc_wallet/catalog/sections/toggle_catalog.dart';
import 'package:usdc_wallet/catalog/sections/typography_catalog.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Widget Catalog Screen
/// Design system component showcase for visual testing and documentation
class WidgetCatalogView extends ConsumerStatefulWidget {
  const WidgetCatalogView({super.key});

  @override
  ConsumerState<WidgetCatalogView> createState() => _WidgetCatalogViewState();
}

class _WidgetCatalogViewState extends ConsumerState<WidgetCatalogView> {
  int _selectedIndex = 0;

  final List<_CatalogSection> _sections = [
    _CatalogSection(
      title: 'Design Tokens',
      icon: Icons.palette,
      subsections: [
        _CatalogSubsection(title: 'Colors', builder: (context) => const ColorCatalog()),
        _CatalogSubsection(title: 'Typography', builder: (context) => const TypographyCatalog()),
        _CatalogSubsection(title: 'Spacing', builder: (context) => const SpacingCatalog()),
      ],
    ),
    _CatalogSection(
      title: 'Primitives',
      icon: Icons.widgets,
      subsections: [
        _CatalogSubsection(title: 'AppButton', builder: (context) => const ButtonCatalog()),
        _CatalogSubsection(title: 'AppText', builder: (context) => const TextCatalog()),
        _CatalogSubsection(title: 'AppInput', builder: (context) => const InputCatalog()),
        _CatalogSubsection(title: 'AppCard', builder: (context) => const CardCatalog()),
        _CatalogSubsection(title: 'AppSelect', builder: (context) => const SelectCatalog()),
        _CatalogSubsection(title: 'AppToggle', builder: (context) => const ToggleCatalog()),
        _CatalogSubsection(title: 'AppSkeleton', builder: (context) => const SkeletonCatalog()),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar navigation
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: colors.container,
                border: Border(
                  right: BorderSide(color: colors.borderSubtle),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: AppColors.goldGradient,
                                ),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: const Icon(
                                Icons.palette,
                                size: 20,
                                color: AppColors.textInverse,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            AppText(
                              'Widget Catalog',
                              variant: AppTextVariant.titleLarge,
                              color: colors.textPrimary,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppText(
                          'Design System Showcase',
                          variant: AppTextVariant.bodySmall,
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Navigation items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      itemCount: _getTotalItemCount(),
                      itemBuilder: (context, index) => _buildNavigationItem(index, colors),
                    ),
                  ),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: _buildContent(colors),
            ),
          ],
        ),
      ),
    );
  }

  int _getTotalItemCount() {
    int count = 0;
    for (final section in _sections) {
      count += 1; // Section header
      count += section.subsections.length;
    }
    return count;
  }

  Widget _buildNavigationItem(int flatIndex, ThemeColors colors) {
    int currentIndex = 0;

    for (final section in _sections) {
      // Section header
      if (currentIndex == flatIndex) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(section.icon, size: 16, color: colors.gold),
              const SizedBox(width: AppSpacing.sm),
              AppText(
                section.title,
                variant: AppTextVariant.labelSmall,
                color: colors.gold,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        );
      }
      currentIndex++;

      // Subsection items
      for (int i = 0; i < section.subsections.length; i++) {
        if (currentIndex == flatIndex) {
          final subsection = section.subsections[i];
          final isSelected = _selectedIndex == _getSubsectionGlobalIndex(section, i);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedIndex = _getSubsectionGlobalIndex(section, i);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colors.gold.withValues(alpha: 0.1) : null,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: isSelected
                      ? Border.all(color: colors.gold.withValues(alpha: 0.3))
                      : null,
                ),
                child: AppText(
                  subsection.title,
                  variant: AppTextVariant.bodyMedium,
                  color: isSelected ? colors.gold : colors.textSecondary,
                ),
              ),
            ),
          );
        }
        currentIndex++;
      }
    }

    return const SizedBox.shrink();
  }

  int _getSubsectionGlobalIndex(_CatalogSection section, int subsectionIndex) {
    int index = 0;
    for (final s in _sections) {
      if (s == section) {
        return index + subsectionIndex;
      }
      index += s.subsections.length;
    }
    return 0;
  }

  Widget _buildContent(ThemeColors colors) {
    int currentIndex = 0;

    for (final section in _sections) {
      for (final subsection in section.subsections) {
        if (currentIndex == _selectedIndex) {
          return Container(
            color: colors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content header
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.container,
                    border: Border(
                      bottom: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(section.icon, size: 24, color: colors.gold),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            subsection.title,
                            variant: AppTextVariant.headlineSmall,
                            color: colors.textPrimary,
                          ),
                          AppText(
                            section.title,
                            variant: AppTextVariant.bodySmall,
                            color: colors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: subsection.builder(context),
                  ),
                ),
              ],
            ),
          );
        }
        currentIndex++;
      }
    }

    return const Center(child: Text('No content'));
  }
}

class _CatalogSection {
  final String title;
  final IconData icon;
  final List<_CatalogSubsection> subsections;

  _CatalogSection({
    required this.title,
    required this.icon,
    required this.subsections,
  });
}

class _CatalogSubsection {
  final String title;
  final WidgetBuilder builder;

  _CatalogSubsection({
    required this.title,
    required this.builder,
  });
}

/// Section wrapper for catalog items
class CatalogSection extends StatelessWidget {
  const CatalogSection({
    super.key,
    required this.title,
    this.description,
    required this.children,
  });

  final String title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.xs),
          AppText(
            description!,
            variant: AppTextVariant.bodySmall,
            color: colors.textSecondary,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        ...children,
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// Demo card wrapper
class DemoCard extends StatelessWidget {
  const DemoCard({
    super.key,
    this.label,
    required this.child,
    this.padding,
  });

  final String? label;
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          AppText(
            label!,
            variant: AppTextVariant.labelMedium,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: child,
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
