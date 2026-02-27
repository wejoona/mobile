import 'package:usdc_wallet/core/utils/amount_conversion.dart';

/// Unified currency formatting utility for consistent USDC display.
///
/// Fix #10: Replace inconsistent mix of toStringAsFixed(2) and raw doubles.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format a USDC amount for display (always 2 decimal places).
  static String formatUsdc(double amount) => amount.toStringAsFixed(2);

  /// Format with dollar sign: "\$10.50"
  static String formatUsdcWithSymbol(double amount) =>
      '\$${formatUsdc(amount)}';

  /// Format fee for display. Shows "Free" if zero.
  static String formatFee(double fee) =>
      fee == 0 ? 'Free' : '\$${formatUsdc(fee)}';

  /// Format total (amount + fee) for display.
  static String formatTotal(double amount, double fee) =>
      formatUsdcWithSymbol(amount + fee);

  /// Format XOF (CFA Franc) amounts (no decimals).
  static String formatXof(double amount) =>
      '${amount.toStringAsFixed(0)} FCFA';

  /// Sanitize a USDC amount to 2 decimal places (prevents floating-point drift).
  static double sanitize(double amount) =>
      double.parse(amount.toStringAsFixed(2));

  /// Convert display amount to cents for API calls.
  static int toCentsForApi(double amount) => toCents(sanitize(amount));
}
