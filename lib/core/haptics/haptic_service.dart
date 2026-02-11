import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Standardized haptic feedback patterns for the app
///
/// Provides consistent tactile feedback across:
/// - Transactional operations (success, error, warning)
/// - UI interactions (selection, toggle, navigation)
/// - Contextual feedback (light, medium, heavy)
class HapticService {
  HapticService._();
  static final HapticService _instance = HapticService._();
  factory HapticService() => _instance;

  bool _isEnabled = true;

  /// Enable or disable haptics globally
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Check if haptics are enabled
  bool get isEnabled => _isEnabled;

  // ============================================================================
  // Transaction Feedback
  // ============================================================================

  /// Successful transaction completion
  /// Use: Transfer sent, payment completed, KYC approved
  Future<void> success() async {
    if (!_isEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Transaction or validation error
  /// Use: Failed transfer, invalid input, insufficient balance
  Future<void> error() async {
    if (!_isEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Warning or confirmation required
  /// Use: Large amount warning, unusual activity, confirm deletion
  Future<void> warning() async {
    if (!_isEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  // ============================================================================
  // UI Interaction Feedback
  // ============================================================================

  /// Light selection feedback
  /// Use: Tapping items in a list, selecting options, menu navigation
  Future<void> selection() async {
    if (!_isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Alias for lightTap.
  Future<void> lightImpact() => lightTap();

  /// Light tap feedback
  /// Use: Secondary buttons, navigation items, tabs
  Future<void> lightTap() async {
    if (!_isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium tap feedback
  /// Use: Primary buttons, confirmations, important actions
  Future<void> mediumTap() async {
    if (!_isEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy tap feedback
  /// Use: Destructive actions, final confirmations, critical buttons
  Future<void> heavyTap() async {
    if (!_isEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  // ============================================================================
  // Contextual Feedback
  // ============================================================================

  /// Toggle switch or checkbox state change
  /// Use: Settings toggles, biometric enable/disable, feature flags
  Future<void> toggle() async {
    if (!_isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Scrolling to important boundary or snap point
  /// Use: Amount picker snap, date selector, carousel pagination
  Future<void> snap() async {
    if (!_isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Long press detected
  /// Use: Context menu trigger, quick actions, item preview
  Future<void> longPress() async {
    if (!_isEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Pull-to-refresh trigger
  /// Use: Transaction list refresh, balance update
  Future<void> refresh() async {
    if (!_isEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  // ============================================================================
  // Financial Context Feedback
  // ============================================================================

  /// Payment initiated
  /// Use: Send money button press, bill payment start
  Future<void> paymentStart() async {
    if (!_isEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Payment confirmed
  /// Use: PIN verified, transaction submitted
  Future<void> paymentConfirmed() async {
    if (!_isEnabled) return;
    await success();
  }

  /// Funds received
  /// Use: Incoming transfer notification, deposit completed
  Future<void> fundsReceived() async {
    if (!_isEnabled) return;
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 30));
    await HapticFeedback.mediumImpact();
  }

  /// Biometric authentication triggered
  /// Use: FaceID/TouchID prompt shown
  Future<void> biometricPrompt() async {
    if (!_isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// PIN digit entered
  /// Use: Each PIN number tap (subtle feedback)
  Future<void> pinDigit() async {
    if (!_isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// PIN complete (all digits entered)
  /// Use: Final PIN digit entered
  Future<void> pinComplete() async {
    if (!_isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  // ============================================================================
  // Utility Methods
  // ============================================================================

  /// Vibrate with custom pattern (Android only)
  /// iOS falls back to medium impact
  Future<void> customPattern(List<int> pattern) async {
    if (!_isEnabled) return;

    if (defaultTargetPlatform == TargetPlatform.android) {
      await HapticFeedback.vibrate();
    } else {
      // iOS fallback
      await HapticFeedback.mediumImpact();
    }
  }

  /// Execute haptic with delay
  Future<void> delayedHaptic(
    Future<void> Function() hapticFn,
    Duration delay,
  ) async {
    await Future.delayed(delay);
    await hapticFn();
  }
}

/// Global haptic service instance
final hapticService = HapticService();
