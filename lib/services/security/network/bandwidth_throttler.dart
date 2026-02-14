import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Throttles bandwidth usage for security-sensitive operations.
class BandwidthThrottler {
  static const _tag = 'Throttler';
  // ignore: unused_field
  final AppLogger _log = AppLogger(_tag);
  int _bytesThisWindow = 0;
  DateTime _windowStart = DateTime.now();
  final int maxBytesPerMinute;

  BandwidthThrottler({this.maxBytesPerMinute = 10 * 1024 * 1024});

  /// Check if the transfer can proceed.
  bool canTransfer(int bytes) {
    _resetWindowIfNeeded();
    return (_bytesThisWindow + bytes) <= maxBytesPerMinute;
  }

  /// Record bytes transferred.
  void recordTransfer(int bytes) {
    _resetWindowIfNeeded();
    _bytesThisWindow += bytes;
  }

  void _resetWindowIfNeeded() {
    if (DateTime.now().difference(_windowStart) > const Duration(minutes: 1)) {
      _bytesThisWindow = 0;
      _windowStart = DateTime.now();
    }
  }

  double get usagePercent => _bytesThisWindow / maxBytesPerMinute;
}

final bandwidthThrottlerProvider = Provider<BandwidthThrottler>((ref) {
  return BandwidthThrottler();
});
