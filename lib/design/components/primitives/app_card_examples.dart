import 'package:flutter/material.dart';
import '../../tokens/index.dart';
import 'app_card.dart';
import 'app_text.dart';

/// AppCard Usage Examples
///
/// This file demonstrates all variants and features of the AppCard component.
/// View this in the catalog or use as a reference for implementation.

class AppCardExamples extends StatelessWidget {
  const AppCardExamples({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: const Text('AppCard Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Basic Variants',
              'All card styles with theme-aware colors and shadows',
              colors,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildFlatCardExample(colors),
            const SizedBox(height: AppSpacing.md),
            _buildElevatedCardExample(colors),
            const SizedBox(height: AppSpacing.md),
            _buildOutlinedCardExample(colors),
            const SizedBox(height: AppSpacing.md),
            _buildFilledCardExample(colors),
            const SizedBox(height: AppSpacing.md),
            _buildGoldAccentCardExample(colors),
            const SizedBox(height: AppSpacing.md),
            _buildGlassCardExample(colors),
            const SizedBox(height: AppSpacing.xxl),

            _buildSectionHeader(
              'Selection States',
              'Cards with isSelected property for multi-select UIs',
              colors,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSelectionExample(colors),
            const SizedBox(height: AppSpacing.xxl),

            _buildSectionHeader(
              'Interactive Cards',
              'Cards with onTap handlers showing hover/press states',
              colors,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildInteractiveExample(colors),
            const SizedBox(height: AppSpacing.xxl),

            _buildSectionHeader(
              'Custom Styling',
              'Override colors and borders for specific use cases',
              colors,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildCustomStyleExample(colors),
            const SizedBox(height: AppSpacing.xxl),

            _buildSectionHeader(
              'Real-World Examples',
              'Common patterns for cards in production',
              colors,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildRealWorldExamples(colors),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String description, ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.xs),
        AppText(
          description,
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildFlatCardExample(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Flat Card',
          variant: AppTextVariant.labelLarge,
          color: colors.textTertiary,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          variant: AppCardVariant.flat,
          child: AppText(
            'No shadow, subtle border. Best for dense layouts where elevation might be too heavy.',
            variant: AppTextVariant.bodyMedium,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildElevatedCardExample(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Elevated Card (Default)',
          variant: AppTextVariant.labelLarge,
          color: colors.textTertiary,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          variant: AppCardVariant.elevated,
          child: AppText(
            'Shadow with no border. Default variant. Shadow is lighter in light mode, stronger in dark mode.',
            variant: AppTextVariant.bodyMedium,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildOutlinedCardExample(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Outlined Card',
          variant: AppTextVariant.labelLarge,
          color: colors.textTertiary,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          variant: AppCardVariant.outlined,
          child: AppText(
            'Visible border, no shadow. Good for form sections or settings groups.',
            variant: AppTextVariant.bodyMedium,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilledCardExample(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Filled Card',
          variant: AppTextVariant.labelLarge,
          color: colors.textTertiary,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          variant: AppCardVariant.filled,
          child: AppText(
            'Solid background color. Automatically tinted gold when selected.',
            variant: AppTextVariant.bodyMedium,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildGoldAccentCardExample(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Gold Accent Card',
          variant: AppTextVariant.labelLarge,
          color: colors.textTertiary,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          variant: AppCardVariant.goldAccent,
          child: Row(
            children: [
              Icon(Icons.star, color: colors.gold, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText(
                  'Premium content with gold border. Use sparingly for featured items.',
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCardExample(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Glass Card',
          variant: AppTextVariant.labelLarge,
          color: colors.textTertiary,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          variant: AppCardVariant.glass,
          child: AppText(
            'Semi-transparent glassmorphism effect. Works over backgrounds or images.',
            variant: AppTextVariant.bodyMedium,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionExample(ThemeColors colors) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Not Selected',
                variant: AppTextVariant.labelSmall,
                color: colors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                variant: AppCardVariant.outlined,
                isSelected: false,
                child: Column(
                  children: [
                    Icon(Icons.radio_button_unchecked, color: colors.textTertiary),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      'Option A',
                      variant: AppTextVariant.bodyMedium,
                      color: colors.textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Selected',
                variant: AppTextVariant.labelSmall,
                color: colors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                variant: AppCardVariant.outlined,
                isSelected: true,
                child: Column(
                  children: [
                    Icon(Icons.radio_button_checked, color: colors.gold),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      'Option B',
                      variant: AppTextVariant.bodyMedium,
                      color: colors.textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveExample(ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.elevated,
      onTap: () {
        // Handle tap
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.touch_app, color: colors.gold),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Tap to Interact',
                  variant: AppTextVariant.titleMedium,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  'Press to see ripple effect. Hover on web/desktop.',
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildCustomStyleExample(ThemeColors colors) {
    return Column(
      children: [
        AppCard(
          variant: AppCardVariant.outlined,
          backgroundColor: colors.successBg,
          borderColor: colors.success,
          child: Row(
            children: [
              Icon(Icons.check_circle, color: colors.success),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText(
                  'Custom success card with green background and border',
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          variant: AppCardVariant.flat,
          backgroundColor: colors.errorBg,
          borderColor: colors.error,
          child: Row(
            children: [
              Icon(Icons.error, color: colors.error),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText(
                  'Custom error card with red background and border',
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRealWorldExamples(ThemeColors colors) {
    return Column(
      children: [
        // Payment method selector
        AppText(
          'Payment Method Selector',
          variant: AppTextVariant.labelMedium,
          color: colors.textTertiary,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          variant: AppCardVariant.outlined,
          isSelected: true,
          onTap: () {},
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.credit_card, color: colors.gold, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Credit Card',
                      variant: AppTextVariant.bodyLarge,
                      color: colors.textPrimary,
                    ),
                    AppText(
                      'Visa ending in 4242',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
              Icon(Icons.check_circle, color: colors.gold),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Feature card
        AppText(
          'Feature Highlight',
          variant: AppTextVariant.labelMedium,
          color: colors.textTertiary,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          variant: AppCardVariant.goldAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: colors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: AppText(
                      'PREMIUM',
                      variant: AppTextVariant.labelSmall,
                      color: colors.gold,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.star, color: colors.gold, size: 16),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                'Unlock Premium Features',
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppText(
                'Get instant transfers, priority support, and cashback rewards',
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Code snippets for documentation

const String basicUsageCode = '''
// Basic elevated card (default)
AppCard(
  child: Text('Card content'),
)

// Flat card with subtle border
AppCard(
  variant: AppCardVariant.flat,
  child: Text('Minimal card'),
)

// Outlined card with visible border
AppCard(
  variant: AppCardVariant.outlined,
  child: Text('Outlined card'),
)
''';

const String selectionCode = '''
// Selectable card (for multi-select UIs)
AppCard(
  variant: AppCardVariant.outlined,
  isSelected: isSelected,
  onTap: () => setState(() => isSelected = !isSelected),
  child: Row(
    children: [
      Icon(
        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isSelected ? colors.gold : colors.textTertiary,
      ),
      SizedBox(width: 12),
      Text('Option'),
    ],
  ),
)
''';

const String customStylingCode = '''
// Custom colors for semantic cards
AppCard(
  variant: AppCardVariant.outlined,
  backgroundColor: colors.successBg,
  borderColor: colors.success,
  child: Row(
    children: [
      Icon(Icons.check_circle, color: colors.success),
      SizedBox(width: 8),
      Text('Success message'),
    ],
  ),
)
''';

const String interactiveCode = '''
// Interactive card with tap handler
AppCard(
  variant: AppCardVariant.elevated,
  onTap: () => Navigator.push(...),
  child: Row(
    children: [
      Icon(Icons.account_circle),
      SizedBox(width: 12),
      Expanded(child: Text('Profile Settings')),
      Icon(Icons.chevron_right),
    ],
  ),
)
''';
