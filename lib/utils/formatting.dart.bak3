import 'package:intl/intl.dart';

class Formatting {
  /// Format currency amount
  static String formatCurrency(double amount, {String symbol = 'FCFA'}) {
    final formatter = NumberFormat('#,##0.00');
    return '${formatter.format(amount)} $symbol';
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('MMM dd, yyyy HH:mm');
    return formatter.format(dateTime);
  }

  /// Format date only
  static String formatDate(DateTime dateTime) {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(dateTime);
  }

  /// Format time only
  static String formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  /// Format phone number
  static String formatPhoneNumber(String phone) {
    if (phone.length < 10) return phone;

    // Format as +XXX XX XX XX XX
    final countryCode = phone.substring(0, phone.length - 8);
    final rest = phone.substring(phone.length - 8);
    final parts = [
      rest.substring(0, 2),
      rest.substring(2, 4),
      rest.substring(4, 6),
      rest.substring(6, 8),
    ];

    return '$countryCode ${parts.join(' ')}';
  }

  /// Format large numbers (1000 -> 1K, 1000000 -> 1M)
  static String formatCompactNumber(double number) {
    if (number < 1000) return number.toStringAsFixed(0);
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }
}
