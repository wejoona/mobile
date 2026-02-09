import 'package:flutter/material.dart';
import 'package:usdc_wallet/catalog/widget_catalog_view.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

class ColorCatalog extends StatelessWidget {
  const ColorCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogSection(
          title: 'Brand Colors - Gold Palette',
          description: 'Premium gold accent system (5% of UI)',
          children: [
            _buildColorGrid([
              _ColorItem('gold50', AppColors.gold50),
              _ColorItem('gold100', AppColors.gold100),
              _ColorItem('gold200', AppColors.gold200),
              _ColorItem('gold300', AppColors.gold300),
              _ColorItem('gold400', AppColors.gold400),
              _ColorItem('gold500', AppColors.gold500, isPrimary: true),
              _ColorItem('gold600', AppColors.gold600),
              _ColorItem('gold700', AppColors.gold700),
              _ColorItem('gold800', AppColors.gold800),
              _ColorItem('gold900', AppColors.gold900),
            ], colors),
          ],
        ),
        CatalogSection(
          title: 'Background Colors',
          description: 'Dark foundations (70% of UI)',
          children: [
            DemoCard(
              label: 'Obsidian - Main canvas',
              child: _buildColorSwatch('obsidian', AppColors.obsidian),
            ),
            DemoCard(
              label: 'Graphite - Elevated surfaces',
              child: _buildColorSwatch('graphite', AppColors.graphite),
            ),
            DemoCard(
              label: 'Slate - Cards, containers',
              child: _buildColorSwatch('slate', AppColors.slate),
            ),
            DemoCard(
              label: 'Elevated - Hover, inputs',
              child: _buildColorSwatch('elevated', AppColors.elevated),
            ),
            DemoCard(
              label: 'Glass - Glassmorphism',
              child: _buildColorSwatch('glass', AppColors.glass),
            ),
          ],
        ),
        CatalogSection(
          title: 'Text Colors',
          description: 'Text hierarchy (20% of UI)',
          children: [
            DemoCard(
              label: 'Primary - High emphasis',
              child: _buildTextSwatch('textPrimary', AppColors.textPrimary),
            ),
            DemoCard(
              label: 'Secondary - Medium emphasis',
              child: _buildTextSwatch('textSecondary', AppColors.textSecondary),
            ),
            DemoCard(
              label: 'Tertiary - Low emphasis',
              child: _buildTextSwatch('textTertiary', AppColors.textTertiary),
            ),
            DemoCard(
              label: 'Disabled - Disabled state',
              child: _buildTextSwatch('textDisabled', AppColors.textDisabled),
            ),
            DemoCard(
              label: 'Inverse - On light backgrounds',
              child: _buildTextSwatch('textInverse', AppColors.textInverse, isDark: false),
            ),
          ],
        ),
        CatalogSection(
          title: 'Semantic Colors',
          description: 'Status and feedback colors',
          children: [
            DemoCard(
              label: 'Success - Emerald (wealth, growth)',
              child: _buildSemanticSwatch(
                'Success',
                AppColors.successBase,
                AppColors.successLight,
                AppColors.successDark,
                AppColors.successText,
              ),
            ),
            DemoCard(
              label: 'Warning - Amber',
              child: _buildSemanticSwatch(
                'Warning',
                AppColors.warningBase,
                AppColors.warningLight,
                AppColors.warningDark,
                AppColors.warningText,
              ),
            ),
            DemoCard(
              label: 'Error - Crimson velvet',
              child: _buildSemanticSwatch(
                'Error',
                AppColors.errorBase,
                AppColors.errorLight,
                AppColors.errorDark,
                AppColors.errorText,
              ),
            ),
            DemoCard(
              label: 'Info - Steel blue',
              child: _buildSemanticSwatch(
                'Info',
                AppColors.infoBase,
                AppColors.infoLight,
                AppColors.infoDark,
                AppColors.infoText,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Border & Divider Colors',
          description: 'Subtle separation elements',
          children: [
            DemoCard(
              label: 'Border Subtle - 6% white',
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.all(color: AppColors.borderSubtle, width: 2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: AppText(
                    'Subtle border',
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),
            DemoCard(
              label: 'Border Default - 10% white',
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.all(color: AppColors.borderDefault, width: 2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: AppText(
                    'Default border',
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
            DemoCard(
              label: 'Border Gold - Premium accent',
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.all(color: AppColors.borderGold, width: 2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: AppText(
                    'Gold border',
                    color: colors.gold,
                  ),
                ),
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Overlay Colors',
          description: 'Modal and interaction overlays',
          children: [
            DemoCard(
              label: 'Overlay Dark',
              child: Stack(
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: colors.gold,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.overlayDark,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: AppText(
                        'Dark overlay (60%)',
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DemoCard(
              label: 'Overlay Light',
              child: Stack(
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.overlayLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: AppText(
                        'Light overlay (10%)',
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorGrid(List<_ColorItem> colors, ThemeColors themeColors) {
    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      children: colors.map((item) {
        return Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: item.isPrimary
                      ? Border.all(color: AppColors.gold700, width: 2)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppText(
              item.name,
              variant: AppTextVariant.labelSmall,
              color: themeColors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Center(
        child: AppText(
          name,
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextSwatch(String name, Color color, {bool isDark = true}) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? AppColors.obsidian : AppColors.gold500,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Center(
        child: AppText(
          name,
          variant: AppTextVariant.bodyMedium,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSemanticSwatch(
    String name,
    Color base,
    Color light,
    Color dark,
    Color text,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: dark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                bottomLeft: Radius.circular(AppRadius.md),
              ),
            ),
            child: Center(
              child: AppText('Dark', color: text, variant: AppTextVariant.labelSmall),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 80,
            color: base,
            child: Center(
              child: AppText('Base', color: text, variant: AppTextVariant.bodyMedium),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 80,
            color: light,
            child: Center(
              child: AppText('Light', color: text, variant: AppTextVariant.labelSmall),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.obsidian,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppRadius.md),
                bottomRight: Radius.circular(AppRadius.md),
              ),
            ),
            child: Center(
              child: AppText('Text', color: text, variant: AppTextVariant.labelSmall),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorItem {
  final String name;
  final Color color;
  final bool isPrimary;

  _ColorItem(this.name, this.color, {this.isPrimary = false});
}
