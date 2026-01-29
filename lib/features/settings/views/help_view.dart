import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

class HelpView extends ConsumerStatefulWidget {
  const HelpView({super.key});

  @override
  ConsumerState<HelpView> createState() => _HelpViewState();
}

class _HelpViewState extends ConsumerState<HelpView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int? _expandedFaqIndex;

  final List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'How do I deposit USDC?',
      answer: 'To deposit USDC, go to the Home screen and tap "Deposit". You can deposit via bank transfer, card, or by sending USDC to your wallet address. Follow the instructions for your chosen method.',
      category: 'Deposits',
    ),
    _FaqItem(
      question: 'How long do deposits take?',
      answer: 'Bank transfers typically take 1-3 business days. Card deposits are instant. Crypto transfers depend on network congestion but usually complete within 15-30 minutes.',
      category: 'Deposits',
    ),
    _FaqItem(
      question: 'What are the fees for sending money?',
      answer: 'JoonaPay charges no fees for internal transfers between JoonaPay users. External transfers to other wallets or banks may incur small network fees, which are shown before you confirm.',
      category: 'Transfers',
    ),
    _FaqItem(
      question: 'How do I withdraw to my bank?',
      answer: 'Go to the Home screen and tap "Withdraw". Select your linked bank account and enter the amount. Withdrawals typically process within 1-2 business days.',
      category: 'Withdrawals',
    ),
    _FaqItem(
      question: 'What is KYC and why is it required?',
      answer: 'KYC (Know Your Customer) verification confirms your identity to comply with financial regulations. It also unlocks higher transaction limits and protects against fraud.',
      category: 'Account',
    ),
    _FaqItem(
      question: 'How do I increase my transaction limits?',
      answer: 'Complete KYC verification to unlock higher limits. Go to Settings > Verify Identity to start the process. Premium accounts have even higher limits.',
      category: 'Account',
    ),
    _FaqItem(
      question: 'Is my money safe?',
      answer: 'Yes! JoonaPay uses bank-level encryption and your USDC is backed 1:1 by USD reserves. We also offer biometric login and 2FA for additional security.',
      category: 'Security',
    ),
    _FaqItem(
      question: 'I forgot my PIN. What do I do?',
      answer: 'Go to Settings > Security > Reset PIN. You\'ll need to verify your identity via email or phone before setting a new PIN.',
      category: 'Security',
    ),
    _FaqItem(
      question: 'How do referrals work?',
      answer: 'Share your referral code with friends. When they sign up and make their first deposit, you both receive a bonus! Check the Rewards tab for your code.',
      category: 'Rewards',
    ),
    _FaqItem(
      question: 'Can I cancel a transaction?',
      answer: 'Once a transaction is confirmed on the blockchain, it cannot be reversed. For pending transactions, contact support immediately. Internal transfers may be reversible.',
      category: 'Transfers',
    ),
  ];

  List<_FaqItem> get _filteredFaqs {
    if (_searchQuery.isEmpty) return _faqs;
    final query = _searchQuery.toLowerCase();
    return _faqs.where((faq) =>
      faq.question.toLowerCase().contains(query) ||
      faq.answer.toLowerCase().contains(query) ||
      faq.category.toLowerCase().contains(query)
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Help & Support',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            AppInput(
              controller: _searchController,
              hint: 'Search help topics...',
              prefixIcon: Icons.search,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Quick Help Actions
            AppText(
              'Get Help',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildHelpAction(
                    colors: colors,
                    icon: Icons.chat_bubble_outline,
                    label: 'Live Chat',
                    onTap: _startLiveChat,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildHelpAction(
                    colors: colors,
                    icon: Icons.email_outlined,
                    label: 'Email Us',
                    onTap: _sendEmail,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildHelpAction(
                    colors: colors,
                    icon: Icons.phone_outlined,
                    label: 'Call Us',
                    onTap: _callSupport,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // FAQs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  'Frequently Asked Questions',
                  variant: AppTextVariant.titleMedium,
                  color: colors.textPrimary,
                ),
                if (_searchQuery.isNotEmpty)
                  AppText(
                    '${_filteredFaqs.length} results',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            if (_filteredFaqs.isEmpty)
              _buildNoResults(colors)
            else
              ...List.generate(_filteredFaqs.length, (index) {
                final faq = _filteredFaqs[index];
                return _buildFaqItem(colors, faq, index);
              }),

            const SizedBox(height: AppSpacing.xxl),

            // Popular Topics
            if (_searchQuery.isEmpty) ...[
              AppText(
                'Popular Topics',
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _buildTopicChip(colors, 'Deposits'),
                  _buildTopicChip(colors, 'Transfers'),
                  _buildTopicChip(colors, 'Withdrawals'),
                  _buildTopicChip(colors, 'Security'),
                  _buildTopicChip(colors, 'Account'),
                  _buildTopicChip(colors, 'Rewards'),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],

            // Resources
            AppText(
              'Resources',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildResourceItem(
              colors: colors,
              icon: Icons.article_outlined,
              title: 'User Guide',
              subtitle: 'Complete guide to using JoonaPay',
              onTap: () => _openUrl('https://joonapay.com/guide'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildResourceItem(
              colors: colors,
              icon: Icons.play_circle_outline,
              title: 'Video Tutorials',
              subtitle: 'Watch step-by-step tutorials',
              onTap: () => _openUrl('https://joonapay.com/videos'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildResourceItem(
              colors: colors,
              icon: Icons.policy_outlined,
              title: 'Terms of Service',
              subtitle: 'Read our terms and conditions',
              onTap: () => _openUrl('https://joonapay.com/terms'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildResourceItem(
              colors: colors,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data',
              onTap: () => _openUrl('https://joonapay.com/privacy'),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // App Info
            AppCard(
              variant: AppCardVariant.subtle,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: colors.textTertiary, size: 16),
                      const SizedBox(width: AppSpacing.sm),
                      AppText(
                        'JoonaPay v1.0.0',
                        variant: AppTextVariant.bodySmall,
                        color: colors.textTertiary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: _showLicenses,
                    child: AppText(
                      'Open Source Licenses',
                      variant: AppTextVariant.bodySmall,
                      color: colors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpAction({
    required ThemeColors colors,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colors.gold, size: 24),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              label,
              variant: AppTextVariant.labelSmall,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(ThemeColors colors, _FaqItem faq, int index) {
    final isExpanded = _expandedFaqIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        variant: AppCardVariant.subtle,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedFaqIndex = isExpanded ? null : index;
                });
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: AppText(
                      faq.category,
                      variant: AppTextVariant.labelSmall,
                      color: colors.gold,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: colors.textTertiary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedFaqIndex = isExpanded ? null : index;
                });
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppText(
                  faq.question,
                  variant: AppTextVariant.labelMedium,
                  color: colors.textPrimary,
                ),
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: AppSpacing.md),
              Divider(color: colors.borderSubtle),
              const SizedBox(height: AppSpacing.md),
              AppText(
                faq.answer,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  AppText(
                    'Was this helpful?',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textTertiary,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.thumb_up_outlined, size: 18),
                    color: colors.textTertiary,
                    onPressed: () => _markHelpful(true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.thumb_down_outlined, size: 18),
                    color: colors.textTertiary,
                    onPressed: () => _markHelpful(false),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(ThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              color: colors.textTertiary,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              'No results found',
              variant: AppTextVariant.titleMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              'Try different keywords or contact support',
              variant: AppTextVariant.bodyMedium,
              color: colors.textTertiary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicChip(ThemeColors colors, String topic) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchController.text = topic;
          _searchQuery = topic;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: AppText(
          topic,
          variant: AppTextVariant.labelSmall,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildResourceItem({
    required ThemeColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        variant: AppCardVariant.subtle,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: colors.gold, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    variant: AppTextVariant.labelMedium,
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
            Icon(
              Icons.open_in_new,
              color: colors.textTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _startLiveChat() {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.container,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.support_agent, color: colors.gold, size: 40),
            ),
            const SizedBox(height: AppSpacing.lg),
            const AppText(
              'Start Live Chat',
              variant: AppTextVariant.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              'Our support team is available 24/7. Average response time: 2 minutes.',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Start Chat',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Connecting to support agent...'),
                    backgroundColor: AppColors.infoBase,
                  ),
                );
              },
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Cancel',
              onPressed: () => Navigator.pop(context),
              variant: AppButtonVariant.secondary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  void _sendEmail() async {
    final uri = Uri.parse('mailto:support@joonapay.com?subject=JoonaPay Support Request');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _callSupport() async {
    final uri = Uri.parse('tel:+1-800-555-0123');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _markHelpful(bool helpful) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(helpful ? 'Thanks for your feedback!' : 'We\'ll improve this answer'),
        backgroundColor: AppColors.infoBase,
      ),
    );
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'JoonaPay',
      applicationVersion: '1.0.0',
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  final String category;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}
