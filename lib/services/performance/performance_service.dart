import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Performance Service Provider
final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService();
});

/// Performance metric types
enum MetricType {
  appStartup,
  screenRender,
  apiCall,
  frameRate,
  memory,
  custom,
}

/// Performance metric data
class PerformanceMetric {
  final String name;
  final MetricType type;
  final DateTime timestamp;
  final Duration? duration;
  final Map<String, dynamic>? attributes;
  final double? value;

  const PerformanceMetric({
    required this.name,
    required this.type,
    required this.timestamp,
    this.duration,
    this.attributes,
    this.value,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        if (duration != null) 'duration_ms': duration!.inMilliseconds,
        if (value != null) 'value': value,
        if (attributes != null) ...attributes!,
      };

  @override
  String toString() {
    final sb = StringBuffer('$name (${type.name})');
    if (duration != null) sb.write(' - ${duration!.inMilliseconds}ms');
    if (value != null) sb.write(' - $value');
    return sb.toString();
  }
}

/// Performance trace for tracking operations
class PerformanceTrace {
  final String name;
  final DateTime startTime;
  final Map<String, dynamic> attributes;
  final MetricType type;

  PerformanceTrace({
    required this.name,
    required this.type,
    Map<String, dynamic>? attributes,
  })  : startTime = DateTime.now(),
        attributes = attributes ?? {};

  /// Add attribute to trace
  void putAttribute(String key, dynamic value) {
    attributes[key] = value;
  }

  /// Stop trace and return metric
  PerformanceMetric stop() {
    final duration = DateTime.now().difference(startTime);
    return PerformanceMetric(
      name: name,
      type: type,
      timestamp: startTime,
      duration: duration,
      attributes: attributes,
    );
  }
}

/// Performance monitoring service
/// Tracks app startup, screen render, API calls, frame rate, memory usage
class PerformanceService {
  static final _logger = AppLogger('Performance');
  final _metrics = <PerformanceMetric>[];
  final _traces = <String, PerformanceTrace>{};

  // App lifecycle tracking
  DateTime? _appStartTime;
  DateTime? _firstFrameTime;
  bool _isInitialized = false;

  // Performance thresholds (in milliseconds)
  static const _slowScreenThreshold = 1000;
  static const _slowApiThreshold = 3000;
  static const _slowFrameThreshold = 16.67; // 60fps = 16.67ms per frame

  // Memory tracking
  int _lastMemoryUsage = 0;
  Timer? _memoryMonitorTimer;

  // Frame rate tracking
  final _frameDurations = <double>[];
  static const _maxFrameSamples = 100;

  PerformanceService() {
    _initialize();
  }

  void _initialize() {
    if (_isInitialized) return;

    _appStartTime = DateTime.now();
    _isInitialized = true;

    // Start memory monitoring in debug mode
    if (kDebugMode) {
      _startMemoryMonitoring();
    }

    _logger.info('Performance monitoring initialized');
  }

  /// Mark app startup complete
  void markAppStartupComplete() {
    if (_appStartTime == null) return;

    final duration = DateTime.now().difference(_appStartTime!);
    final metric = PerformanceMetric(
      name: 'app_startup',
      type: MetricType.appStartup,
      timestamp: _appStartTime!,
      duration: duration,
      attributes: {'cold_start': true},
    );

    _recordMetric(metric);
    _logger.info('App startup: ${duration.inMilliseconds}ms');
  }

  /// Mark first frame rendered
  void markFirstFrameRendered() {
    if (_appStartTime == null || _firstFrameTime != null) return;

    _firstFrameTime = DateTime.now();
    final duration = _firstFrameTime!.difference(_appStartTime!);
    final metric = PerformanceMetric(
      name: 'first_frame',
      type: MetricType.appStartup,
      timestamp: _appStartTime!,
      duration: duration,
    );

    _recordMetric(metric);
    _logger.info('First frame: ${duration.inMilliseconds}ms');
  }

  /// Start a custom trace
  PerformanceTrace startTrace(
    String name, {
    MetricType type = MetricType.custom,
    Map<String, dynamic>? attributes,
  }) {
    final trace = PerformanceTrace(
      name: name,
      type: type,
      attributes: attributes,
    );
    _traces[name] = trace;
    return trace;
  }

  /// Stop a trace and record metric
  void stopTrace(String name, {Map<String, dynamic>? additionalAttributes}) {
    final trace = _traces.remove(name);
    if (trace == null) {
      _logger.warn('Attempted to stop non-existent trace: $name');
      return;
    }

    if (additionalAttributes != null) {
      trace.attributes.addAll(additionalAttributes);
    }

    final metric = trace.stop();
    _recordMetric(metric);

    // Log slow operations
    if (metric.duration != null) {
      final durationMs = metric.duration!.inMilliseconds;
      if (metric.type == MetricType.screenRender &&
          durationMs > _slowScreenThreshold) {
        _logger.warn('Slow screen render: $name took ${durationMs}ms');
      } else if (metric.type == MetricType.apiCall &&
          durationMs > _slowApiThreshold) {
        _logger.warn('Slow API call: $name took ${durationMs}ms');
      }
    }
  }

  /// Track screen render time
  void trackScreenRender(String screenName, Duration duration) {
    final metric = PerformanceMetric(
      name: 'screen_render_$screenName',
      type: MetricType.screenRender,
      timestamp: DateTime.now(),
      duration: duration,
      attributes: {'screen': screenName},
    );

    _recordMetric(metric);

    if (duration.inMilliseconds > _slowScreenThreshold) {
      _logger.warn(
          'Slow screen: $screenName took ${duration.inMilliseconds}ms');
    }
  }

  /// Track API response time
  void trackApiCall(String endpoint, Duration duration,
      {int? statusCode, bool? isError}) {
    final metric = PerformanceMetric(
      name: 'api_$endpoint',
      type: MetricType.apiCall,
      timestamp: DateTime.now(),
      duration: duration,
      attributes: {
        'endpoint': endpoint,
        if (statusCode != null) 'status_code': statusCode,
        if (isError != null) 'is_error': isError,
      },
    );

    _recordMetric(metric);

    if (duration.inMilliseconds > _slowApiThreshold) {
      _logger.warn('Slow API: $endpoint took ${duration.inMilliseconds}ms');
    }
  }

  /// Track frame duration (for frame rate monitoring)
  void trackFrameDuration(double durationMs) {
    _frameDurations.add(durationMs);

    // Keep only recent samples
    if (_frameDurations.length > _maxFrameSamples) {
      _frameDurations.removeAt(0);
    }

    // Log frame drops (slower than 60fps)
    if (durationMs > _slowFrameThreshold) {
      final fps = 1000 / durationMs;
      _logger.debug('Frame drop: ${durationMs.toStringAsFixed(2)}ms ($fps fps)');
    }
  }

  /// Get current frame rate
  double? getCurrentFrameRate() {
    if (_frameDurations.isEmpty) return null;

    final avgDuration =
        _frameDurations.reduce((a, b) => a + b) / _frameDurations.length;
    return 1000 / avgDuration; // Convert to FPS
  }

  /// Get frame drop percentage
  double getFrameDropPercentage() {
    if (_frameDurations.isEmpty) return 0;

    final droppedFrames =
        _frameDurations.where((d) => d > _slowFrameThreshold).length;
    return (droppedFrames / _frameDurations.length) * 100;
  }

  /// Track memory usage
  void trackMemoryUsage(int bytes) {
    final mb = bytes / (1024 * 1024);
    _lastMemoryUsage = bytes;

    final metric = PerformanceMetric(
      name: 'memory_usage',
      type: MetricType.memory,
      timestamp: DateTime.now(),
      value: mb,
      attributes: {'bytes': bytes},
    );

    _recordMetric(metric);
  }

  /// Start automatic memory monitoring
  void _startMemoryMonitoring() {
    _memoryMonitorTimer?.cancel();
    _memoryMonitorTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      // In a real implementation, you would use platform channels
      // or packages like vm_service to get actual memory usage
      // For now, this is a placeholder
      _logger.debug('Memory monitoring tick');
    });
  }

  /// Record a custom metric
  void recordMetric(
    String name,
    double value, {
    Map<String, dynamic>? attributes,
  }) {
    final metric = PerformanceMetric(
      name: name,
      type: MetricType.custom,
      timestamp: DateTime.now(),
      value: value,
      attributes: attributes,
    );

    _recordMetric(metric);
  }

  /// Internal metric recording
  void _recordMetric(PerformanceMetric metric) {
    _metrics.add(metric);

    // Keep only recent metrics (last 1000)
    if (_metrics.length > 1000) {
      _metrics.removeAt(0);
    }

    // Log in debug mode
    if (kDebugMode) {
      _logger.debug(metric.toString());
    }

    // Send to analytics in production
    if (kReleaseMode) {
      _sendToAnalytics(metric);
    }
  }

  /// Send metric to analytics service
  void _sendToAnalytics(PerformanceMetric metric) {
    // In production, send to Firebase Performance, custom backend, etc.
    // For now, this is a placeholder
  }

  /// Get all metrics
  List<PerformanceMetric> getMetrics({MetricType? type}) {
    if (type == null) return List.unmodifiable(_metrics);
    return _metrics.where((m) => m.type == type).toList();
  }

  /// Get metrics for a specific screen
  List<PerformanceMetric> getScreenMetrics(String screenName) {
    return _metrics
        .where((m) =>
            m.type == MetricType.screenRender &&
            m.attributes?['screen'] == screenName)
        .toList();
  }

  /// Get average screen render time
  Duration? getAverageScreenRenderTime(String screenName) {
    final metrics = getScreenMetrics(screenName);
    if (metrics.isEmpty) return null;

    final totalMs =
        metrics.fold<int>(0, (sum, m) => sum + (m.duration?.inMilliseconds ?? 0));
    return Duration(milliseconds: totalMs ~/ metrics.length);
  }

  /// Get API metrics for endpoint
  List<PerformanceMetric> getApiMetrics(String endpoint) {
    return _metrics
        .where((m) =>
            m.type == MetricType.apiCall &&
            m.attributes?['endpoint'] == endpoint)
        .toList();
  }

  /// Get average API response time
  Duration? getAverageApiResponseTime(String endpoint) {
    final metrics = getApiMetrics(endpoint);
    if (metrics.isEmpty) return null;

    final totalMs =
        metrics.fold<int>(0, (sum, m) => sum + (m.duration?.inMilliseconds ?? 0));
    return Duration(milliseconds: totalMs ~/ metrics.length);
  }

  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    final screenMetrics = getMetrics(type: MetricType.screenRender);
    final apiMetrics = getMetrics(type: MetricType.apiCall);

    return {
      'total_metrics': _metrics.length,
      'screen_renders': screenMetrics.length,
      'api_calls': apiMetrics.length,
      'avg_screen_render_ms': screenMetrics.isEmpty
          ? 0
          : screenMetrics.fold<int>(
                  0, (sum, m) => sum + (m.duration?.inMilliseconds ?? 0)) ~/
              screenMetrics.length,
      'avg_api_response_ms': apiMetrics.isEmpty
          ? 0
          : apiMetrics.fold<int>(
                  0, (sum, m) => sum + (m.duration?.inMilliseconds ?? 0)) ~/
              apiMetrics.length,
      'current_fps': getCurrentFrameRate()?.toStringAsFixed(1),
      'frame_drop_percentage': getFrameDropPercentage().toStringAsFixed(1),
      'last_memory_mb': (_lastMemoryUsage / (1024 * 1024)).toStringAsFixed(2),
    };
  }

  /// Clear all metrics
  void clearMetrics() {
    _metrics.clear();
    _frameDurations.clear();
    _logger.info('Performance metrics cleared');
  }

  /// Dispose resources
  void dispose() {
    _memoryMonitorTimer?.cancel();
    _traces.clear();
    _logger.info('Performance service disposed');
  }
}
