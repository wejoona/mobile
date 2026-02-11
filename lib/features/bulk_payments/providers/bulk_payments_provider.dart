import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/bulk_payment.dart';
import '../../../services/api/api_client.dart';

/// Bulk payments list provider.
final bulkPaymentsProvider =
    FutureProvider<List<BulkPayment>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();

  Timer(const Duration(minutes: 2), () => link.close());

  final response = await dio.get('/bulk-payments');
  final data = response.data as Map<String, dynamic>;
  final items = data['data'] as List? ?? [];
  return items
      .map((e) => BulkPayment.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Create and manage bulk payments.
class BulkPaymentActions {
  final Dio _dio;

  BulkPaymentActions(this._dio);

  Future<BulkPayment> create({
    required String name,
    required List<BulkPaymentItem> items,
  }) async {
    final response = await _dio.post('/bulk-payments', data: {
      'name': name,
      'items': items.map((i) => i.toJson()).toList(),
    });
    return BulkPayment.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BulkPayment> getStatus(String id) async {
    final response = await _dio.get('/bulk-payments/$id');
    return BulkPayment.fromJson(response.data as Map<String, dynamic>);
  }
}

final bulkPaymentActionsProvider = Provider<BulkPaymentActions>((ref) {
  return BulkPaymentActions(ref.watch(dioProvider));
});
