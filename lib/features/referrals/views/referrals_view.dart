import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/referrals/providers/referrals_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class ReferralsView extends ConsumerWidget {
  const ReferralsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final referralAsync = ref.watch(referralProvider);
    final phone = authState.user?.phone ?? '';
    // Use referral code from API if available, else generate locally
    final referralCode = referralAsync.whenOrNull(data: (info) => info.referralCode) ?? _generateReferralCode(phone);
    final totalReferrals = referralAsync.whenOrNull(data: (info) => info.totalReferrals) ?? 0;
    final totalEarned = referralAsync.whenOrNull(data: (info) => info.totalEarned) ?? 0.0;
    final referralHistory = referralAsync.whenOrNull(data: (info) => info.referrals) ?? [];

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              AppText(
                l10n.referrals_title,
                variant: AppTextVariant.headlineMedium,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                l10n.referrals_subtitle,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
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
                        gradient: LinearGradient(
                          colors: context.colors.goldGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Icon(
                        Icons.card_giftcard,
                        size: 40,
                        color: context.colors.textInverse,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppText(
                      l10n.referrals_earnAmount,
                      variant: AppTextVariant.displaySmall,
                      color: colors.gold,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppText(
                      l10n.referrals_earnDescription,
                      variant: AppTextVariant.bodyMedium,
                      color: colors.textSecondary,
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
                    AppText(
                      l10n.referrals_yourCode,
                      variant: AppTextVariant.labelMedium,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: colors.elevated,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: colors.gold.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: AppText(
                                referralCode,
                                variant: AppTextVariant.titleLarge,
                                color: colors.gold,
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
                              color: colors.gold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              Icons.copy,
                              color: colors.gold,
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
                      label: l10n.referrals_shareLink,
                      onPressed: () => _shareLink(context, referralCode, l10n),
                      variant: AppButtonVariant.primary,
                      icon: Icons.share,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: l10n.referrals_invite,
                      onPressed: () => _inviteContacts(context, l10n),
                      variant: AppButtonVariant.secondary,
                      icon: Icons.people,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Stats
              AppText(
                l10n.referrals_yourRewards,
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      colors: colors,
                      icon: Icons.people_outline,
                      value: '$totalReferrals',
                      label: l10n.referrals_friendsInvited,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      colors: colors,
                      icon: Icons.attach_money,
                      value: '\$${totalEarned.toStringAsFixed(2)}',
                      label: l10n.referrals_totalEarned,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // How it works
              AppText(
                l10n.referrals_howItWorks,
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.lg),

              _HowItWorksStep(
                colors: colors,
                number: '1',
                title: l10n.referrals_step1Title,
                description: l10n.referrals_step1Description,
              ),
              _HowItWorksStep(
                colors: colors,
                number: '2',
                title: l10n.referrals_step2Title,
                description: l10n.referrals_step2Description,
              ),
              _HowItWorksStep(
                colors: colors,
                number: '3',
                title: l10n.referrals_step3Title,
                description: l10n.referrals_step3Description,
              ),
              _HowItWorksStep(
                colors: colors,
                number: '4',
                title: l10n.referrals_step4Title,
                description: l10n.referrals_step4Description,
                isLast: true,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Referral History
              AppText(
                l10n.referrals_history,
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.md),

              if (referralHistory.isEmpty)
                AppCard(
                  variant: AppCardVariant.subtle,
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: colors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppText(
                          l10n.referrals_noReferrals,
                          variant: AppTextVariant.bodyMedium,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppText(
                          l10n.referrals_startInviting,
                          variant: AppTextVariant.bodySmall,
                          color: colors.textTertiary,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...referralHistory.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    variant: AppCardVariant.subtle,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: colors.gold.withValues(alpha: 0.2),
                          child: AppText(
                            entry.referredName.isNotEmpty ? entry.referredName[0].toUpperCase() : '?',
                            variant: AppTextVariant.bodyLarge,
                            color: colors.gold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                entry.referredName,
                                variant: AppTextVariant.bodyMedium,
                                color: colors.textPrimary,
                              ),
                              AppText(
                                entry.status,
                                variant: AppTextVariant.bodySmall,
                                color: colors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                        if (entry.reward != null)
                          AppText(
                            '+\$${entry.reward!.toStringAsFixed(2)}',
                            variant: AppTextVariant.bodyMedium,
                            color: colors.success,
                          ),
                      ],
                    ),
                  ),
                )),

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
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.referrals_codeCopied),
        backgroundColor: colors.success,
      ),
    );
  }

  void _shareLink(BuildContext context, String code, AppLocalizations l10n) {
    SharePlus.instance.share(ShareParams(text: 
      l10n.referrals_shareMessage(code), title: l10n.referrals_shareSubject,
    ));
  }

  void _inviteContacts(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.container,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: colors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.referrals_invite,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.message, color: Color(0xFF25D366)),
              title: const AppText('WhatsApp'),
              onTap: () {
                Navigator.pop(ctx);
                final msg = Uri.encodeComponent(l10n.referrals_shareMessage('KORIDO'));
                launchUrl(Uri.parse('https://wa.me/?text=$msg'), mode: LaunchMode.externalApplication);
              },
            ),
            ListTile(
              leading: Icon(Icons.sms, color: colors.gold),
              title: const AppText('SMS'),
              onTap: () {
                Navigator.pop(ctx);
                final msg = Uri.encodeComponent(l10n.referrals_shareMessage('KORIDO'));
                launchUrl(Uri.parse('sms:?body=$msg'), mode: LaunchMode.externalApplication);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: colors.textSecondary),
              title: AppText(l10n.referrals_shareLink),
              onTap: () {
                Navigator.pop(ctx);
                SharePlus.instance.share(ShareParams(text: 
                  l10n.referrals_shareMessage('KORIDO'), title: l10n.referrals_shareSubject,
                ));
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.colors,
    required this.icon,
    required this.value,
    required this.label,
  });

  final ThemeColors colors;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        children: [
          Icon(icon, color: colors.gold, size: 28),
          const SizedBox(height: AppSpacing.md),
          AppText(
            value,
            variant: AppTextVariant.titleLarge,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            label,
            variant: AppTextVariant.bodySmall,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  const _HowItWorksStep({
    required this.colors,
    required this.number,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  final ThemeColors colors;
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
                gradient: LinearGradient(
                  colors: context.colors.goldGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Center(
                child: AppText(
                  number,
                  variant: AppTextVariant.labelLarge,
                  color: context.colors.textInverse,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: colors.gold.withValues(alpha: 0.3),
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
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  description,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
