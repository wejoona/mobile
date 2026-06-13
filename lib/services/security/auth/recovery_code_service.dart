import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Manages backup recovery codes for MFA.
class RecoveryCodeService {
  static const _tag = 'RecoveryCodes';
  final AppLogger _log = const AppLogger(_tag);
  final Set<String> _usedCodes = {};

  /// Generate a set of recovery codes.
  List<String> generateCodes({int count = 10}) {
    _log.security(
      'Rejected local recovery-code generation; MFA recovery codes must be backend-issued',
      level: 'WARN',
    );
    return const [];
  }

  /// Verify and consume a recovery code.
  bool verifyAndConsume(String code, List<String> validCodes) {
    if (_usedCodes.contains(code)) {
      return false;
    }
    if (!validCodes.contains(code)) {
      return false;
    }
    _usedCodes.add(code);
    _log.debug('Recovery code consumed');
    return true;
  }

  int remainingCodes(List<String> allCodes) =>
      allCodes.where((c) => !_usedCodes.contains(c)).length;
}

final recoveryCodeServiceProvider = Provider<RecoveryCodeService>(
  (ref) => RecoveryCodeService(),
);
