import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Manages backup recovery codes for MFA.
class RecoveryCodeService {
  static const _tag = 'RecoveryCodes';
  final AppLogger _log = AppLogger(_tag);
  final Random _random = Random.secure();
  final Set<String> _usedCodes = {};

  /// Generate a set of recovery codes.
  List<String> generateCodes({int count = 10}) {
    _log.debug('Generating $count recovery codes');
    return List.generate(count, (_) => _generateCode());
  }

  String _generateCode() {
    final chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return List.generate(8, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  /// Verify and consume a recovery code.
  bool verifyAndConsume(String code, List<String> validCodes) {
    if (_usedCodes.contains(code)) return false;
    if (!validCodes.contains(code)) return false;
    _usedCodes.add(code);
    _log.debug('Recovery code consumed');
    return true;
  }

  int remainingCodes(List<String> allCodes) {
    return allCodes.where((c) => !_usedCodes.contains(c)).length;
  }
}

final recoveryCodeServiceProvider = Provider<RecoveryCodeService>((ref) {
  return RecoveryCodeService();
});
