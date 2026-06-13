import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/security/auth/mfa_provider.dart';
import 'package:usdc_wallet/services/security/auth/step_up_auth_service.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Coordonne les flux d'authentification renforcée.
enum StepUpReason { highValueTransfer, settingsChange, export, withdrawal }

class StepUpAuthCoordinator {
  StepUpAuthCoordinator(this._stepUp);

  static const _tag = 'StepUpCoord';
  final AppLogger _log = const AppLogger(_tag);
  final StepUpAuthService _stepUp;

  /// Determine required auth level for action.
  MfaMethod requiredMethod(StepUpReason reason) {
    switch (reason) {
      case StepUpReason.highValueTransfer:
      case StepUpReason.withdrawal:
      case StepUpReason.settingsChange:
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

final stepUpAuthCoordinatorProvider = Provider<StepUpAuthCoordinator>(
  (ref) => StepUpAuthCoordinator(ref.read(stepUpAuthServiceProvider)),
);
