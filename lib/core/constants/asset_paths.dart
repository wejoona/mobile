/// Centralized asset path constants.
class AssetPaths {
  AssetPaths._();

  // Images
  static const logo = 'assets/images/logo.png';
  static const logoDark = 'assets/images/logo_dark.png';
  static const logoIcon = 'assets/images/logo_icon.png';
  static const onboarding1 = 'assets/images/onboarding_1.png';
  static const onboarding2 = 'assets/images/onboarding_2.png';
  static const onboarding3 = 'assets/images/onboarding_3.png';
  static const emptyState = 'assets/images/empty_state.png';
  static const successIllustration = 'assets/images/success.png';
  static const errorIllustration = 'assets/images/error.png';

  // Animations (Lottie)
  static const loadingAnimation = 'assets/animations/loading.json';
  static const successAnimation = 'assets/animations/success.json';
  static const confettiAnimation = 'assets/animations/confetti.json';

  // Icons
  static const sendIcon = 'assets/icons/send.svg';
  static const receiveIcon = 'assets/icons/receive.svg';
  static const scanIcon = 'assets/icons/scan.svg';
  static const billIcon = 'assets/icons/bill.svg';

  // Flags (country codes)
  static String flag(String countryCode) =>
      'assets/flags/${countryCode.toLowerCase()}.png';

  // Bank logos
  static String bankLogo(String bankCode) =>
      'assets/banks/${bankCode.toLowerCase()}.png';
}
