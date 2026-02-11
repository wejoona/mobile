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
    return WalletBalance(
      currency: json['currency'] as String? ?? 'USD',
      available: (json['available'] as num?)?.toDouble() ?? 0,
      pending: (json['pending'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
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

  factory DepositChannel.fromJson(Map<String, dynamic> json) {
    return DepositChannel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      provider: json['provider'] as String,
      country: json['country'] as String,
      minAmount: (json['minAmount'] as num).toDouble(),
      maxAmount: (json['maxAmount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      feeType: json['feeType'] as String,
      currency: json['currency'] as String,
    );
  }
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
