import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Screenshot detection event.
class ScreenshotEvent {
  final DateTime timestamp;
  final String? screenName;

  const ScreenshotEvent({required this.timestamp, this.screenName});
}

/// Detects when the user takes a screenshot.
///
/// Used to warn users about capturing sensitive financial data
/// and to log security events for audit trail.
class ScreenshotDetector {
  static const _tag = 'ScreenshotDetector';
  static const _channel = MethodChannel('com.korido.security/screenshot');
  final AppLogger _log = AppLogger(_tag);

  final _controller = StreamController<ScreenshotEvent>.broadcast();
  Stream<ScreenshotEvent> get onScreenshot => _controller.stream;

  String? _currentScreen;

  /// Start listening for screenshots.
  void startListening() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onScreenshot') {
        final event = ScreenshotEvent(
          timestamp: DateTime.now(),
          screenName: _currentScreen,
        );
        _controller.add(event);
        _log.debug('Screenshot detected on: $_currentScreen');
      }
    });
    _log.debug('Screenshot detection started');
  }

  /// Update the current screen name for event context.
  void setCurrentScreen(String screenName) {
    _currentScreen = screenName;
  }

  /// Stop listening.
  void stopListening() {
    _channel.setMethodCallHandler(null);
  }

  void dispose() {
    stopListening();
    _controller.close();
  }
}

final screenshotDetectorProvider = Provider<ScreenshotDetector>((ref) {
  final detector = ScreenshotDetector();
  ref.onDispose(detector.dispose);
  return detector;
});
