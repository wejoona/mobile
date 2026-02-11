/// Currency formatting utilities.

/// Format USDC amount: "1,234.56 USDC"
String formatUsdc(double amount, {bool showSymbol = true}) {
  final formatted = amount.toStringAsFixed(2);
  final parts = formatted.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  final result = '${intPart}.${parts[1]}';
  return showSymbol ? '$result USDC' : result;
}

/// Format XOF amount: "25,000 XOF"
String formatXof(double amount, {bool showSymbol = true}) {
  final formatted = amount.toStringAsFixed(0);
  final intPart = formatted.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return showSymbol ? '$intPart XOF' : intPart;
}

/// Auto-format based on currency code
String formatCurrency(double amount, String currency) {
  switch (currency.toUpperCase()) {
    case 'USDC':
    case 'USD':
      return formatUsdc(amount);
    case 'XOF':
      return formatXof(amount);
    default:
      return '${amount.toStringAsFixed(2)} $currency';
  }
}

/// Convert USDC to XOF (approximate)
double usdcToXof(double usdc, {double rate = 600.0}) => usdc * rate;

/// Convert XOF to USDC (approximate)
double xofToUsdc(double xof, {double rate = 600.0}) => xof / rate;
