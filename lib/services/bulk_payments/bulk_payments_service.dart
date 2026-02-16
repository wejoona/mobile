import 'package:dio/dio.dart';
import 'package:usdc_wallet/features/bulk_payments/models/bulk_batch.dart';

class BulkPaymentsService {
  final Dio _dio;

  BulkPaymentsService(this._dio);

  Future<List<BulkBatch>> getBatches() async {
    final response = await _dio.get('/bulk-payments/batches');
    final data = response.data;
    // Backend returns { batches: [...] }; handle both wrapped and direct list
    final List items;
    if (data is Map && data.containsKey('batches')) {
      items = data['batches'] as List? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      items = [];
    }
    return items.map((json) => BulkBatch.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<BulkBatch> submitBatch(BulkBatch batch) async {
    final response = await _dio.post(
      '/bulk-payments/batches',
      data: {
        'name': batch.name,
        'payments': batch.validPayments.map((p) => p.toJson()).toList(),
      },
    );
    return BulkBatch.fromJson(response.data);
  }

  Future<BulkBatch> getBatchStatus(String batchId) async {
    final response = await _dio.get('/bulk-payments/batches/$batchId');
    return BulkBatch.fromJson(response.data);
  }

  Future<String> downloadFailedPayments(String batchId) async {
    final response =
        await _dio.get('/bulk-payments/batches/$batchId/failed-report');
    final data = response.data;
    if (data is Map) return data['csv'] as String? ?? '';
    return data?.toString() ?? '';
  }


  // === Stub methods ===
  Future<List<dynamic>> getBulkPayments() async => [];
  Future<List<Map<String, dynamic>>> parseCsvFile(String path) async => [];

}
