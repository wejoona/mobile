import 'package:usdc_wallet/design/components/primitives/list_tile_card.dart';
import 'package:usdc_wallet/design/components/primitives/app_divider.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/utils/app_info.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';

/// Run 377: About screen with app version, legal links, and credits
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: const AppText('A propos', style: AppTextStyle.headingSmall),
        backgroundColor: context.colors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          // Logo and app name
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.colors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: context.colors.gold,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppText(AppStrings.appName, style: AppTextStyle.headingMedium),
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  'Votre portefeuille USDC',
                  style: AppTextStyle.bodyMedium,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                FutureBuilder<String>(
                  future: AppInfo.getVersion(),
                  builder: (context, snapshot) {
                    return AppText(
                      'Version ${snapshot.data ?? "..."}',
                      style: AppTextStyle.bodySmall,
                      color: context.colors.textTertiary,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          const AppDivider(),
          _AboutLink(
            title: 'Conditions d\'utilisation',
            icon: Icons.description_outlined,
            onTap: () => Navigator.of(context).pushNamed('/settings/terms'),
          ),
          _AboutLink(
            title: 'Politique de confidentialite',
            icon: Icons.privacy_tip_outlined,
            onTap: () => Navigator.of(context).pushNamed('/settings/privacy'),
          ),
          _AboutLink(
            title: 'Politique de cookies',
            icon: Icons.cookie_outlined,
            onTap: () => Navigator.of(context).pushNamed('/settings/cookies'),
          ),
          _AboutLink(
            title: 'Licences open source',
            icon: Icons.code,
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Korido',
            ),
          ),
          const AppDivider(),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: AppText(
              '2024 Korido. Tous droits reserves.',
              style: AppTextStyle.bodySmall,
              color: context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutLink extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _AboutLink({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: ListTileCard(
        leading: Icon(icon, color: context.colors.textSecondary, size: 20),
        title: title,
        trailing: Icon(
          Icons.chevron_right,
          color: context.colors.textTertiary,
        ),
        onTap: onTap,
      ),
    );
  }
}
