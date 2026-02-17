import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

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
      question: 'Comment déposer des USDC ?',
      answer: 'Pour déposer des USDC, allez sur l\'écran d\'accueil et appuyez sur « Dépôt ». Vous pouvez déposer via mobile money, virement bancaire, ou en envoyant des USDC à votre adresse de portefeuille.',
      category: 'Dépôts',
    ),
    _FaqItem(
      question: 'Combien de temps prennent les dépôts ?',
      answer: 'Les virements bancaires prennent généralement 1 à 3 jours ouvrables. Les dépôts mobile money sont quasi instantanés. Les transferts crypto dépendent de la congestion du réseau.',
      category: 'Dépôts',
    ),
    _FaqItem(
      question: 'Quels sont les frais d\'envoi d\'argent ?',
      answer: 'Korido ne facture aucun frais pour les transferts internes entre utilisateurs Korido. Les transferts externes vers d\'autres portefeuilles ou banques peuvent entraîner de petits frais réseau, affichés avant confirmation.',
      category: 'Transferts',
    ),
    _FaqItem(
      question: 'Comment retirer vers ma banque ?',
      answer: 'Allez sur l\'écran d\'accueil et appuyez sur « Retrait ». Sélectionnez votre compte bancaire et entrez le montant. Les retraits sont généralement traités sous 1 à 2 jours ouvrables.',
      category: 'Retraits',
    ),
    _FaqItem(
      question: 'Qu\'est-ce que le KYC et pourquoi est-il requis ?',
      answer: 'La vérification KYC (Know Your Customer) confirme votre identité conformément aux réglementations financières. Elle débloque également des limites de transaction plus élevées et protège contre la fraude.',
      category: 'Compte',
    ),
    _FaqItem(
      question: 'Comment augmenter mes limites de transaction ?',
      answer: 'Complétez la vérification KYC pour débloquer des limites plus élevées. Allez dans Paramètres > Vérifier l\'identité pour commencer le processus.',
      category: 'Compte',
    ),
    _FaqItem(
      question: 'Mon argent est-il en sécurité ?',
      answer: 'Oui ! Korido utilise un chiffrement de niveau bancaire et vos USDC sont garantis 1:1 par des réserves en USD. Nous offrons aussi la connexion biométrique et la 2FA pour plus de sécurité.',
      category: 'Sécurité',
    ),
    _FaqItem(
      question: 'J\'ai oublié mon PIN. Que faire ?',
      answer: 'Allez dans Paramètres > Sécurité > Réinitialiser le PIN. Vous devrez vérifier votre identité par e-mail ou téléphone avant de définir un nouveau PIN.',
      category: 'Sécurité',
    ),
    _FaqItem(
      question: 'Comment fonctionne le parrainage ?',
      answer: 'Partagez votre code de parrainage avec vos amis. Quand ils s\'inscrivent et font leur premier dépôt, vous recevez tous les deux un bonus ! Consultez l\'onglet Récompenses pour votre code.',
      category: 'Récompenses',
    ),
    _FaqItem(
      question: 'Puis-je annuler une transaction ?',
      answer: 'Une fois qu\'une transaction est confirmée sur la blockchain, elle ne peut pas être annulée. Pour les transactions en attente, contactez immédiatement le support. Les transferts internes peuvent être réversibles.',
      category: 'Transferts',
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
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.settings_help,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.safePop(fallbackRoute: '/settings'),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            AppInput(
              controller: _searchController,
              hint: l10n.help_searchPlaceholder,
              prefixIcon: Icons.search,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),

            SizedBox(height: AppSpacing.xxl),

            // Quick Help Actions
            AppText(
              l10n.help_getHelp,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildHelpAction(
                    icon: Icons.chat_bubble_outline,
                    label: l10n.help_liveChat,
                    onTap: _startLiveChat,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildHelpAction(
                    icon: Icons.email_outlined,
                    label: l10n.help_emailUs,
                    onTap: _sendEmail,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildHelpAction(
                    icon: Icons.phone_outlined,
                    label: l10n.help_callUs,
                    onTap: _callSupport,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.xxl),

            // FAQs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: AppText(
                    l10n.help_faq,
                    variant: AppTextVariant.titleMedium,
                    color: colors.textPrimary,
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  AppText(
                    '${_filteredFaqs.length} ${l10n.help_results}',
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
              subtitle: 'Complete guide to using Korido',
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
                        'Korido v1.0.0',
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
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.elevated,
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
            SizedBox(height: AppSpacing.sm),
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
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.settings_connectingToSupport),
                    backgroundColor: context.colors.info,
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
    final uri = Uri.parse('mailto:support@joonapay.com?subject=Korido Support Request');
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
        content: Text(helpful ? AppLocalizations.of(context)!.settings_thanksFeedback : AppLocalizations.of(context)!.settings_improveAnswer),
        backgroundColor: context.colors.info,
      ),
    );
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'Korido',
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
