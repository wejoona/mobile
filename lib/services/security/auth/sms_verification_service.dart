import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Service de vérification par SMS.
class SmsVerificationService {
  static const _tag = 'SmsVerify';
  final AppLogger _log = const AppLogger(_tag);
  final Duration _cooldown = const Duration(seconds: 60);
  DateTime? _lastSent;

  /// Send verification SMS.
  Future<bool> sendCode(String phoneNumber) async {
    if (_lastSent != null &&
        DateTime.now().difference(_lastSent!) < _cooldown) {
      _log.warn('SMS cooldown active');
      return false;
    }
    _log.security(
      'Rejected local SMS verification send; use Korido API or step-up OTP endpoints',
      level: 'WARN',
    );
    _lastSent = DateTime.now();
    return false;
  }

  /// Verify the received code.
  Future<bool> verifyCode(String phoneNumber, String code) async {
    _log.security(
      'Rejected local SMS verification check; use Korido API or step-up OTP endpoints',
      level: 'WARN',
    );
    return false;
  }

  Duration get cooldownRemaining {
    if (_lastSent == null) {
      return Duration.zero;
    }
    final elapsed = DateTime.now().difference(_lastSent!);
    return elapsed >= _cooldown ? Duration.zero : _cooldown - elapsed;
  }
}

final smsVerificationServiceProvider = Provider<SmsVerificationService>(
  (ref) => SmsVerificationService(),
);
