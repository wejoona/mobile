class ProviderData {
  final String id;
  final String name;
  final String? logo;
  final double? minAmount;
  final double? maxAmount;
  final String? paymentMethodType;
  final String? enumProvider;
  final List<String> countries;
  final List<String> supportedCurrencies;
  final List<String> rails;

  const ProviderData({
    required this.id,
    required this.name,
    this.logo,
    this.minAmount,
    this.maxAmount,
    this.paymentMethodType,
    this.enumProvider,
    this.countries = const [],
    this.supportedCurrencies = const [],
    this.rails = const [],
  });
}

class DepositProvidersAvailability {
  final List<ProviderData> providers;
  final String? country;
  final String? currency;
  final String status;
  final String? reason;
  final bool retryable;
  final bool supportReviewRequired;

  const DepositProvidersAvailability({
    required this.providers,
    this.country,
    this.currency,
    this.status = 'available',
    this.reason,
    this.retryable = false,
    this.supportReviewRequired = false,
  });

  bool get hasProviders => providers.isNotEmpty;

  bool get isUnavailable =>
      status.toLowerCase() == 'unavailable' ||
      (!hasProviders && reason != null) ||
      supportReviewRequired;
}
