import 'package:flutter/material.dart';

import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// AppButton Demo - Showcases all button variants in light and dark themes
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => const AppButtonDemo()),
/// );
/// ```
class AppButtonDemo extends StatelessWidget {
  const AppButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: const Text('AppButton Theme Demo'),
        actions: [
          IconButton(
            icon: Icon(colors.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              // Toggle theme
              // Note: Implement theme toggle in your app's state management
            },
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          // Primary Buttons
          _buildSection(
            'Primary Buttons',
            'Gold gradient (dark) or solid gold (light)',
            [
              AppButton(
                label: 'Primary Button',
                onPressed: () {},
              ),
              AppButton(
                label: 'With Icon',
                icon: Icons.send,
                onPressed: () {},
              ),
              AppButton(
                label: 'Loading',
                isLoading: true,
                onPressed: () {},
              ),
              const AppButton(
                label: 'Disabled',
                onPressed: null,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Secondary Buttons
          _buildSection(
            'Secondary Buttons',
            'Outlined style with theme-aware borders',
            [
              AppButton(
                label: 'Secondary Button',
                variant: AppButtonVariant.secondary,
                onPressed: () {},
              ),
              AppButton(
                label: 'With Icon',
                variant: AppButtonVariant.secondary,
                icon: Icons.edit,
                onPressed: () {},
              ),
              const AppButton(
                label: 'Disabled',
                variant: AppButtonVariant.secondary,
                onPressed: null,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Tertiary Buttons
          _buildSection(
            'Tertiary Buttons',
            'Minimal background with gold text',
            [
              AppButton(
                label: 'Tertiary Button',
                variant: AppButtonVariant.tertiary,
                onPressed: () {},
              ),
              AppButton(
                label: 'With Icon',
                variant: AppButtonVariant.tertiary,
                icon: Icons.settings,
                onPressed: () {},
              ),
              const AppButton(
                label: 'Disabled',
                variant: AppButtonVariant.tertiary,
                onPressed: null,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Ghost Buttons
          _buildSection(
            'Ghost Buttons',
            'Text only, minimal styling',
            [
              AppButton(
                label: 'Ghost Button',
                variant: AppButtonVariant.ghost,
                onPressed: () {},
              ),
              AppButton(
                label: 'With Icon',
                variant: AppButtonVariant.ghost,
                icon: Icons.arrow_forward,
                iconPosition: IconPosition.right,
                onPressed: () {},
              ),
              const AppButton(
                label: 'Disabled',
                variant: AppButtonVariant.ghost,
                onPressed: null,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Success Buttons
          _buildSection(
            'Success Buttons',
            'Green semantic color',
            [
              AppButton(
                label: 'Success Button',
                variant: AppButtonVariant.success,
                onPressed: () {},
              ),
              AppButton(
                label: 'Complete',
                variant: AppButtonVariant.success,
                icon: Icons.check_circle,
                onPressed: () {},
              ),
              const AppButton(
                label: 'Disabled',
                variant: AppButtonVariant.success,
                onPressed: null,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Danger Buttons
          _buildSection(
            'Danger Buttons',
            'Red semantic color for destructive actions',
            [
              AppButton(
                label: 'Danger Button',
                variant: AppButtonVariant.danger,
                onPressed: () {},
              ),
              AppButton(
                label: 'Delete',
                variant: AppButtonVariant.danger,
                icon: Icons.delete,
                onPressed: () {},
              ),
              const AppButton(
                label: 'Disabled',
                variant: AppButtonVariant.danger,
                onPressed: null,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Sizes
          _buildSection(
            'Button Sizes',
            'Small, medium, and large sizes',
            [
              AppButton(
                label: 'Small',
                size: AppButtonSize.small,
                onPressed: () {},
              ),
              AppButton(
                label: 'Medium (Default)',
                size: AppButtonSize.medium,
                onPressed: () {},
              ),
              AppButton(
                label: 'Large',
                size: AppButtonSize.large,
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Full Width
          _buildSection(
            'Full Width',
            'Buttons that expand to container width',
            [
              AppButton(
                label: 'Full Width Primary',
                isFullWidth: true,
                onPressed: () {},
              ),
              AppButton(
                label: 'Full Width Secondary',
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String description, List<Widget> buttons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        ...buttons.map((button) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: button,
            )),
      ],
    );
  }
}
