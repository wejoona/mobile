/// Recurring Transfers API — CRUD, pause, resume
library;

import 'package:dio/dio.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';

class RecurringTransfersApi {
  RecurringTransfersApi(this._dio);
  final Dio _dio;

  /// GET /recurring-transfers
  Future<Response> list() => _dio.get('/recurring-transfers');

  /// POST /recurring-transfers
  Future<Response> create(
    Map<String, dynamic> data, {
    required String pinToken,
    required String idempotencyKey,
  }) => _dio.post(
    '/recurring-transfers',
    data: data,
    options: Options(
      headers: transactionHeaders(
        pinToken: pinToken,
        idempotencyKey: idempotencyKey,
      ),
    ),
  );

  /// GET /recurring-transfers/:id
  Future<Response> getById(String id) => _dio.get('/recurring-transfers/$id');

  /// DELETE /recurring-transfers/:id
  Future<Response> delete(String id) => _dio.delete('/recurring-transfers/$id');

  /// POST /recurring-transfers/:id/pause
  Future<Response> pause(String id) =>
      _dio.post('/recurring-transfers/$id/pause');

  /// POST /recurring-transfers/:id/resume
  Future<Response> resume(String id) =>
      _dio.post('/recurring-transfers/$id/resume');
}
