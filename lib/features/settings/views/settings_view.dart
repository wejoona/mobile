import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../domain/enums/index.dart';
import '../../../services/biometric/biometric_service.dart';
import '../../../state/index.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Settings',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            AppCard(
              variant: AppCardVariant.elevated,
              onTap: () => context.push('/settings/profile'),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.goldGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.textInverse,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Profile',
                          variant: AppTextVariant.titleMedium,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        AppText(
                          'Manage your personal information',
                          variant: AppTextVariant.bodySmall,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Security Section
            const AppText(
              'Security',
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            _SettingsTile(
              icon: Icons.security,
              title: 'Security Settings',
              subtitle: 'PIN, 2FA, biometrics',
              onTap: () => context.push('/settings/security'),
            ),
            _KycTile(onTap: () => context.push('/settings/kyc')),
            _SettingsTile(
              icon: Icons.speed,
              title: 'Transaction Limits',
              subtitle: 'View & increase limits',
              onTap: () => context.push('/settings/limits'),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Preferences Section
            const AppText(
              'Preferences',
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => context.push('/settings/notifications'),
            ),
            _SettingsTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.attach_money,
              title: 'Default Currency',
              subtitle: 'USD',
              onTap: () {},
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Support Section
            const AppText(
              'Support',
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            _SettingsTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'FAQs, chat, contact',
              onTap: () => context.push('/settings/help'),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Referral
            AppCard(
              variant: AppCardVariant.goldAccent,
              onTap: () => context.push('/referrals'),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.gold500.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: AppColors.gold500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Refer & Earn',
                          variant: AppTextVariant.titleSmall,
                          color: AppColors.gold500,
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        AppText(
                          'Invite friends and earn rewards',
                          variant: AppTextVariant.bodySmall,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.gold500,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Logout Button
            AppButton(
              label: 'Log Out',
              onPressed: () => _showLogoutDialog(context, ref),
              variant: AppButtonVariant.secondary,
              isFullWidth: true,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Version
            const Center(
              child: AppText(
                'Version 1.0.0',
                variant: AppTextVariant.labelSmall,
                color: AppColors.textTertiary,
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: const AppText(
          'Log Out',
          variant: AppTextVariant.titleMedium,
        ),
        content: const AppText(
          'Are you sure you want to log out?',
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText(
              'Cancel',
              variant: AppTextVariant.labelLarge,
              color: AppColors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const AppText(
              'Log Out',
              variant: AppTextVariant.labelLarge,
              color: AppColors.errorText,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppText(
                  title,
                  variant: AppTextVariant.bodyLarge,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null)
                AppText(
                  subtitle!,
                  variant: AppTextVariant.bodyMedium,
                  color: subtitleColor ?? AppColors.textTertiary,
                ),
              if (trailing != null) trailing!,
              if (trailing == null && subtitle == null)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KycTile extends ConsumerWidget {
  const _KycTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kycStatus = ref.watch(kycStatusProvider);

    String subtitle;
    Color subtitleColor;
    IconData icon;

    switch (kycStatus) {
      case KycStatus.verified:
        subtitle = 'Verified';
        subtitleColor = AppColors.successText;
        icon = Icons.verified_user;
      case KycStatus.pending:
        subtitle = 'Pending Review';
        subtitleColor = AppColors.warningBase;
        icon = Icons.hourglass_top;
      case KycStatus.rejected:
        subtitle = 'Rejected - Retry';
        subtitleColor = AppColors.errorText;
        icon = Icons.error_outline;
      case KycStatus.none:
        subtitle = 'Not Started';
        subtitleColor = AppColors.textTertiary;
        icon = Icons.verified_user_outlined;
    }

    return _SettingsTile(
      icon: icon,
      title: 'KYC Verification',
      subtitle: subtitle,
      subtitleColor: subtitleColor,
      onTap: onTap,
    );
  }
}

class _BiometricTile extends ConsumerWidget {
  const _BiometricTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricType = ref.watch(primaryBiometricTypeProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);

    return biometricType.when(
      data: (type) {
        if (type == BiometricType.none) {
          return const SizedBox.shrink();
        }

        return biometricEnabled.when(
          data: (enabled) => _SettingsTile(
            icon: type == BiometricType.faceId ? Icons.face : Icons.fingerprint,
            title: type == BiometricType.faceId ? 'Face ID' : 'Touch ID',
            trailing: Switch(
              value: enabled,
              onChanged: (value) async {
                final service = ref.read(biometricServiceProvider);
                if (value) {
                  final authenticated = await service.authenticate(
                    reason: 'Authenticate to enable biometric login',
                  );
                  if (authenticated) {
                    await service.enableBiometric();
                    ref.invalidate(biometricEnabledProvider);
                  }
                } else {
                  await service.disableBiometric();
                  ref.invalidate(biometricEnabledProvider);
                }
              },
              activeColor: AppColors.gold500,
            ),
            onTap: () {},
          ),
          loading: () => _SettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            trailing: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            onTap: () {},
          ),
          error: (_, __) => _SettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Error',
            onTap: () {},
          ),
        );
      },
      loading: () => _SettingsTile(
        icon: Icons.fingerprint,
        title: 'Biometric Login',
        trailing: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        onTap: () {},
      ),
      error: (_, __) => _SettingsTile(
        icon: Icons.fingerprint,
        title: 'Biometric Login',
        subtitle: 'Error',
        onTap: () {},
      ),
    );
  }
}
