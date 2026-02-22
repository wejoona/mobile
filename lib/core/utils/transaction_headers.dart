import 'package:usdc_wallet/core/utils/idempotency.dart';

/// Build the required headers for a money-movement API call.
/// [pinToken] — from PIN verification (required by backend PinVerificationGuard).
/// [idempotencyKey] — UUID v4 generated once per user action (required by backend IdempotencyGuard).
Map<String, String> transactionHeaders({
  required String pinToken,
  String? idempotencyKey,
}) {
  return {
    'X-Pin-Token': pinToken,
    'X-Idempotency-Key': idempotencyKey ?? generateIdempotencyKey(),
  };
}
