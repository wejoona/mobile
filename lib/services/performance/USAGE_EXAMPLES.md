# Performance Monitoring - Usage Examples

Real-world examples of using performance monitoring in JoonaPay.

## Example 1: Track Send Money Flow

```dart
// lib/features/send/providers/send_money_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/performance/index.dart';
import '../../../services/sdk/usdc_wallet_sdk.dart';

class SendMoneyNotifier extends Notifier<SendMoneyState> {
  @override
  SendMoneyState build() => SendMoneyState.initial();

  Future<void> sendMoney({
    required String recipientId,
    required double amount,
    required String currency,
  }) async {
    // Start performance trace for entire flow
    final performanceService = ref.read(performanceServiceProvider);
    final trace = performanceService.startTrace(
      'send_money_complete_flow',
      type: MetricType.custom,
      attributes: {
        'amount': amount.toString(),
        'currency': currency,
        'recipient_type': 'user',
      },
    );

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Step 1: Validate recipient
      final validateTrace = performanceService.startTrace('send_money_validate_recipient');
      final sdk = ref.read(sdkProvider);
      final isValid = await sdk.beneficiaries.validateRecipient(recipientId);
      performanceService.stopTrace('send_money_validate_recipient');

      if (!isValid) {
        trace.putAttribute('error', 'invalid_recipient');
        throw Exception('Invalid recipient');
      }

      // Step 2: Check balance
      final balanceTrace = performanceService.startTrace('send_money_check_balance');
      final balance = await sdk.wallet.getBalance();
      performanceService.stopTrace('send_money_check_balance');

      if (balance < amount) {
        trace.putAttribute('error', 'insufficient_funds');
        throw Exception('Insufficient funds');
      }

      // Step 3: Execute transfer
      final transferTrace = performanceService.startTrace('send_money_execute_transfer');
      final result = await sdk.transfers.sendMoney(
        recipientId: recipientId,
        amount: amount,
        currency: currency,
      );
      performanceService.stopTrace('send_money_execute_transfer');

      // Add success attributes
      trace.putAttribute('transaction_id', result.id);
      trace.putAttribute('success', true);
      trace.putAttribute('status', result.status);

      state = state.copyWith(
        isLoading: false,
        success: true,
        transaction: result,
      );
    } catch (e) {
      trace.putAttribute('error', e.toString());
      trace.putAttribute('success', false);

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } finally {
      performanceService.stopTrace('send_money_complete_flow');
    }
  }
}
```

## Example 2: Track Screen with Heavy Data Loading

```dart
// lib/features/transactions/views/transactions_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/performance/index.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView>
    with PerformanceTrackingMixin {
  @override
  String get screenName => 'TransactionsList';

  DateTime? _dataLoadStart;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    _dataLoadStart = DateTime.now();

    await trackOperation('load_transactions', () async {
      await ref.read(transactionsProvider.notifier).loadTransactions();
    });

    // Track data load separately from screen render
    if (_dataLoadStart != null) {
      final duration = DateTime.now().difference(_dataLoadStart!);
      ref.read(performanceServiceProvider).recordMetric(
            'transactions_data_load_time',
            duration.inMilliseconds.toDouble(),
            attributes: {'screen': 'TransactionsList'},
          );
    }
  }

  Future<void> _loadMore() async {
    await trackOperation('load_more_transactions', () async {
      await ref.read(transactionsProvider.notifier).loadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: transactionsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (transactions) => ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            if (index == transactions.length - 1) {
              // Load more at end
              _loadMore();
            }
            return TransactionListItem(transaction: transactions[index]);
          },
        ),
      ),
    );
  }
}
```

## Example 3: Track Image Processing

```dart
// lib/features/kyc/services/document_processing_service.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/performance/index.dart';

class DocumentProcessingService with AsyncPerformanceTracking {
  final PerformanceService _performanceService;

  DocumentProcessingService(this._performanceService);

  Future<File> processDocument(File document) async {
    return trackAsync(
      'kyc_document_processing',
      () async {
        // Step 1: Compress image
        final compressTrace = _performanceService.startTrace('compress_image');
        final originalSize = await document.length();
        compressTrace.putAttribute('original_size_bytes', originalSize);

        final compressed = await _compressImage(document);

        final compressedSize = await compressed.length();
        compressTrace.putAttribute('compressed_size_bytes', compressedSize);
        compressTrace.putAttribute(
          'compression_ratio',
          (originalSize / compressedSize).toStringAsFixed(2),
        );
        _performanceService.stopTrace('compress_image');

        // Step 2: Detect document type
        final detectTrace = _performanceService.startTrace('detect_document_type');
        final docType = await _detectDocumentType(compressed);
        detectTrace.putAttribute('document_type', docType);
        _performanceService.stopTrace('detect_document_type');

        // Step 3: Validate quality
        final validateTrace = _performanceService.startTrace('validate_document_quality');
        final quality = await _validateQuality(compressed);
        validateTrace.putAttribute('quality_score', quality.toString());
        _performanceService.stopTrace('validate_document_quality');

        return compressed;
      },
      attributes: {
        'feature': 'kyc',
        'operation': 'document_upload',
      },
    );
  }

  Future<File> _compressImage(File file) async {
    // Image compression logic
    await Future.delayed(const Duration(milliseconds: 500));
    return file;
  }

  Future<String> _detectDocumentType(File file) async {
    // ML-based document detection
    await Future.delayed(const Duration(milliseconds: 200));
    return 'passport';
  }

  Future<double> _validateQuality(File file) async {
    // Quality check (blur, lighting, etc.)
    await Future.delayed(const Duration(milliseconds: 100));
    return 0.92;
  }
}
```

## Example 4: Track API Heavy Operation

```dart
// lib/features/insights/providers/insights_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/performance/index.dart';

class InsightsNotifier extends Notifier<InsightsState> {
  @override
  InsightsState build() => InsightsState.initial();

  Future<void> loadInsights({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final performanceService = ref.read(performanceServiceProvider);
    final trace = performanceService.startTrace(
      'load_financial_insights',
      attributes: {
        'date_range_days': endDate.difference(startDate).inDays.toString(),
      },
    );

    state = state.copyWith(isLoading: true);

    try {
      final sdk = ref.read(sdkProvider);

      // Track each API call separately
      final transactionsTrace = performanceService.startTrace('insights_fetch_transactions');
      final transactions = await sdk.transactions.getTransactions(
        startDate: startDate,
        endDate: endDate,
      );
      transactionsTrace.putAttribute('transaction_count', transactions.length);
      performanceService.stopTrace('insights_fetch_transactions');

      // Process data locally
      final processTrace = performanceService.startTrace('insights_process_data');
      final insights = await _processTransactions(transactions);
      processTrace.putAttribute('categories_analyzed', insights.categories.length);
      performanceService.stopTrace('insights_process_data');

      // Track successful completion
      trace.putAttribute('success', true);
      trace.putAttribute('total_transactions', transactions.length);
      trace.putAttribute('insights_generated', insights.categories.length);

      state = state.copyWith(
        isLoading: false,
        insights: insights,
      );
    } catch (e) {
      trace.putAttribute('error', e.toString());
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } finally {
      performanceService.stopTrace('load_financial_insights');
    }
  }

  Future<Insights> _processTransactions(List<Transaction> transactions) async {
    // Heavy data processing
    await Future.delayed(const Duration(milliseconds: 300));
    return Insights(/* ... */);
  }
}
```

## Example 5: Monitor Frame Rate During Animation

```dart
// lib/features/onboarding/views/animated_onboarding_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/performance/index.dart';

class AnimatedOnboardingView extends ConsumerStatefulWidget {
  const AnimatedOnboardingView({super.key});

  @override
  ConsumerState<AnimatedOnboardingView> createState() =>
      _AnimatedOnboardingViewState();
}

class _AnimatedOnboardingViewState extends ConsumerState<AnimatedOnboardingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  DateTime? _animationStartTime;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.forward && _animationStartTime == null) {
        _animationStartTime = DateTime.now();
      } else if (status == AnimationStatus.completed && _animationStartTime != null) {
        // Track animation completion time
        final duration = DateTime.now().difference(_animationStartTime!);
        final performanceService = ref.read(performanceServiceProvider);

        performanceService.recordMetric(
          'onboarding_animation_duration',
          duration.inMilliseconds.toDouble(),
          attributes: {
            'animation_type': 'fade_slide',
            'target_duration_ms': '2000',
          },
        );

        // Check if animation lagged
        if (duration.inMilliseconds > 2100) {
          // Animation took longer than expected
          performanceService.recordMetric(
            'animation_lag',
            (duration.inMilliseconds - 2000).toDouble(),
            attributes: {'screen': 'onboarding'},
          );
        }
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        )),
        child: const OnboardingContent(),
      ),
    );
  }
}
```

## Example 6: Track Offline Queue Processing

```dart
// lib/services/offline/offline_queue_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../performance/index.dart';

class OfflineQueueService {
  final PerformanceService _performanceService;

  OfflineQueueService(this._performanceService);

  Future<void> processQueue() async {
    final trace = _performanceService.startTrace(
      'offline_queue_processing',
      attributes: {'queue_type': 'pending_transactions'},
    );

    try {
      final queue = await _getOfflineQueue();
      trace.putAttribute('queue_size', queue.length);

      int successCount = 0;
      int errorCount = 0;

      for (final item in queue) {
        final itemTrace = _performanceService.startTrace(
          'process_offline_item',
          attributes: {'item_type': item.type},
        );

        try {
          await _processItem(item);
          successCount++;
          itemTrace.putAttribute('success', true);
        } catch (e) {
          errorCount++;
          itemTrace.putAttribute('error', e.toString());
        } finally {
          _performanceService.stopTrace('process_offline_item');
        }
      }

      trace.putAttribute('success_count', successCount);
      trace.putAttribute('error_count', errorCount);
      trace.putAttribute('success_rate',
          (successCount / queue.length * 100).toStringAsFixed(1));
    } finally {
      _performanceService.stopTrace('offline_queue_processing');
    }
  }

  Future<List<QueueItem>> _getOfflineQueue() async {
    // Get queue from local storage
    return [];
  }

  Future<void> _processItem(QueueItem item) async {
    // Process single item
  }
}
```

## Example 7: Performance-Aware Widget

```dart
// lib/features/wallet/widgets/transaction_list_widget.dart

import 'package:flutter/material.dart';
import '../../../services/performance/index.dart';

class TransactionListWidget extends StatefulWidget {
  final List<Transaction> transactions;

  const TransactionListWidget({
    super.key,
    required this.transactions,
  });

  @override
  State<TransactionListWidget> createState() => _TransactionListWidgetState();
}

class _TransactionListWidgetState extends State<TransactionListWidget>
    with PerformanceTrackingMixin {
  @override
  String get screenName => 'TransactionListWidget';

  @override
  void didUpdateWidget(TransactionListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Track list rebuild performance
    if (widget.transactions.length != oldWidget.transactions.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Widget has been rebuilt with new data
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use performance-optimized list view
    return ListView.builder(
      itemCount: widget.transactions.length,
      // Use RepaintBoundary to isolate items
      itemBuilder: (context, index) => RepaintBoundary(
        child: TransactionListItem(
          transaction: widget.transactions[index],
        ),
      ),
    );
  }
}
```

## Example 8: Debug Performance Issues

```dart
// lib/utils/performance_debug.dart

import 'package:flutter/foundation.dart';
import '../services/performance/index.dart';

class PerformanceDebug {
  final PerformanceService _performanceService;

  PerformanceDebug(this._performanceService);

  /// Print performance summary to console
  void printSummary() {
    if (!kDebugMode) return;

    final summary = _performanceService.getPerformanceSummary();
    print('=== Performance Summary ===');
    print('Total Metrics: ${summary['total_metrics']}');
    print('Screen Renders: ${summary['screen_renders']} (avg: ${summary['avg_screen_render_ms']}ms)');
    print('API Calls: ${summary['api_calls']} (avg: ${summary['avg_api_response_ms']}ms)');
    print('Current FPS: ${summary['current_fps']}');
    print('Frame Drops: ${summary['frame_drop_percentage']}%');
    print('Memory: ${summary['last_memory_mb']}MB');
  }

  /// Print slow operations
  void printSlowOperations() {
    if (!kDebugMode) return;

    print('=== Slow Operations ===');

    // Find slow screens
    final screenMetrics = _performanceService.getMetrics(type: MetricType.screenRender);
    final slowScreens = screenMetrics
        .where((m) => m.duration!.inMilliseconds > 1000)
        .toList()
      ..sort((a, b) => b.duration!.compareTo(a.duration!));

    if (slowScreens.isNotEmpty) {
      print('\nSlow Screens (>1000ms):');
      for (final metric in slowScreens.take(5)) {
        print('  ${metric.attributes?['screen']}: ${metric.duration!.inMilliseconds}ms');
      }
    }

    // Find slow APIs
    final apiMetrics = _performanceService.getMetrics(type: MetricType.apiCall);
    final slowApis = apiMetrics
        .where((m) => m.duration!.inMilliseconds > 3000)
        .toList()
      ..sort((a, b) => b.duration!.compareTo(a.duration!));

    if (slowApis.isNotEmpty) {
      print('\nSlow APIs (>3000ms):');
      for (final metric in slowApis.take(5)) {
        print('  ${metric.attributes?['endpoint']}: ${metric.duration!.inMilliseconds}ms');
      }
    }

    // Check frame rate
    final fps = _performanceService.getCurrentFrameRate();
    final drops = _performanceService.getFrameDropPercentage();

    if (fps != null && fps < 55) {
      print('\n⚠️ Low FPS: $fps (target: 60)');
    }

    if (drops > 5) {
      print('⚠️ High Frame Drops: ${drops.toStringAsFixed(1)}% (target: <5%)');
    }
  }

  /// Export metrics to JSON for analysis
  Map<String, dynamic> exportMetrics() {
    final allMetrics = _performanceService.getMetrics();

    return {
      'timestamp': DateTime.now().toIso8601String(),
      'summary': _performanceService.getPerformanceSummary(),
      'metrics': allMetrics.map((m) => m.toJson()).toList(),
    };
  }
}
```

## Example 9: Integration Test with Performance

```dart
// test/integration/send_money_performance_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/performance/index.dart';

void main() {
  group('Send Money Performance', () {
    late PerformanceService performanceService;

    setUp(() {
      performanceService = PerformanceService();
    });

    test('Send money flow completes within performance budget', () async {
      final trace = performanceService.startTrace('send_money_test');

      // Simulate send money flow
      await Future.delayed(const Duration(milliseconds: 800));

      performanceService.stopTrace('send_money_test');

      final metrics = performanceService.getMetrics();
      final sendMoneyMetric = metrics.firstWhere(
        (m) => m.name == 'send_money_test',
      );

      // Assert performance budget: <1000ms
      expect(sendMoneyMetric.duration!.inMilliseconds, lessThan(1000));
    });

    test('Batch operations maintain performance', () async {
      // Track 100 operations
      for (int i = 0; i < 100; i++) {
        final trace = performanceService.startTrace('batch_operation_$i');
        await Future.delayed(const Duration(milliseconds: 10));
        performanceService.stopTrace('batch_operation_$i');
      }

      final avgDuration = performanceService
              .getMetrics()
              .fold<int>(0, (sum, m) => sum + (m.duration?.inMilliseconds ?? 0)) ~/
          100;

      // Average should be close to 10ms
      expect(avgDuration, lessThan(15));
    });
  });
}
```

These examples demonstrate real-world usage of the performance monitoring system across different features and scenarios in the JoonaPay mobile app.
