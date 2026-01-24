import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../auth/providers/auth_provider.dart';

class ReferralsView extends ConsumerWidget {
  const ReferralsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final phone = authState.user?.phone ?? '';
    // Generate a simple referral code from phone
    final referralCode = _generateReferralCode(phone);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const AppText(
                'Refer & Earn',
                variant: AppTextVariant.headlineMedium,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.sm),
              const AppText(
                'Invite friends and earn rewards together',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.textSecondary,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Rewards Card
              AppCard(
                variant: AppCardVariant.goldAccent,
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.goldGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        size: 40,
                        color: AppColors.textInverse,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const AppText(
                      'Earn \$5',
                      variant: AppTextVariant.displaySmall,
                      color: AppColors.gold500,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const AppText(
                      'for each friend who signs up and makes their first deposit',
                      variant: AppTextVariant.bodyMedium,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Referral Code Card
              AppCard(
                variant: AppCardVariant.elevated,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      'Your Referral Code',
                      variant: AppTextVariant.labelMedium,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.elevated,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: AppColors.gold500.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: AppText(
                                referralCode,
                                variant: AppTextVariant.titleLarge,
                                color: AppColors.gold500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        IconButton(
                          onPressed: () => _copyCode(context, referralCode),
                          icon: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.gold500.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              Icons.copy,
                              color: AppColors.gold500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Share Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Share Link',
                      onPressed: () => _shareLink(referralCode),
                      variant: AppButtonVariant.primary,
                      icon: Icons.share,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Invite',
                      onPressed: () => _inviteContacts(context),
                      variant: AppButtonVariant.secondary,
                      icon: Icons.people,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Stats
              const AppText(
                'Your Rewards',
                variant: AppTextVariant.titleMedium,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.people_outline,
                      value: '0',
                      label: 'Friends Invited',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.attach_money,
                      value: '\$0.00',
                      label: 'Total Earned',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // How it works
              const AppText(
                'How it works',
                variant: AppTextVariant.titleMedium,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.lg),

              _HowItWorksStep(
                number: '1',
                title: 'Share your code',
                description: 'Send your referral code or link to friends',
              ),
              _HowItWorksStep(
                number: '2',
                title: 'Friend signs up',
                description: 'They create an account using your code',
              ),
              _HowItWorksStep(
                number: '3',
                title: 'First deposit',
                description: 'They make their first deposit of \$10 or more',
              ),
              _HowItWorksStep(
                number: '4',
                title: 'You both earn!',
                description: 'You get \$5, and your friend gets \$5 too',
                isLast: true,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Referral History
              const AppText(
                'Referral History',
                variant: AppTextVariant.titleMedium,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.md),

              AppCard(
                variant: AppCardVariant.subtle,
                child: const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppText(
                        'No referrals yet',
                        variant: AppTextVariant.bodyMedium,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      AppText(
                        'Start inviting friends to see your rewards here',
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.textTertiary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  String _generateReferralCode(String phone) {
    // Generate a simple referral code from phone
    if (phone.isEmpty) return 'JOONA000';
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length < 4) return 'JOONA000';
    return 'JOONA${cleaned.substring(cleaned.length - 4)}';
  }

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral code copied!'),
        backgroundColor: AppColors.successBase,
      ),
    );
  }

  void _shareLink(String code) {
    Share.share(
      'Join JoonaPay and get \$5 bonus on your first deposit! Use my referral code: $code\n\nDownload now: https://joonapay.com/download',
      subject: 'Join JoonaPay - Get \$5 bonus!',
    );
  }

  void _inviteContacts(BuildContext context) {
    // TODO: Open contacts picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact invite coming soon'),
        backgroundColor: AppColors.gold500,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        children: [
          Icon(icon, color: AppColors.gold500, size: 28),
          const SizedBox(height: AppSpacing.md),
          AppText(
            value,
            variant: AppTextVariant.titleLarge,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            label,
            variant: AppTextVariant.bodySmall,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  const _HowItWorksStep({
    required this.number,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  final String number;
  final String title;
  final String description;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.goldGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Center(
                child: AppText(
                  number,
                  variant: AppTextVariant.labelLarge,
                  color: AppColors.textInverse,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: AppColors.gold500.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.titleSmall,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  description,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
