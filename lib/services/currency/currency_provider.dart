import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'currency_service.dart';

/// State for managing currency preferences
class CurrencyState {
  final ReferenceCurrency referenceCurrency;
  final bool showReference;
  final bool isLoading;

  const CurrencyState({
    this.referenceCurrency = ReferenceCurrency.none,
    this.showReference = false,
    this.isLoading = false,
  });

  CurrencyState copyWith({
    ReferenceCurrency? referenceCurrency,
    bool? showReference,
    bool? isLoading,
  }) {
    return CurrencyState(
      referenceCurrency: referenceCurrency ?? this.referenceCurrency,
      showReference: showReference ?? this.showReference,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Check if reference currency should be displayed
  bool get shouldShowReference => showReference && referenceCurrency != ReferenceCurrency.none;
}

/// Provider for currency service
final currencyServiceProvider = Provider<CurrencyService>((ref) {
  return CurrencyService();
});

/// Notifier for managing currency preferences
class CurrencyNotifier extends Notifier<CurrencyState> {
  late final CurrencyService _currencyService;

  @override
  CurrencyState build() {
    _currencyService = ref.watch(currencyServiceProvider);
    _loadSavedPreferences();
    return const CurrencyState();
  }

  /// Load saved preferences from storage
  Future<void> _loadSavedPreferences() async {
    final currency = await _currencyService.getSavedReferenceCurrency();
    final enabled = await _currencyService.isReferenceCurrencyEnabled();
    state = CurrencyState(
      referenceCurrency: currency,
      showReference: enabled,
    );
  }

  /// Set reference currency
  Future<void> setReferenceCurrency(ReferenceCurrency currency) async {
    state = state.copyWith(isLoading: true);

    final saved = await _currencyService.saveReferenceCurrency(currency);
    if (saved) {
      state = state.copyWith(
        referenceCurrency: currency,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Toggle reference currency display
  Future<void> toggleShowReference(bool show) async {
    state = state.copyWith(isLoading: true);

    final saved = await _currencyService.setReferenceCurrencyEnabled(show);
    if (saved) {
      state = state.copyWith(
        showReference: show,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Get supported currencies
  List<ReferenceCurrency> getSupportedCurrencies() {
    return _currencyService.getSupportedCurrencies();
  }

  /// Convert amount to reference currency
  double convertToReference(double usdcAmount) {
    return _currencyService.convertToReference(
      usdcAmount,
      state.referenceCurrency,
    );
  }

  /// Format reference amount for display
  String formatReferenceAmount(double amount) {
    return _currencyService.formatReferenceAmount(
      amount,
      state.referenceCurrency,
    );
  }

  /// Get formatted reference for USDC amount (convenience method)
  String getFormattedReference(double usdcAmount) {
    if (!state.shouldShowReference) return '';
    final refAmount = convertToReference(usdcAmount);
    return formatReferenceAmount(refAmount);
  }

  /// Get default currency for country
  ReferenceCurrency getDefaultForCountry(String countryCode) {
    return _currencyService.getDefaultForCountry(countryCode);
  }
}

/// Provider for currency state
final currencyProvider = NotifierProvider<CurrencyNotifier, CurrencyState>(() {
  return CurrencyNotifier();
});

/// Convenience provider for checking if reference should show
final showReferenceCurrencyProvider = Provider<bool>((ref) {
  return ref.watch(currencyProvider).shouldShowReference;
});

/// Convenience provider for getting reference currency
final referenceCurrencyProvider = Provider<ReferenceCurrency>((ref) {
  return ref.watch(currencyProvider).referenceCurrency;
});
