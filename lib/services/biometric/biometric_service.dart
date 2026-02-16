import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth_platform_interface/types/biometric_type.dart' as platform;

export 'package:usdc_wallet/services/biometric/biometric_provider.dart';

const _kBiometricEnabledKey = 'biometric_enabled';

/// App-level biometric types
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
  static const _storage = FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> isAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Determine which biometric type is available (Face ID, Touch ID, etc.)
  Future<BiometricType> getAvailableType() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();

      if (biometrics.contains(platform.BiometricType.face)) {
        return BiometricType.faceId;
      }
      if (biometrics.contains(platform.BiometricType.fingerprint)) {
        return BiometricType.fingerprint;
      }
      if (biometrics.contains(platform.BiometricType.iris)) {
        return BiometricType.iris;
      }
      // strong/weak = device has some biometric
      if (biometrics.contains(platform.BiometricType.strong) ||
          biometrics.contains(platform.BiometricType.weak)) {
        return BiometricType.fingerprint; // generic fallback
      }

      return BiometricType.none;
    } catch (_) {
      return BiometricType.none;
    }
  }

  Future<bool> isEnrolled() async {
    final value = await _storage.read(key: _kBiometricEnabledKey);
    return value == 'true';
  }

  /// Authenticate using device biometric (Face ID / Touch ID / fingerprint).
  /// The OS decides which biometric to use — we just request authentication.
  Future<BiometricResult> authenticate({
    String localizedReason = 'Authentifiez-vous pour continuer',
    bool stickyAuth = true,
  }) async {
    try {
      final available = await isAvailable();
      if (!available) {
        return const BiometricResult.failure(
          'Authentification biométrique non disponible',
          reason: BiometricFailureReason.notAvailable,
        );
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      if (didAuthenticate) {
        return const BiometricResult.success();
      } else {
        return const BiometricResult.failure(
          'Authentification annulée',
          reason: BiometricFailureReason.cancelled,
        );
      }
    } on Exception catch (e) {
      final message = e.toString();

      if (message.contains(auth_error.notAvailable) ||
          message.contains(auth_error.notEnrolled)) {
        return const BiometricResult.failure(
          'Biométrie non configurée sur cet appareil',
          reason: BiometricFailureReason.notEnrolled,
        );
      }

      if (message.contains(auth_error.lockedOut) ||
          message.contains(auth_error.permanentlyLockedOut)) {
        return const BiometricResult.failure(
          'Biométrie verrouillée. Utilisez votre code d\'accès.',
          reason: BiometricFailureReason.lockedOut,
        );
      }

      return const BiometricResult.failure(
        'Échec de l\'authentification biométrique',
        reason: BiometricFailureReason.unknown,
      );
    }
  }

  Future<void> enroll() async {
    await _storage.write(key: _kBiometricEnabledKey, value: 'true');
  }

  Future<void> unenroll() async {
    await _storage.write(key: _kBiometricEnabledKey, value: 'false');
  }

  Future<bool> isBiometricEnabled() async => isEnrolled();

  Future<List<BiometricType>> getAvailableBiometrics() async {
    final type = await getAvailableType();
    if (type == BiometricType.none) return [];
    return [type];
  }

  Future<bool> isDeviceSupported() async => isAvailable();
  Future<bool> canCheckBiometrics() async => isAvailable();
  Future<BiometricType> getPrimaryBiometricType() async => getAvailableType();

  Future<void> enableBiometric() async {
    await _storage.write(key: _kBiometricEnabledKey, value: 'true');
  }

  Future<void> disableBiometric() async {
    await _storage.write(key: _kBiometricEnabledKey, value: 'false');
  }

  Future<BiometricResult> authenticateSensitive({
    String localizedReason = 'Vérification de sécurité requise',
  }) async {
    return authenticate(localizedReason: localizedReason);
  }

  Future<BiometricResult> guardPinChange() async =>
      authenticate(localizedReason: 'Vérifiez votre identité pour changer le PIN');
}
