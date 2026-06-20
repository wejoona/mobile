import 'package:usdc_wallet/core/utils/idempotency.dart';

/// Build the required headers for a money-movement API call.
/// [pinToken] — from PIN verification (required by backend PinVerificationGuard).
/// [idempotencyKey] — UUID v4 generated once per user action (required by backend IdempotencyGuard).
/// [stepUpToken] — completed challenge token for backend RiskAssessmentGuard.
Map<String, String> transactionHeaders({
  required String pinToken,
  String? idempotencyKey,
  String? stepUpToken,
}) {
  return {
    'X-Pin-Token': pinToken,
    'X-Idempotency-Key': idempotencyKey ?? generateIdempotencyKey(),
    if (stepUpToken != null && stepUpToken.isNotEmpty)
      'X-Step-Up-Token': stepUpToken,
  };
}
