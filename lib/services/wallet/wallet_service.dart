import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../../domain/entities/index.dart';

/// Wallet Service - mirrors backend WalletController
class WalletService {
  final Dio _dio;

  WalletService(this._dio);

  /// GET /wallet
  Future<WalletBalanceResponse> getBalance() async {
    try {
      final response = await _dio.get('/wallet');
      return WalletBalanceResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /wallet/deposit/channels
  Future<List<DepositChannel>> getDepositChannels({String? currency}) async {
    try {
      final response = await _dio.get(
        '/wallet/deposit/channels',
        queryParameters: currency != null ? {'currency': currency} : null,
      );
      final List<dynamic> channels = response.data['channels'] ?? [];
      return channels
          .map((e) => DepositChannel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /wallet/deposit
  Future<DepositResponse> initiateDeposit({
    required double amount,
    required String sourceCurrency,
    required String channelId,
  }) async {
    try {
      final response = await _dio.post('/wallet/deposit', data: {
        'amount': amount,
        'sourceCurrency': sourceCurrency,
        'channelId': channelId,
      });
      return DepositResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /wallet/transfer/internal
  Future<TransferResponse> internalTransfer({
    required String toPhone,
    required double amount,
    required String currency,
  }) async {
    try {
      final response = await _dio.post('/wallet/transfer/internal', data: {
        'toPhone': toPhone,
        'amount': amount,
        'currency': currency,
      });
      return TransferResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /wallet/transfer/external
  Future<TransferResponse> externalTransfer({
    required String toAddress,
    required double amount,
    required String currency,
    String? network,
  }) async {
    try {
      final response = await _dio.post('/wallet/transfer/external', data: {
        'toAddress': toAddress,
        'amount': amount,
        'currency': currency,
        if (network != null) 'network': network,
      });
      return TransferResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /wallet/rate
  Future<ExchangeRate> getRate({
    required String sourceCurrency,
    required String targetCurrency,
    required double amount,
    String direction = 'deposit',
  }) async {
    try {
      final response = await _dio.get('/wallet/rate', queryParameters: {
        'sourceCurrency': sourceCurrency,
        'targetCurrency': targetCurrency,
        'amount': amount,
        'direction': direction,
      });
      return ExchangeRate.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /wallet/kyc/status
  Future<KycStatusResponse> getKycStatus() async {
    try {
      final response = await _dio.get('/wallet/kyc/status');
      return KycStatusResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /wallet/kyc/submit
  Future<KycStatusResponse> submitKyc({
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String country,
    required String idType,
    required String idNumber,
    String? idExpiryDate,
    String? address,
  }) async {
    try {
      final response = await _dio.post('/wallet/kyc/submit', data: {
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'country': country,
        'idType': idType,
        'idNumber': idNumber,
        if (idExpiryDate != null) 'idExpiryDate': idExpiryDate,
        if (address != null) 'address': address,
      });
      return KycStatusResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

/// Wallet Balance Response
class WalletBalanceResponse {
  final String walletId;
  final String? walletAddress;
  final String blockchain;
  final String currency;
  final List<WalletBalance> balances;

  const WalletBalanceResponse({
    required this.walletId,
    this.walletAddress,
    required this.blockchain,
    required this.currency,
    required this.balances,
  });

  double get totalBalance {
    if (balances.isEmpty) return 0;
    return balances.first.total;
  }

  double get availableBalance {
    if (balances.isEmpty) return 0;
    return balances.first.available;
  }

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> balanceList = json['balances'] ?? [];
    return WalletBalanceResponse(
      walletId: json['walletId'] as String? ?? '',
      walletAddress: json['walletAddress'] as String? ?? json['circleWalletAddress'] as String?,
      blockchain: json['blockchain'] as String? ?? 'MATIC',
      currency: json['currency'] as String? ?? 'USD',
      balances: balanceList
          .map((e) => WalletBalance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Deposit Response
class DepositResponse {
  final String transactionId;
  final String depositId;
  final double amount;
  final String sourceCurrency;
  final String targetCurrency;
  final double rate;
  final double fee;
  final double estimatedAmount;
  final PaymentInstructions paymentInstructions;
  final DateTime expiresAt;

  const DepositResponse({
    required this.transactionId,
    required this.depositId,
    required this.amount,
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.fee,
    required this.estimatedAmount,
    required this.paymentInstructions,
    required this.expiresAt,
  });

  factory DepositResponse.fromJson(Map<String, dynamic> json) {
    return DepositResponse(
      transactionId: json['transactionId'] as String,
      depositId: json['depositId'] as String,
      amount: (json['amount'] as num).toDouble(),
      sourceCurrency: json['sourceCurrency'] as String,
      targetCurrency: json['targetCurrency'] as String,
      rate: (json['rate'] as num).toDouble(),
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      estimatedAmount: (json['estimatedAmount'] as num).toDouble(),
      paymentInstructions: PaymentInstructions.fromJson(
        json['paymentInstructions'] as Map<String, dynamic>,
      ),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

/// Payment Instructions
class PaymentInstructions {
  final String type;
  final String provider;
  final String accountNumber;
  final String reference;
  final String instructions;

  const PaymentInstructions({
    required this.type,
    required this.provider,
    required this.accountNumber,
    required this.reference,
    required this.instructions,
  });

  factory PaymentInstructions.fromJson(Map<String, dynamic> json) {
    return PaymentInstructions(
      type: json['type'] as String,
      provider: json['provider'] as String,
      accountNumber: json['accountNumber'] as String,
      reference: json['reference'] as String,
      instructions: json['instructions'] as String,
    );
  }
}

/// Transfer Response
class TransferResponse {
  final String transactionId;
  final double amount;
  final String currency;
  final double fee;
  final String status;

  const TransferResponse({
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.fee,
    required this.status,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      transactionId: json['transactionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String,
    );
  }
}

/// KYC Status Response
class KycStatusResponse {
  final String walletId;
  final String kycStatus;
  final String? providerStatus;
  final DateTime? verifiedAt;
  final String? message;

  const KycStatusResponse({
    required this.walletId,
    required this.kycStatus,
    this.providerStatus,
    this.verifiedAt,
    this.message,
  });

  factory KycStatusResponse.fromJson(Map<String, dynamic> json) {
    return KycStatusResponse(
      walletId: json['walletId'] as String,
      kycStatus: json['kycStatus'] as String,
      providerStatus: json['providerStatus'] as String?,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      message: json['message'] as String?,
    );
  }
}

/// Wallet Service Provider
final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService(ref.watch(dioProvider));
});
