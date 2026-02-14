class ProviderData {
  final String id;
  final String name;
  final String? logo;
  final double? minAmount;
  final double? maxAmount;
  final String? paymentMethodType;
  final String? enumProvider;

  const ProviderData({
    required this.id,
    required this.name,
    this.logo,
    this.minAmount,
    this.maxAmount,
    this.paymentMethodType,
    this.enumProvider,
  });
}
