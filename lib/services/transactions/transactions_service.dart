import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Transactions Service - mirrors backend TransactionsController
class TransactionsService {
  final Dio _dio;

  TransactionsService(this._dio);

  /// GET /wallet/transactions with advanced filtering
  Future<TransactionPage> getTransactions({
    int page = 1,
    int pageSize = 20,
    String? type,
    String? status,
    TransactionFilter? filter,
  }) async {
    try {
      // Build query parameters
      final queryParameters = <String, dynamic>{
        'limit': pageSize,
        'offset': (page - 1) * pageSize,
      };

      // Apply filter parameters if provided
      if (filter != null) {
        queryParameters.addAll(filter.toQueryParams());
      } else {
        // Legacy support for simple type/status filters
        if (type != null) queryParameters['type'] = type;
        if (status != null) queryParameters['status'] = status;
      }

      final response = await _dio.get(
        ApiEndpoints.walletTransactions,
        queryParameters: queryParameters,
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      return TransactionPage.fromJson(_asStringMap(response.data));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /wallet/transactions/:id
  Future<Transaction> getTransaction(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.walletTransactionById(id));
      return Transaction.fromJson(_responseObject(response.data));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /wallet/transactions/deposit/:id/status
  Future<DepositStatusResponse> getDepositStatus(String depositId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.walletDepositTransactionStatus(depositId),
      );
      return DepositStatusResponse.fromJson(_responseObject(response.data));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

/// Deposit Status Response
class DepositStatusResponse {
  final String transactionId;
  final String depositId;
  final String status;
  final double? amount;
  final DateTime? completedAt;

  const DepositStatusResponse({
    required this.transactionId,
    required this.depositId,
    required this.status,
    this.amount,
    this.completedAt,
  });

  factory DepositStatusResponse.fromJson(Map<String, dynamic> json) {
    return DepositStatusResponse(
      transactionId: json['transactionId'] as String,
      depositId: json['depositId'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

/// Transactions Service Provider
final transactionsServiceProvider = Provider<TransactionsService>((ref) {
  return TransactionsService(ref.watch(dioProvider));
});

Map<String, dynamic> _asStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const FormatException('Expected JSON object');
}

Map<String, dynamic> _responseObject(Object? value) {
  final map = _asStringMap(value);
  final data = map['data'];
  if (data is Map) return Map<String, dynamic>.from(data);
  return map;
}
