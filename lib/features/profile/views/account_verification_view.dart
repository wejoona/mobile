import 'package:usdc_wallet/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Run 342: Account verification status view
class AccountVerificationView extends ConsumerWidget {
  const AccountVerificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileState = ref.watch(profileProvider);
    final user = profileState.user;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.verification_accountVerification,
          style: AppTextStyle.headingSmall,
        ),
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _VerificationStep(
            step: 1,
            title: l10n.verification_phoneNumber,
            subtitle: l10n.verification_verified,
            isComplete: true,
            icon: Icons.phone_android,
          ),
          _VerificationStep(
            step: 2,
            title: l10n.verification_personalInfo,
            subtitle: user?.firstName != null ? l10n.verification_complete : l10n.verification_toComplete,
            isComplete: user?.firstName != null,
            icon: Icons.person_outline,
          ),
          _VerificationStep(
            step: 3,
            title: l10n.verification_identityDocument,
            subtitle: l10n.verification_verifyIdentity,
            isComplete: false,
            icon: Icons.badge_outlined,
          ),
          _VerificationStep(
            step: 4,
            title: l10n.verification_selfie,
            subtitle: l10n.verification_confirmIdentity,
            isComplete: false,
            icon: Icons.camera_alt_outlined,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Semantics(
            label: l10n.verification_continue,
            child: AppButton(
              label: l10n.verification_continue,
              variant: AppButtonVariant.primary,
              onPressed: () {
                Navigator.of(context).pushNamed('/kyc/start');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationStep extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final bool isComplete;
  final IconData icon;

  const _VerificationStep({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.isComplete,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        label: '${l10n.verification_step(step)}: $title - $subtitle',
        child: AppCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isComplete
                        ? context.colors.success.withValues(alpha: 0.15)
                        : context.colors.elevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isComplete ? Icons.check : icon,
                    color: isComplete ? context.colors.success : context.colors.gold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(title, style: AppTextStyle.labelLarge),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        subtitle,
                        style: AppTextStyle.bodySmall,
                        color: isComplete
                            ? context.colors.success
                            : context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
