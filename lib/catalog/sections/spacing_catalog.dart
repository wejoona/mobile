import 'package:flutter/material.dart';
import 'package:usdc_wallet/catalog/widget_catalog_view.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

class SpacingCatalog extends StatelessWidget {
  const SpacingCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogSection(
          title: 'Spacing Scale',
          description: 'Consistent spacing system for layouts',
          children: [
            _buildSpacingRow('xxs', AppSpacing.xxs, colors),
            _buildSpacingRow('xs', AppSpacing.xs, colors),
            _buildSpacingRow('sm', AppSpacing.sm, colors),
            _buildSpacingRow('md', AppSpacing.md, colors),
            _buildSpacingRow('lg', AppSpacing.lg, colors),
            _buildSpacingRow('xl', AppSpacing.xl, colors),
            _buildSpacingRow('xxl', AppSpacing.xxl, colors),
          ],
        ),
        CatalogSection(
          title: 'Border Radius',
          description: 'Corner radius system',
          children: [
            _buildRadiusRow('sm', AppRadius.sm, colors),
            _buildRadiusRow('md', AppRadius.md, colors),
            _buildRadiusRow('lg', AppRadius.lg, colors),
            _buildRadiusRow('xl', AppRadius.xl, colors),
            _buildRadiusRow('full', AppRadius.full, colors),
          ],
        ),
        CatalogSection(
          title: 'Component Spacing',
          description: 'Predefined spacing for common components',
          children: [
            DemoCard(
              label: 'Screen Padding (${AppSpacing.screenPadding}px)',
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.gold.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: AppCard(
                  child: AppText(
                    'Screen content with standard padding',
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
            DemoCard(
              label: 'Card Padding (${AppSpacing.cardPadding}px)',
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: AppText(
                  'Card with standard padding',
                  color: colors.textPrimary,
                ),
              ),
            ),
            DemoCard(
              label: 'Section Gap (${AppSpacing.sectionGap}px)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: AppText('Section 1', color: colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  AppCard(
                    child: AppText('Section 2', color: colors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Layout Examples',
          description: 'Spacing applied in real layouts',
          children: [
            DemoCard(
              label: 'Form Layout',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Sign In',
                    variant: AppTextVariant.headlineMedium,
                    color: colors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppText(
                    'Enter your credentials',
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppInput(
                    controller: TextEditingController(),
                    label: 'Email',
                    hint: 'email@example.com',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    controller: TextEditingController(),
                    label: 'Password',
                    hint: 'Enter password',
                    obscureText: true,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Sign In',
                    isFullWidth: true,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            DemoCard(
              label: 'Card Grid Layout',
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.2,
                children: [
                  AppCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, color: colors.gold, size: 32),
                        const SizedBox(height: AppSpacing.sm),
                        AppText('Send', color: colors.textPrimary),
                      ],
                    ),
                  ),
                  AppCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code, color: colors.gold, size: 32),
                        const SizedBox(height: AppSpacing.sm),
                        AppText('Receive', color: colors.textPrimary),
                      ],
                    ),
                  ),
                  AppCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swap_horiz, color: colors.gold, size: 32),
                        const SizedBox(height: AppSpacing.sm),
                        AppText('Exchange', color: colors.textPrimary),
                      ],
                    ),
                  ),
                  AppCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, color: colors.gold, size: 32),
                        const SizedBox(height: AppSpacing.sm),
                        AppText('History', color: colors.textPrimary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            DemoCard(
              label: 'List Item Spacing',
              child: Column(
                children: [
                  _buildListItem('Transaction 1', 'Jan 30, 2026', colors),
                  const SizedBox(height: AppSpacing.sm),
                  _buildListItem('Transaction 2', 'Jan 29, 2026', colors),
                  const SizedBox(height: AppSpacing.sm),
                  _buildListItem('Transaction 3', 'Jan 28, 2026', colors),
                ],
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Shadows & Elevation',
          description: 'Shadow system for depth hierarchy',
          children: [
            DemoCard(
              label: 'Small Shadow',
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppShadows.sm,
                ),
                child: Center(
                  child: AppText('Small elevation', color: colors.textPrimary),
                ),
              ),
            ),
            DemoCard(
              label: 'Medium Shadow',
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppShadows.md,
                ),
                child: Center(
                  child: AppText('Medium elevation', color: colors.textPrimary),
                ),
              ),
            ),
            DemoCard(
              label: 'Large Shadow',
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppShadows.lg,
                ),
                child: Center(
                  child: AppText('Large elevation', color: colors.textPrimary),
                ),
              ),
            ),
            DemoCard(
              label: 'Gold Glow',
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.goldGradient),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppShadows.goldGlow,
                ),
                child: Center(
                  child: AppText(
                    'Premium gold glow',
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpacingRow(String name, double value, ThemeColors colors) {
    return DemoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: AppText(
              name,
              variant: AppTextVariant.labelMedium,
              color: colors.textSecondary,
            ),
          ),
          AppText(
            '${value.toInt()}px',
            variant: AppTextVariant.bodySmall,
            color: colors.textTertiary,
          ),
          const Spacer(),
          Container(
            width: value,
            height: 20,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.3),
              border: Border.all(color: colors.gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusRow(String name, double value, ThemeColors colors) {
    return DemoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: AppText(
              name,
              variant: AppTextVariant.labelMedium,
              color: colors.textSecondary,
            ),
          ),
          AppText(
            '${value.toInt()}px',
            variant: AppTextVariant.bodySmall,
            color: colors.textTertiary,
          ),
          const Spacer(),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.2),
              border: Border.all(color: colors.gold),
              borderRadius: BorderRadius.circular(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String title, String subtitle, ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.receipt, color: colors.gold, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, color: colors.textPrimary),
                AppText(
                  subtitle,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: colors.textTertiary),
        ],
      ),
    );
  }
}
