import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../../domain/entities/index.dart';

/// Transfers Service - mirrors backend TransfersController
class TransfersService {
  final Dio _dio;

  TransfersService(this._dio);

  /// POST /transfers/internal
  Future<TransferResult> createInternalTransfer({
    required String recipientPhone,
    required double amount,
    String? note,
  }) async {
    try {
      final response = await _dio.post('/transfers/internal', data: {
        'recipientPhone': recipientPhone,
        'amount': amount,
        if (note != null) 'note': note,
      });
      return TransferResult.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /transfers/external
  Future<TransferResult> createExternalTransfer({
    required String recipientAddress,
    required double amount,
    String? blockchain,
    String? note,
  }) async {
    try {
      final response = await _dio.post('/transfers/external', data: {
        'recipientAddress': recipientAddress,
        'amount': amount,
        if (blockchain != null) 'blockchain': blockchain,
        if (note != null) 'note': note,
      });
      return TransferResult.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /transfers
  Future<TransferPage> getTransfers({
    int page = 1,
    int pageSize = 20,
    String? type,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        '/transfers',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (type != null) 'type': type,
          if (status != null) 'status': status,
        },
      );
      return TransferPage.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /transfers/:id
  Future<Transfer> getTransfer(String id) async {
    try {
      final response = await _dio.get('/transfers/$id');
      return Transfer.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

/// Transfer Result DTO
class TransferResult {
  final String id;
  final String reference;
  final String type;
  final String status;
  final double amount;
  final double fee;
  final String currency;
  final String? recipientPhone;
  final String? recipientAddress;
  final String? txHash;
  final DateTime createdAt;

  const TransferResult({
    required this.id,
    required this.reference,
    required this.type,
    required this.status,
    required this.amount,
    required this.fee,
    required this.currency,
    this.recipientPhone,
    this.recipientAddress,
    this.txHash,
    required this.createdAt,
  });

  factory TransferResult.fromJson(Map<String, dynamic> json) {
    return TransferResult(
      id: json['id'] as String,
      reference: json['reference'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USDC',
      recipientPhone: json['recipientPhone'] as String?,
      recipientAddress: json['recipientAddress'] as String?,
      txHash: json['txHash'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Transfer Page DTO
class TransferPage {
  final List<Transfer> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const TransferPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory TransferPage.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsData = json['items'] ?? json['data'] ?? [];
    return TransferPage(
      items: itemsData
          .map((e) => Transfer.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

/// Transfers Service Provider
final transfersServiceProvider = Provider<TransfersService>((ref) {
  return TransfersService(ref.watch(dioProvider));
});
