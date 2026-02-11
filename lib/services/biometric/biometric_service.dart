import 'dart:async';

export 'package:usdc_wallet/services/biometric/biometric_provider.dart';

/// Run 372: Biometric authentication service
enum BiometricType { fingerprint, faceId, iris, none }

class BiometricResult {
  final bool success;
  final String? errorMessage;
  final BiometricFailureReason? failureReason;

  const BiometricResult({
    required this.success,
    this.errorMessage,
    this.failureReason,
  });

  const BiometricResult.success() : this(success: true);
  const BiometricResult.failure(String message, {BiometricFailureReason? reason})
      : this(success: false, errorMessage: message, failureReason: reason);
}

enum BiometricFailureReason {
  notAvailable,
  notEnrolled,
  lockedOut,
  cancelled,
  unknown,
}

class BiometricService {
  Future<bool> isAvailable() async {
    // Check if device supports biometric authentication
    return true;
  }

  Future<BiometricType> getAvailableType() async {
    // Determine which biometric type is available
    return BiometricType.fingerprint;
  }

  Future<bool> isEnrolled() async {
    // Check if user has enrolled biometric authentication
    return false;
  }

  Future<BiometricResult> authenticate({
    String localizedReason = 'Authentifiez-vous pour continuer',
    bool stickyAuth = true,
  }) async {
    try {
      // Platform-specific biometric authentication
      await Future.delayed(const Duration(milliseconds: 500));
      return const BiometricResult.success();
    } catch (e) {
      return BiometricResult.failure(
        'Echec de l\'authentification biometrique',
        reason: BiometricFailureReason.unknown,
      );
    }
  }

  Future<void> enroll() async {
    // Enable biometric for this account
  }

  Future<void> unenroll() async {
    // Disable biometric for this account
  }

  /// Check if biometric authentication is enabled for this user
  Future<bool> isBiometricEnabled() async {
    return isEnrolled();
  }

  /// Get list of available biometric types on this device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    final type = await getAvailableType();
    if (type == BiometricType.none) return [];
    return [type];
  }

  /// Check if the device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    return isAvailable();
  }

  /// Check if the device can check biometrics (alias for isAvailable)
  Future<bool> canCheckBiometrics() async {
    return isAvailable();
  }

  /// Get the primary biometric type available on this device
  Future<BiometricType> getPrimaryBiometricType() async {
    return getAvailableType();
  }

  /// Enable biometric authentication for this user.
  Future<void> enableBiometric() async {
    // TODO: persist preference
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Disable biometric authentication for this user.
  Future<void> disableBiometric() async {
    // TODO: persist preference
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Authenticate for sensitive operations (higher security level).
  Future<BiometricResult> authenticateSensitive({
    String localizedReason = 'Vérification de sécurité requise',
  }) async {
    return authenticate(localizedReason: localizedReason);
  }

  Future<BiometricResult> guardPinChange() async => authenticate(localizedReason: 'Vérifiez votre identité pour changer le PIN');

}
