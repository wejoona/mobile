import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Surveillance en temps réel des menaces.
enum ThreatType { rootDetected, debuggerAttached, tamperingDetected, networkCompromised, mitmDetected }

class ThreatEvent {
  final ThreatType type;
  final DateTime timestamp;
  final String details;
  ThreatEvent({required this.type, required this.details}) : timestamp = DateTime.now();
}

class RealtimeThreatMonitor {
  static const _tag = 'ThreatMonitor';
  final AppLogger _log = AppLogger(_tag);
  final _controller = StreamController<ThreatEvent>.broadcast();
  final List<ThreatEvent> _history = [];

  Stream<ThreatEvent> get threats => _controller.stream;

  void reportThreat(ThreatType type, String details) {
    final event = ThreatEvent(type: type, details: details);
    _history.add(event);
    _controller.add(event);
    _log.error('THREAT: ${type.name} - $details');
  }

  List<ThreatEvent> get history => List.unmodifiable(_history);

  bool get hasActiveThreats => _history.any(
    (e) => DateTime.now().difference(e.timestamp) < const Duration(hours: 1),
  );

  void dispose() => _controller.close();
}

final realtimeThreatMonitorProvider = Provider<RealtimeThreatMonitor>((ref) {
  final monitor = RealtimeThreatMonitor();
  ref.onDispose(monitor.dispose);
  return monitor;
});
