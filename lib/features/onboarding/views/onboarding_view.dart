import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// Provider to track if onboarding has been completed
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_completed') ?? false;
});

/// Set onboarding as completed
Future<void> completeOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_completed', true);
}

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<_OnboardingPage> get _pages => [
    const _OnboardingPage(
      icon: Icons.account_balance_wallet,
      titleFr: 'Votre argent, simplifié',
      titleEn: 'Your Money, Simplified',
      descriptionFr:
          'Gardez, envoyez et recevez de l\'argent en toute sécurité. Votre portefeuille digital en FCFA.',
      descriptionEn:
          'Store, send, and receive money securely. Your digital wallet in FCFA.',
      color: Color(0xFFD4AF37),
    ),
    const _OnboardingPage(
      icon: Icons.send,
      titleFr: 'Envoyez en un instant',
      titleEn: 'Send Money Instantly',
      descriptionFr:
          'Transférez de l\'argent à vos proches en quelques secondes. Par numéro de téléphone, c\'est tout.',
      descriptionEn:
          'Transfer money to friends and family in seconds. Just a phone number.',
      color: Color(0xFF4CAF50),
    ),
    const _OnboardingPage(
      icon: Icons.swap_horiz,
      titleFr: 'Orange, MTN, Wave, Moov',
      titleEn: 'Orange, MTN, Wave, Moov',
      descriptionFr:
          'Déposez et retirez via Mobile Money. Compatible avec tous vos opérateurs.',
      descriptionEn:
          'Deposit and withdraw via Mobile Money. Works with all your providers.',
      color: Color(0xFF2196F3),
    ),
    const _OnboardingPage(
      icon: Icons.security,
      titleFr: 'Sécurité maximale',
      titleEn: 'Maximum Security',
      descriptionFr:
          'Protégé par code PIN et empreinte digitale. Votre argent est en sécurité.',
      descriptionEn:
          'Protected by PIN and fingerprint. Your money is safe.',
      color: Color(0xFF9C27B0),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: AppText(
                  Localizations.localeOf(context).languageCode == 'fr' ? 'Passer' : 'Skip',
                  variant: AppTextVariant.labelLarge,
                  color: colors.textSecondary,
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], colors);
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _PageDot(isActive: index == _currentPage, colors: colors),
                ),
              ),
            ),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: AppButton(
                label: _currentPage == _pages.length - 1
                    ? (Localizations.localeOf(context).languageCode == 'fr' ? 'Commencer' : 'Get Started')
                    : (Localizations.localeOf(context).languageCode == 'fr' ? 'Suivant' : 'Next'),
                onPressed: _onNextPressed,
                variant: AppButtonVariant.primary,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 70,
              color: page.color,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Title
          AppText(
            page.title(context),
            variant: AppTextVariant.headlineMedium,
            color: colors.textPrimary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppText(
              page.description(context),
              variant: AppTextVariant.bodyLarge,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await completeOnboarding();
    if (mounted) {
      context.go('/login');
    }
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.titleFr,
    required this.titleEn,
    required this.descriptionFr,
    required this.descriptionEn,
    required this.color,
  });

  final IconData icon;
  final String titleFr;
  final String titleEn;
  final String descriptionFr;
  final String descriptionEn;
  final Color color;

  /// Returns title based on locale (French-first)
  String title(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'fr' ? titleFr : titleEn;
  }

  /// Returns description based on locale (French-first)
  String description(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'fr' ? descriptionFr : descriptionEn;
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({required this.isActive, required this.colors});

  final bool isActive;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? colors.gold : colors.textTertiary,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
