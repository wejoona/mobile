import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Manages clipboard security by auto-clearing sensitive data.
///
/// When sensitive data (wallet addresses, amounts, PINs) is copied,
/// the clipboard is automatically cleared after a timeout.
class SecureClipboardService {
  static const _tag = 'SecureClipboard';
  final AppLogger _log = AppLogger(_tag);

  Timer? _clearTimer;
  static const Duration _defaultClearDelay = Duration(seconds: 60);

  /// Copy sensitive data to clipboard with auto-clear.
  Future<void> copySecure(
    String data, {
    Duration clearAfter = _defaultClearDelay,
  }) async {
    await Clipboard.setData(ClipboardData(text: data));
    _scheduleClear(clearAfter);
    _log.debug('Sensitive data copied, clearing in ${clearAfter.inSeconds}s');
  }

  /// Copy a wallet address with shorter clear time.
  Future<void> copyAddress(String address) async {
    await copySecure(address, clearAfter: const Duration(seconds: 120));
  }

  /// Immediately clear the clipboard.
  Future<void> clearNow() async {
    await Clipboard.setData(const ClipboardData(text: ''));
    _clearTimer?.cancel();
    _log.debug('Clipboard cleared');
  }

  void _scheduleClear(Duration delay) {
    _clearTimer?.cancel();
    _clearTimer = Timer(delay, () async {
      await Clipboard.setData(const ClipboardData(text: ''));
      _log.debug('Clipboard auto-cleared');
    });
  }

  void dispose() {
    _clearTimer?.cancel();
  }
}

final secureClipboardServiceProvider =
    Provider<SecureClipboardService>((ref) {
  final service = SecureClipboardService();
  ref.onDispose(service.dispose);
  return service;
});
