import 'package:flutter/material.dart';

/// Color utility methods for the app.
class ColorUtils {
  ColorUtils._();

  /// Generate a deterministic color from a string (for avatars, tags).
  static Color fromString(String input) {
    final hash = input.hashCode;
    return Color.fromARGB(
      255,
      (hash & 0xFF0000) >> 16,
      (hash & 0x00FF00) >> 8,
      hash & 0x0000FF,
    ).withValues(alpha: 1.0);
  }

  /// Generate a pastel color from a string (softer, for backgrounds).
  static Color pastelFromString(String input) {
    final hash = input.hashCode;
    return HSLColor.fromAHSL(
      1.0,
      (hash % 360).toDouble(),
      0.5,
      0.85,
    ).toColor();
  }

  /// Get a contrasting text color (black or white) for a given background.
  static Color contrastingText(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Transaction status color.
  static Color statusColor(String status, {bool isDark = false}) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return isDark ? Colors.green.shade300 : Colors.green.shade700;
      case 'pending':
      case 'processing':
        return isDark ? Colors.orange.shade300 : Colors.orange.shade700;
      case 'failed':
      case 'rejected':
        return isDark ? Colors.red.shade300 : Colors.red.shade700;
      case 'cancelled':
        return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
      default:
        return isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    }
  }

  /// Transaction type color.
  static Color transactionTypeColor(String type, {bool isDark = false}) {
    switch (type.toLowerCase()) {
      case 'deposit':
      case 'receive':
        return isDark ? Colors.green.shade300 : Colors.green.shade700;
      case 'withdrawal':
      case 'send':
        return isDark ? Colors.red.shade300 : Colors.red.shade700;
      case 'transfer':
        return isDark ? Colors.blue.shade300 : Colors.blue.shade700;
      case 'bill_payment':
        return isDark ? Colors.purple.shade300 : Colors.purple.shade700;
      default:
        return isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    }
  }
}
