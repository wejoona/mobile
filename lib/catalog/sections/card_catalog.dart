import 'package:flutter/material.dart';
import 'package:usdc_wallet/catalog/widget_catalog_view.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

class CardCatalog extends StatelessWidget {
  const CardCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogSection(
          title: 'Variants',
          description: 'Different card styles for various contexts',
          children: [
            DemoCard(
              label: 'Flat - No shadow, subtle border',
              child: AppCard(
                variant: AppCardVariant.flat,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Flat Card',
                      variant: AppTextVariant.titleMedium,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      'Minimal card with subtle border, no shadow',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            DemoCard(
              label: 'Elevated - Standard card with shadow (default)',
              child: AppCard(
                variant: AppCardVariant.elevated,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Elevated Card',
                      variant: AppTextVariant.titleMedium,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      'Standard card with elevation and shadow',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            DemoCard(
              label: 'Outlined - Visible border, no shadow',
              child: AppCard(
                variant: AppCardVariant.outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Outlined Card',
                      variant: AppTextVariant.titleMedium,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      'Card with visible border, no shadow',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            DemoCard(
              label: 'Filled - Solid background',
              child: AppCard(
                variant: AppCardVariant.filled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Filled Card',
                      variant: AppTextVariant.titleMedium,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      'Card with solid background color',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            DemoCard(
              label: 'Gold Accent - Featured content',
              child: AppCard(
                variant: AppCardVariant.goldAccent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Gold Accent Card',
                      variant: AppTextVariant.titleMedium,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      'Premium card with gold border',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            DemoCard(
              label: 'Glass - Glassmorphism effect',
              child: AppCard(
                variant: AppCardVariant.glass,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Glass Card',
                      variant: AppTextVariant.titleMedium,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      'Card with glass morphism effect',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Selection States',
          description: 'Cards with selected state (useful for multi-select, options)',
          children: [
            DemoCard(
              label: 'Flat - Selected',
              child: AppCard(
                variant: AppCardVariant.flat,
                isSelected: true,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: colors.gold),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppText(
                        'Selected flat card with gold border',
                        variant: AppTextVariant.bodyMedium,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DemoCard(
              label: 'Outlined - Selected',
              child: AppCard(
                variant: AppCardVariant.outlined,
                isSelected: true,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: colors.gold),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppText(
                        'Selected outlined card',
                        variant: AppTextVariant.bodyMedium,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DemoCard(
              label: 'Filled - Selected',
              child: AppCard(
                variant: AppCardVariant.filled,
                isSelected: true,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: colors.gold),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppText(
                        'Selected filled card with gold tint',
                        variant: AppTextVariant.bodyMedium,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Interactive',
          description: 'Cards with tap interactions',
          children: [
            DemoCard(
              label: 'Tappable Card',
              child: AppCard(
                variant: AppCardVariant.elevated,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: AppText(
                        'Card tapped!',
                        color: colors.textPrimary,
                      ),
                      backgroundColor: colors.container,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.touch_app, color: colors.gold),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Tap me!',
                            variant: AppTextVariant.titleMedium,
                            color: colors.textPrimary,
                          ),
                          AppText(
                            'Interactive card with tap handler',
                            variant: AppTextVariant.bodySmall,
                            color: colors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: colors.textTertiary),
                  ],
                ),
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Custom Spacing',
          description: 'Cards with custom padding and margin',
          children: [
            DemoCard(
              label: 'No Padding',
              child: AppCard(
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: Column(
                    children: [
                      Container(
                        height: 120,
                        color: colors.gold.withValues(alpha: 0.2),
                        child: Center(
                          child: AppText(
                            'Full Bleed Content',
                            variant: AppTextVariant.titleMedium,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: AppText(
                          'Card with no padding and image header',
                          variant: AppTextVariant.bodySmall,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            DemoCard(
              label: 'Custom Padding',
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: AppText(
                  'Card with extra padding',
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Custom Border Radius',
          description: 'Cards with different corner radii',
          children: [
            DemoCard(
              label: 'Small Radius',
              child: AppCard(
                borderRadius: AppRadius.sm,
                child: AppText(
                  'Card with small border radius',
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textPrimary,
                ),
              ),
            ),
            DemoCard(
              label: 'Medium Radius',
              child: AppCard(
                borderRadius: AppRadius.md,
                child: AppText(
                  'Card with medium border radius',
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textPrimary,
                ),
              ),
            ),
            DemoCard(
              label: 'Extra Large Radius (default)',
              child: AppCard(
                borderRadius: AppRadius.xl,
                child: AppText(
                  'Card with extra large border radius',
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
