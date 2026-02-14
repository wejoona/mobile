import 'package:dio/dio.dart';
import 'package:usdc_wallet/features/bulk_payments/models/bulk_batch.dart';

class BulkPaymentsService {
  final Dio _dio;

  BulkPaymentsService(this._dio);

  Future<List<BulkBatch>> getBatches() async {
    final response = await _dio.get('/bulk-payments/batches');
    // ignore: avoid_dynamic_calls
    return (response.data['batches'] as List)
        .map((json) => BulkBatch.fromJson(json))
        .toList();
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
    // ignore: avoid_dynamic_calls
    return response.data['csv'] as String;
  }


  // === Stub methods ===
  Future<List<dynamic>> getBulkPayments() async => [];
  Future<List<Map<String, dynamic>>> parseCsvFile(String path) async => [];

}
