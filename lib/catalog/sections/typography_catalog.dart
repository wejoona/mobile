import 'package:flutter/material.dart';
import 'package:usdc_wallet/catalog/widget_catalog_view.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

class TypographyCatalog extends StatelessWidget {
  const TypographyCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogSection(
          title: 'Typography Scale',
          description: 'Complete type hierarchy from display to labels',
          children: [
            _buildTypeRow('Display Large', AppTypography.displayLarge, colors),
            _buildTypeRow('Display Medium', AppTypography.displayMedium, colors),
            _buildTypeRow('Display Small', AppTypography.displaySmall, colors),
            const SizedBox(height: AppSpacing.md),
            _buildTypeRow('Headline Large', AppTypography.headlineLarge, colors),
            _buildTypeRow('Headline Medium', AppTypography.headlineMedium, colors),
            _buildTypeRow('Headline Small', AppTypography.headlineSmall, colors),
            const SizedBox(height: AppSpacing.md),
            _buildTypeRow('Title Large', AppTypography.titleLarge, colors),
            _buildTypeRow('Title Medium', AppTypography.titleMedium, colors),
            _buildTypeRow('Title Small', AppTypography.titleSmall, colors),
            const SizedBox(height: AppSpacing.md),
            _buildTypeRow('Body Large', AppTypography.bodyLarge, colors),
            _buildTypeRow('Body Medium', AppTypography.bodyMedium, colors),
            _buildTypeRow('Body Small', AppTypography.bodySmall, colors),
            const SizedBox(height: AppSpacing.md),
            _buildTypeRow('Label Large', AppTypography.labelLarge, colors),
            _buildTypeRow('Label Medium', AppTypography.labelMedium, colors),
            _buildTypeRow('Label Small', AppTypography.labelSmall, colors),
          ],
        ),
        CatalogSection(
          title: 'Special Typography',
          description: 'Domain-specific type styles',
          children: [
            DemoCard(
              label: 'Balance Display',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1,234.56 XOF',
                    style: AppTypography.balanceDisplay.copyWith(color: colors.gold),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildStyleInfo(AppTypography.balanceDisplay, colors),
                ],
              ),
            ),
            DemoCard(
              label: 'Percentage Change',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '+12.5%',
                    style: AppTypography.percentageChange.copyWith(color: colors.success),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildStyleInfo(AppTypography.percentageChange, colors),
                ],
              ),
            ),
            DemoCard(
              label: 'Card Label',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARD NUMBER',
                    style: AppTypography.cardLabel.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildStyleInfo(AppTypography.cardLabel, colors),
                ],
              ),
            ),
            DemoCard(
              label: 'Button',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Button Text',
                    style: AppTypography.button.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildStyleInfo(AppTypography.button, colors),
                ],
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Monospace Typography',
          description: 'Fixed-width fonts for codes and addresses',
          children: [
            DemoCard(
              label: 'Mono Large',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '0x1234567890ABCDEF',
                    style: AppTypography.monoLarge.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildStyleInfo(AppTypography.monoLarge, colors),
                ],
              ),
            ),
            DemoCard(
              label: 'Mono Medium',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ABC-123-XYZ-789',
                    style: AppTypography.monoMedium.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildStyleInfo(AppTypography.monoMedium, colors),
                ],
              ),
            ),
            DemoCard(
              label: 'Mono Small',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'tx-hash-123456',
                    style: AppTypography.monoSmall.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildStyleInfo(AppTypography.monoSmall, colors),
                ],
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Font Weights',
          description: 'Available weight variations',
          children: [
            DemoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeightRow('Light (300)', FontWeight.w300, colors),
                  const SizedBox(height: AppSpacing.md),
                  _buildWeightRow('Regular (400)', FontWeight.w400, colors),
                  const SizedBox(height: AppSpacing.md),
                  _buildWeightRow('Medium (500)', FontWeight.w500, colors),
                  const SizedBox(height: AppSpacing.md),
                  _buildWeightRow('Semi Bold (600)', FontWeight.w600, colors),
                  const SizedBox(height: AppSpacing.md),
                  _buildWeightRow('Bold (700)', FontWeight.w700, colors),
                ],
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Line Height & Spacing',
          description: 'Text readability and rhythm',
          children: [
            DemoCard(
              label: 'Tight Line Height (1.2)',
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  height: 1.2,
                ),
              ),
            ),
            DemoCard(
              label: 'Normal Line Height (1.5)',
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            DemoCard(
              label: 'Loose Line Height (1.8)',
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  height: 1.8,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeRow(String name, TextStyle style, ThemeColors colors) {
    return DemoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: style.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildStyleInfo(style, colors),
        ],
      ),
    );
  }

  Widget _buildStyleInfo(TextStyle style, ThemeColors colors) {
    return AppText(
      '${style.fontSize?.toStringAsFixed(0)}px • ${_getWeightName(style.fontWeight)} • ${style.height?.toStringAsFixed(2) ?? "auto"} line height',
      variant: AppTextVariant.labelSmall,
      color: colors.textTertiary,
    );
  }

  Widget _buildWeightRow(String name, FontWeight weight, ThemeColors colors) {
    return Text(
      name,
      style: AppTypography.bodyLarge.copyWith(
        fontWeight: weight,
        color: colors.textPrimary,
      ),
    );
  }

  String _getWeightName(FontWeight? weight) {
    if (weight == null) return 'Regular';
    switch (weight.index) {
      case 0: return 'Thin';
      case 1: return 'Extra Light';
      case 2: return 'Light';
      case 3: return 'Regular';
      case 4: return 'Medium';
      case 5: return 'Semi Bold';
      case 6: return 'Bold';
      case 7: return 'Extra Bold';
      case 8: return 'Black';
      default: return 'Regular';
    }
  }
}
