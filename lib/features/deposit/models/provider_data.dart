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

  String get brandKey {
    final normalized = [
      enumProvider,
      id,
      name,
    ].whereType<String>().map(_normalizeBrandCandidate).join(' ');

    if (normalized.contains('orange') || normalized.contains('omci')) {
      return 'orange_money';
    }
    if (normalized.contains('mtn') || normalized.contains('mtnci')) {
      return 'mtn_momo';
    }
    if (normalized.contains('moov') || normalized.contains('moovci')) {
      return 'moov_money';
    }
    if (normalized.contains('wave') || normalized.contains('waveci')) {
      return 'wave';
    }
    if (normalized.contains('ach')) {
      return 'ach';
    }
    if (normalized.contains('card')) {
      return 'card';
    }
    if (normalized.contains('crypto') || normalized.contains('usdc')) {
      return 'crypto';
    }

    return _normalizeBrandCandidate(enumProvider ?? id);
  }
}

String _normalizeBrandCandidate(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');

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
