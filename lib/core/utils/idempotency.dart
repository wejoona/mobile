import 'package:uuid/uuid.dart';

/// Generate a UUID v4 idempotency key for transaction requests.
/// IMPORTANT: Generate once per user action, reuse on retries.
String generateIdempotencyKey() => const Uuid().v4();
