import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Help & Support Screen
/// FAQ, contact options, and problem reporting
class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final Map<int, bool> _expandedFaqs = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.settings_helpSupport,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.safePop(fallbackRoute: '/settings'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // Quick Actions
          _buildQuickActions(colors),

          const SizedBox(height: AppSpacing.xxl),

          // FAQ Section
          AppText(
            'Frequently Asked Questions',
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),

          ..._buildFaqList(colors),

          const SizedBox(height: AppSpacing.xxxl),

          // Contact Section
          AppText(
            'Need More Help?',
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),

          _buildContactCard(
            colors: colors,
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@joonapay.com',
            onTap: () => _copyToClipboard('support@joonapay.com'),
          ),

          const SizedBox(height: AppSpacing.md),

          _buildContactCard(
            colors: colors,
            icon: Icons.chat_bubble_outline,
            title: 'WhatsApp Support',
            subtitle: '+225 XX XX XX XX',
            onTap: () => _openWhatsApp(),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeColors colors) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            colors: colors,
            icon: Icons.bug_report_outlined,
            label: 'Report Problem',
            onTap: () => _showReportDialog(),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildQuickActionCard(
            colors: colors,
            icon: Icons.chat_outlined,
            label: 'Live Chat',
            onTap: () => _openLiveChat(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required ThemeColors colors,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return AppCard(
      variant: AppCardVariant.elevated,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(
              icon,
              color: colors.gold,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppText(
            label,
            variant: AppTextVariant.labelLarge,
            color: colors.textPrimary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFaqList(ThemeColors colors) {
    final faqs = _getFaqs();
    return faqs.asMap().entries.map((entry) {
      final index = entry.key;
      final faq = entry.value;
      final isExpanded = _expandedFaqs[index] ?? false;

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: AppCard(
          variant: AppCardVariant.elevated,
          padding: EdgeInsets.zero,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              title: AppText(
                faq.question,
                variant: AppTextVariant.bodyLarge,
                color: colors.textPrimary,
              ),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: colors.gold,
              ),
              onExpansionChanged: (expanded) {
                setState(() {
                  _expandedFaqs[index] = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.cardPadding,
                    0,
                    AppSpacing.cardPadding,
                    AppSpacing.cardPadding,
                  ),
                  child: AppText(
                    faq.answer,
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildContactCard({
    required ThemeColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AppCard(
      variant: AppCardVariant.elevated,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: colors.gold,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
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
                  subtitle,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: colors.textTertiary,
          ),
        ],
      ),
    );
  }

  List<_FaqItem> _getFaqs() {
    return [
      _FaqItem(
        question: 'How do I deposit money into my wallet?',
        answer:
            'You can deposit funds using mobile money (Orange Money, MTN MoMo, Wave) or by receiving from another Korido user. Go to Home > Deposit and select your preferred method.',
      ),
      _FaqItem(
        question: 'How long do transactions take?',
        answer:
            'P2P transfers between Korido users are instant. Mobile money deposits typically take 1-5 minutes. Withdrawals to mobile money take 5-15 minutes during business hours.',
      ),
      _FaqItem(
        question: 'What are the transaction limits?',
        answer:
            'Limits depend on your KYC verification level. Unverified accounts have lower limits. Complete KYC verification in Settings > KYC Verification to increase your limits.',
      ),
      _FaqItem(
        question: 'How do I verify my account (KYC)?',
        answer:
            'Go to Settings > KYC Verification. You\'ll need to provide a government-issued ID and take a selfie. Verification typically takes 24-48 hours.',
      ),
      _FaqItem(
        question: 'What fees does Korido charge?',
        answer:
            'P2P transfers are free. Mobile money deposits incur operator fees (1-2%). Withdrawals have a small fixed fee. Check the confirmation screen before completing any transaction.',
      ),
      _FaqItem(
        question: 'I forgot my PIN. What should I do?',
        answer:
            'On the login screen, tap "Forgot PIN?" and follow the recovery process. You\'ll need access to your registered phone number to receive an OTP.',
      ),
      _FaqItem(
        question: 'Is my money safe?',
        answer:
            'Yes. Korido uses USDC stablecoin, which is backed 1:1 by US dollars. Your wallet is secured with PIN, biometrics, and device verification. We never store your PIN in plain text.',
      ),
      _FaqItem(
        question: 'Can I use Korido outside West Africa?',
        answer:
            'Korido is currently optimized for Côte d\'Ivoire, Senegal, and Mali. USDC transfers work globally, but mobile money integrations are region-specific.',
      ),
    ];
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText('Copied to clipboard'),
        backgroundColor: context.colors.success,
      ),
    );
  }

  void _openWhatsApp() {
    // In production, use url_launcher to open whatsapp://
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText('Opening WhatsApp...'),
        backgroundColor: context.colors.info,
      ),
    );
  }

  void _openLiveChat() {
    // In production, integrate with support chat service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText('Opening live chat...'),
        backgroundColor: context.colors.info,
      ),
    );
  }

  void _showReportDialog() {
    final colors = context.colors;
    final problemController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.container,
        title: AppText(
          'Report a Problem',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              'Describe the issue you\'re experiencing',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              controller: problemController,
              maxLines: 4,
              hint: 'Type your problem here...',
              maxLength: 500,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppText(
              'Cancel',
              variant: AppTextVariant.labelLarge,
              color: colors.textSecondary,
            ),
          ),
          AppButton(
            label: 'Submit',
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: AppText('Problem reported. We\'ll get back to you soon.'),
                  backgroundColor: context.colors.success,
                ),
              );
            },
            variant: AppButtonVariant.primary,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  _FaqItem({required this.question, required this.answer});
}
