/// Response DTO for wallet balance.
class WalletBalanceResponse {
  final String walletId;
  final double availableBalance;
  final double pendingBalance;
  final double totalBalance;
  final String currency;
  final DateTime lastUpdated;

  const WalletBalanceResponse({
    required this.walletId,
    required this.availableBalance,
    required this.pendingBalance,
    required this.totalBalance,
    required this.currency,
    required this.lastUpdated,
  });

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    return WalletBalanceResponse(
      walletId: json['walletId'] as String,
      availableBalance: (json['availableBalance'] as num).toDouble(),
      pendingBalance: (json['pendingBalance'] as num?)?.toDouble() ?? 0.0,
      totalBalance: (json['totalBalance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USDC',
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
