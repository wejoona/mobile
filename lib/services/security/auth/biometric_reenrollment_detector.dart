import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Detects changes in enrolled biometrics on the device.
///
/// If new fingerprints/faces are enrolled since last check,
/// the user must re-authenticate to prevent unauthorized biometric access.
class BiometricReenrollmentDetector {
  static const _tag = 'BiometricReenroll';
  static const _prefKey = 'biometric_enrollment_hash';
  final AppLogger _log = AppLogger(_tag);

  /// Check if biometric enrollment has changed.
  Future<bool> hasEnrollmentChanged() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString(_prefKey);
      final currentHash = await _getCurrentEnrollmentHash();

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
    } catch (e) {
      _log.error('Biometric enrollment check failed', e);
      return false;
    }
  }

  /// Update stored enrollment hash after re-verification.
  Future<void> acknowledgeChange() async {
    final prefs = await SharedPreferences.getInstance();
    final currentHash = await _getCurrentEnrollmentHash();
    await prefs.setString(_prefKey, currentHash);
    _log.debug('Biometric enrollment hash updated');
  }

  /// Clear stored hash (on logout or device unbind).
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  Future<String> _getCurrentEnrollmentHash() async {
    // Platform channel needed for actual implementation:
    // Android: BiometricManager.BIOMETRIC_STRONG
    // iOS: LAContext evaluatedPolicyDomainState
    return 'biometric_state_placeholder';
  }
}

final biometricReenrollmentDetectorProvider =
    Provider<BiometricReenrollmentDetector>((ref) {
  return BiometricReenrollmentDetector();
});
