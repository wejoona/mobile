import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Manages periodic rotation of credentials and tokens.
class CredentialRotationService {
  static const _tag = 'CredRotation';
  final AppLogger _log = AppLogger(_tag);
  DateTime? _lastRotation;
  final Duration rotationInterval;

  CredentialRotationService({
    this.rotationInterval = const Duration(days: 30),
  });

  bool get needsRotation {
    if (_lastRotation == null) return true;
    return DateTime.now().difference(_lastRotation!) > rotationInterval;
  }

  Future<bool> rotateApiKey() async {
    _log.debug('Rotating API key');
    _lastRotation = DateTime.now();
    return true;
  }

  Future<bool> rotateRefreshToken() async {
    _log.debug('Rotating refresh token');
    return true;
  }

  DateTime? get lastRotation => _lastRotation;
}

final credentialRotationServiceProvider = Provider<CredentialRotationService>((ref) {
  return CredentialRotationService();
});
