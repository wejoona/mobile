import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/services/security/auth/mfa_provider.dart';

/// Gère l'inscription aux méthodes MFA disponibles.
class MfaEnrollmentManager {
  static const _tag = 'MfaEnrollment';
  final AppLogger _log = AppLogger(_tag);
  final MfaProvider _mfaProvider;

  MfaEnrollmentManager(this._mfaProvider);

  /// Initiate enrollment flow for the given method.
  Future<MfaEnrollmentResult> startEnrollment(MfaMethod method) async {
    _log.debug('Starting enrollment for $method');
    try {
      final success = await _mfaProvider.enroll(method);
      return success
          ? MfaEnrollmentResult.success(method)
          : MfaEnrollmentResult.failed(method, 'Enrollment rejected');
    } catch (e) {
      _log.error('Enrollment failed', e);
      return MfaEnrollmentResult.failed(method, e.toString());
    }
  }

  /// Verify enrollment with confirmation code.
  Future<bool> confirmEnrollment(MfaMethod method, String code) async {
    return _mfaProvider.verify(method, code);
  }

  /// Get available methods not yet enrolled.
  List<MfaMethod> availableMethods(List<MfaMethod> enrolled) {
    return MfaMethod.values.where((m) => !enrolled.contains(m)).toList();
  }
}

class MfaEnrollmentResult {
  final MfaMethod method;
  final bool success;
  final String? error;

  MfaEnrollmentResult.success(this.method) : success = true, error = null;
  MfaEnrollmentResult.failed(this.method, this.error) : success = false;
}

final mfaEnrollmentManagerProvider = Provider<MfaEnrollmentManager>((ref) {
  return MfaEnrollmentManager(ref.read(mfaProvider.notifier));
});
