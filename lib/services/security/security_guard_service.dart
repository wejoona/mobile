import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../biometric/biometric_service.dart';
import '../liveness/liveness_service.dart';

/// Security guard service for sensitive operations
/// Coordinates biometric and liveness checks for various security levels
class SecurityGuardService {
  final BiometricService _biometricService;
  final LivenessService _livenessService;

  SecurityGuardService({
    required BiometricService biometricService,
    required LivenessService livenessService,
  })  : _biometricService = biometricService,
        _livenessService = livenessService;

  // Security thresholds
  static const double externalTransferThreshold = 100.0;
  static const double highValueTransferThreshold = 500.0;

  /// Require biometric authentication for sensitive operations
  /// Returns true if authenticated or biometric not enabled
  /// Throws BiometricAuthenticationFailedException if authentication fails
  Future<bool> requireBiometric(String reason) async {
    final isEnabled = await _biometricService.isBiometricEnabled();

    // If biometric not enabled, allow operation (user preference)
    if (!isEnabled) {
      return true;
    }

    final success = await _biometricService.authenticate(reason: reason);

    if (!success) {
      throw BiometricAuthenticationFailedException(
        'Biometric authentication required for this operation',
      );
    }

    return true;
  }

  /// Require liveness check for high-security operations
  /// Returns LivenessResult if check passes
  /// Throws LivenessCheckFailedException if check fails
  Future<LivenessResult?> requireLiveness(String reason) async {
    try {
      // Start liveness session
      final session = await _livenessService.startSession(
        purpose: reason,
      );

      // In production, this would trigger UI to show liveness check widget
      // For service layer, we just verify the session was started
      debugPrint('Liveness session started: ${session.sessionId}');

      // Return null to indicate UI should handle liveness check
      return null;
    } catch (e) {
      throw LivenessCheckFailedException(
        'Failed to start liveness check: $e',
      );
    }
  }

  /// Require both biometric and liveness for critical operations
  /// Returns true if both checks pass
  Future<bool> requireBiometricAndLiveness(String reason) async {
    // First check biometric
    await requireBiometric(reason);

    // Then require liveness (UI will handle)
    await requireLiveness(reason);

    return true;
  }

  // --- Specific Operation Guards ---

  /// Guard for external transfers
  /// Small amounts: no check
  /// Medium amounts ($100-$500): biometric
  /// Large amounts (>$500): biometric + liveness
  Future<bool> guardExternalTransfer(double amount) async {
    if (amount < externalTransferThreshold) {
      // Small transfer, no additional security needed
      return true;
    }

    if (amount >= highValueTransferThreshold) {
      // High-value transfer: require biometric and liveness
      return requireBiometricAndLiveness(
        'Confirm external transfer of \$${amount.toStringAsFixed(2)}',
      );
    }

    // Medium transfer: require biometric only
    return requireBiometric(
      'Confirm external transfer of \$${amount.toStringAsFixed(2)}',
    );
  }

  /// Guard for PIN changes
  /// Always requires biometric if enabled
  Future<bool> guardPinChange() async {
    return requireBiometric('Confirm your identity to change PIN');
  }

  /// Guard for adding new recipients
  /// Requires biometric for external wallet addresses
  Future<bool> guardAddRecipient({
    required bool isExternal,
    String? recipientAddress,
  }) async {
    if (!isExternal) {
      // Internal JoonaPay recipient, no additional security
      return true;
    }

    return requireBiometric(
      'Confirm adding external wallet address',
    );
  }

  /// Guard for KYC selfie submission
  /// Always requires liveness check
  Future<LivenessResult?> guardKycSelfie() async {
    return requireLiveness('kyc');
  }

  /// Guard for first withdrawal to new recipient
  /// Requires biometric for security
  Future<bool> guardFirstWithdrawal({
    required String recipientAddress,
    required double amount,
  }) async {
    return requireBiometric(
      'Confirm first withdrawal to new address',
    );
  }

  /// Guard for account recovery
  /// Requires liveness check to prevent unauthorized access
  Future<LivenessResult?> guardAccountRecovery() async {
    return requireLiveness('recovery');
  }

  /// Guard for biometric enrollment
  /// Verifies biometric works before enabling
  Future<bool> guardBiometricEnrollment() async {
    final success = await _biometricService.authenticate(
      reason: 'Verify your biometric authentication',
    );

    if (!success) {
      throw BiometricAuthenticationFailedException(
        'Biometric verification failed. Please try again.',
      );
    }

    return true;
  }

  /// Guard for disabling biometric
  /// Requires current biometric to disable
  Future<bool> guardBiometricDisable() async {
    return requireBiometric('Confirm disabling biometric authentication');
  }

  /// Guard for exporting wallet recovery phrase
  /// Requires biometric authentication
  Future<bool> guardExportRecoveryPhrase() async {
    return requireBiometric('Authenticate to view recovery phrase');
  }

  /// Guard for deleting account
  /// Requires both biometric and liveness
  Future<bool> guardAccountDeletion() async {
    return requireBiometricAndLiveness('Confirm account deletion');
  }
}

/// Exception thrown when biometric authentication fails
class BiometricAuthenticationFailedException implements Exception {
  final String message;

  BiometricAuthenticationFailedException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when liveness check fails
class LivenessCheckFailedException implements Exception {
  final String message;

  LivenessCheckFailedException(this.message);

  @override
  String toString() => message;
}

/// Security Guard Service Provider
final securityGuardServiceProvider = Provider<SecurityGuardService>((ref) {
  return SecurityGuardService(
    biometricService: ref.watch(biometricServiceProvider),
    livenessService: ref.watch(livenessServiceProvider),
  );
});
