import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'performance_service.dart';
import '../../utils/logger.dart';

/// Firebase Performance Service Provider
/// Note: Requires firebase_performance package to be added to pubspec.yaml
final firebasePerformanceServiceProvider = Provider<FirebasePerformanceService>((ref) {
  final performanceService = ref.watch(performanceServiceProvider);
  return FirebasePerformanceService(performanceService);
});

/// Firebase Performance Monitoring integration
/// Wraps Firebase Performance APIs with local PerformanceService
class FirebasePerformanceService {
  final PerformanceService _localPerformance;

  // Firebase Performance is available but not yet configured
  // Uncomment when firebase_performance is added to pubspec.yaml
  // final FirebasePerformance? _firebasePerformance;
  final bool _isEnabled;

  FirebasePerformanceService(this._localPerformance)
      : _isEnabled = false; // Set to true when Firebase Performance is configured
  // : _firebasePerformance = _initializeFirebase(),
  //   _isEnabled = _initializeFirebase() != null;

  // static FirebasePerformance? _initializeFirebase() {
  //   try {
  //     return FirebasePerformance.instance;
  //   } catch (e) {
  //     _logger.warn('Failed to initialize Firebase Performance', e);
  //     return null;
  //   }
  // }

  /// Start a trace
  Future<FirebaseTrace> startTrace(String name) async {
    // Start local trace
    final localTrace = _localPerformance.startTrace(name);

    // Start Firebase trace
    // Uncomment when firebase_performance is configured
    // FirebaseTrace? firebaseTrace;
    // if (_isEnabled) {
    //   try {
    //     firebaseTrace = await _firebasePerformance!.newTrace(name);
    //     await firebaseTrace.start();
    //   } catch (e) {
    //     _logger.error('Failed to start Firebase trace', e);
    //   }
    // }

    return FirebaseTrace(
      name: name,
      localTrace: localTrace,
      // firebaseTrace: firebaseTrace,
      localPerformance: _localPerformance,
    );
  }

  /// Track HTTP request performance
  Future<void> trackHttpRequest({
    required String url,
    required String httpMethod,
    required int statusCode,
    required int requestPayloadBytes,
    required int responsePayloadBytes,
    required Duration duration,
  }) async {
    // Track locally
    _localPerformance.trackApiCall(
      url,
      duration,
      statusCode: statusCode,
    );

    // Track in Firebase
    if (!_isEnabled) return;

    // Uncomment when firebase_performance is configured
    // try {
    //   final metric = await _firebasePerformance!.newHttpMetric(url, httpMethod);
    //   metric.httpResponseCode = statusCode;
    //   metric.requestPayloadSize = requestPayloadBytes;
    //   metric.responsePayloadSize = responsePayloadBytes;
    //   await metric.start();
    //   await Future.delayed(duration); // Simulate the duration
    //   await metric.stop();
    // } catch (e) {
    //   _logger.error('Failed to track HTTP metric', e);
    // }
  }

  /// Set performance collection enabled
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    if (!_isEnabled) return;

    // Uncomment when firebase_performance is configured
    // try {
    //   await _firebasePerformance!.setPerformanceCollectionEnabled(enabled);
    //   _logger.info('Performance collection ${enabled ? 'enabled' : 'disabled'}');
    // } catch (e) {
    //   _logger.error('Failed to set performance collection', e);
    // }
  }

  /// Get performance data enabled status
  Future<bool> isPerformanceCollectionEnabled() async {
    if (!_isEnabled) return false;

    // Uncomment when firebase_performance is configured
    // try {
    //   return await _firebasePerformance!.isPerformanceCollectionEnabled();
    // } catch (e) {
    //   _logger.error('Failed to check performance collection status', e);
    //   return false;
    // }

    return false;
  }
}

/// Firebase trace wrapper
class FirebaseTrace {
  final String name;
  final PerformanceTrace localTrace;
  // final FirebaseTrace? firebaseTrace;
  final PerformanceService localPerformance;

  final Map<String, int> _metrics = {};
  final Map<String, String> _attributes = {};

  FirebaseTrace({
    required this.name,
    required this.localTrace,
    // this.firebaseTrace,
    required this.localPerformance,
  });

  /// Set metric value
  void setMetric(String name, int value) {
    _metrics[name] = value;
    localTrace.putAttribute(name, value);

    // Uncomment when firebase_performance is configured
    // firebaseTrace?.setMetric(name, value);
  }

  /// Increment metric
  void incrementMetric(String name, int value) {
    final current = _metrics[name] ?? 0;
    setMetric(name, current + value);
  }

  /// Get metric value
  int getMetric(String name) => _metrics[name] ?? 0;

  /// Set attribute
  void putAttribute(String name, String value) {
    _attributes[name] = value;
    localTrace.putAttribute(name, value);

    // Uncomment when firebase_performance is configured
    // firebaseTrace?.putAttribute(name, value);
  }

  /// Remove attribute
  void removeAttribute(String name) {
    _attributes.remove(name);

    // Uncomment when firebase_performance is configured
    // firebaseTrace?.removeAttribute(name);
  }

  /// Get attribute value
  String? getAttribute(String name) => _attributes[name];

  /// Get all attributes
  Map<String, String> getAttributes() => Map.unmodifiable(_attributes);

  /// Stop trace
  Future<void> stop() async {
    // Stop local trace
    localPerformance.stopTrace(name, additionalAttributes: _attributes);

    // Stop Firebase trace
    // Uncomment when firebase_performance is configured
    // try {
    //   await firebaseTrace?.stop();
    // } catch (e) {
    //   AppLogger('FirebaseTrace').error('Failed to stop Firebase trace', e);
    // }
  }
}

/// Extension to add performance tracking to widgets
extension PerformanceTracking on Widget {
  /// Wrap widget with performance tracking
  Widget trackPerformance(String traceName) {
    return PerformanceTrackedWidget(
      traceName: traceName,
      child: this,
    );
  }
}

/// Widget that tracks its own build performance
class PerformanceTrackedWidget extends StatefulWidget {
  final String traceName;
  final Widget child;

  const PerformanceTrackedWidget({
    super.key,
    required this.traceName,
    required this.child,
  });

  @override
  State<PerformanceTrackedWidget> createState() => _PerformanceTrackedWidgetState();
}

class _PerformanceTrackedWidgetState extends State<PerformanceTrackedWidget> {
  DateTime? _buildStartTime;

  @override
  void initState() {
    super.initState();
    _buildStartTime = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_buildStartTime != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_buildStartTime != null && mounted) {
          final duration = DateTime.now().difference(_buildStartTime!);
          AppLogger('PerformanceWidget')
              .debug('${widget.traceName} rendered in ${duration.inMilliseconds}ms');
          _buildStartTime = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Mixin for tracking async operations
mixin AsyncPerformanceTracking {
  /// Track async operation performance
  Future<T> trackAsync<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? attributes,
  }) async {
    final startTime = DateTime.now();
    final logger = AppLogger('AsyncPerformance');

    try {
      final result = await operation();
      final duration = DateTime.now().difference(startTime);

      logger.debug('$operationName completed in ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      logger.error(
        '$operationName failed after ${duration.inMilliseconds}ms',
        e,
      );
      rethrow;
    }
  }
}
