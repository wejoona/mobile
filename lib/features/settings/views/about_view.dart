import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../utils/app_info.dart';

/// Run 377: About screen with app version, legal links, and credits
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const AppText('A propos', style: AppTextStyle.headingSmall),
        backgroundColor: AppColors.backgroundSecondary,
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
                    color: AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.gold,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppText('Korido', style: AppTextStyle.headingMedium),
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  'Votre portefeuille USDC',
                  style: AppTextStyle.bodyMedium,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                FutureBuilder<String>(
                  future: AppInfo.getVersion(),
                  builder: (context, snapshot) {
                    return AppText(
                      'Version ${snapshot.data ?? "..."}',
                      style: AppTextStyle.bodySmall,
                      color: AppColors.textTertiary,
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
              color: AppColors.textTertiary,
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
        leading: Icon(icon, color: AppColors.textSecondary, size: 20),
        title: title,
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textTertiary,
        ),
        onTap: onTap,
      ),
    );
  }
}
