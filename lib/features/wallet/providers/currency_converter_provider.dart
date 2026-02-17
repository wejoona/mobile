import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/services/wallet/wallet_service.dart';

/// Currency converter state management — fetches live rates from GET /wallet/rate.
class CurrencyConversionState {
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double? convertedAmount;
  final double? rate;
  final bool isLoading;
  final String? error;
  final DateTime? rateTimestamp;

  const CurrencyConversionState({
    this.fromCurrency = 'USDC',
    this.toCurrency = 'XOF',
    this.amount = 0,
    this.convertedAmount,
    this.rate,
    this.isLoading = false,
    this.error,
    this.rateTimestamp,
  });

  bool get isRateStale {
    if (rateTimestamp == null) return true;
    return DateTime.now().difference(rateTimestamp!).inMinutes > 5;
  }

  CurrencyConversionState copyWith({
    String? fromCurrency,
    String? toCurrency,
    double? amount,
    double? convertedAmount,
    double? rate,
    bool? isLoading,
    String? error,
    DateTime? rateTimestamp,
  }) => CurrencyConversionState(
    fromCurrency: fromCurrency ?? this.fromCurrency,
    toCurrency: toCurrency ?? this.toCurrency,
    amount: amount ?? this.amount,
    convertedAmount: convertedAmount ?? this.convertedAmount,
    rate: rate ?? this.rate,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    rateTimestamp: rateTimestamp ?? this.rateTimestamp,
  );
}

class CurrencyConverterNotifier extends StateNotifier<CurrencyConversionState> {
  final WalletService _walletService;

  CurrencyConverterNotifier(this._walletService)
      : super(const CurrencyConversionState());

  void setFromCurrency(String currency) {
    state = state.copyWith(fromCurrency: currency);
    fetchRate(); // Re-fetch when currency changes
  }

  void setToCurrency(String currency) {
    state = state.copyWith(toCurrency: currency);
    fetchRate(); // Re-fetch when currency changes
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
    _recalculate();
  }

  void swapCurrencies() {
    state = state.copyWith(
      fromCurrency: state.toCurrency,
      toCurrency: state.fromCurrency,
    );
    fetchRate();
  }

  /// Fetch live exchange rate from backend GET /wallet/rate.
  /// Falls back to hardcoded rates if the API is unreachable.
  Future<void> fetchRate() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final rateResponse = await _walletService.getRate(
        sourceCurrency: state.fromCurrency,
        targetCurrency: state.toCurrency,
        amount: state.amount > 0 ? state.amount : 1,
      );

      // Backend returns { sourceCurrency, targetCurrency, rate, sourceAmount, targetAmount }
      // We need the conversion factor: how many toCurrency per 1 fromCurrency
      final double rate = (state.amount > 0 && rateResponse.sourceAmount > 0)
          ? rateResponse.targetAmount / rateResponse.sourceAmount
          : rateResponse.rate;

      state = state.copyWith(
        rate: rate,
        isLoading: false,
        rateTimestamp: DateTime.now(),
      );
      _recalculate();
    } catch (e) {
      // Fallback to approximate rates if API fails
      final fallbackRate = _getFallbackRate(state.fromCurrency, state.toCurrency);
      state = state.copyWith(
        rate: fallbackRate,
        isLoading: false,
        rateTimestamp: DateTime.now(),
        error: null, // Don't show error — fallback is fine
      );
      _recalculate();
    }
  }

  void _recalculate() {
    if (state.rate != null && state.amount > 0) {
      state = state.copyWith(convertedAmount: state.amount * state.rate!);
    }
  }

  /// Fallback rates used when the API is unreachable.
  double _getFallbackRate(String from, String to) {
    if (from == 'USDC' && to == 'XOF') return 615.0;
    if (from == 'XOF' && to == 'USDC') return 1 / 615.0;
    if (from == 'USDC' && to == 'EUR') return 0.92;
    if (from == 'EUR' && to == 'USDC') return 1.087;
    if (from == 'USD' && to == 'XOF') return 615.0;
    if (from == 'XOF' && to == 'USD') return 1 / 615.0;
    return 1.0;
  }
}

final currencyConverterProvider = StateNotifierProvider<
    CurrencyConverterNotifier, CurrencyConversionState>((ref) {
  final walletService = ref.watch(walletServiceProvider);
  final notifier = CurrencyConverterNotifier(walletService);
  notifier.fetchRate();
  return notifier;
});

/// Supported currencies for conversion
final supportedCurrenciesProvider = Provider<List<String>>((ref) {
  return ['USDC', 'XOF', 'EUR', 'USD', 'NGN', 'GHS'];
});
