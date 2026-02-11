import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'behavioral_biometrics_model.dart';

/// Collecteur de données biométriques comportementales.
///
/// Accumule les données de saisie, toucher et navigation
/// pour construire un profil comportemental.
class BehavioralBiometricsCollector {
  static const _tag = 'BiometricsCollector';
  final AppLogger _log = AppLogger(_tag);
  static const int _maxSamples = 100;

  final Queue<double> _keystrokeIntervals = Queue();
  final Queue<double> _dwellTimes = Queue();
  final Queue<double> _touchPressures = Queue();
  final Queue<String> _screenFlows = Queue();
  int _totalKeystrokes = 0;
  int _errorCount = 0;
  DateTime? _sessionStart;

  void recordKeystroke({required double intervalMs, required double dwellMs}) {
    _addSample(_keystrokeIntervals, intervalMs);
    _addSample(_dwellTimes, dwellMs);
    _totalKeystrokes++;
  }

  void recordTypingError() {
    _errorCount++;
  }

  void recordTouch({required double pressure}) {
    _addSample(_touchPressures, pressure);
  }

  void recordScreenVisit(String screenName) {
    if (_sessionStart == null) _sessionStart = DateTime.now();
    _screenFlows.addLast(screenName);
    if (_screenFlows.length > _maxSamples) _screenFlows.removeFirst();
  }

  void _addSample(Queue<double> queue, double value) {
    queue.addLast(value);
    if (queue.length > _maxSamples) queue.removeFirst();
  }

  double _average(Queue<double> queue) {
    if (queue.isEmpty) return 0.0;
    return queue.reduce((a, b) => a + b) / queue.length;
  }

  /// Générer le profil biométrique actuel
  BehavioralBiometricProfile generateProfile({required String userId}) {
    return BehavioralBiometricProfile(
      userId: userId,
      typingPattern: _keystrokeIntervals.isNotEmpty ? TypingPattern(
        avgKeystrokeInterval: _average(_keystrokeIntervals),
        avgDwellTime: _average(_dwellTimes),
        typingSpeed: _totalKeystrokes > 0 ? _totalKeystrokes / (_sessionDurationMin.clamp(0.1, double.infinity)) : 0,
        errorRate: _totalKeystrokes > 0 ? _errorCount / _totalKeystrokes : 0,
      ) : null,
      touchPattern: _touchPressures.isNotEmpty ? TouchPattern(
        avgPressure: _average(_touchPressures),
        avgTouchArea: 0.0,
        swipeSpeed: 0.0,
      ) : null,
      navigationPattern: NavigationPattern(
        commonFlows: _screenFlows.toList(),
        avgSessionDuration: _sessionDurationSec,
        avgScreenTime: _screenFlows.isNotEmpty ? _sessionDurationSec / _screenFlows.length : 0,
        avgActionsPerSession: _totalKeystrokes,
      ),
      capturedAt: DateTime.now(),
    );
  }

  double get _sessionDurationSec {
    if (_sessionStart == null) return 0;
    return DateTime.now().difference(_sessionStart!).inSeconds.toDouble();
  }

  double get _sessionDurationMin => _sessionDurationSec / 60.0;

  void reset() {
    _keystrokeIntervals.clear();
    _dwellTimes.clear();
    _touchPressures.clear();
    _screenFlows.clear();
    _totalKeystrokes = 0;
    _errorCount = 0;
    _sessionStart = null;
  }
}

final behavioralBiometricsCollectorProvider = Provider<BehavioralBiometricsCollector>((ref) {
  return BehavioralBiometricsCollector();
});
