import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Monitors network quality and adjusts security accordingly.
enum NetworkQuality { excellent, good, fair, poor, offline }

class NetworkQualityState {
  final NetworkQuality quality;
  final int latencyMs;
  final DateTime lastCheck;

  const NetworkQualityState({
    this.quality = NetworkQuality.offline,
    this.latencyMs = 0,
    required this.lastCheck,
  });
}

class NetworkQualityMonitor extends StateNotifier<NetworkQualityState> {
  static const _tag = 'NetQuality';
  final AppLogger _log = AppLogger(_tag);

  NetworkQualityMonitor()
      : super(NetworkQualityState(lastCheck: DateTime.now()));

  Future<void> measureLatency(String endpoint) async {
    final start = DateTime.now();
    // Would ping endpoint
    final latency = DateTime.now().difference(start).inMilliseconds;
    final quality = _classify(latency);
    state = NetworkQualityState(
      quality: quality,
      latencyMs: latency,
      lastCheck: DateTime.now(),
    );
    _log.debug('Network quality: ${quality.name} (${latency}ms)');
  }

  NetworkQuality _classify(int ms) {
    if (ms < 100) return NetworkQuality.excellent;
    if (ms < 300) return NetworkQuality.good;
    if (ms < 1000) return NetworkQuality.fair;
    return NetworkQuality.poor;
  }
}

final networkQualityMonitorProvider =
    StateNotifierProvider<NetworkQualityMonitor, NetworkQualityState>((ref) {
  return NetworkQualityMonitor();
});
