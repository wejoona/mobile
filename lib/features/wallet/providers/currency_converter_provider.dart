import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/services/fx/fx_service.dart';

const _unset = Object();

/// Currency converter state management — fetches live indicative FX quotes.
class CurrencyConversionState {
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

  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double? convertedAmount;
  final double? rate;
  final bool isLoading;
  final String? error;
  final DateTime? rateTimestamp;

  bool get isRateStale {
    if (rateTimestamp == null) {
      return true;
    }
    return DateTime.now().difference(rateTimestamp!).inMinutes > 5;
  }

  CurrencyConversionState copyWith({
    String? fromCurrency,
    String? toCurrency,
    double? amount,
    Object? convertedAmount = _unset,
    double? rate,
    bool? isLoading,
    String? error,
    DateTime? rateTimestamp,
  }) => CurrencyConversionState(
    fromCurrency: fromCurrency ?? this.fromCurrency,
    toCurrency: toCurrency ?? this.toCurrency,
    amount: amount ?? this.amount,
    convertedAmount: identical(convertedAmount, _unset)
        ? this.convertedAmount
        : convertedAmount as double?,
    rate: rate ?? this.rate,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    rateTimestamp: rateTimestamp ?? this.rateTimestamp,
  );
}

class CurrencyConverterNotifier extends StateNotifier<CurrencyConversionState> {
  CurrencyConverterNotifier(this._fxService)
    : super(const CurrencyConversionState());

  final FxService _fxService;

  void setFromCurrency(String currency) {
    state = state.copyWith(fromCurrency: currency);
    unawaited(fetchRate());
  }

  void setToCurrency(String currency) {
    state = state.copyWith(toCurrency: currency);
    unawaited(fetchRate());
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
    unawaited(fetchRate());
  }

  /// Fetch live indicative quote from backend GET /fx/quote.
  Future<void> fetchRate() async {
    state = state.copyWith(isLoading: true);
    try {
      final quote = await _fxService.quote(
        sourceCurrency: state.fromCurrency,
        targetCurrency: state.toCurrency,
        amount: state.amount > 0 ? state.amount : 1,
      );

      final rate = quote.rate;

      state = state.copyWith(
        rate: rate,
        convertedAmount: state.amount > 0 ? quote.targetAmount : null,
        isLoading: false,
        rateTimestamp: quote.updatedAt ?? DateTime.now(),
      );
    } on Object {
      state = CurrencyConversionState(
        fromCurrency: state.fromCurrency,
        toCurrency: state.toCurrency,
        amount: state.amount,
        error: 'Exchange rate unavailable. Please try again.',
      );
    }
  }

  void _recalculate() {
    if (state.rate != null && state.amount > 0) {
      state = state.copyWith(convertedAmount: state.amount * state.rate!);
    } else {
      state = state.copyWith(convertedAmount: null);
    }
  }
}

final currencyConverterProvider =
    StateNotifierProvider<CurrencyConverterNotifier, CurrencyConversionState>((
      ref,
    ) {
      final fxService = ref.watch(fxServiceProvider);
      final notifier = CurrencyConverterNotifier(fxService);
      unawaited(notifier.fetchRate());
      return notifier;
    });

/// Supported currencies for conversion
final supportedCurrenciesProvider = FutureProvider<List<String>>((ref) async {
  try {
    final currencies = await ref
        .watch(fxServiceProvider)
        .getSupportedCurrencies();
    final codes = currencies.map((currency) => currency.code).toSet().toList()
      ..sort();
    return codes.isEmpty ? _fallbackSupportedCurrencies : codes;
  } on Object {
    return _fallbackSupportedCurrencies;
  }
});

const _fallbackSupportedCurrencies = ['USDC', 'XOF', 'USD', 'EUR'];
