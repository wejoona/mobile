import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../../utils/logger.dart';

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

  static const _keyDeviceBiometricHash = 'device_biometric_hash';
  static const _keyLastBiometricCheck = 'last_biometric_check';

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
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      // Log the error for debugging but don't expose details to caller
      // Common errors: NotAvailable, NotEnrolled, PasscodeNotSet
      AppLogger('Debug').debug('Biometric authentication error: ${e.code}');
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

  /// Check for device biometric changes
  /// Returns true if biometric enrollment has changed since last check
  Future<bool> hasDeviceBiometricChanged() async {
    try {
      final currentHash = await _getBiometricHash();
      final storedHash = await _storage.read(key: _keyDeviceBiometricHash);

      if (storedHash == null) {
        // First time check, store current hash
        await _storage.write(key: _keyDeviceBiometricHash, value: currentHash);
        return false;
      }

      return currentHash != storedHash;
    } catch (e) {
      AppLogger('BiometricService').debug('Error checking biometric change: $e');
      return false;
    }
  }

  /// Update stored biometric hash
  Future<void> updateBiometricHash() async {
    final currentHash = await _getBiometricHash();
    await _storage.write(key: _keyDeviceBiometricHash, value: currentHash);
    await _storage.write(
      key: _keyLastBiometricCheck,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Get a hash representing current biometric enrollment
  Future<String> _getBiometricHash() async {
    final types = await getAvailableBiometrics();
    final canCheck = await canCheckBiometrics();
    final isSupported = await isDeviceSupported();

    // Create a simple hash from biometric state
    return '${types.map((t) => t.name).join(',')}_${canCheck}_$isSupported';
  }

  /// Handle device biometric change
  /// Disables biometric auth if enrollment has changed
  Future<BiometricChangeResult> handleBiometricChange() async {
    final hasChanged = await hasDeviceBiometricChanged();

    if (hasChanged) {
      final wasEnabled = await isBiometricEnabled();
      if (wasEnabled) {
        // Disable biometric for security
        await disableBiometric();
        return BiometricChangeResult(
          changed: true,
          wasDisabled: true,
          requiresReEnrollment: true,
        );
      }
      return BiometricChangeResult(
        changed: true,
        wasDisabled: false,
        requiresReEnrollment: false,
      );
    }

    return BiometricChangeResult(
      changed: false,
      wasDisabled: false,
      requiresReEnrollment: false,
    );
  }

  /// Check if biometric authentication has timed out
  Future<bool> hasBiometricTimedOut(int timeoutMinutes) async {
    if (timeoutMinutes == 0) {
      // Immediate timeout always requires re-auth
      return true;
    }

    final lastCheckStr = await _storage.read(key: _keyLastBiometricCheck);
    if (lastCheckStr == null) {
      return true;
    }

    try {
      final lastCheck = DateTime.parse(lastCheckStr);
      final now = DateTime.now();
      final difference = now.difference(lastCheck);

      return difference.inMinutes >= timeoutMinutes;
    } catch (e) {
      return true;
    }
  }

  /// Update last biometric check timestamp
  Future<void> updateLastBiometricCheck() async {
    await _storage.write(
      key: _keyLastBiometricCheck,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Get localized biometric type name
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.faceId:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.none:
        return 'None';
    }
  }
}

/// Result of biometric change check
class BiometricChangeResult {
  final bool changed;
  final bool wasDisabled;
  final bool requiresReEnrollment;

  BiometricChangeResult({
    required this.changed,
    required this.wasDisabled,
    required this.requiresReEnrollment,
  });
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

/// Biometric Guard for sensitive operations
/// Throws [BiometricRequiredException] if biometric check fails
class BiometricGuard {
  final BiometricService _biometricService;

  BiometricGuard(this._biometricService);

  /// Threshold for requiring biometric confirmation on external transfers
  static const double externalTransferThreshold = 100.0;

  /// Check if biometric confirmation is required for transfer
  bool requiresConfirmation({
    required double amount,
    required bool isExternal,
  }) {
    // External transfers over threshold require biometric
    if (isExternal && amount >= externalTransferThreshold) {
      return true;
    }
    return false;
  }

  /// Require biometric confirmation for sensitive action
  /// Returns true if confirmed, throws if denied or fails
  Future<bool> confirmSensitiveAction({
    required String reason,
  }) async {
    final isEnabled = await _biometricService.isBiometricEnabled();
    if (!isEnabled) {
      // If biometric not enabled, allow action (user chose not to use biometric)
      return true;
    }

    final success = await _biometricService.authenticateSensitive(reason: reason);
    if (!success) {
      throw BiometricRequiredException('Biometric confirmation required');
    }
    return true;
  }

  /// Guard for external transfer
  Future<bool> guardExternalTransfer(double amount) async {
    if (!requiresConfirmation(amount: amount, isExternal: true)) {
      return true;
    }
    return confirmSensitiveAction(
      reason: 'Confirm external transfer of \$${amount.toStringAsFixed(2)}',
    );
  }

  /// Guard for PIN change
  Future<bool> guardPinChange() async {
    return confirmSensitiveAction(
      reason: 'Confirm your identity to change PIN',
    );
  }
}

/// Exception thrown when biometric confirmation is required but not provided
class BiometricRequiredException implements Exception {
  final String message;
  BiometricRequiredException(this.message);

  @override
  String toString() => message;
}

/// Biometric Guard Provider
final biometricGuardProvider = Provider<BiometricGuard>((ref) {
  return BiometricGuard(ref.watch(biometricServiceProvider));
});
