import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'e2e_encryption_service.dart';

/// Sensitivity classification for data payloads.
enum DataSensitivity { public, internal, confidential, restricted }

/// A secure channel for transmitting classified data.
///
/// Routes data through appropriate encryption based on sensitivity level.
class SecureDataChannel {
  static const _tag = 'SecureDataChannel';
  final AppLogger _log = AppLogger(_tag);
  final E2eEncryptionService _e2e;

  SecureDataChannel({required E2eEncryptionService e2eService})
      : _e2e = e2eService;

  /// Prepare a payload for transmission based on sensitivity.
  Map<String, dynamic> preparePayload({
    required Map<String, dynamic> data,
    required DataSensitivity sensitivity,
  }) {
    switch (sensitivity) {
      case DataSensitivity.public:
      case DataSensitivity.internal:
        return data;
      case DataSensitivity.confidential:
        return {
          'encrypted': _e2e.encrypt(jsonEncode(data)),
          'sensitivity': sensitivity.name,
          'v': 1,
        };
      case DataSensitivity.restricted:
        return {
          'encrypted': _e2e.encrypt(jsonEncode(data)),
          'sensitivity': sensitivity.name,
          'doubleEncrypt': true,
          'v': 1,
        };
    }
  }

  /// Receive and decrypt a payload.
  Map<String, dynamic> receivePayload(Map<String, dynamic> raw) {
    if (!raw.containsKey('encrypted')) return raw;
    final decrypted = _e2e.decrypt(raw['encrypted'] as String);
    return jsonDecode(decrypted) as Map<String, dynamic>;
  }
}

final secureDataChannelProvider = Provider<SecureDataChannel>((ref) {
  return SecureDataChannel(
    e2eService: ref.watch(e2eEncryptionServiceProvider),
  );
});
