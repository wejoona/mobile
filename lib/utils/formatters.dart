import 'package:intl/intl.dart';

/// Utility class for formatting values
class Formatters {
  Formatters._();

  /// Format currency with 2 decimal places
  static String formatCurrency(double amount, {int decimals = 2}) {
    return amount.toStringAsFixed(decimals);
  }

  /// Format date to short format (Jan 29, 2026)
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date and time (Jan 29, 2026 3:45 PM)
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy h:mm a').format(dateTime);
  }

  /// Format time only (3:45 PM)
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Format phone number with spacing
  static String formatPhoneNumber(String phone) {
    // Remove any existing spacing
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');

    // Format as +225 XX XX XX XX XX
    if (cleaned.startsWith('+225') && cleaned.length == 13) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 10)} ${cleaned.substring(10, 12)} ${cleaned.substring(12)}';
    }

    return phone;
  }

  /// Format large numbers with abbreviations (1.5K, 2.3M)
  static String formatCompact(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }
}
