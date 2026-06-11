import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/services/wallet/wallet_service.dart';

/// Currency converter state management — fetches live rates from GET /wallet/exchange-rate.
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

  /// Fetch live exchange rate from backend GET /wallet/exchange-rate.
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
      state = CurrencyConversionState(
        fromCurrency: state.fromCurrency,
        toCurrency: state.toCurrency,
        amount: state.amount,
        isLoading: false,
        error: 'Exchange rate unavailable. Please try again.',
      );
    }
  }

  void _recalculate() {
    if (state.rate != null && state.amount > 0) {
      state = state.copyWith(convertedAmount: state.amount * state.rate!);
    }
  }
}

final currencyConverterProvider =
    StateNotifierProvider<CurrencyConverterNotifier, CurrencyConversionState>((
      ref,
    ) {
      final walletService = ref.watch(walletServiceProvider);
      final notifier = CurrencyConverterNotifier(walletService);
      notifier.fetchRate();
      return notifier;
    });

/// Supported currencies for conversion
final supportedCurrenciesProvider = Provider<List<String>>((ref) {
  return ['USDC', 'XOF', 'USD', 'EUR'];
});
