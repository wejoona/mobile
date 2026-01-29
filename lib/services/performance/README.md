# Performance Monitoring

Comprehensive performance monitoring system for tracking app startup, screen rendering, API calls, frame rate, and memory usage.

## Features

- **App Startup Tracking**: Measure cold start and first frame render times
- **Screen Performance**: Track render time for each screen
- **API Monitoring**: Track response times and error rates for all API calls
- **Frame Rate**: Monitor FPS and detect frame drops
- **Memory Usage**: Track memory consumption over time
- **Custom Metrics**: Record custom performance metrics

## Quick Start

### 1. Initialize Performance Monitoring

The performance service is automatically initialized. To mark app startup completion:

```dart
import 'package:usdc_wallet/services/performance/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Your initialization code...

  runApp(const MyApp());

  // Mark startup complete after first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final container = ProviderContainer();
    final performanceService = container.read(performanceServiceProvider);
    performanceService.markAppStartupComplete();
  });
}
```

### 2. Add Performance Observer to Router

```dart
// In app_router.dart or main.dart
import 'package:usdc_wallet/services/performance/index.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final performanceService = ref.watch(performanceServiceProvider);

  return GoRouter(
    // ... your router config
    observers: [
      GoRouterPerformanceObserver(performanceService),
    ],
  );
});
```

### 3. Add API Performance Interceptor

```dart
// In api_client.dart
import 'package:usdc_wallet/services/performance/index.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(/* ... */));

  // Add performance interceptor
  final performanceInterceptor = ref.watch(apiPerformanceInterceptorProvider);
  dio.interceptors.add(performanceInterceptor);

  // ... other interceptors

  return dio;
});
```

## Usage Examples

### Track Screen Render Time

Automatic tracking via router observer (recommended):
```dart
// Routes are automatically tracked when using GoRouterPerformanceObserver
```

Manual tracking:
```dart
class MyScreenView extends ConsumerStatefulWidget {
  @override
  State<MyScreenView> createState() => _MyScreenViewState();
}

class _MyScreenViewState extends ConsumerState<MyScreenView> {
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
        if (_startTime != null) {
          final duration = DateTime.now().difference(_startTime!);
          final performanceService = ref.read(performanceServiceProvider);
          performanceService.trackScreenRender('MyScreen', duration);
          _startTime = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(/* ... */);
  }
}
```

Using mixin:
```dart
class MyScreenView extends StatefulWidget {
  @override
  State<MyScreenView> createState() => _MyScreenViewState();
}

class _MyScreenViewState extends State<MyScreenView>
    with PerformanceTrackingMixin {
  @override
  String get screenName => 'MyScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(/* ... */);
  }
}
```

### Track Custom Operations

```dart
class MyService {
  final PerformanceService _performanceService;

  Future<void> doSomething() async {
    final trace = _performanceService.startTrace('my_operation');

    try {
      // Your operation
      await heavyComputation();

      trace.putAttribute('success', true);
    } catch (e) {
      trace.putAttribute('error', e.toString());
      rethrow;
    } finally {
      _performanceService.stopTrace('my_operation');
    }
  }
}
```

### Track API Calls

API calls are automatically tracked when using `ApiPerformanceInterceptor`:

```dart
// No manual tracking needed - interceptor handles it automatically
final response = await dio.get('/api/wallet');
```

### Record Custom Metrics

```dart
final performanceService = ref.read(performanceServiceProvider);

// Record a numeric metric
performanceService.recordMetric(
  'cache_hit_rate',
  0.85,
  attributes: {'cache_type': 'image'},
);

// Record with trace
final trace = performanceService.startTrace('image_processing');
trace.putAttribute('image_size', '1024x768');
// ... do work
performanceService.stopTrace('image_processing');
```

### Monitor Frame Rate

Frame rate is automatically tracked via `PerformanceObserver`. Access current stats:

```dart
final performanceService = ref.read(performanceServiceProvider);

final fps = performanceService.getCurrentFrameRate();
final dropPercentage = performanceService.getFrameDropPercentage();

print('Current FPS: $fps');
print('Frame drops: $dropPercentage%');
```

## Firebase Performance Integration

To enable Firebase Performance Monitoring:

1. Add dependency to `pubspec.yaml`:
```yaml
dependencies:
  firebase_performance: ^0.10.0
```

2. Uncomment Firebase code in `firebase_performance_service.dart`

3. Use Firebase traces:
```dart
final firebasePerf = ref.read(firebasePerformanceServiceProvider);

final trace = await firebasePerf.startTrace('my_operation');
trace.putAttribute('user_type', 'premium');
trace.setMetric('items_processed', 100);
await trace.stop();
```

## Performance Dashboard

View performance metrics in the app:

```dart
// Add route to app_router.dart
GoRoute(
  path: '/settings/performance',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context, state, const PerformanceMonitorView(),
  ),
),

// Navigate from settings
context.push('/settings/performance');
```

The dashboard shows:
- Overview of all metrics
- Screen-by-screen render times
- API endpoint performance
- Frame rate statistics

## Performance Thresholds

Default thresholds for slow operations:
- Screen render: **1000ms**
- API call: **3000ms**
- Frame time: **16.67ms** (60 FPS)

Warnings are logged when operations exceed these thresholds.

## Querying Metrics

```dart
final performanceService = ref.read(performanceServiceProvider);

// Get all metrics
final allMetrics = performanceService.getMetrics();

// Get metrics by type
final screenMetrics = performanceService.getMetrics(type: MetricType.screenRender);
final apiMetrics = performanceService.getMetrics(type: MetricType.apiCall);

// Get screen-specific metrics
final homeMetrics = performanceService.getScreenMetrics('HomeScreen');
final avgRenderTime = performanceService.getAverageScreenRenderTime('HomeScreen');

// Get API-specific metrics
final walletApiMetrics = performanceService.getApiMetrics('/wallet/balance');
final avgResponseTime = performanceService.getAverageApiResponseTime('/wallet/balance');

// Get summary
final summary = performanceService.getPerformanceSummary();
print(summary);
// {
//   'total_metrics': 150,
//   'screen_renders': 45,
//   'api_calls': 80,
//   'avg_screen_render_ms': 450,
//   'avg_api_response_ms': 850,
//   'current_fps': '58.5',
//   'frame_drop_percentage': '2.3',
//   'last_memory_mb': '142.50'
// }
```

## Best Practices

### 1. Use Automatic Tracking
- Let `GoRouterPerformanceObserver` track screen navigation
- Let `ApiPerformanceInterceptor` track API calls
- Let `PerformanceObserver` track frame rate

### 2. Track Critical User Flows
```dart
// Example: Track payment flow
final trace = performanceService.startTrace('payment_flow');
trace.putAttribute('amount', amount.toString());
trace.putAttribute('method', paymentMethod);

try {
  await processPayment();
  trace.putAttribute('success', true);
} catch (e) {
  trace.putAttribute('error', e.toString());
} finally {
  performanceService.stopTrace('payment_flow');
}
```

### 3. Monitor Business-Critical Screens
```dart
// Track screens users visit frequently
performanceService.trackScreenRender('WalletHome', duration);
performanceService.trackScreenRender('TransactionList', duration);
performanceService.trackScreenRender('SendMoney', duration);
```

### 4. Set Performance Budgets
```dart
// In tests or monitoring code
final avgRenderTime = performanceService.getAverageScreenRenderTime('HomeScreen');
assert(avgRenderTime!.inMilliseconds < 1000, 'Home screen too slow!');
```

### 5. Clean Up Old Metrics
```dart
// Periodically clear old metrics to prevent memory growth
performanceService.clearMetrics();
```

## Debugging Slow Performance

### Find Slow Screens
```dart
final screenMetrics = performanceService.getMetrics(type: MetricType.screenRender);
final slowScreens = screenMetrics
    .where((m) => m.duration!.inMilliseconds > 1000)
    .toList();

for (final metric in slowScreens) {
  print('Slow screen: ${metric.name} - ${metric.duration!.inMilliseconds}ms');
}
```

### Find Slow APIs
```dart
final apiMetrics = performanceService.getMetrics(type: MetricType.apiCall);
final slowApis = apiMetrics
    .where((m) => m.duration!.inMilliseconds > 3000)
    .toList();

for (final metric in slowApis) {
  print('Slow API: ${metric.attributes?['endpoint']} - ${metric.duration!.inMilliseconds}ms');
}
```

### Monitor Frame Drops
```dart
if (performanceService.getFrameDropPercentage() > 5) {
  print('Warning: High frame drop rate!');
  // Investigate heavy widgets, reduce rebuilds, optimize images
}
```

## Architecture

```
performance/
├── performance_service.dart          # Core service, metrics storage
├── performance_observer.dart         # Automatic route & frame tracking
├── api_performance_interceptor.dart  # Dio interceptor for API tracking
├── firebase_performance_service.dart # Firebase Performance integration
└── index.dart                        # Exports
```

## Metric Types

- `MetricType.appStartup`: App initialization and first frame
- `MetricType.screenRender`: Screen navigation and render time
- `MetricType.apiCall`: HTTP request/response time
- `MetricType.frameRate`: Frame timing and FPS
- `MetricType.memory`: Memory usage snapshots
- `MetricType.custom`: Custom application metrics

## Integration Checklist

- [x] Add `GoRouterPerformanceObserver` to router
- [x] Add `ApiPerformanceInterceptor` to Dio
- [x] Mark app startup complete
- [x] Add performance monitor route (optional, for debugging)
- [ ] Configure Firebase Performance (optional)
- [ ] Set up production analytics (optional)

## Notes

- Metrics are kept in memory (last 1000)
- Frame tracking only active when app is resumed
- Performance monitoring has minimal overhead (<1ms per operation)
- Safe to use in production builds
- Automatically logs slow operations in debug mode
