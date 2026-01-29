# Performance Monitoring - Quick Reference

## Import

```dart
import 'package:usdc_wallet/services/performance/index.dart';
```

## Get Performance Service

```dart
// In ConsumerWidget
final performanceService = ref.watch(performanceServiceProvider);

// In regular Widget with ProviderScope
final container = ProviderContainer();
final performanceService = container.read(performanceServiceProvider);
```

## Common Tasks

### Track Custom Operation

```dart
// Start trace
final trace = performanceService.startTrace('operation_name');

// Add attributes
trace.putAttribute('user_id', userId);
trace.putAttribute('item_count', itemCount.toString());

// Stop trace
performanceService.stopTrace('operation_name');
```

### Record Metric

```dart
performanceService.recordMetric(
  'cache_hit_rate',
  0.85,
  attributes: {'cache_type': 'image'},
);
```

### Track Screen Manually

```dart
DateTime? _startTime;

@override
void initState() {
  super.initState();
  _startTime = DateTime.now();
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();

  if (_startTime != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final duration = DateTime.now().difference(_startTime!);
      ref.read(performanceServiceProvider).trackScreenRender(
        'ScreenName',
        duration,
      );
      _startTime = null;
    });
  }
}
```

### Use Performance Mixin

```dart
class MyScreenView extends StatefulWidget {
  @override
  State<MyScreenView> createState() => _MyScreenViewState();
}

class _MyScreenViewState extends State<MyScreenView>
    with PerformanceTrackingMixin {
  @override
  String get screenName => 'MyScreen';

  Future<void> _loadData() async {
    await trackOperation('load_data', () async {
      // Your async operation
    });
  }
}
```

### Track Async Operation

```dart
class MyService with AsyncPerformanceTracking {
  Future<Result> doWork() async {
    return trackAsync(
      'my_operation',
      () async {
        // Heavy work here
        return result;
      },
      attributes: {'type': 'heavy'},
    );
  }
}
```

## Query Metrics

### Get All Metrics

```dart
final allMetrics = performanceService.getMetrics();
final screenMetrics = performanceService.getMetrics(type: MetricType.screenRender);
final apiMetrics = performanceService.getMetrics(type: MetricType.apiCall);
```

### Get Screen Stats

```dart
final homeMetrics = performanceService.getScreenMetrics('HomeScreen');
final avgTime = performanceService.getAverageScreenRenderTime('HomeScreen');
print('Home screen avg render: ${avgTime?.inMilliseconds}ms');
```

### Get API Stats

```dart
final walletMetrics = performanceService.getApiMetrics('/wallet/balance');
final avgTime = performanceService.getAverageApiResponseTime('/wallet/balance');
print('Wallet API avg: ${avgTime?.inMilliseconds}ms');
```

### Get Summary

```dart
final summary = performanceService.getPerformanceSummary();
print('Total metrics: ${summary['total_metrics']}');
print('Avg screen render: ${summary['avg_screen_render_ms']}ms');
print('Avg API response: ${summary['avg_api_response_ms']}ms');
print('Current FPS: ${summary['current_fps']}');
print('Frame drops: ${summary['frame_drop_percentage']}%');
```

### Get Frame Rate

```dart
final fps = performanceService.getCurrentFrameRate();
final dropPercentage = performanceService.getFrameDropPercentage();

if (fps != null && fps < 55) {
  print('Low frame rate: $fps FPS');
}

if (dropPercentage > 5) {
  print('High frame drop rate: $dropPercentage%');
}
```

## Clear Metrics

```dart
performanceService.clearMetrics();
```

## API Performance Interceptor

### Get Endpoint Stats

```dart
final interceptor = ref.read(apiPerformanceInterceptorProvider);
final stats = interceptor.getEndpointStats('/wallet/balance');

print('Total calls: ${stats['total_calls']}');
print('Avg duration: ${stats['avg_duration_ms']}ms');
print('Error rate: ${stats['error_rate']}%');
```

### Get All API Stats

```dart
final allStats = interceptor.getAllStats();
print('Total API calls: ${allStats['total_calls']}');
print('Success rate: ${allStats['success_calls']} / ${allStats['total_calls']}');
print('Slowest endpoints: ${allStats['slowest_endpoints']}');
```

## Firebase Performance

### Start Trace

```dart
final firebasePerf = ref.read(firebasePerformanceServiceProvider);
final trace = await firebasePerf.startTrace('my_operation');

trace.putAttribute('user_type', 'premium');
trace.setMetric('items_loaded', 50);

await trace.stop();
```

### Track HTTP Request

```dart
await firebasePerf.trackHttpRequest(
  url: 'https://api.example.com/data',
  httpMethod: 'GET',
  statusCode: 200,
  requestPayloadBytes: 1024,
  responsePayloadBytes: 4096,
  duration: const Duration(milliseconds: 850),
);
```

## Widget Extensions

### Track Widget Performance

```dart
Widget build(BuildContext context) {
  return MyExpensiveWidget().trackPerformance('my_widget');
}
```

## Metric Types

```dart
MetricType.appStartup      // App initialization
MetricType.screenRender    // Screen navigation
MetricType.apiCall         // HTTP requests
MetricType.frameRate       // Frame timing
MetricType.memory          // Memory usage
MetricType.custom          // Custom metrics
```

## Performance Thresholds

| Operation | Threshold | Action |
|-----------|-----------|--------|
| Screen Render | 1000ms | Warning logged |
| API Call | 3000ms | Warning logged |
| Frame Time | 16.67ms | Frame drop tracked |

## Debug Commands

```dart
// Log all slow screens
final screenMetrics = performanceService.getMetrics(type: MetricType.screenRender);
final slowScreens = screenMetrics
    .where((m) => m.duration!.inMilliseconds > 1000)
    .toList();
for (final metric in slowScreens) {
  print('Slow: ${metric.name} - ${metric.duration!.inMilliseconds}ms');
}

// Log all slow APIs
final apiMetrics = performanceService.getMetrics(type: MetricType.apiCall);
final slowApis = apiMetrics
    .where((m) => m.duration!.inMilliseconds > 3000)
    .toList();
for (final metric in slowApis) {
  print('Slow API: ${metric.attributes?['endpoint']} - ${metric.duration!.inMilliseconds}ms');
}

// Check frame rate health
final fps = performanceService.getCurrentFrameRate();
final drops = performanceService.getFrameDropPercentage();
if (fps != null && fps < 55) print('WARNING: Low FPS - $fps');
if (drops > 5) print('WARNING: High frame drops - $drops%');
```

## Navigation

```dart
// View performance dashboard (debug only)
context.push('/settings/performance');
```

## Production Setup

```dart
// In performance_service.dart
void _sendToAnalytics(PerformanceMetric metric) {
  if (!kReleaseMode) return;

  // Send to your backend
  analyticsService.logEvent(
    'performance_metric',
    parameters: metric.toJson(),
  );
}
```

## Memory Management

```dart
// Clear old metrics periodically
Timer.periodic(const Duration(minutes: 30), (_) {
  performanceService.clearMetrics();
});
```

## Testing

```dart
void main() {
  test('Operation completes within budget', () async {
    final service = PerformanceService();
    final trace = service.startTrace('test_operation');

    await doWork();

    service.stopTrace('test_operation');
    final avgTime = service.getAverageScreenRenderTime('test_operation');

    expect(avgTime!.inMilliseconds, lessThan(500));
  });
}
```
