import 'package:usdc_wallet/design/components/primitives/list_tile_card.dart';
import 'package:usdc_wallet/design/components/primitives/gradient_card.dart';
import 'package:usdc_wallet/design/components/primitives/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Run 341: Profile security overview - shows security status and actions
class ProfileSecurityView extends ConsumerWidget {
  const ProfileSecurityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: const AppText(
          'Securite du compte',
          style: AppTextStyle.headingSmall,
        ),
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SecurityScoreCard(),
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(title: 'Authentification'),
          const SizedBox(height: AppSpacing.sm),
          _SecurityOption(
            icon: Icons.pin_outlined,
            title: 'Code PIN',
            subtitle: 'Modifier votre code PIN',
            status: _SecurityStatus.active,
            onTap: () => Navigator.of(context).pushNamed('/pin/change'),
          ),
          _SecurityOption(
            icon: Icons.fingerprint,
            title: 'Biometrie',
            subtitle: 'Empreinte digitale ou Face ID',
            status: _SecurityStatus.active,
            onTap: () =>
                Navigator.of(context).pushNamed('/settings/biometric'),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(title: 'Appareils'),
          const SizedBox(height: AppSpacing.sm),
          _SecurityOption(
            icon: Icons.devices,
            title: 'Appareils connectes',
            subtitle: 'Gerer vos appareils',
            status: _SecurityStatus.info,
            onTap: () => Navigator.of(context).pushNamed('/settings/devices'),
          ),
          _SecurityOption(
            icon: Icons.history,
            title: 'Sessions actives',
            subtitle: 'Voir les sessions en cours',
            status: _SecurityStatus.info,
            onTap: () => Navigator.of(context).pushNamed('/settings/sessions'),
          ),
        ],
      ),
    );
  }
}

enum _SecurityStatus { active, inactive, info }

class _SecurityScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Score de securite: Eleve',
      child: GradientCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Icon(Icons.shield, color: context.colors.gold, size: 48),
              const SizedBox(height: AppSpacing.md),
              AppText(
                'Securite Elevee',
                style: AppTextStyle.headingSmall,
                color: context.colors.gold,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppText(
                'Votre compte est bien protege',
                style: AppTextStyle.bodySmall,
                color: context.colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final _SecurityStatus status;
  final VoidCallback onTap;

  const _SecurityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case _SecurityStatus.active:
        return AppColors.successBase;
      case _SecurityStatus.inactive:
        return AppColors.errorBase;
      case _SecurityStatus.info:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title: $subtitle',
      child: ListTileCard(
        leading: Icon(icon, color: context.colors.gold),
        title: title,
        subtitle: subtitle,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == _SecurityStatus.active)
              Icon(Icons.check_circle, color: _statusColor, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right, color: context.colors.textTertiary),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
