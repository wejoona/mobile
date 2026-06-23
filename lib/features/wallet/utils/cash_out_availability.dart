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
  return statusCode == 404 || statusCode == 501;
}
