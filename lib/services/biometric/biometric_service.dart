import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_platform_interface/types/auth_exception.dart';
import 'package:local_auth_platform_interface/types/auth_messages.dart';
import 'package:local_auth_platform_interface/types/biometric_type.dart'
    as platform;

export 'package:usdc_wallet/services/biometric/biometric_provider.dart';

const _kBiometricEnabledKey = 'biometric_enabled';
const _kBiometricUserIdKey = 'biometric_user_id';
const _kBiometricPhoneKey = 'biometric_phone';
const _kStoredUserIdKey = 'user_id';

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
  const BiometricResult.failure(
    String message, {
    BiometricFailureReason? reason,
  }) : this(success: false, errorMessage: message, failureReason: reason);
}

enum BiometricFailureReason {
  notAvailable,
  notEnrolled,
  lockedOut,
  cancelled,
  unknown,
}

class BiometricService {
  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  BiometricService([
    LocalAuthentication? localAuth,
    FlutterSecureStorage? storage,
  ]) : _localAuth = localAuth ?? LocalAuthentication(),
       _storage = storage ?? const FlutterSecureStorage();

  /// Check if device supports biometric authentication
  Future<bool> isAvailable() async {
    try {
      if (await _localAuth.canCheckBiometrics) return true;
      return await _localAuth.isDeviceSupported();
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

  Future<bool> isEnrolled({String? userId}) async {
    final value = await _storage.read(key: _kBiometricEnabledKey);
    if (value != 'true') return false;

    final boundUserId = await _storage.read(key: _kBiometricUserIdKey);
    if (boundUserId == null || boundUserId.isEmpty) return false;

    final expectedUserId =
        userId ?? await _storage.read(key: _kStoredUserIdKey);
    if (expectedUserId == null || expectedUserId.isEmpty) return false;

    return boundUserId == expectedUserId;
  }

  Future<String?> getBoundUserId() async {
    final value = await _storage.read(key: _kBiometricEnabledKey);
    if (value != 'true') return null;

    final boundUserId = await _storage.read(key: _kBiometricUserIdKey);
    final normalized = boundUserId?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  /// Authenticate using device biometric (Face ID / Touch ID / fingerprint).
  /// The OS decides which biometric to use — we just request authentication.
  Future<BiometricResult> authenticate({
    String? reason,
    String localizedReason = 'Authentifiez-vous pour continuer',
    bool stickyAuth = true,
  }) async {
    try {
      final authenticationReason = reason ?? localizedReason;
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: authenticationReason,
        authMessages: const <AuthMessages>[],
        biometricOnly: true,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: stickyAuth,
      );

      if (didAuthenticate) {
        return const BiometricResult.success();
      } else {
        return const BiometricResult.failure(
          'Authentification annulée',
          reason: BiometricFailureReason.cancelled,
        );
      }
    } on LocalAuthException catch (e) {
      if (e.code == LocalAuthExceptionCode.noBiometricHardware ||
          e.code == LocalAuthExceptionCode.noBiometricsEnrolled ||
          e.code == LocalAuthExceptionCode.noCredentialsSet) {
        return const BiometricResult.failure(
          'Biométrie non configurée sur cet appareil',
          reason: BiometricFailureReason.notEnrolled,
        );
      }

      if (e.code == LocalAuthExceptionCode.temporaryLockout ||
          e.code == LocalAuthExceptionCode.biometricLockout) {
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

  Future<void> enroll({required String userId, String? phone}) async {
    await enableBiometric(userId: userId, phone: phone);
  }

  Future<void> unenroll() async {
    await disableBiometric();
  }

  Future<void> enableBiometric({required String userId, String? phone}) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'Cannot bind biometric');
    }
    await _storage.write(key: _kBiometricEnabledKey, value: 'true');
    await _storage.write(key: _kBiometricUserIdKey, value: normalizedUserId);
    if (phone != null && phone.trim().isNotEmpty) {
      await _storage.write(key: _kBiometricPhoneKey, value: phone.trim());
    }
  }

  Future<bool> isBiometricEnabled({String? userId}) async =>
      isEnrolled(userId: userId);

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      final types = <BiometricType>[];

      for (final biometric in biometrics) {
        final type = switch (biometric) {
          platform.BiometricType.face => BiometricType.faceId,
          platform.BiometricType.fingerprint => BiometricType.fingerprint,
          platform.BiometricType.iris => BiometricType.iris,
          platform.BiometricType.strong ||
          platform.BiometricType.weak => BiometricType.fingerprint,
        };

        if (!types.contains(type)) {
          types.add(type);
        }
      }

      return types.toSet().toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<BiometricType> getPrimaryBiometricType() async => getAvailableType();

  Future<void> disableBiometric() async {
    await _storage.write(key: _kBiometricEnabledKey, value: 'false');
    await _storage.delete(key: _kBiometricUserIdKey);
    await _storage.delete(key: _kBiometricPhoneKey);
  }

  Future<BiometricResult> authenticateSensitive({
    String localizedReason = 'Vérification de sécurité requise',
  }) async {
    return authenticate(localizedReason: localizedReason);
  }

  Future<BiometricResult> guardPinChange() async => authenticate(
    localizedReason: 'Vérifiez votre identité pour changer le PIN',
  );
}
