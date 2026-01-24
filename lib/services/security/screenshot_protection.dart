import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SECURITY: Screenshot and screen recording protection service
/// Prevents sensitive financial data from being captured
class ScreenshotProtectionService {
  static const MethodChannel _channel = MethodChannel(
    'com.joonapay.usdc_wallet/security',
  );

  // Callbacks for security events
  Function()? onScreenshotDetected;
  Function(bool isCaptured)? onScreenRecordingChanged;

  ScreenshotProtectionService() {
    _setupMethodCallHandler();
  }

  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onScreenshotDetected':
          onScreenshotDetected?.call();
          break;
        case 'onScreenRecordingChanged':
          final isCaptured = call.arguments['isCaptured'] as bool? ?? false;
          onScreenRecordingChanged?.call(isCaptured);
          break;
      }
    });
  }

  /// Enable secure mode (prevents screenshots)
  /// Should be enabled on sensitive screens like:
  /// - Wallet balance
  /// - Transaction details
  /// - PIN entry
  /// - QR codes with wallet addresses
  Future<bool> enableSecureMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('enableSecureMode');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Disable secure mode (allows screenshots)
  /// Only disable on non-sensitive screens if needed
  Future<bool> disableSecureMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('disableSecureMode');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}

/// Provider for screenshot protection service
final screenshotProtectionProvider = Provider<ScreenshotProtectionService>((ref) {
  return ScreenshotProtectionService();
});

/// State notifier for screen recording status
class ScreenRecordingNotifier extends StateNotifier<bool> {
  final ScreenshotProtectionService _service;

  ScreenRecordingNotifier(this._service) : super(false) {
    _service.onScreenRecordingChanged = (isCaptured) {
      state = isCaptured;
    };
  }
}

/// Provider for screen recording detection
final screenRecordingProvider =
    StateNotifierProvider<ScreenRecordingNotifier, bool>((ref) {
  final service = ref.watch(screenshotProtectionProvider);
  return ScreenRecordingNotifier(service);
});
