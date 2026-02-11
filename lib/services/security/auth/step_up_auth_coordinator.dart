import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';
import 'mfa_provider.dart';
import 'step_up_auth_service.dart';

/// Coordonne les flux d'authentification renforcée.
enum StepUpReason { highValueTransfer, settingsChange, export, withdrawal }

class StepUpAuthCoordinator {
  static const _tag = 'StepUpCoord';
  final AppLogger _log = AppLogger(_tag);
  final StepUpAuthService _stepUp;

  StepUpAuthCoordinator(this._stepUp);

  /// Determine required auth level for action.
  MfaMethod requiredMethod(StepUpReason reason) {
    switch (reason) {
      case StepUpReason.highValueTransfer:
      case StepUpReason.withdrawal:
        return MfaMethod.biometric;
      case StepUpReason.settingsChange:
        return MfaMethod.totp;
      case StepUpReason.export:
        return MfaMethod.biometric;
    }
  }

  /// Execute step-up flow and return success.
  Future<bool> executeStepUp(StepUpReason reason) async {
    final method = requiredMethod(reason);
    _log.debug('Step-up auth: $reason requires $method');
    return _stepUp.requestStepUp(method.name);
  }
}

final stepUpAuthCoordinatorProvider = Provider<StepUpAuthCoordinator>((ref) {
  return StepUpAuthCoordinator(ref.read(stepUpAuthServiceProvider));
});
