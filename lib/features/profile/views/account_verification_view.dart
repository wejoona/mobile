import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/profile_provider.dart';

/// Run 342: Account verification status view
class AccountVerificationView extends ConsumerWidget {
  const AccountVerificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);
    final user = profileState.user;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const AppText(
          'Verification du compte',
          style: AppTextStyle.headingSmall,
        ),
        backgroundColor: AppColors.backgroundSecondary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _VerificationStep(
            step: 1,
            title: 'Numero de telephone',
            subtitle: 'Verifie',
            isComplete: true,
            icon: Icons.phone_android,
          ),
          _VerificationStep(
            step: 2,
            title: 'Information personnelle',
            subtitle: user?.firstName != null ? 'Complete' : 'A remplir',
            isComplete: user?.firstName != null,
            icon: Icons.person_outline,
          ),
          _VerificationStep(
            step: 3,
            title: 'Document d\'identite',
            subtitle: 'Verifier votre identite',
            isComplete: false,
            icon: Icons.badge_outlined,
          ),
          _VerificationStep(
            step: 4,
            title: 'Selfie de verification',
            subtitle: 'Confirmez votre identite',
            isComplete: false,
            icon: Icons.camera_alt_outlined,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Semantics(
            label: 'Continuer la verification',
            child: AppButton(
              label: 'Continuer la verification',
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        label: 'Etape $step: $title - $subtitle',
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
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.elevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isComplete ? Icons.check : icon,
                    color: isComplete ? AppColors.success : AppColors.gold,
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
                            ? AppColors.success
                            : AppColors.textSecondary,
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
