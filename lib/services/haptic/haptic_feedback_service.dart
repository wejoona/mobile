import 'package:flutter/services.dart';

/// Centralized haptic feedback service.
/// Provides consistent tactile feedback across the app.
class HapticFeedbackService {
  HapticFeedbackService._();

  /// Light tap — button presses, selections.
  static Future<void> lightTap() => HapticFeedback.lightImpact();

  /// Medium tap — confirmations, toggles.
  static Future<void> mediumTap() => HapticFeedback.mediumImpact();

  /// Heavy tap — important actions like send money.
  static Future<void> heavyTap() => HapticFeedback.heavyImpact();

  /// Selection tick — scrolling through items.
  static Future<void> selectionTick() => HapticFeedback.selectionClick();

  /// Success pattern — double light tap.
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error pattern — heavy tap.
  static Future<void> error() => HapticFeedback.heavyImpact();

  /// Warning pattern.
  static Future<void> warning() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
  }

  /// Notification received.
  static Future<void> notification() => HapticFeedback.mediumImpact();

  // Aliases for compatibility
  static Future<void> lightImpact() => lightTap();
}
