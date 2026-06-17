import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/features/limits/models/transaction_limits.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Wallet Service - mirrors backend WalletController
class WalletService {
  final Dio _dio;

  WalletService(this._dio);

  /// GET /wallet
  Future<WalletBalanceResponse> getBalance() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.walletBalance,
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          validateStatus: (status) =>
              status != null && (status < 400 || status == 404),
        ),
      );
      if (response.statusCode == 404) {
        return createWallet();
      }
      return WalletBalanceResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return createWallet();
      }
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /wallet/create - Create a new wallet
  Future<WalletBalanceResponse> createWallet() async {
    try {
      final response = await _dio.post(
        ApiEndpoints.walletCreate,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      return WalletBalanceResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /wallet/deposit/channels
  Future<List<DepositChannel>> getDepositChannels({String? currency}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.depositChannels,
        queryParameters: currency == null ? null : {'currency': currency},
      );
      final data = response.data;
      final List<dynamic> channels = data is List
          ? data
          // ignore: avoid_dynamic_calls
          : data['providers'] as List<dynamic>? ??
                // ignore: avoid_dynamic_calls
                data['channels'] as List<dynamic>? ??
                [];
      return channels
          .map((e) => DepositChannel.fromJson(e as Map<String, dynamic>))
          .where((e) => currency == null || e.currency == currency)
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
    required String phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.depositInitiate,
        data: {
          'amount': amount.round(),
          'sourceCurrency': sourceCurrency,
          'channelId': _mobileMoneyChannelId(channelId),
          if (phoneNumber.trim().isNotEmpty) 'phoneNumber': phoneNumber.trim(),
        },
        options: Options(
          headers: {'X-Idempotency-Key': generateIdempotencyKey()},
        ),
      );
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
    String? note,
    String? pinToken,
    String? idempotencyKey,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.transfersSend,
        data: {
          'toPhone': toPhone,
          'amount': amount,
          'currency': currency,
          if (note != null) 'note': note,
        },
        options: Options(
          headers: _transactionHeaders(
            pinToken: pinToken,
            idempotencyKey: idempotencyKey,
          ),
        ),
      );
      return TransferResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /transfers/external
  Future<TransferResponse> externalTransfer({
    required String toAddress,
    required double amount,
    required String currency,
    String? network,
    String? note,
    String? pinToken,
    String? idempotencyKey,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.transfersExternal,
        data: {
          'toAddress': toAddress,
          'amount': amount,
          'currency': currency,
          if (network != null) 'network': network,
          if (note != null) 'note': note,
        },
        options: Options(
          headers: _transactionHeaders(
            pinToken: pinToken,
            idempotencyKey: idempotencyKey,
          ),
        ),
      );
      return TransferResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /wallet/exchange-rate
  Future<ExchangeRate> getRate({
    required String sourceCurrency,
    required String targetCurrency,
    required double amount,
    String direction = 'deposit',
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.walletExchangeRate,
        queryParameters: {
          'sourceCurrency': sourceCurrency,
          'targetCurrency': targetCurrency,
          'amount': amount,
          'direction': direction,
        },
      );
      return _exchangeRateFromPayload(
        response.data,
        sourceCurrency: sourceCurrency,
        targetCurrency: targetCurrency,
        amount: amount,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /wallet/transfer/external
  Future<WithdrawResponse> withdraw({
    required double amount,
    required String destinationAddress,
    String? network,
    String? method,
    String? pinToken,
    String? idempotencyKey,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.transfersExternal,
        data: {
          'amount': amount,
          'toAddress': destinationAddress,
          'network': network ?? 'polygon',
          'currency': 'USDC',
          if (method != null) 'method': method,
        },
        options: Options(
          headers: _transactionHeaders(
            pinToken: pinToken,
            idempotencyKey: idempotencyKey,
          ),
        ),
      );
      return WithdrawResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /kyc/status
  Future<KycStatusResponse> getKycStatus() async {
    try {
      final response = await _dio.get(ApiEndpoints.kycStatus);
      return KycStatusResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /kyc/submit
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
      final response = await _dio.post(
        ApiEndpoints.kycSubmit,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'dateOfBirth': dateOfBirth,
          'country': country,
          'idType': idType,
          'idNumber': idNumber,
          if (idExpiryDate != null) 'idExpiryDate': idExpiryDate,
          if (address != null) 'address': address,
        },
      );
      return KycStatusResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /wallet/limits
  Future<TransactionLimitsResponse> getTransactionLimits() async {
    try {
      final response = await _dio.get(ApiEndpoints.walletLimits);
      return TransactionLimitsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

ExchangeRate _exchangeRateFromPayload(
  Object? payload, {
  required String sourceCurrency,
  required String targetCurrency,
  required double amount,
}) {
  final data = _asStringMap(payload);
  final rate = (data['rate'] as num?)?.toDouble() ?? 0;
  final safeRate = rate > 0 ? rate : 1.0;
  final sourceAmount =
      (data['sourceAmount'] as num?)?.toDouble() ??
      (data['fromAmount'] as num?)?.toDouble() ??
      amount;
  final targetAmount =
      (data['targetAmount'] as num?)?.toDouble() ??
      (data['toAmount'] as num?)?.toDouble() ??
      (sourceAmount / safeRate);

  return ExchangeRate(
    sourceCurrency:
        data['sourceCurrency'] as String? ??
        data['fromCurrency'] as String? ??
        sourceCurrency,
    targetCurrency:
        data['targetCurrency'] as String? ??
        data['toCurrency'] as String? ??
        targetCurrency,
    rate: safeRate,
    sourceAmount: sourceAmount,
    targetAmount: targetAmount,
    fee: (data['fee'] as num?)?.toDouble() ?? 0,
    expiresAt:
        DateTime.tryParse(
          data['expiresAt'] as String? ??
              data['timestamp'] as String? ??
              data['updatedAt'] as String? ??
              '',
        ) ??
        DateTime.now(),
  );
}

/// Wallet Balance Response
class WalletBalanceResponse {
  final String walletId;
  final String? walletAddress;
  final String blockchain;
  final String currency;
  final List<WalletBalance> balances;
  final bool degraded;
  final bool isStale;
  final String? warning;
  final String? sourceOfTruth;
  final String? readStatus;

  const WalletBalanceResponse({
    required this.walletId,
    this.walletAddress,
    required this.blockchain,
    required this.currency,
    required this.balances,
    this.degraded = false,
    this.isStale = false,
    this.warning,
    this.sourceOfTruth,
    this.readStatus,
  });

  double get totalBalance {
    return _primaryBalance()?.total ?? 0;
  }

  double get availableBalance {
    return _primaryBalance()?.available ?? 0;
  }

  WalletBalance? _primaryBalance() {
    if (balances.isEmpty) return null;

    for (final balance in balances) {
      if (balance.currency.toUpperCase() == 'USDC') {
        return balance;
      }
    }

    final declaredCurrency = currency.toUpperCase();
    for (final balance in balances) {
      if (balance.currency.toUpperCase() == declaredCurrency) {
        return balance;
      }
    }

    for (final balance in balances) {
      if (balance.available > 0 || balance.total > 0) {
        return balance;
      }
    }

    return balances.first;
  }

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    final payload = _walletPayload(json);
    final balanceList = _balanceEntries(payload['balances']);

    // Handle both GET /wallet and POST /wallet/create response formats
    // GET returns: {walletId, walletAddress, balances: [...]}
    // POST returns: {id, circleWalletAddress, balance: number}
    final walletId =
        payload['walletId'] as String? ?? payload['id'] as String? ?? '';
    final walletAddress =
        payload['walletAddress'] as String? ??
        payload['wallet_address'] as String? ??
        payload['circleWalletAddress'] as String? ??
        payload['circle_wallet_address'] as String? ??
        payload['address'] as String? ??
        payload['publicAddress'] as String? ??
        payload['public_address'] as String? ??
        payload['depositAddress'] as String? ??
        payload['deposit_address'] as String?;

    // If balances array is empty but balance field exists, create a synthetic balance
    List<WalletBalance> balances;
    if (balanceList.isNotEmpty) {
      balances = balanceList
          .whereType<Map>()
          .map((e) => WalletBalance.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final flatBalance = _flatBalanceFromPayload(payload);
      if (flatBalance != null && !_hasSpendableBalance(balances)) {
        final usdcIndex = balances.indexWhere(
          (balance) => balance.currency.toUpperCase() == 'USDC',
        );
        balances = [...balances];
        if (usdcIndex == -1) {
          balances.add(flatBalance);
        } else {
          balances[usdcIndex] = flatBalance;
        }
      }
    } else if (payload['balance'] != null ||
        payload['available'] != null ||
        payload['availableBalance'] != null ||
        payload['balanceUsdc'] != null ||
        payload['total'] != null) {
      // Create synthetic balance from single balance field
      final balance = _readAmount(payload, const [
        'availableDecimal',
        'available_decimal',
        'availableBalanceDecimal',
        'available_balance_decimal',
        'balanceDecimal',
        'balance_decimal',
        'available',
        'availableBalance',
        'available_balance',
        'balanceUsdc',
        'balance',
        'total',
      ]);
      final pending = _readAmount(payload, const [
        'pendingDecimal',
        'pending_decimal',
        'pendingBalanceDecimal',
        'pending_balance_decimal',
        'pending',
        'pendingBalance',
        'pending_balance',
      ]);
      final total = _readAmount(payload, const [
        'totalDecimal',
        'total_decimal',
        'totalBalanceDecimal',
        'total_balance_decimal',
        'balanceDecimal',
        'balance_decimal',
        'total',
        'totalBalance',
        'total_balance',
        'balanceUsdc',
        'balance',
      ]);
      final currency = payload['currency'] as String? ?? 'USDC';
      balances = [
        WalletBalance(
          currency: currency,
          available: balance,
          pending: pending,
          total: total == 0 ? balance + pending : total,
        ),
      ];
    } else {
      balances = [];
    }

    return WalletBalanceResponse(
      walletId: walletId,
      walletAddress: walletAddress,
      blockchain: payload['blockchain'] as String? ?? 'polygon',
      currency: payload['currency'] as String? ?? 'USDC',
      balances: balances,
      degraded: payload['degraded'] == true,
      isStale: payload['isStale'] == true,
      warning: payload['warning'] as String?,
      sourceOfTruth: payload['sourceOfTruth'] as String?,
      readStatus: payload['readStatus'] as String?,
    );
  }
}

List<Map<String, dynamic>> _balanceEntries(Object? raw) {
  if (raw is List) {
    return raw.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  if (raw is Map) {
    return raw.entries.map((entry) {
      final currency = entry.key.toString().toUpperCase();
      final value = entry.value;
      if (value is Map) {
        return {
          'currency': value['currency'] ?? currency,
          ...Map<String, dynamic>.from(value),
        };
      }
      return {'currency': currency, 'available': value, 'total': value};
    }).toList();
  }

  return const [];
}

WalletBalance? _flatBalanceFromPayload(Map<String, dynamic> payload) {
  const balanceKeys = [
    'availableDecimal',
    'available_decimal',
    'availableBalanceDecimal',
    'available_balance_decimal',
    'balanceDecimal',
    'balance_decimal',
    'available',
    'availableBalance',
    'available_balance',
    'balanceUsdc',
    'balance',
    'total',
  ];
  const pendingKeys = [
    'pendingDecimal',
    'pending_decimal',
    'pendingBalanceDecimal',
    'pending_balance_decimal',
    'pending',
    'pendingBalance',
    'pending_balance',
  ];
  const totalKeys = [
    'totalDecimal',
    'total_decimal',
    'totalBalanceDecimal',
    'total_balance_decimal',
    'balanceDecimal',
    'balance_decimal',
    'total',
    'totalBalance',
    'total_balance',
    'balanceUsdc',
    'balance',
  ];

  if (!_hasAnyAmountKey(payload, balanceKeys) &&
      !_hasAnyAmountKey(payload, pendingKeys) &&
      !_hasAnyAmountKey(payload, totalKeys)) {
    return null;
  }

  final balance = _readAmount(payload, balanceKeys);
  final pending = _readAmount(payload, pendingKeys);
  final total = _readAmount(payload, totalKeys);

  return WalletBalance(
    currency: payload['currency'] as String? ?? 'USDC',
    available: balance,
    pending: pending,
    total: total == 0 ? balance + pending : total,
  );
}

bool _hasSpendableBalance(List<WalletBalance> balances) {
  for (final balance in balances) {
    if (balance.available > 0 || balance.pending > 0 || balance.total > 0) {
      return true;
    }
  }
  return false;
}

bool _hasAnyAmountKey(Map<String, dynamic> payload, List<String> keys) {
  for (final key in keys) {
    if (payload.containsKey(key) && payload[key] != null) {
      return true;
    }
  }
  return false;
}

Map<String, dynamic> _walletPayload(Map<String, dynamic> json) {
  final data = json['data'];
  final payload = data is Map<String, dynamic>
      ? data
      : data is Map
      ? Map<String, dynamic>.from(data)
      : json;
  return _unwrapWalletPayload(payload);
}

Map<String, dynamic> _unwrapWalletPayload(Map<String, dynamic> payload) {
  for (final key in const ['wallet', 'account', 'result']) {
    final nested = payload[key];
    if (nested is Map<String, dynamic>) {
      return _mergeWalletEnvelope(payload, nested);
    }
    if (nested is Map) {
      return _mergeWalletEnvelope(payload, Map<String, dynamic>.from(nested));
    }
  }
  return payload;
}

Map<String, dynamic> _mergeWalletEnvelope(
  Map<String, dynamic> envelope,
  Map<String, dynamic> wallet,
) {
  final merged = <String, dynamic>{...envelope, ...wallet};
  for (final key in const [
    'balances',
    'balance',
    'available',
    'availableBalance',
    'balanceUsdc',
    'pending',
    'pendingBalance',
    'total',
  ]) {
    if (merged[key] == null && envelope.containsKey(key)) {
      merged[key] = envelope[key];
    }
  }
  return merged;
}

double _readAmount(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return 0;
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
    final paymentInstructions =
        json['paymentInstructions'] as Map<String, dynamic>?;
    final depositId =
        json['depositId'] as String? ?? json['id'] as String? ?? '';

    return DepositResponse(
      transactionId: json['transactionId'] as String? ?? depositId,
      depositId: depositId,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      sourceCurrency:
          json['sourceCurrency'] as String? ??
          json['currency'] as String? ??
          'XOF',
      targetCurrency:
          json['targetCurrency'] as String? ??
          json['convertedCurrency'] as String? ??
          'USDC',
      rate:
          (json['rate'] as num?)?.toDouble() ??
          (json['exchangeRate'] as num?)?.toDouble() ??
          0,
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      estimatedAmount:
          (json['estimatedAmount'] as num?)?.toDouble() ??
          (json['convertedAmount'] as num?)?.toDouble() ??
          0,
      paymentInstructions: PaymentInstructions.fromJson(
        paymentInstructions ?? json,
      ),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(const Duration(minutes: 15)),
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
      type:
          json['type'] as String? ??
          json['paymentMethodType'] as String? ??
          'mobile_money',
      provider:
          json['provider'] as String? ?? json['providerCode'] as String? ?? '',
      accountNumber:
          json['accountNumber'] as String? ??
          json['phoneNumber'] as String? ??
          '',
      reference: json['reference'] as String? ?? json['token'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
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
      transactionId:
          json['transactionId'] as String? ?? json['id'] as String? ?? '',
      amount: _readAmount(json, const ['amountDecimal', 'amount']),
      currency: json['currency'] as String? ?? 'USDC',
      fee: _readAmount(json, const ['feeDecimal', 'fee']),
      status: json['status'] as String? ?? 'pending',
    );
  }
}

/// Withdraw Response
class WithdrawResponse {
  final String transactionId;
  final double amount;
  final String destinationAddress;
  final String network;
  final double fee;
  final String status;

  const WithdrawResponse({
    required this.transactionId,
    required this.amount,
    required this.destinationAddress,
    required this.network,
    required this.fee,
    required this.status,
  });

  factory WithdrawResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawResponse(
      transactionId:
          json['transactionId'] as String? ?? json['id'] as String? ?? '',
      amount: _readAmount(json, const ['amountDecimal', 'amount']),
      destinationAddress:
          json['destinationAddress'] as String? ??
          json['toAddress'] as String? ??
          json['recipientAddress'] as String? ??
          json['phoneNumber'] as String? ??
          '',
      network:
          json['network'] as String? ?? json['providerCode'] as String? ?? '',
      fee: _readAmount(json, const ['feeDecimal', 'fee']),
      status: json['status'] as String? ?? 'pending',
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
      walletId:
          json['walletId'] as String? ?? json['wallet_id'] as String? ?? '',
      kycStatus:
          json['kycStatus'] as String? ??
          json['kyc_status'] as String? ??
          json['status'] as String? ??
          'pending',
      providerStatus:
          json['providerStatus'] as String? ??
          json['provider_status'] as String?,
      verifiedAt: _parseOptionalDate(json['verifiedAt'] ?? json['approvedAt']),
      message: json['message'] as String?,
    );
  }
}

DateTime? _parseOptionalDate(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

/// Transaction Limits Response
class TransactionLimitsResponse extends TransactionLimits {
  const TransactionLimitsResponse({
    required super.dailyLimit,
    required super.monthlyLimit,
    required super.singleTransactionLimit,
    required super.withdrawalLimit,
    required super.dailyUsed,
    required super.monthlyUsed,
    required super.kycTier,
    required super.tierName,
    super.nextTierName,
    super.nextTierDailyLimit,
    super.nextTierMonthlyLimit,
    super.resetTime,
    super.hoursUntilReset,
    super.minutesUntilReset,
  });

  factory TransactionLimitsResponse.fromJson(Map<String, dynamic> json) {
    return TransactionLimitsResponse(
      dailyLimit: (json['dailyLimit'] as num).toDouble(),
      monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
      singleTransactionLimit:
          (json['singleTransactionLimit'] as num?)?.toDouble() ?? 0.0,
      withdrawalLimit: (json['withdrawalLimit'] as num?)?.toDouble() ?? 0.0,
      dailyUsed: (json['dailyUsed'] as num).toDouble(),
      monthlyUsed: (json['monthlyUsed'] as num).toDouble(),
      kycTier: json['kycTier'] as int,
      tierName: json['tierName'] as String,
      nextTierName: json['nextTierName'] as String?,
      nextTierDailyLimit: json['nextTierDailyLimit'] != null
          ? (json['nextTierDailyLimit'] as num).toDouble()
          : null,
      nextTierMonthlyLimit: json['nextTierMonthlyLimit'] != null
          ? (json['nextTierMonthlyLimit'] as num).toDouble()
          : null,
      resetTime: json['resetTime'] != null
          ? DateTime.parse(json['resetTime'] as String)
          : null,
      hoursUntilReset: json['hoursUntilReset'] as int?,
      minutesUntilReset: json['minutesUntilReset'] as int?,
    );
  }
}

/// Wallet Service Provider
final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService(ref.watch(dioProvider));
});

Map<String, String> _transactionHeaders({
  String? pinToken,
  String? idempotencyKey,
}) {
  return {
    if (pinToken != null) 'X-Pin-Token': pinToken,
    'X-Idempotency-Key': idempotencyKey ?? generateIdempotencyKey(),
  };
}

Map<String, dynamic> _asStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

String _mobileMoneyChannelId(String value) {
  switch (value.replaceAll('-', '_').toLowerCase()) {
    case 'orange_money_ci':
    case 'omci':
    case 'orange':
    case 'orange_money':
    case 'mobile_money':
      return 'orange_money_ci';
    case 'mtn_momo_ci':
    case 'mtnci':
    case 'mtn':
    case 'mtn_momo':
    case 'mtn_mobile_money':
      return 'mtn_momo_ci';
    case 'moov_money_ci':
    case 'moovci':
    case 'moov':
    case 'moov_money':
      return 'moov_money_ci';
    case 'wave_ci':
    case 'waveci':
    case 'wave':
      return 'wave_ci';
    default:
      return value;
  }
}
