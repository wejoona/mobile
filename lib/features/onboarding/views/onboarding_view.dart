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

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.account_balance_wallet,
      title: 'Your Money, Your Way',
      description:
          'Store, send, and receive USDC securely. Your digital wallet for the modern world.',
      color: Color(0xFFD4AF37),
    ),
    _OnboardingPage(
      icon: Icons.send,
      title: 'Send Money Instantly',
      description:
          'Transfer funds to friends and family in seconds. No borders, no delays.',
      color: Color(0xFF4CAF50),
    ),
    _OnboardingPage(
      icon: Icons.swap_horiz,
      title: 'Easy Deposits & Withdrawals',
      description:
          'Add money via Mobile Money, bank transfer, or card. Cash out anytime.',
      color: Color(0xFF2196F3),
    ),
    _OnboardingPage(
      icon: Icons.security,
      title: 'Bank-Level Security',
      description:
          'Your funds are protected with state-of-the-art encryption and biometric authentication.',
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
                  'Skip',
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
                label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
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
            page.title,
            variant: AppTextVariant.headlineMedium,
            color: colors.textPrimary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppText(
              page.description,
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
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
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
