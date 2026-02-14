import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Supported reference currencies for display
enum ReferenceCurrency {
  none, // No secondary currency display
  xof, // West African CFA Franc
  xaf, // Central African CFA Franc
  ngn, // Nigerian Naira
  ghs, // Ghanaian Cedi
  eur, // Euro
  usd, // US Dollar (for non-USD users)
}

extension ReferenceCurrencyExt on ReferenceCurrency {
  String get code {
    switch (this) {
      case ReferenceCurrency.none:
        return '';
      case ReferenceCurrency.xof:
        return 'XOF';
      case ReferenceCurrency.xaf:
        return 'XAF';
      case ReferenceCurrency.ngn:
        return 'NGN';
      case ReferenceCurrency.ghs:
        return 'GHS';
      case ReferenceCurrency.eur:
        return 'EUR';
      case ReferenceCurrency.usd:
        return 'USD';
    }
  }

  String get name {
    switch (this) {
      case ReferenceCurrency.none:
        return 'None';
      case ReferenceCurrency.xof:
        return 'CFA Franc (XOF)';
      case ReferenceCurrency.xaf:
        return 'CFA Franc (XAF)';
      case ReferenceCurrency.ngn:
        return 'Nigerian Naira';
      case ReferenceCurrency.ghs:
        return 'Ghanaian Cedi';
      case ReferenceCurrency.eur:
        return 'Euro';
      case ReferenceCurrency.usd:
        return 'US Dollar';
    }
  }

  String get symbol {
    switch (this) {
      case ReferenceCurrency.none:
        return '';
      case ReferenceCurrency.xof:
      case ReferenceCurrency.xaf:
        return 'CFA';
      case ReferenceCurrency.ngn:
        return '\u20A6';
      case ReferenceCurrency.ghs:
        return 'GH\u20B5';
      case ReferenceCurrency.eur:
        return '\u20AC';
      case ReferenceCurrency.usd:
        return '\$';
    }
  }

  String get flag {
    switch (this) {
      case ReferenceCurrency.none:
        return '';
      case ReferenceCurrency.xof:
        return '\u{1F1E8}\u{1F1EE}'; // Ivory Coast flag
      case ReferenceCurrency.xaf:
        return '\u{1F1E8}\u{1F1F2}'; // Cameroon flag
      case ReferenceCurrency.ngn:
        return '\u{1F1F3}\u{1F1EC}'; // Nigeria flag
      case ReferenceCurrency.ghs:
        return '\u{1F1EC}\u{1F1ED}'; // Ghana flag
      case ReferenceCurrency.eur:
        return '\u{1F1EA}\u{1F1FA}'; // EU flag
      case ReferenceCurrency.usd:
        return '\u{1F1FA}\u{1F1F8}'; // US flag
    }
  }

  /// Approximate exchange rate from USDC (1 USDC = 1 USD)
  /// These are approximate rates for display purposes
  double get approximateRate {
    switch (this) {
      case ReferenceCurrency.none:
        return 0;
      case ReferenceCurrency.xof:
        return 615.0; // 1 USD ≈ 615 XOF
      case ReferenceCurrency.xaf:
        return 615.0; // 1 USD ≈ 615 XAF
      case ReferenceCurrency.ngn:
        return 1550.0; // 1 USD ≈ 1550 NGN
      case ReferenceCurrency.ghs:
        return 15.5; // 1 USD ≈ 15.5 GHS
      case ReferenceCurrency.eur:
        return 0.92; // 1 USD ≈ 0.92 EUR
      case ReferenceCurrency.usd:
        return 1.0;
    }
  }
}

/// Service for managing currency preferences
class CurrencyService {
  static const String _referenceCurrencyKey = 'reference_currency';
  static const String _showReferenceCurrencyKey = 'show_reference_currency';

  /// Get saved reference currency from storage
  Future<ReferenceCurrency> getSavedReferenceCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_referenceCurrencyKey);
      if (code == null) return ReferenceCurrency.none;

      return ReferenceCurrency.values.firstWhere(
        (c) => c.code == code,
        orElse: () => ReferenceCurrency.none,
      );
    } catch (e) {
      AppLogger('Error getting saved reference currency').error('Error getting saved reference currency', e);
      return ReferenceCurrency.none;
    }
  }

  /// Save reference currency to storage
  Future<bool> saveReferenceCurrency(ReferenceCurrency currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_referenceCurrencyKey, currency.code);
    } catch (e) {
      AppLogger('Error saving reference currency').error('Error saving reference currency', e);
      return false;
    }
  }

  /// Get whether reference currency display is enabled
  Future<bool> isReferenceCurrencyEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_showReferenceCurrencyKey) ?? false;
    } catch (e) {
      AppLogger('Error getting reference currency enabled').error('Error getting reference currency enabled', e);
      return false;
    }
  }

  /// Set whether reference currency display is enabled
  Future<bool> setReferenceCurrencyEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_showReferenceCurrencyKey, enabled);
    } catch (e) {
      AppLogger('Error saving reference currency enabled').error('Error saving reference currency enabled', e);
      return false;
    }
  }

  /// Get supported reference currencies
  List<ReferenceCurrency> getSupportedCurrencies() {
    return ReferenceCurrency.values.where((c) => c != ReferenceCurrency.none).toList();
  }

  /// Get default currency for country code
  ReferenceCurrency getDefaultForCountry(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'CI': // Ivory Coast
      case 'SN': // Senegal
      case 'ML': // Mali
      case 'BF': // Burkina Faso
      case 'NE': // Niger
      case 'TG': // Togo
      case 'BJ': // Benin
        return ReferenceCurrency.xof;
      case 'CM': // Cameroon
      case 'CF': // Central African Republic
      case 'TD': // Chad
      case 'CG': // Congo
      case 'GA': // Gabon
      case 'GQ': // Equatorial Guinea
        return ReferenceCurrency.xaf;
      case 'NG': // Nigeria
        return ReferenceCurrency.ngn;
      case 'GH': // Ghana
        return ReferenceCurrency.ghs;
      default:
        return ReferenceCurrency.xof;
    }
  }

  /// Convert USDC amount to reference currency
  double convertToReference(double usdcAmount, ReferenceCurrency currency) {
    if (currency == ReferenceCurrency.none) return 0;
    return usdcAmount * currency.approximateRate;
  }

  /// Format reference currency amount for display
  String formatReferenceAmount(double amount, ReferenceCurrency currency) {
    if (currency == ReferenceCurrency.none) return '';

    // Format with appropriate decimal places
    String formatted;
    if (currency == ReferenceCurrency.eur || currency == ReferenceCurrency.usd) {
      formatted = amount.toStringAsFixed(2);
    } else {
      // For most African currencies, show whole numbers
      formatted = amount.toStringAsFixed(0);
    }

    // Add thousand separators
    final parts = formatted.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );

    if (parts.length > 1) {
      return '${currency.symbol} $intPart.${parts[1]}';
    }
    return '${currency.symbol} $intPart';
  }
}
