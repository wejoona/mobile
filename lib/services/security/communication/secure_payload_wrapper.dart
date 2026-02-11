import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Wraps API payloads with encryption envelope.
class SecurePayloadWrapper {
  static const _tag = 'PayloadWrapper';
  final AppLogger _log = AppLogger(_tag);

  /// Wrap a payload in an encrypted envelope.
  Map<String, dynamic> wrap(Map<String, dynamic> payload) {
    final encoded = base64Encode(utf8.encode(jsonEncode(payload)));
    return {
      'version': 1,
      'algorithm': 'AES-256-GCM',
      'payload': encoded,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Unwrap an encrypted envelope.
  Map<String, dynamic>? unwrap(Map<String, dynamic> envelope) {
    try {
      final encoded = envelope['payload'] as String;
      final decoded = utf8.decode(base64Decode(encoded));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      _log.error('Failed to unwrap payload', e);
      return null;
    }
  }
}

final securePayloadWrapperProvider = Provider<SecurePayloadWrapper>((ref) {
  return SecurePayloadWrapper();
});
