import 'package:intl/intl.dart';

/// Utility class for common formatting operations.
class Formatters {
  Formatters._();

  /// Format a number as currency string (2 decimal places).
  static String formatCurrency(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }

  /// Format a DateTime to a readable date string.
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format a DateTime to a readable date+time string.
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }
}
