/// Haptic Feedback System
///
/// Provides consistent tactile feedback across the app.
///
/// Usage:
/// ```dart
/// import 'package:usdc_wallet/../core/haptics/index.dart';
///
/// // In button callback
/// hapticService.mediumTap();
///
/// // In transaction success
/// hapticService.paymentConfirmed();
///
/// // In PIN entry
/// hapticService.pinDigit();
///
/// // User preferences (in settings)
/// ref.watch(hapticPreferencesProvider);
/// ref.read(hapticPreferencesProvider.notifier).toggle();
/// ```

export 'haptic_service.dart';
export 'haptic_preferences_provider.dart';
