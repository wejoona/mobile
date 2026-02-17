import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service that detects rooted/jailbroken devices using
/// [flutter_jailbreak_detection] and blocks app usage when compromised.
///
/// Unlike [DeviceIntegrityService] which warns, this service **blocks**
/// access entirely — no dismiss, no workaround.
class TamperDetectionService {
  TamperDetectionService();

  bool _isCompromised = false;

  /// Whether the device was found to be rooted or jailbroken.
  bool get isCompromised => _isCompromised;

  /// Run the root/jailbreak check.
  ///
  /// Returns `true` if device is compromised.
  /// In debug mode the check is skipped (always returns `false`).
  Future<bool> check() async {
    if (kDebugMode) {
      _isCompromised = false;
      return false;
    }

    try {
      final jailbroken = await FlutterJailbreakDetection.jailbroken;
      final developerMode = await FlutterJailbreakDetection.developerMode;

      _isCompromised = jailbroken;

      if (kDebugMode) {
        debugPrint(
          '[TamperDetection] jailbroken=$jailbroken, developerMode=$developerMode',
        );
      }
    } catch (e) {
      // If detection fails in release, assume compromised (fail-closed).
      if (kDebugMode) {
        debugPrint('[TamperDetection] check failed: $e');
        _isCompromised = false;
      } else {
        _isCompromised = true;
      }
    }

    return _isCompromised;
  }

  /// Show a **non-dismissible** blocking dialog when the device is
  /// compromised. The user cannot close this dialog — app is unusable.
  static Future<void> showBlockingDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Security Alert'),
          content: const Text(
            'This device appears to be rooted or jailbroken.\n\n'
            'For the safety of your funds, Korido cannot run on '
            'compromised devices.\n\n'
            'Please use a non-modified device to access your wallet.',
          ),
          actions: const [
            // No dismiss button — intentionally empty.
          ],
        ),
      ),
    );
  }
}

/// Riverpod provider for [TamperDetectionService].
final tamperDetectionServiceProvider = Provider<TamperDetectionService>((ref) {
  return TamperDetectionService();
});
