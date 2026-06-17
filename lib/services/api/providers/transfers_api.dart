/// Transfers API — internal, external, history
library;

import 'package:dio/dio.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/core/utils/idempotency.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

class TransfersApi {
  TransfersApi(this._dio);
  final Dio _dio;

  /// POST /wallet/transfer/internal
  Future<Response> sendInternal(
    Map<String, dynamic> data, {
    String? pinToken,
    String? idempotencyKey,
  }) => _dio.post(
    ApiEndpoints.transfersSend,
    data: _internalTransferPayload(data),
    options: _transferOptions(
      pinToken: pinToken,
      idempotencyKey: idempotencyKey,
    ),
  );

  /// POST /wallet/transfer/external
  Future<Response> sendExternal(
    Map<String, dynamic> data, {
    String? pinToken,
    String? idempotencyKey,
  }) => _dio.post(
    ApiEndpoints.transfersExternal,
    data: _externalTransferPayload(data),
    options: _transferOptions(
      pinToken: pinToken,
      idempotencyKey: idempotencyKey,
    ),
  );

  /// GET /wallet/transactions — list canonical money-movement history.
  Future<Response> list({int? page, int? limit}) => _dio.get(
    ApiEndpoints.walletTransactions,
    queryParameters: {
      if (limit != null) 'limit': limit,
      if (page != null && limit != null)
        'offset': (page - 1).clamp(0, 1 << 31) * limit,
    },
  );

  /// GET /wallet/transactions/:id
  Future<Response> getById(String id) =>
      _dio.get(ApiEndpoints.walletTransactionById(id));

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

Map<String, dynamic> _internalTransferPayload(Map<String, dynamic> data) {
  final payload = Map<String, dynamic>.from(data);
  final recipientId = _stringValue(payload.remove('recipientId'));
  final recipientUsername = _normalizeUsername(
    _stringValue(payload.remove('recipientUsername')),
  );
  final recipientPhone = payload.remove('recipientPhone');
  final toPhone = payload.remove('toPhone') ?? recipientPhone;

  if (recipientId != null && recipientId.isNotEmpty) {
    payload['recipientId'] = recipientId;
  } else if (recipientUsername != null && recipientUsername.isNotEmpty) {
    payload['recipientUsername'] = recipientUsername;
  } else {
    final normalizedPhone = PhoneNumberValue.tryFromAny(
      phoneNumber: _stringValue(toPhone),
    )?.e164;
    if (normalizedPhone != null && normalizedPhone.isNotEmpty) {
      payload['toPhone'] = normalizedPhone;
    }
  }

  return payload;
}

Map<String, dynamic> _externalTransferPayload(Map<String, dynamic> data) {
  final payload = Map<String, dynamic>.from(data);
  final recipientAddress = payload.remove('recipientAddress');
  payload['toAddress'] = payload['toAddress'] ?? recipientAddress;
  return payload;
}

String? _stringValue(Object? value) {
  final string = value?.toString().trim();
  return string == null || string.isEmpty ? null : string;
}

String? _normalizeUsername(String? username) {
  if (username == null || username.isEmpty) {
    return null;
  }

  final withoutPrefix = username.startsWith('@')
      ? username.substring(1)
      : username;
  return withoutPrefix.toLowerCase();
}
