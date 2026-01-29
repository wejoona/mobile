import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../../domain/entities/index.dart';

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
        '/wallet/transactions',
        queryParameters: queryParameters,
      );
      return TransactionPage.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /wallet/transactions/:id
  Future<Transaction> getTransaction(String id) async {
    try {
      final response = await _dio.get('/wallet/transactions/$id');
      return Transaction.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /wallet/transactions/deposit/:id/status
  Future<DepositStatusResponse> getDepositStatus(String depositId) async {
    try {
      final response = await _dio.get(
        '/wallet/transactions/deposit/$depositId/status',
      );
      return DepositStatusResponse.fromJson(response.data);
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
