import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities for WCAG AA compliance
///
/// Features:
/// - Contrast ratio checking (WCAG AA: 4.5:1 for normal text, 3:1 for large text)
/// - Semantic label generation
/// - Screen reader announcements
/// - Focus management
class AccessibilityUtils {
  AccessibilityUtils._();

  // ══════════════════════════════════════════════════════════════════════════
  // CONTRAST RATIO (WCAG AA COMPLIANCE)
  // ══════════════════════════════════════════════════════════════════════════

  /// Calculate relative luminance of a color
  /// Formula from WCAG 2.1: https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html
  static double _relativeLuminance(Color color) {
    final r = _adjustColor(color.red / 255.0);
    final g = _adjustColor(color.green / 255.0);
    final b = _adjustColor(color.blue / 255.0);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _adjustColor(double colorValue) {
    if (colorValue <= 0.03928) {
      return colorValue / 12.92;
    }
    return ((colorValue + 0.055) / 1.055).pow(2.4);
  }

  /// Calculate contrast ratio between two colors
  /// Returns ratio from 1:1 (no contrast) to 21:1 (maximum contrast)
  static double contrastRatio(Color foreground, Color background) {
    final l1 = _relativeLuminance(foreground);
    final l2 = _relativeLuminance(background);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if contrast meets WCAG AA for normal text (4.5:1)
  static bool meetsWcagAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 4.5;
  }

  /// Check if contrast meets WCAG AA for large text (3:1)
  static bool meetsWcagAALarge(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 3.0;
  }

  /// Check if contrast meets WCAG AAA for normal text (7:1)
  static bool meetsWcagAAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 7.0;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEMANTIC LABELS
  // ══════════════════════════════════════════════════════════════════════════

  /// Format currency amount for screen readers
  /// \$1,234.56 → "1 thousand 234 dollars and 56 cents"
  static String formatCurrencyForScreenReader(double amount, {String currency = 'USD'}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final dollars = absAmount.floor();
    final cents = ((absAmount - dollars) * 100).round();

    final parts = <String>[];

    if (isNegative) {
      parts.add('negative');
    }

    // Format dollars with word numbers for large amounts
    if (dollars >= 1000000000) {
      final billions = dollars ~/ 1000000000;
      final remainder = dollars % 1000000000;
      parts.add('$billions billion');
      if (remainder > 0) {
        parts.add(_formatThousands(remainder));
      }
    } else if (dollars >= 1000000) {
      final millions = dollars ~/ 1000000;
      final remainder = dollars % 1000000;
      parts.add('$millions million');
      if (remainder > 0) {
        parts.add(_formatThousands(remainder));
      }
    } else if (dollars >= 1000) {
      parts.add(_formatThousands(dollars));
    } else {
      parts.add('$dollars');
    }

    parts.add(dollars == 1 ? 'dollar' : 'dollars');

    if (cents > 0) {
      parts.add('and $cents ${cents == 1 ? 'cent' : 'cents'}');
    }

    return parts.join(' ');
  }

  static String _formatThousands(int number) {
    if (number >= 1000) {
      final thousands = number ~/ 1000;
      final remainder = number % 1000;
      if (remainder > 0) {
        return '$thousands thousand $remainder';
      }
      return '$thousands thousand';
    }
    return '$number';
  }

  /// Format phone number for screen readers
  /// +2250712345678 → "phone number, country code plus 2 2 5, 0 7 1 2 3 4 5 6 7 8"
  static String formatPhoneForScreenReader(String phone) {
    if (phone.isEmpty) return 'no phone number';

    final parts = <String>[];
    parts.add('phone number');

    if (phone.startsWith('+')) {
      final countryCode = phone.substring(1, phone.length >= 4 ? 4 : phone.length);
      final remaining = phone.length > 4 ? phone.substring(4) : '';

      parts.add('country code plus ${_spellDigits(countryCode)}');
      if (remaining.isNotEmpty) {
        parts.add(_spellDigits(remaining));
      }
    } else {
      parts.add(_spellDigits(phone));
    }

    return parts.join(', ');
  }

  static String _spellDigits(String digits) {
    return digits.split('').join(' ');
  }

  /// Format wallet address for screen readers
  /// 0x1234...5678 → "wallet address 0 x 1 2 3 4 dot dot dot 5 6 7 8"
  static String formatWalletAddressForScreenReader(String address) {
    if (address.isEmpty) return 'no wallet address';

    if (address.length <= 10) {
      return 'wallet address ${_spellCharacters(address)}';
    }

    // For long addresses, spell first 6 and last 4 characters
    final start = address.substring(0, 6);
    final end = address.substring(address.length - 4);

    return 'wallet address ${_spellCharacters(start)}, dot dot dot, ${_spellCharacters(end)}';
  }

  static String _spellCharacters(String text) {
    return text.toLowerCase().split('').map((char) {
      if (char == 'x') return 'x';
      return char;
    }).join(' ');
  }

  /// Format transaction status for screen readers
  static String formatTransactionStatusForScreenReader(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'pending, transaction in progress';
      case 'completed':
      case 'success':
        return 'completed successfully';
      case 'failed':
        return 'failed, transaction did not complete';
      case 'cancelled':
        return 'cancelled by user';
      default:
        return status;
    }
  }

  /// Format date for screen readers
  /// 2024-01-15 14:30 → "January 15, 2024 at 2:30 PM"
  static String formatDateForScreenReader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'today at ${_formatTime(date)}';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'yesterday at ${_formatTime(date)}';
    } else if (dateOnly.isAfter(today.subtract(const Duration(days: 7)))) {
      return '${_weekday(date.weekday)} at ${_formatTime(date)}';
    } else {
      return '${_month(date.month)} ${date.day}, ${date.year} at ${_formatTime(date)}';
    }
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  static String _weekday(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  static String _month(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEMANTIC HINTS
  // ══════════════════════════════════════════════════════════════════════════

  /// Generate hint for button actions
  static String buttonHint(String action) {
    return 'Double tap to $action';
  }

  /// Generate hint for toggleable items
  static String toggleHint(bool isOn) {
    return 'Double tap to ${isOn ? 'turn off' : 'turn on'}';
  }

  /// Generate hint for expandable items
  static String expandableHint(bool isExpanded) {
    return 'Double tap to ${isExpanded ? 'collapse' : 'expand'}';
  }

  /// Generate hint for selectable items
  static String selectableHint(bool isSelected) {
    return isSelected ? 'Selected, double tap to deselect' : 'Not selected, double tap to select';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SCREEN READER ANNOUNCEMENTS
  // ══════════════════════════════════════════════════════════════════════════

  /// Announce message to screen reader
  /// Use for dynamic content changes that users should be aware of
  static void announce(BuildContext context, String message, {bool assertive = false}) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Announce error to screen reader
  static void announceError(BuildContext context, String error) {
    announce(context, 'Error: $error', assertive: true);
  }

  /// Announce success to screen reader
  static void announceSuccess(BuildContext context, String message) {
    announce(context, 'Success: $message', assertive: false);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FOCUS MANAGEMENT
  // ══════════════════════════════════════════════════════════════════════════

  /// Request focus for a node
  static void requestFocus(BuildContext context, FocusNode node) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (node.canRequestFocus) {
        FocusScope.of(context).requestFocus(node);
      }
    });
  }

  /// Move focus to next focusable element
  static void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move focus to previous focusable element
  static void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Unfocus current element
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ══════════════════════════════════════════════════════════════════════════

  /// Wrap widget with proper semantics for screen readers
  static Widget withSemantics({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool? button,
    bool? focusable,
    bool? selected,
    bool? enabled,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool excludeSemantics = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button ?? false,
      focusable: focusable ?? true,
      selected: selected,
      enabled: enabled ?? true,
      onTap: onTap,
      onLongPress: onLongPress,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  /// Create a semantics container for grouping related content
  static Widget semanticsContainer({
    required Widget child,
    required String label,
    bool explicitChildNodes = false,
  }) {
    return Semantics(
      container: true,
      label: label,
      explicitChildNodes: explicitChildNodes,
      child: child,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ══════════════════════════════════════════════════════════════════════════

  /// Validate and log contrast issues in debug mode
  static void validateContrast({
    required Color foreground,
    required Color background,
    required String componentName,
    bool isLargeText = false,
  }) {
    assert(() {
      final ratio = contrastRatio(foreground, background);
      final meetsStandard = isLargeText
          ? meetsWcagAALarge(foreground, background)
          : meetsWcagAA(foreground, background);

      if (!meetsStandard) {
        debugPrint(
          '⚠️ ACCESSIBILITY WARNING: $componentName has insufficient contrast\n'
          '   Foreground: $foreground\n'
          '   Background: $background\n'
          '   Contrast Ratio: ${ratio.toStringAsFixed(2)}:1\n'
          '   Required: ${isLargeText ? '3.0' : '4.5'}:1 (WCAG AA)\n'
        );
      }
      return true;
    }());
  }
}

// Extension for num.pow
extension on num {
  double pow(num exponent) {
    return math.pow(this, exponent).toDouble();
  }
}
