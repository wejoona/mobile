/// Data model for onboarding pages.
class OnboardingPageData {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  /// Default onboarding pages.
  static const List<OnboardingPageData> pages = [
    OnboardingPageData(
      title: 'Send Money Instantly',
      description:
          'Transfer USDC to anyone across West Africa in seconds. No borders, no delays.',
      imagePath: 'assets/images/onboarding_1.png',
    ),
    OnboardingPageData(
      title: 'Low Fees, High Speed',
      description:
          'Free internal transfers. External sends at just 1%. Way less than traditional remittances.',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    OnboardingPageData(
      title: 'Your Money, Your Control',
      description:
          'Savings pots, spending insights, virtual cards. Everything you need in one app.',
      imagePath: 'assets/images/onboarding_3.png',
    ),
  ];
}
