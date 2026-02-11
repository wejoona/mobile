import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Service de vérification par SMS.
class SmsVerificationService {
  static const _tag = 'SmsVerify';
  final AppLogger _log = AppLogger(_tag);
  final Duration _cooldown = const Duration(seconds: 60);
  DateTime? _lastSent;

  /// Send verification SMS.
  Future<bool> sendCode(String phoneNumber) async {
    if (_lastSent != null &&
        DateTime.now().difference(_lastSent!) < _cooldown) {
      _log.warn('SMS cooldown active');
      return false;
    }
    _log.debug('Sending SMS to ${phoneNumber.substring(0, 4)}***');
    _lastSent = DateTime.now();
    return true;
  }

  /// Verify the received code.
  Future<bool> verifyCode(String phoneNumber, String code) async {
    _log.debug('Verifying SMS code');
    // Would verify via backend
    return code.length == 6;
  }

  Duration get cooldownRemaining {
    if (_lastSent == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_lastSent!);
    return elapsed >= _cooldown ? Duration.zero : _cooldown - elapsed;
  }
}

final smsVerificationServiceProvider = Provider<SmsVerificationService>((ref) {
  return SmsVerificationService();
});
