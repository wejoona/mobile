import 'package:dio/dio.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_request.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_response.dart';
import 'package:usdc_wallet/features/deposit/models/exchange_rate.dart';

/// Deposit Service
///
/// Handles mobile money deposit operations via the Korido API.
/// Mobile only talks to Korido wallet deposit routes — never to payment
/// providers directly.
class DepositService {
  final Dio _dio;

  DepositService(this._dio);

  /// Get available deposit providers
  Future<List<Map<String, dynamic>>> getProviders() async {
    final availability = await getProvidersAvailability();
    return availability.providers;
  }

  /// Get available deposit providers plus capability metadata.
  Future<DepositProvidersPayload> getProvidersAvailability({
    String? countryCode,
    String? currency,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.depositChannels,
      queryParameters: {
        if (countryCode != null && countryCode.isNotEmpty)
          'country': countryCode,
        if (currency != null && currency.isNotEmpty) 'currency': currency,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['channels'] != null) {
      return DepositProvidersPayload.fromJson(data, listKey: 'channels');
    }
    if (data is Map<String, dynamic> && data['providers'] != null) {
      return DepositProvidersPayload.fromJson(data, listKey: 'providers');
    }
    if (data is List) {
      return DepositProvidersPayload(
        providers: List<Map<String, dynamic>>.from(data),
      );
    }
    return const DepositProvidersPayload(providers: []);
  }

  /// Initiate a deposit — returns payment method type + instructions
  Future<DepositResponse> initiateDeposit(
    InitiateDepositRequest request,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.depositInitiate,
      data: request.toWalletDepositJson(),
      options: Options(
        headers: {'X-Idempotency-Key': generateIdempotencyKey()},
      ),
    );
    return DepositResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get deposit status (for polling)
  Future<DepositResponse> getDepositStatus(String depositId) async {
    final response = await _dio.get(ApiEndpoints.depositById(depositId));
    return DepositResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// List user's deposits
  Future<List<DepositResponse>> listDeposits({
    int page = 1,
    int limit = 20,
  }) async {
    final offset = page <= 1 ? 0 : (page - 1) * limit;
    final response = await _dio.get(
      ApiEndpoints.depositHistory,
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['deposits'] != null) {
      return (data['deposits'] as List)
          .map((e) => DepositResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is List) {
      return data
          .map((e) => DepositResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Initiate a mobile money deposit
  Future<DepositResponse> initiateMobileMoneyDeposit(
    Map<String, dynamic> data,
  ) async {
    final provider = data['provider'] ?? data['providerCode'];
    final channelId = provider ?? data['channelId'];
    if (channelId == null || channelId.toString().trim().isEmpty) {
      throw ArgumentError('Deposit channel is required');
    }
    final normalized = {
      'amount': data['amount'],
      'sourceCurrency': data['currency'] ?? data['sourceCurrency'] ?? 'XOF',
      'channelId': normalizeDepositChannelId(channelId.toString()),
      if ((data['phoneNumber'] as String?)?.trim().isNotEmpty == true)
        'phoneNumber': data['phoneNumber'],
    };
    final response = await _dio.post(
      ApiEndpoints.depositInitiate,
      data: normalized,
      options: Options(
        headers: {'X-Idempotency-Key': generateIdempotencyKey()},
      ),
    );
    return DepositResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get available deposit methods (alias for getProviders)
  Future<List<Map<String, dynamic>>> getDepositMethods() async {
    return getProviders();
  }

  /// Get exchange rate (XOF to USD)
  Future<ExchangeRate> getExchangeRate({
    String from = 'XOF',
    String to = 'USD',
    double amount = 10000,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.walletExchangeRate,
      queryParameters: {
        'sourceCurrency': from,
        'targetCurrency': to,
        'amount': amount,
        'direction': 'buy',
      },
    );
    final data = response.data as Map<String, dynamic>;
    if (data.containsKey('fromCurrency')) {
      return ExchangeRate.fromJson(data);
    }

    final sourceAmount = (data['sourceAmount'] as num?)?.toDouble() ?? amount;
    final targetAmount = (data['targetAmount'] as num?)?.toDouble() ?? 0;
    final rawRate = (data['rate'] as num?)?.toDouble() ?? 0.001524;
    final rate = targetAmount > 0
        ? sourceAmount / targetAmount
        : rawRate > 0
        ? 1 / rawRate
        : 655.957;
    return ExchangeRate(
      fromCurrency: data['sourceCurrency'] as String? ?? from,
      toCurrency: data['targetCurrency'] as String? ?? to,
      rate: rate,
      timestamp:
          DateTime.tryParse(data['expiresAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class DepositProvidersPayload {
  final List<Map<String, dynamic>> providers;
  final String? country;
  final String? currency;
  final String status;
  final String? reason;
  final bool retryable;
  final bool supportReviewRequired;

  const DepositProvidersPayload({
    required this.providers,
    this.country,
    this.currency,
    this.status = 'available',
    this.reason,
    this.retryable = false,
    this.supportReviewRequired = false,
  });

  factory DepositProvidersPayload.fromJson(
    Map<String, dynamic> json, {
    required String listKey,
  }) {
    return DepositProvidersPayload(
      providers: List<Map<String, dynamic>>.from(json[listKey] as List),
      country: json['country'] as String?,
      currency: json['currency'] as String?,
      status: json['status'] as String? ?? 'available',
      reason: json['reason'] as String?,
      retryable: json['retryable'] as bool? ?? false,
      supportReviewRequired: json['supportReviewRequired'] as bool? ?? false,
    );
  }
}
