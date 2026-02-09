import 'package:flutter/material.dart';
import 'package:usdc_wallet/catalog/widget_catalog_view.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

class TextCatalog extends StatelessWidget {
  const TextCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogSection(
          title: 'Display Styles',
          description: 'Largest text styles for major headlines',
          children: [
            DemoCard(
              label: 'Display Large',
              child: AppText(
                'Display Large',
                variant: AppTextVariant.displayLarge,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Display Medium',
              child: AppText(
                'Display Medium',
                variant: AppTextVariant.displayMedium,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Display Small',
              child: AppText(
                'Display Small',
                variant: AppTextVariant.displaySmall,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Headline Styles',
          description: 'Section headers and prominent titles',
          children: [
            DemoCard(
              label: 'Headline Large',
              child: AppText(
                'Headline Large',
                variant: AppTextVariant.headlineLarge,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Headline Medium',
              child: AppText(
                'Headline Medium',
                variant: AppTextVariant.headlineMedium,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Headline Small',
              child: AppText(
                'Headline Small',
                variant: AppTextVariant.headlineSmall,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Title Styles',
          description: 'Card titles and subsection headers',
          children: [
            DemoCard(
              label: 'Title Large',
              child: AppText(
                'Title Large',
                variant: AppTextVariant.titleLarge,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Title Medium',
              child: AppText(
                'Title Medium',
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Title Small',
              child: AppText(
                'Title Small',
                variant: AppTextVariant.titleSmall,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Body Styles',
          description: 'Main content text',
          children: [
            DemoCard(
              label: 'Body Large',
              child: AppText(
                'Body Large - The quick brown fox jumps over the lazy dog',
                variant: AppTextVariant.bodyLarge,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Body Medium',
              child: AppText(
                'Body Medium - The quick brown fox jumps over the lazy dog',
                variant: AppTextVariant.bodyMedium,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Body Small',
              child: AppText(
                'Body Small - The quick brown fox jumps over the lazy dog',
                variant: AppTextVariant.bodySmall,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Label Styles',
          description: 'Form labels, captions, and metadata',
          children: [
            DemoCard(
              label: 'Label Large',
              child: AppText(
                'Label Large',
                variant: AppTextVariant.labelLarge,
                color: colors.textSecondary,
              ),
            ),
            DemoCard(
              label: 'Label Medium',
              child: AppText(
                'Label Medium',
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
            ),
            DemoCard(
              label: 'Label Small',
              child: AppText(
                'Label Small',
                variant: AppTextVariant.labelSmall,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Special Variants',
          description: 'Domain-specific text styles',
          children: [
            DemoCard(
              label: 'Balance Display',
              child: AppText(
                '1,234.56 XOF',
                variant: AppTextVariant.balance,
                color: colors.gold,
              ),
            ),
            DemoCard(
              label: 'Percentage Change',
              child: AppText(
                '+12.5%',
                variant: AppTextVariant.percentage,
                color: colors.success,
              ),
            ),
            DemoCard(
              label: 'Card Label',
              child: AppText(
                'Card Number',
                variant: AppTextVariant.cardLabel,
                color: colors.textSecondary,
              ),
            ),
            DemoCard(
              label: 'Mono Large',
              child: AppText(
                '0x1234...5678',
                variant: AppTextVariant.monoLarge,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Mono Medium',
              child: AppText(
                'ABC-123-XYZ',
                variant: AppTextVariant.monoMedium,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Mono Small',
              child: AppText(
                'tx-hash-here',
                variant: AppTextVariant.monoSmall,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Color Variants',
          description: 'Text with semantic colors',
          children: [
            DemoCard(
              label: 'Primary Text',
              child: AppText(
                'Primary text color (high emphasis)',
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Secondary Text',
              child: AppText(
                'Secondary text color (medium emphasis)',
                color: colors.textSecondary,
              ),
            ),
            DemoCard(
              label: 'Tertiary Text',
              child: AppText(
                'Tertiary text color (low emphasis)',
                color: colors.textTertiary,
              ),
            ),
            DemoCard(
              label: 'Gold Accent',
              child: AppText(
                'Gold accent text (premium/featured)',
                color: colors.gold,
              ),
            ),
            DemoCard(
              label: 'Success',
              child: AppText(
                'Success state text',
                color: colors.success,
              ),
            ),
            DemoCard(
              label: 'Error',
              child: AppText(
                'Error state text',
                color: colors.error,
              ),
            ),
            DemoCard(
              label: 'Warning',
              child: AppText(
                'Warning state text',
                color: colors.warning,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Text Alignment & Overflow',
          description: 'Text alignment and overflow handling',
          children: [
            DemoCard(
              label: 'Left Aligned',
              child: AppText(
                'Left aligned text',
                textAlign: TextAlign.left,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Center Aligned',
              child: AppText(
                'Center aligned text',
                textAlign: TextAlign.center,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Right Aligned',
              child: AppText(
                'Right aligned text',
                textAlign: TextAlign.right,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Ellipsis Overflow',
              child: AppText(
                'This is a very long text that will be truncated with ellipsis when it exceeds the maximum width available in the container',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Multiline (2 lines max)',
              child: AppText(
                'This is a longer text that will wrap to multiple lines but will be limited to a maximum of two lines before being truncated',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Font Weight',
          description: 'Custom font weights',
          children: [
            DemoCard(
              label: 'Light',
              child: AppText(
                'Light weight text',
                variant: AppTextVariant.bodyLarge,
                fontWeight: FontWeight.w300,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Regular',
              child: AppText(
                'Regular weight text',
                variant: AppTextVariant.bodyLarge,
                fontWeight: FontWeight.w400,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Medium',
              child: AppText(
                'Medium weight text',
                variant: AppTextVariant.bodyLarge,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Semi Bold',
              child: AppText(
                'Semi bold weight text',
                variant: AppTextVariant.bodyLarge,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            DemoCard(
              label: 'Bold',
              child: AppText(
                'Bold weight text',
                variant: AppTextVariant.bodyLarge,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
