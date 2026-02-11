import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'performance_service.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Performance observer provider
final performanceObserverProvider = Provider<PerformanceObserver>((ref) {
  final performanceService = ref.watch(performanceServiceProvider);
  return PerformanceObserver(performanceService);
});

/// Automatic performance observer
/// Tracks screen navigation, frame rate, and lifecycle events
class PerformanceObserver extends RouteObserver<ModalRoute<dynamic>>
    with WidgetsBindingObserver {
  final PerformanceService _performanceService;
  static final _logger = AppLogger('PerformanceObserver');

  // Screen tracking
  final Map<Route<dynamic>, DateTime> _routeStartTimes = {};
  final Map<Route<dynamic>, String> _routeNames = {};

  // Frame timing tracking
  bool _isTrackingFrames = false;
  final List<FrameTiming> _frameTimings = [];

  PerformanceObserver(this._performanceService) {
    _initialize();
  }

  void _initialize() {
    WidgetsBinding.instance.addObserver(this);
    _startFrameTracking();
    _logger.info('Performance observer initialized');
  }

  // RouteObserver methods

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRouteStart(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _trackRouteEnd(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) {
      _trackRouteEnd(oldRoute);
    }
    if (newRoute != null) {
      _trackRouteStart(newRoute);
    }
  }

  void _trackRouteStart(Route<dynamic> route) {
    _routeStartTimes[route] = DateTime.now();
    final routeName = _getRouteName(route);
    _routeNames[route] = routeName;

    _logger.debug('Screen navigation start: $routeName');

    // Schedule frame callback to measure render time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final startTime = _routeStartTimes[route];
      if (startTime != null) {
        final duration = DateTime.now().difference(startTime);
        _performanceService.trackScreenRender(routeName, duration);
        _logger.debug('Screen rendered: $routeName in ${duration.inMilliseconds}ms');
      }
    });
  }

  void _trackRouteEnd(Route<dynamic> route) {
    final routeName = _routeNames.remove(route);
    _routeStartTimes.remove(route);

    if (routeName != null) {
      _logger.debug('Screen navigation end: $routeName');
    }
  }

  String _getRouteName(Route<dynamic> route) {
    if (route.settings.name != null) {
      return route.settings.name!;
    }
    return route.toString();
  }

  // WidgetsBindingObserver methods

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _logger.info('App resumed');
        _startFrameTracking();
        break;
      case AppLifecycleState.paused:
        _logger.info('App paused');
        _stopFrameTracking();
        break;
      case AppLifecycleState.inactive:
        _logger.debug('App inactive');
        break;
      case AppLifecycleState.detached:
        _logger.info('App detached');
        _stopFrameTracking();
        break;
      case AppLifecycleState.hidden:
        _logger.debug('App hidden');
        break;
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Track screen size changes, orientation changes, etc.
    _logger.debug('Metrics changed');
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    _logger.debug('Locales changed: $locales');
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _logger.debug('Platform brightness changed');
  }

  // Frame tracking

  void _startFrameTracking() {
    if (_isTrackingFrames) return;

    _isTrackingFrames = true;
    _scheduleFrameTracking();
    _logger.debug('Frame tracking started');
  }

  void _stopFrameTracking() {
    _isTrackingFrames = false;
    _logger.debug('Frame tracking stopped');
  }

  void _scheduleFrameTracking() {
    if (!_isTrackingFrames) return;

    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    _frameTimings.addAll(timings);

    // Process frame timings
    for (final timing in timings) {
      final frameDuration = _calculateFrameDuration(timing);
      _performanceService.trackFrameDuration(frameDuration);
    }

    // Keep only recent frame timings
    if (_frameTimings.length > 100) {
      _frameTimings.removeRange(0, _frameTimings.length - 100);
    }

    // Continue tracking
    _scheduleFrameTracking();
  }

  double _calculateFrameDuration(FrameTiming timing) {
    // Total frame time = build + raster
    final buildDuration =
        timing.buildDuration.inMicroseconds / 1000.0; // Convert to ms
    final rasterDuration =
        timing.rasterDuration.inMicroseconds / 1000.0; // Convert to ms
    return buildDuration + rasterDuration;
  }

  /// Get recent frame statistics
  Map<String, dynamic> getFrameStats() {
    if (_frameTimings.isEmpty) {
      return {
        'count': 0,
        'avg_build_ms': 0,
        'avg_raster_ms': 0,
        'avg_total_ms': 0,
      };
    }

    final buildDurations = _frameTimings
        .map((t) => t.buildDuration.inMicroseconds / 1000.0)
        .toList();
    final rasterDurations = _frameTimings
        .map((t) => t.rasterDuration.inMicroseconds / 1000.0)
        .toList();

    final avgBuild =
        buildDurations.reduce((a, b) => a + b) / buildDurations.length;
    final avgRaster =
        rasterDurations.reduce((a, b) => a + b) / rasterDurations.length;

    return {
      'count': _frameTimings.length,
      'avg_build_ms': avgBuild.toStringAsFixed(2),
      'avg_raster_ms': avgRaster.toStringAsFixed(2),
      'avg_total_ms': (avgBuild + avgRaster).toStringAsFixed(2),
    };
  }

  /// Dispose resources
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopFrameTracking();
    _routeStartTimes.clear();
    _routeNames.clear();
    _frameTimings.clear();
    _logger.info('Performance observer disposed');
  }
}

/// GoRouter observer for performance tracking
class GoRouterPerformanceObserver extends NavigatorObserver {
  final PerformanceService _performanceService;
  static final _logger = AppLogger('GoRouterPerformanceObserver');

  final Map<Route<dynamic>, DateTime> _routeStartTimes = {};

  GoRouterPerformanceObserver(this._performanceService);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRouteStart(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _trackRouteEnd(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) {
      _trackRouteEnd(oldRoute);
    }
    if (newRoute != null) {
      _trackRouteStart(newRoute);
    }
  }

  void _trackRouteStart(Route<dynamic> route) {
    final routeName = _getRouteName(route);
    _routeStartTimes[route] = DateTime.now();

    // Start trace for screen render
    _performanceService.startTrace(
      'screen_$routeName',
      type: MetricType.screenRender,
      attributes: {'screen': routeName},
    );

    _logger.debug('Route pushed: $routeName');
  }

  void _trackRouteEnd(Route<dynamic> route) {
    final routeName = _getRouteName(route);
    _routeStartTimes.remove(route);

    _logger.debug('Route popped: $routeName');
  }

  String _getRouteName(Route<dynamic> route) {
    // Try to get GoRouter location
    if (route.settings.name != null && route.settings.name!.isNotEmpty) {
      return route.settings.name!;
    }

    // Fallback to route type
    return route.runtimeType.toString();
  }
}

/// Widget mixin for automatic performance tracking
mixin PerformanceTrackingMixin<T extends StatefulWidget> on State<T> {
  DateTime? _buildStartTime;
  String get screenName => widget.runtimeType.toString();

  @override
  void initState() {
    super.initState();
    _buildStartTime = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Track first build completion
    if (_buildStartTime != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_buildStartTime != null) {
          final duration = DateTime.now().difference(_buildStartTime!);
          // Access performance service through provider if available
          AppLogger('PerformanceMixin')
              .debug('$screenName built in ${duration.inMilliseconds}ms');
          _buildStartTime = null;
        }
      });
    }
  }

  /// Track custom operation
  void trackOperation(String operationName, Future<void> Function() operation) async {
    final start = DateTime.now();
    try {
      await operation();
      final duration = DateTime.now().difference(start);
      AppLogger('PerformanceMixin')
          .debug('$screenName.$operationName took ${duration.inMilliseconds}ms');
    } catch (e) {
      AppLogger('PerformanceMixin').error('$screenName.$operationName failed', e);
      rethrow;
    }
  }
}
