import 'package:flutter/material.dart';
import 'package:usdc_wallet/catalog/widget_catalog_view.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

class ButtonCatalog extends StatefulWidget {
  const ButtonCatalog({super.key});

  @override
  State<ButtonCatalog> createState() => _ButtonCatalogState();
}

class _ButtonCatalogState extends State<ButtonCatalog> {
  bool _isLoading = false;
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogSection(
          title: 'Variants',
          description: 'Different button styles for various contexts',
          children: [
            DemoCard(
              label: 'Primary - Main CTAs',
              child: AppButton(
                label: 'Primary Button',
                onPressed: _handleTap,
              ),
            ),
            DemoCard(
              label: 'Secondary - Alternative actions',
              child: AppButton(
                label: 'Secondary Button',
                variant: AppButtonVariant.secondary,
                onPressed: _handleTap,
              ),
            ),
            DemoCard(
              label: 'Ghost - Tertiary actions',
              child: AppButton(
                label: 'Ghost Button',
                variant: AppButtonVariant.ghost,
                onPressed: _handleTap,
              ),
            ),
            DemoCard(
              label: 'Success - Confirmation actions',
              child: AppButton(
                label: 'Success Button',
                variant: AppButtonVariant.success,
                onPressed: _handleTap,
              ),
            ),
            DemoCard(
              label: 'Danger - Destructive actions',
              child: AppButton(
                label: 'Danger Button',
                variant: AppButtonVariant.danger,
                onPressed: _handleTap,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Sizes',
          description: 'Three size options for different contexts',
          children: [
            DemoCard(
              label: 'Small',
              child: AppButton(
                label: 'Small Button',
                size: AppButtonSize.small,
                onPressed: _handleTap,
              ),
            ),
            DemoCard(
              label: 'Medium (default)',
              child: AppButton(
                label: 'Medium Button',
                size: AppButtonSize.medium,
                onPressed: _handleTap,
              ),
            ),
            DemoCard(
              label: 'Large',
              child: AppButton(
                label: 'Large Button',
                size: AppButtonSize.large,
                onPressed: _handleTap,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'States',
          description: 'Loading, disabled, and interactive states',
          children: [
            DemoCard(
              label: 'Loading State',
              child: Column(
                children: [
                  AppButton(
                    label: 'Toggle Loading',
                    onPressed: () {
                      setState(() => _isLoading = !_isLoading);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Loading Button',
                    isLoading: _isLoading,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            DemoCard(
              label: 'Disabled State',
              child: AppButton(
                label: 'Disabled Button',
                onPressed: null,
              ),
            ),
            DemoCard(
              label: 'Interactive Counter (tap count: $_tapCount)',
              child: AppButton(
                label: 'Tap Me',
                onPressed: _handleTap,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'With Icons',
          description: 'Buttons with leading or trailing icons',
          children: [
            DemoCard(
              label: 'Icon Left',
              child: AppButton(
                label: 'Send Money',
                icon: Icons.send,
                iconPosition: IconPosition.left,
                onPressed: _handleTap,
              ),
            ),
            DemoCard(
              label: 'Icon Right',
              child: AppButton(
                label: 'Continue',
                icon: Icons.arrow_forward,
                iconPosition: IconPosition.right,
                onPressed: _handleTap,
              ),
            ),
            DemoCard(
              label: 'Secondary with Icon',
              child: AppButton(
                label: 'Download',
                icon: Icons.download,
                variant: AppButtonVariant.secondary,
                onPressed: _handleTap,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Full Width',
          description: 'Buttons that expand to container width',
          children: [
            DemoCard(
              label: 'Full Width Primary',
              child: AppButton(
                label: 'Continue',
                isFullWidth: true,
                onPressed: _handleTap,
              ),
            ),
            DemoCard(
              label: 'Full Width Secondary',
              child: AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
                onPressed: _handleTap,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Haptics',
          description: 'Different haptic feedback per variant',
          children: [
            DemoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Haptic Feedback Levels:',
                    variant: AppTextVariant.labelMedium,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Primary - Medium Tap',
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'Secondary - Light Tap',
                    variant: AppButtonVariant.secondary,
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'Danger - Heavy Tap',
                    variant: AppButtonVariant.danger,
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'No Haptics',
                    enableHaptics: false,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleTap() {
    setState(() {
      _tapCount++;
    });
  }
}
