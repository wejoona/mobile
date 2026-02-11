import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Prevents screen recording and mirroring on sensitive screens.
///
/// Uses platform-specific APIs to detect and block screen capture
/// when displaying sensitive financial information.
class ScreenRecordingPreventer {
  static const _tag = 'ScreenRecordPreventer';
  static const _channel = MethodChannel('com.korido.security/screen');
  final AppLogger _log = AppLogger(_tag);

  bool _isProtectionActive = false;

  /// Enable screen recording protection.
  Future<void> enableProtection() async {
    if (_isProtectionActive) return;
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('setSecureFlag', true);
      } else if (Platform.isIOS) {
        await _channel.invokeMethod('enableScreenProtection');
      }
      _isProtectionActive = true;
      _log.debug('Screen recording protection enabled');
    } catch (e) {
      _log.error('Failed to enable screen protection', e);
    }
  }

  /// Disable screen recording protection.
  Future<void> disableProtection() async {
    if (!_isProtectionActive) return;
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('setSecureFlag', false);
      } else if (Platform.isIOS) {
        await _channel.invokeMethod('disableScreenProtection');
      }
      _isProtectionActive = false;
      _log.debug('Screen recording protection disabled');
    } catch (e) {
      _log.error('Failed to disable screen protection', e);
    }
  }

  /// Check if screen is currently being recorded/mirrored.
  Future<bool> isScreenBeingCaptured() async {
    try {
      final result = await _channel.invokeMethod<bool>('isScreenCaptured');
      return result ?? false;
    } catch (e) {
      _log.error('Failed to check screen capture status', e);
      return false;
    }
  }

  bool get isProtectionActive => _isProtectionActive;
}

final screenRecordingPreventerProvider =
    Provider<ScreenRecordingPreventer>((ref) {
  return ScreenRecordingPreventer();
});
