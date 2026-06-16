import 'package:usdc_wallet/domain/enums/index.dart';

/// Wallet entity - mirrors backend Wallet domain entity
class Wallet {
  final String id;
  final String userId;
  final String? circleWalletId;
  final String? walletAddress;
  final String blockchain;
  final KycStatus kycStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wallet({
    required this.id,
    required this.userId,
    this.circleWalletId,
    this.walletAddress,
    required this.blockchain,
    required this.kycStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isKycVerified => kycStatus == KycStatus.verified;

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String,
      userId: json['userId'] as String,
      circleWalletId: json['circleWalletId'] as String?,
      walletAddress: json['walletAddress'] as String?,
      blockchain: json['blockchain'] as String? ?? 'polygon',
      kycStatus: KycStatus.values.firstWhere(
        (e) => e.name == json['kycStatus'],
        orElse: () => KycStatus.none,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'circleWalletId': circleWalletId,
      'walletAddress': walletAddress,
      'blockchain': blockchain,
      'kycStatus': kycStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Wallet Balance
class WalletBalance {
  final String currency;
  final double available;
  final double pending;
  final double total;

  const WalletBalance({
    required this.currency,
    required this.available,
    required this.pending,
    required this.total,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    final available = _walletAmountOrNull(json, const [
      'availableDecimal',
      'available_decimal',
      'availableBalanceDecimal',
      'available_balance_decimal',
      'balanceDecimal',
      'balance_decimal',
      'available',
      'availableBalance',
      'available_balance',
      'balance',
    ]);
    final pending = _walletAmountOrNull(json, const [
      'pendingDecimal',
      'pending_decimal',
      'pendingBalanceDecimal',
      'pending_balance_decimal',
      'pending',
      'pendingBalance',
      'pending_balance',
    ]);
    final total = _walletAmountOrNull(json, const [
      'totalDecimal',
      'total_decimal',
      'totalBalanceDecimal',
      'total_balance_decimal',
      'balanceDecimal',
      'balance_decimal',
      'total',
      'totalBalance',
      'total_balance',
      'balance',
      'available',
      'availableBalance',
      'available_balance',
    ]);

    return WalletBalance(
      currency: json['currency'] as String? ?? 'USD',
      available: available ?? total ?? 0,
      pending: pending ?? 0,
      total: total ?? available ?? 0,
    );
  }
}

double? _walletAmountOrNull(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (!json.containsKey(key)) continue;
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return null;
}

/// Deposit Channel
class DepositChannel {
  final String id;
  final String name;
  final String type;
  final String provider;
  final String country;
  final double minAmount;
  final double maxAmount;
  final double fee;
  final String feeType;
  final String currency;

  const DepositChannel({
    required this.id,
    required this.name,
    required this.type,
    required this.provider,
    required this.country,
    required this.minAmount,
    required this.maxAmount,
    required this.fee,
    required this.feeType,
    required this.currency,
  });

  String get feeLabel {
    if (fee <= 0) return 'Free';
    final normalizedFeeType = feeType.toLowerCase();
    if (normalizedFeeType == 'percentage') {
      return '${_formatCompactAmount(fee)}% fee';
    }
    return '${_formatCompactAmount(fee)} $currency fee';
  }

  factory DepositChannel.fromJson(Map<String, dynamic> json) {
    final supportedCurrencies = json['supportedCurrencies'];
    final currency =
        supportedCurrencies is List && supportedCurrencies.isNotEmpty
        ? supportedCurrencies.first as String
        : json['currency'] as String? ?? 'XOF';

    return DepositChannel(
      id: json['id'] as String? ?? json['code'] as String? ?? '',
      name: json['name'] as String,
      type:
          json['type'] as String? ??
          json['paymentMethodType'] as String? ??
          'mobile_money',
      provider: json['provider'] as String? ?? json['code'] as String? ?? '',
      country: json['country'] as String? ?? 'CI',
      minAmount: (json['minAmount'] as num?)?.toDouble() ?? 100,
      maxAmount: (json['maxAmount'] as num?)?.toDouble() ?? 1000000,
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      feeType: json['feeType'] as String? ?? 'fixed',
      currency: currency,
    );
  }
}

String _formatCompactAmount(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

/// Exchange Rate
class ExchangeRate {
  final String sourceCurrency;
  final String targetCurrency;
  final double rate;
  final double sourceAmount;
  final double targetAmount;
  final double fee;
  final DateTime expiresAt;

  const ExchangeRate({
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.sourceAmount,
    required this.targetAmount,
    required this.fee,
    required this.expiresAt,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      sourceCurrency: json['sourceCurrency'] as String,
      targetCurrency: json['targetCurrency'] as String,
      rate: (json['rate'] as num).toDouble(),
      sourceAmount: (json['sourceAmount'] as num).toDouble(),
      targetAmount: (json['targetAmount'] as num).toDouble(),
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}
