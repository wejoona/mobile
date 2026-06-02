/// Transfers API — internal, external, history
library;

import 'package:dio/dio.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';

class TransfersApi {
  TransfersApi(this._dio);
  final Dio _dio;

  /// POST /transfers/internal
  Future<Response> sendInternal(
    Map<String, dynamic> data, {
    String? pinToken,
    String? idempotencyKey,
  }) => _dio.post(
    '/transfers/internal',
    data: data,
    options: _transferOptions(
      pinToken: pinToken,
      idempotencyKey: idempotencyKey,
    ),
  );

  /// POST /transfers/external
  Future<Response> sendExternal(
    Map<String, dynamic> data, {
    String? pinToken,
    String? idempotencyKey,
  }) => _dio.post(
    '/transfers/external',
    data: data,
    options: _transferOptions(
      pinToken: pinToken,
      idempotencyKey: idempotencyKey,
    ),
  );

  /// GET /transfers — list transfer history
  Future<Response> list({int? page, int? limit}) => _dio.get(
    '/transfers',
    queryParameters: {
      if (limit != null) 'limit': limit,
      if (page != null && limit != null)
        'offset': (page - 1).clamp(0, 1 << 31) * limit,
    },
  );

  /// GET /transfers/:id
  Future<Response> getById(String id) => _dio.get('/transfers/$id');

  Options _transferOptions({String? pinToken, String? idempotencyKey}) {
    if (pinToken == null || pinToken.isEmpty) {
      return Options(
        headers: {
          'X-Idempotency-Key': idempotencyKey ?? generateIdempotencyKey(),
        },
      );
    }

    return Options(
      headers: transactionHeaders(
        pinToken: pinToken,
        idempotencyKey: idempotencyKey,
      ),
    );
  }
}
