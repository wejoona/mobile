# Performance Monitoring Integration Guide

Step-by-step guide to integrate performance monitoring into JoonaPay mobile app.

## Step 1: Update main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/performance/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... existing Firebase and other initialization

  runApp(
    ProviderScope(
      child: const JoonaPayApp(),
    ),
  );

  // Mark app startup complete after first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final container = ProviderContainer();
    final performanceService = container.read(performanceServiceProvider);
    performanceService.markAppStartupComplete();
    performanceService.markFirstFrameRendered();
  });
}
```

## Step 2: Update app_router.dart

Add performance observer to GoRouter:

```dart
import 'package:usdc_wallet/services/performance/index.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final featureFlags = ref.watch(featureFlagsProvider);
  final performanceService = ref.watch(performanceServiceProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // ... existing redirect logic
    },
    observers: [
      // Add performance observer for automatic screen tracking
      GoRouterPerformanceObserver(performanceService),
    ],
    routes: [
      // ... existing routes
    ],
  );
});
```

## Step 3: Update api_client.dart

Add API performance interceptor to Dio:

```dart
import 'package:usdc_wallet/services/performance/index.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: Config.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // Add interceptors in order
  if (MockConfig.useMocks) {
    dio.interceptors.add(MockInterceptor());
  }

  dio.interceptors.add(DeduplicationInterceptor());
  dio.interceptors.add(CacheInterceptor());

  // Add performance interceptor AFTER cache/deduplication
  final performanceInterceptor = ref.watch(apiPerformanceInterceptorProvider);
  dio.interceptors.add(performanceInterceptor);

  // Auth interceptor last
  final authInterceptor = ref.watch(authInterceptorProvider);
  dio.interceptors.add(authInterceptor);

  // Logging interceptor
  dio.interceptors.add(LogInterceptor(/* ... */));

  return dio;
});
```

## Step 4: Add Performance Monitor Route (Optional)

In `app_router.dart`, add route for performance dashboard:

```dart
GoRoute(
  path: '/settings/performance',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context,
    state,
    const PerformanceMonitorView(),
  ),
),
```

In `settings_screen.dart`, add navigation button (debug mode only):

```dart
import 'package:flutter/foundation.dart';

// Inside _buildContent or settings list
if (kDebugMode) ...[
  _buildSettingsItem(
    icon: Icons.speed,
    title: 'Performance Monitor',
    subtitle: 'View app performance metrics',
    onTap: () => context.push('/settings/performance'),
  ),
],
```

## Step 5: Track Critical User Flows

### Example: Send Money Flow

```dart
// In send_money_provider.dart
class SendMoneyNotifier extends Notifier<SendMoneyState> {
  @override
  SendMoneyState build() => SendMoneyState.initial();

  Future<void> sendMoney({
    required String recipientId,
    required double amount,
  }) async {
    // Start performance trace
    final performanceService = ref.read(performanceServiceProvider);
    final trace = performanceService.startTrace(
      'send_money_flow',
      type: MetricType.custom,
      attributes: {
        'amount': amount.toString(),
        'recipient_type': 'user',
      },
    );

    state = state.copyWith(isLoading: true, error: null);

    try {
      final sdk = ref.read(sdkProvider);
      final result = await sdk.transfers.sendMoney(
        recipientId: recipientId,
        amount: amount,
      );

      trace.putAttribute('transaction_id', result.id);
      trace.putAttribute('success', true);

      state = state.copyWith(
        isLoading: false,
        success: true,
        transaction: result,
      );

      // Track analytics
      ref.read(analyticsServiceProvider).logTransferCompleted(
            transferType: 'p2p',
            amount: amount,
            currency: 'USDC',
            transactionId: result.id,
          );
    } catch (e) {
      trace.putAttribute('error', e.toString());
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } finally {
      performanceService.stopTrace('send_money_flow');
    }
  }
}
```

### Example: KYC Upload Flow

```dart
// In kyc_provider.dart
Future<void> uploadDocument(File file) async {
  final performanceService = ref.read(performanceServiceProvider);
  final trace = performanceService.startTrace(
    'kyc_document_upload',
    type: MetricType.custom,
  );

  try {
    final fileSize = await file.length();
    trace.putAttribute('file_size_bytes', fileSize);

    final result = await uploadToServer(file);

    trace.putAttribute('upload_success', true);
    trace.setMetric('upload_time_ms', result.duration.inMilliseconds);
  } catch (e) {
    trace.putAttribute('error', e.toString());
    rethrow;
  } finally {
    performanceService.stopTrace('kyc_document_upload');
  }
}
```

## Step 6: Track Heavy Operations

### Example: Image Processing

```dart
import 'package:usdc_wallet/services/performance/index.dart';

class ImageProcessingService with AsyncPerformanceTracking {
  Future<File> compressImage(File image) async {
    return trackAsync(
      'compress_image',
      () async {
        // Heavy image compression
        final compressed = await ImageCompressor.compress(image);
        return compressed;
      },
      attributes: {'format': 'jpeg', 'quality': '80'},
    );
  }
}
```

### Example: List Rendering

```dart
class TransactionListView extends ConsumerStatefulWidget {
  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends ConsumerState<TransactionListView>
    with PerformanceTrackingMixin {
  @override
  String get screenName => 'TransactionList';

  Future<void> _loadMoreTransactions() async {
    await trackOperation('load_more_transactions', () async {
      await ref.read(transactionsProvider.notifier).loadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ... build UI
  }
}
```

## Step 7: Monitor Frame Rate During Animations

```dart
class AnimatedOnboardingView extends ConsumerStatefulWidget {
  @override
  State<AnimatedOnboardingView> createState() => _AnimatedOnboardingViewState();
}

class _AnimatedOnboardingViewState extends ConsumerState<AnimatedOnboardingView>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Monitor frame rate during animation
    _controller.addListener(() {
      final performanceService = ref.read(performanceServiceProvider);
      // Frame rate is automatically tracked by PerformanceObserver
      // No manual tracking needed
    });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: const OnboardingContent(),
    );
  }
}
```

## Step 8: Production Monitoring

For production, send metrics to your analytics backend:

```dart
// In performance_service.dart, update _sendToAnalytics method:

void _sendToAnalytics(PerformanceMetric metric) {
  if (!kReleaseMode) return;

  // Send to your analytics backend
  try {
    final analyticsService = /* get analytics service */;
    analyticsService.logEvent(
      'performance_metric',
      parameters: metric.toJson(),
    );
  } catch (e) {
    _logger.error('Failed to send performance metric', e);
  }
}
```

## Performance Budgets

Set performance budgets for critical flows:

```dart
// In tests/performance/performance_test.dart
void main() {
  group('Performance Budgets', () {
    test('Home screen renders in under 1 second', () async {
      final performanceService = PerformanceService();

      // Simulate screen render
      final trace = performanceService.startTrace('wallet_home');
      await Future.delayed(const Duration(milliseconds: 800));
      performanceService.stopTrace('wallet_home');

      final avgTime = performanceService.getAverageScreenRenderTime('wallet_home');
      expect(avgTime!.inMilliseconds, lessThan(1000));
    });

    test('API calls complete in under 3 seconds', () async {
      final performanceService = PerformanceService();

      performanceService.trackApiCall(
        '/wallet/balance',
        const Duration(milliseconds: 850),
      );

      final avgTime = performanceService.getAverageApiResponseTime('/wallet/balance');
      expect(avgTime!.inMilliseconds, lessThan(3000));
    });
  });
}
```

## Monitoring Checklist

- [x] Performance service initialized
- [x] GoRouterPerformanceObserver added to router
- [x] ApiPerformanceInterceptor added to Dio
- [x] App startup marked complete
- [x] Critical user flows tracked (send money, KYC, deposits)
- [x] Heavy operations tracked (image processing, data loading)
- [x] Performance monitor screen added (debug only)
- [ ] Production analytics configured
- [ ] Performance budgets defined
- [ ] Alerts set up for slow operations

## Troubleshooting

### High Memory Usage
```dart
// Clear old metrics periodically
final performanceService = ref.read(performanceServiceProvider);
performanceService.clearMetrics();
```

### Frame Drops During Animations
- Use `RepaintBoundary` to isolate expensive widgets
- Implement `const` constructors where possible
- Use `ListView.builder` instead of `ListView` for long lists
- Profile with DevTools to identify rebuild issues

### Slow API Calls
```dart
// Check API performance stats
final apiInterceptor = ref.read(apiPerformanceInterceptorProvider);
final stats = apiInterceptor.getAllStats();
print('Slowest endpoints: ${stats['slowest_endpoints']}');
```

### Slow Screen Renders
```dart
// Find slowest screens
final performanceService = ref.read(performanceServiceProvider);
final metrics = performanceService.getMetrics(type: MetricType.screenRender);
final slowestScreen = metrics
    .reduce((a, b) => a.duration! > b.duration! ? a : b);
print('Slowest screen: ${slowestScreen.name} - ${slowestScreen.duration}');
```

## Next Steps

1. Run app and verify metrics are being collected
2. Navigate through critical flows
3. Open performance monitor (`/settings/performance`)
4. Review metrics and identify bottlenecks
5. Optimize slow operations
6. Set up production monitoring
7. Create dashboards for tracking over time
