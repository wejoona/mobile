import 'package:flutter/material.dart';
import 'package:usdc_wallet/catalog/widget_catalog_view.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

class ToggleCatalog extends StatefulWidget {
  const ToggleCatalog({super.key});

  @override
  State<ToggleCatalog> createState() => _ToggleCatalogState();
}

class _ToggleCatalogState extends State<ToggleCatalog> {
  bool _basicToggle = false;
  bool _notificationsToggle = true;
  bool _biometricToggle = false;
  bool _darkModeToggle = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogSection(
          title: 'Basic Toggle',
          description: 'Simple on/off switch',
          children: [
            DemoCard(
              label: 'Default Toggle',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Toggle Switch',
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textPrimary,
                  ),
                  AppToggle(
                    value: _basicToggle,
                    onChanged: (value) {
                      setState(() => _basicToggle = value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Interactive Examples',
          description: 'Real-world toggle use cases',
          children: [
            DemoCard(
              label: 'Settings List',
              child: Column(
                children: [
                  _buildSettingRow(
                    icon: Icons.notifications,
                    title: 'Push Notifications',
                    subtitle: 'Receive alerts for transactions',
                    value: _notificationsToggle,
                    onChanged: (value) {
                      setState(() => _notificationsToggle = value);
                    },
                    colors: colors,
                  ),
                  const Divider(height: AppSpacing.lg),
                  _buildSettingRow(
                    icon: Icons.fingerprint,
                    title: 'Biometric Login',
                    subtitle: 'Use fingerprint or face ID',
                    value: _biometricToggle,
                    onChanged: (value) {
                      setState(() => _biometricToggle = value);
                    },
                    colors: colors,
                  ),
                  const Divider(height: AppSpacing.lg),
                  _buildSettingRow(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: 'Use dark theme',
                    value: _darkModeToggle,
                    onChanged: (value) {
                      setState(() => _darkModeToggle = value);
                    },
                    colors: colors,
                  ),
                ],
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'States',
          description: 'Enabled and disabled states',
          children: [
            DemoCard(
              label: 'Enabled States',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText('Off', color: colors.textPrimary),
                      AppToggle(
                        value: false,
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText('On', color: colors.textPrimary),
                      AppToggle(
                        value: true,
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DemoCard(
              label: 'Disabled States',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText('Disabled Off', color: colors.textDisabled),
                      AppToggle(
                        value: false,
                        onChanged: null,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText('Disabled On', color: colors.textDisabled),
                      AppToggle(
                        value: true,
                        onChanged: null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeColors colors,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: colors.gold, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                variant: AppTextVariant.bodyMedium,
                color: colors.textPrimary,
              ),
              AppText(
                subtitle,
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
        AppToggle(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
