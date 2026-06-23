import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

class FxCurrency {
  const FxCurrency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimals,
    this.stablecoinPeg,
  });

  factory FxCurrency.fromJson(Map<String, dynamic> json) => FxCurrency(
    code: (json['code'] ?? '').toString().toUpperCase(),
    name: (json['name'] ?? '').toString(),
    symbol: (json['symbol'] ?? '').toString(),
    decimals: _intFromJson(json['decimals']) ?? 2,
    stablecoinPeg: json['stablecoinPeg']?.toString(),
  );

  final String code;
  final String name;
  final String symbol;
  final int decimals;
  final String? stablecoinPeg;
}

class FxQuote {
  const FxQuote({
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.sourceAmount,
    required this.targetAmount,
    required this.rate,
    required this.inverseRate,
    required this.quoteType,
    required this.source,
    this.fee = 0,
    this.updatedAt,
    this.expiresAt,
  });

  factory FxQuote.fromJson(Map<String, dynamic> json) => FxQuote(
    sourceCurrency: (json['sourceCurrency'] ?? '').toString().toUpperCase(),
    targetCurrency: (json['targetCurrency'] ?? '').toString().toUpperCase(),
    sourceAmount: _doubleFromJson(json['sourceAmount']) ?? 0,
    targetAmount: _doubleFromJson(json['targetAmount']) ?? 0,
    rate: _doubleFromJson(json['rate']) ?? 0,
    inverseRate: _doubleFromJson(json['inverseRate']) ?? 0,
    fee: _doubleFromJson(json['fee']) ?? 0,
    quoteType: (json['quoteType'] ?? 'indicative').toString(),
    source: (json['source'] ?? 'unknown').toString(),
    updatedAt: _dateFromJson(json['updatedAt']),
    expiresAt: _dateFromJson(json['expiresAt']),
  );

  final String sourceCurrency;
  final String targetCurrency;
  final double sourceAmount;
  final double targetAmount;
  final double rate;
  final double inverseRate;
  final double fee;
  final String quoteType;
  final String source;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
}

class FxService {
  FxService(this._dio);

  final Dio _dio;

  Future<List<FxCurrency>> getSupportedCurrencies() async {
    try {
      final response = await _dio.get(ApiEndpoints.fxCurrencies);
      final data = response.data;
      final currencies = data is Map
          ? data['currencies'] as List<dynamic>? ?? const []
          : const [];
      return currencies
          .whereType<Map>()
          .map((item) => FxCurrency.fromJson(Map<String, dynamic>.from(item)))
          .where((currency) => currency.code.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<FxQuote> quote({
    required double amount,
    required String sourceCurrency,
    required String targetCurrency,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.fxQuote,
        queryParameters: {
          'amount': amount,
          'sourceCurrency': sourceCurrency.trim().toUpperCase(),
          'targetCurrency': targetCurrency.trim().toUpperCase(),
        },
      );
      return FxQuote.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final fxServiceProvider = Provider<FxService>(
  (ref) => FxService(ref.watch(dioProvider)),
);

double? _doubleFromJson(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

int? _intFromJson(Object? value) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _dateFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value.toString());
}
