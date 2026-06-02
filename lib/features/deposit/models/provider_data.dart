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
