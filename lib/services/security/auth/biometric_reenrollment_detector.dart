import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/config/environment_config.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Detects changes in enrolled biometrics on the device.
///
/// If new fingerprints/faces are enrolled since last check,
/// the user must re-authenticate to prevent unauthorized biometric access.
class BiometricReenrollmentDetector {
  static const _tag = 'BiometricReenroll';
  static const _prefKey = 'biometric_enrollment_hash';
  static const _channel = MethodChannel('com.joonapay.usdc_wallet/biometrics');
  final AppLogger _log = const AppLogger(_tag);

  /// Check if biometric enrollment has changed.
  Future<bool> hasEnrollmentChanged() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString(_prefKey);
      final currentHash = await _getCurrentEnrollmentHash();

      if (EnvironmentConfig.isProduction && currentHash == null) {
        _log.error(
          'Native biometric enrollment state is not configured for production',
        );
        return true;
      }

      if (currentHash == null) {
        return false;
      }

      if (storedHash == null) {
        // First check, store baseline
        await prefs.setString(_prefKey, currentHash);
        return false;
      }

      if (storedHash != currentHash) {
        _log.debug('Biometric enrollment change detected');
        return true;
      }

      return false;
    } on Object catch (e) {
      _log.error('Biometric enrollment check failed', e);
      return false;
    }
  }

  /// Update stored enrollment hash after re-verification.
  Future<void> acknowledgeChange() async {
    final prefs = await SharedPreferences.getInstance();
    final currentHash = await _getCurrentEnrollmentHash();
    if (currentHash == null) {
      await prefs.remove(_prefKey);
      return;
    }
    await prefs.setString(_prefKey, currentHash);
    _log.debug('Biometric enrollment hash updated');
  }

  /// Clear stored hash (on logout or device unbind).
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  Future<String?> _getCurrentEnrollmentHash() async {
    try {
      final value = await _channel.invokeMethod<String>(
        'getEnrollmentStateHash',
      );
      if (value == null || value.trim().isEmpty || value == 'unavailable') {
        return null;
      }
      return value;
    } on MissingPluginException catch (e) {
      if (EnvironmentConfig.isProduction) {
        _log.error('Biometric enrollment native channel missing', e);
      } else {
        _log.debug('Biometric enrollment native channel missing', e);
      }
      return null;
    } on PlatformException catch (e) {
      if (e.code == 'BIOMETRIC_UNAVAILABLE') {
        return null;
      }
      _log.error('Biometric enrollment native check failed', e);
      return null;
    }
  }
}

final biometricReenrollmentDetectorProvider =
    Provider<BiometricReenrollmentDetector>(
      (ref) => BiometricReenrollmentDetector(),
    );
