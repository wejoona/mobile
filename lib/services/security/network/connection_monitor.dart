import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'network_trust_evaluator.dart';

/// Periodically monitors network security posture.
///
/// Emits events when network trust level changes, allowing the app
/// to restrict operations on untrusted networks.
class ConnectionMonitor {
  static const _tag = 'ConnectionMonitor';
  final AppLogger _log = AppLogger(_tag);
  final NetworkTrustEvaluator _evaluator;

  Timer? _timer;
  NetworkTrustLevel? _lastLevel;
  final _controller = StreamController<NetworkTrustResult>.broadcast();

  ConnectionMonitor({required NetworkTrustEvaluator evaluator})
      : _evaluator = evaluator;

  Stream<NetworkTrustResult> get trustChanges => _controller.stream;

  /// Start periodic monitoring.
  void start({
    required String apiHost,
    Duration interval = const Duration(minutes: 5),
  }) {
    stop();
    _timer = Timer.periodic(interval, (_) => _check(apiHost));
    _check(apiHost);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _check(String apiHost) async {
    try {
      final result = await _evaluator.evaluate(apiHost);
      if (_lastLevel != result.level) {
        _log.debug('Network trust changed: $_lastLevel -> ${result.level}');
        _lastLevel = result.level;
        _controller.add(result);
      }
    } catch (e) {
      _log.error('Connection monitor check failed', e);
    }
  }

  void dispose() {
    stop();
    _controller.close();
  }
}

final connectionMonitorProvider = Provider<ConnectionMonitor>((ref) {
  final monitor = ConnectionMonitor(
    evaluator: ref.watch(networkTrustEvaluatorProvider),
  );
  ref.onDispose(monitor.dispose);
  return monitor;
});
