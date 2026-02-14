import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/features/onboarding/providers/onboarding_progress_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Enhanced onboarding view with beautiful animations and illustrations
class EnhancedOnboardingView extends ConsumerStatefulWidget {
  const EnhancedOnboardingView({super.key});

  @override
  ConsumerState<EnhancedOnboardingView> createState() => _EnhancedOnboardingViewState();
}

class _EnhancedOnboardingViewState extends ConsumerState<EnhancedOnboardingView>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    final pages = [
      _OnboardingPageData(
        icon: Icons.account_balance_wallet_rounded,
        gradient: context.colors.goldGradient,
        title: l10n.onboarding_page1_title,
        description: l10n.onboarding_page1_description,
        features: [
          l10n.onboarding_page1_feature1,
          l10n.onboarding_page1_feature2,
          l10n.onboarding_page1_feature3,
        ],
      ),
      _OnboardingPageData(
        icon: Icons.flash_on_rounded,
        gradient: const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        title: l10n.onboarding_page2_title,
        description: l10n.onboarding_page2_description,
        features: [
          l10n.onboarding_page2_feature1,
          l10n.onboarding_page2_feature2,
          l10n.onboarding_page2_feature3,
        ],
      ),
      _OnboardingPageData(
        icon: Icons.payment_rounded,
        gradient: const [Color(0xFF2196F3), Color(0xFF1565C0)],
        title: l10n.onboarding_page3_title,
        description: l10n.onboarding_page3_description,
        features: [
          l10n.onboarding_page3_feature1,
          l10n.onboarding_page3_feature2,
          l10n.onboarding_page3_feature3,
        ],
      ),
      _OnboardingPageData(
        icon: Icons.verified_user_rounded,
        gradient: const [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
        title: l10n.onboarding_page4_title,
        description: l10n.onboarding_page4_description,
        features: [
          l10n.onboarding_page4_feature1,
          l10n.onboarding_page4_feature2,
          l10n.onboarding_page4_feature3,
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Header with skip button
            _buildHeader(l10n, colors),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  _animationController.forward(from: 0);
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(pages[index], colors);
                },
              ),
            ),

            // Page indicator and buttons
            _buildFooter(l10n, colors, pages.length),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: context.colors.goldGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: colors.textInverse,
              size: 20,
            ),
          ),

          // Skip button
          if (_currentPage < 3)
            GestureDetector(
              onTap: _completeOnboarding,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: AppText(
                  l10n.action_skip,
                  variant: AppTextVariant.labelLarge,
                  color: colors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPageData page, ThemeColors colors) {
    return FadeTransition(
      opacity: _animationController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon with gradient
              _buildAnimatedIcon(page, colors),
              const SizedBox(height: AppSpacing.giant),

              // Title
              AppText(
                page.title,
                variant: AppTextVariant.headlineLarge,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: AppText(
                  page.description,
                  variant: AppTextVariant.bodyLarge,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Feature list
              ...page.features.map((feature) => _buildFeature(feature, colors)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(_OnboardingPageData page, ThemeColors colors) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: page.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: page.gradient[0].withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeature(String feature, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: colors.gold,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              feature,
              variant: AppTextVariant.bodyMedium,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n, ThemeColors colors, int pageCount) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          // Page indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pageCount,
              (index) => _PageDot(
                isActive: index == _currentPage,
                colors: colors,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Button
          AppButton(
            label: _currentPage == pageCount - 1
              ? l10n.onboarding_getStarted
              : l10n.action_next,
            onPressed: _onNextPressed,
            variant: AppButtonVariant.primary,
            size: AppButtonSize.large,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  void _onNextPressed() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingProgressProvider.notifier).markTutorialCompleted();
    if (mounted) {
      context.go('/login');
    }
  }
}

class _OnboardingPageData {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String description;
  final List<String> features;

  const _OnboardingPageData({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.description,
    required this.features,
  });
}

class _PageDot extends StatelessWidget {
  const _PageDot({required this.isActive, required this.colors});

  final bool isActive;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(colors: context.colors.goldGradient)
            : null,
        color: isActive ? null : colors.textTertiary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
