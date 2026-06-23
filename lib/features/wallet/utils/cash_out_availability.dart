import 'package:dio/dio.dart';

const cashOutUnavailableMessage =
    'Mobile money withdrawals are not available yet. We can notify you when this rail is ready.';

class CashOutUnavailableException implements Exception {
  const CashOutUnavailableException([this.message = cashOutUnavailableMessage]);

  final String message;

  @override
  String toString() => message;
}

bool isCashOutUnavailableError(Object error) {
  if (error is! DioException) {
    return false;
  }
  final statusCode = error.response?.statusCode;
  if (statusCode == 404 || statusCode == 501) {
    return true;
  }
  if (statusCode != 503) {
    return false;
  }

  final data = error.response?.data;
  if (data is Map) {
    final reason = data['reason']?.toString();
    final featureReason = data['featureReason']?.toString();
    return reason == 'provider_not_implemented' ||
        featureReason == 'payout_provider_not_connected';
  }

  return false;
}
