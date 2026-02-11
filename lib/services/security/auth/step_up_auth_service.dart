import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/services/security/auth/mfa_provider.dart';

/// Actions requiring step-up authentication.
enum StepUpAction {
  largeTransfer,
  withdrawal,
  pinChange,
  deviceAdd,
  exportData,
  changePhone,
  changeMfa,
}

/// Result of a step-up auth attempt.
class StepUpResult {
  final bool authorized;
  final MfaMethod? methodUsed;
  final DateTime? authorizedAt;
  final String? failureReason;

  const StepUpResult({
    required this.authorized,
    this.methodUsed,
    this.authorizedAt,
    this.failureReason,
  });
}

/// Manages step-up authentication for sensitive operations.
///
/// When a user attempts a high-risk action, this service determines
/// which additional verification is needed and tracks authorization.
class StepUpAuthService {
  static const _tag = 'StepUpAuth';
  final AppLogger _log = AppLogger(_tag);

  final MfaProvider _mfaProvider;

  /// Cached step-up authorizations with expiry.
  final Map<StepUpAction, DateTime> _authorizations = {};

  StepUpAuthService({required MfaProvider mfaProvider})
      : _mfaProvider = mfaProvider;

  /// Check if a step-up auth is needed for the given action.
  bool requiresStepUp(StepUpAction action) {
    final expiry = _authorizations[action];
    if (expiry != null && DateTime.now().isBefore(expiry)) {
      return false;
    }
    return true;
  }

  /// Determine which MFA method to use for the action.
  MfaMethod recommendedMethod(StepUpAction action) {
    final enrolled = _mfaProvider.state.enrolledMethods;
    if (enrolled.contains(MfaMethod.biometric)) return MfaMethod.biometric;
    if (enrolled.contains(MfaMethod.totp)) return MfaMethod.totp;
    return MfaMethod.sms;
  }

  /// Record a successful step-up authorization.
  void recordAuthorization(StepUpAction action, {Duration? validity}) {
    final duration = validity ?? _defaultValidity(action);
    _authorizations[action] = DateTime.now().add(duration);
    _log.debug('Step-up authorized: $action for ${duration.inMinutes}m');
  }

  /// Request step-up auth by method name. Returns true if authorized.
  Future<bool> requestStepUp(String methodName) async {
    _log.debug('Requesting step-up auth via $methodName');
    // In production, trigger actual MFA flow
    return true;
  }

  /// Clear all step-up authorizations (e.g. on logout).
  void clearAll() {
    _authorizations.clear();
  }

  Duration _defaultValidity(StepUpAction action) {
    switch (action) {
      case StepUpAction.largeTransfer:
      case StepUpAction.withdrawal:
        return const Duration(minutes: 5);
      case StepUpAction.pinChange:
      case StepUpAction.changeMfa:
      case StepUpAction.changePhone:
        return const Duration(minutes: 2);
      case StepUpAction.deviceAdd:
      case StepUpAction.exportData:
        return const Duration(minutes: 10);
    }
  }
}

final stepUpAuthServiceProvider = Provider<StepUpAuthService>((ref) {
  return StepUpAuthService(
    mfaProvider: ref.watch(mfaProvider.notifier),
  );
});
