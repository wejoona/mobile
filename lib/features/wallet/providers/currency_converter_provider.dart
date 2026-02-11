import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Run 348: Currency converter state management
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
  CurrencyConverterNotifier() : super(const CurrencyConversionState());

  void setFromCurrency(String currency) {
    state = state.copyWith(fromCurrency: currency);
    _recalculate();
  }

  void setToCurrency(String currency) {
    state = state.copyWith(toCurrency: currency);
    _recalculate();
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
    _recalculate();
  }

  Future<void> fetchRate() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // Simulated rate - will be replaced by API call
      final rate = _getSimulatedRate(state.fromCurrency, state.toCurrency);
      state = state.copyWith(
        rate: rate,
        isLoading: false,
        rateTimestamp: DateTime.now(),
      );
      _recalculate();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _recalculate() {
    if (state.rate != null && state.amount > 0) {
      state = state.copyWith(convertedAmount: state.amount * state.rate!);
    }
  }

  double _getSimulatedRate(String from, String to) {
    // Placeholder rates for common West African conversions
    if (from == 'USDC' && to == 'XOF') return 615.0;
    if (from == 'XOF' && to == 'USDC') return 1 / 615.0;
    if (from == 'USDC' && to == 'EUR') return 0.92;
    if (from == 'EUR' && to == 'USDC') return 1.087;
    return 1.0;
  }
}

final currencyConverterProvider = StateNotifierProvider<
    CurrencyConverterNotifier, CurrencyConversionState>((ref) {
  final notifier = CurrencyConverterNotifier();
  notifier.fetchRate();
  return notifier;
});

/// Supported currencies for conversion
final supportedCurrenciesProvider = Provider<List<String>>((ref) {
  return ['USDC', 'XOF', 'EUR', 'USD', 'NGN', 'GHS'];
});
