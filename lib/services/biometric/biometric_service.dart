import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';

/// Biometric Types
enum BiometricType {
  fingerprint,
  faceId,
  iris,
  none,
}

/// Biometric Service
class BiometricService {
  final LocalAuthentication _auth;
  final FlutterSecureStorage _storage;

  BiometricService(this._auth, this._storage);

  /// Check if device supports biometrics
  Future<bool> isDeviceSupported() async {
    return _auth.isDeviceSupported();
  }

  /// Check if biometrics are available
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final available = await _auth.getAvailableBiometrics();
      return available.map((type) {
        if (type.name == 'fingerprint') {
          return BiometricType.fingerprint;
        } else if (type.name == 'face') {
          return BiometricType.faceId;
        } else if (type.name == 'iris') {
          return BiometricType.iris;
        }
        return BiometricType.none;
      }).toList();
    } on PlatformException {
      return [];
    }
  }

  /// Authenticate with biometrics
  /// [sensitiveAction] - If true, uses stricter options (biometric only, no device credential fallback)
  Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
    bool sensitiveAction = false,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          // SECURITY: For sensitive actions, prefer biometric only without fallback to device PIN
          biometricOnly: sensitiveAction,
          // SECURITY: stickyAuth keeps the authentication dialog active when app goes to background
          stickyAuth: true,
          // Allow device credentials (PIN/pattern) as fallback for non-sensitive operations
          useErrorDialogs: true,
        ),
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Authentication Required',
            cancelButton: 'Cancel',
            biometricHint: 'Verify your identity',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Please set up biometric authentication',
          ),
        ],
      );
    } on PlatformException catch (e) {
      // Log the error for debugging but don't expose details to caller
      // Common errors: NotAvailable, NotEnrolled, PasscodeNotSet
      print('Biometric authentication error: ${e.code}');
      return false;
    }
  }

  /// Authenticate for sensitive operations (transfers, PIN change, etc.)
  /// Uses stricter biometric-only authentication
  Future<bool> authenticateSensitive({
    String reason = 'Confirm your identity to proceed',
  }) async {
    return authenticate(reason: reason, sensitiveAction: true);
  }

  /// Check if biometric login is enabled
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: StorageKeys.biometricEnabled);
    return value == 'true';
  }

  /// Enable biometric login
  Future<void> enableBiometric() async {
    await _storage.write(key: StorageKeys.biometricEnabled, value: 'true');
  }

  /// Disable biometric login
  Future<void> disableBiometric() async {
    await _storage.write(key: StorageKeys.biometricEnabled, value: 'false');
  }

  /// Get biometric icon based on available types
  Future<BiometricType> getPrimaryBiometricType() async {
    final types = await getAvailableBiometrics();
    if (types.contains(BiometricType.faceId)) {
      return BiometricType.faceId;
    } else if (types.contains(BiometricType.fingerprint)) {
      return BiometricType.fingerprint;
    } else if (types.contains(BiometricType.iris)) {
      return BiometricType.iris;
    }
    return BiometricType.none;
  }
}

/// LocalAuthentication Provider
final localAuthProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

/// Biometric Service Provider
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService(
    ref.watch(localAuthProvider),
    ref.watch(secureStorageProvider),
  );
});

/// Biometric Available Provider
final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  final supported = await service.isDeviceSupported();
  final canCheck = await service.canCheckBiometrics();
  return supported && canCheck;
});

/// Biometric Enabled Provider
final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.isBiometricEnabled();
});

/// Primary Biometric Type Provider
final primaryBiometricTypeProvider = FutureProvider<BiometricType>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.getPrimaryBiometricType();
});
