/// Response DTO for fee estimation.
class FeeEstimateResponse {
  final double fee;
  final double totalAmount;
  final String currency;
  final String feeType;
  final double? feePercentage;

  const FeeEstimateResponse({
    required this.fee,
    required this.totalAmount,
    required this.currency,
    required this.feeType,
    this.feePercentage,
  });

  factory FeeEstimateResponse.fromJson(Map<String, dynamic> json) {
    return FeeEstimateResponse(
      fee: (json['fee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USDC',
      feeType: json['feeType'] as String? ?? 'flat',
      feePercentage: (json['feePercentage'] as num?)?.toDouble(),
    );
  }
}
