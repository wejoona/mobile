import 'package:intl/intl.dart';

/// Format a currency amount for display.
String formatCurrency(double amount, String currency) {
  final formatter = NumberFormat.currency(
    symbol: _currencySymbol(currency),
    decimalDigits: currency == 'XOF' ? 0 : 2,
  );
  return formatter.format(amount);
}

/// Format a date for display.
String formatDate(DateTime date) {
  return DateFormat.yMMMd().format(date);
}

/// Format a date and time for display.
String formatDateTime(DateTime date) {
  return DateFormat.yMMMd().add_jm().format(date);
}

/// Format a relative time (e.g. "2h ago", "Yesterday").
String formatRelativeTime(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 2) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return formatDate(date);
}

/// Get currency symbol.
String _currencySymbol(String currency) {
  switch (currency.toUpperCase()) {
    case 'USDC':
      return '\$';
    case 'USD':
      return '\$';
    case 'XOF':
      return 'CFA ';
    case 'XAF':
      return 'FCFA ';
    case 'GHS':
      return 'GH\u20B5';
    case 'NGN':
      return '\u20A6';
    default:
      return '$currency ';
  }
}

/// Mask a string, showing only last N characters.
String maskString(String input, {int visibleChars = 4, String mask = '****'}) {
  if (input.length <= visibleChars) return input;
  return '$mask ${input.substring(input.length - visibleChars)}';
}
