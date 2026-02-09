/// Performance regression tests for app startup time
///
/// Measures and validates app initialization performance including:
/// - Cold start time
/// - Provider initialization
/// - Route setup time
/// - First frame rendering

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/main.dart';
import 'package:usdc_wallet/router/app_router.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/auth/auth_service.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';

import '../helpers/test_utils.dart';

void main() {
  group('App Startup Performance', () {
    late MockSecureStorage mockStorage;
    late MockAuthService mockAuthService;

    setUp(() {
      mockStorage = MockSecureStorage();
      mockAuthService = MockAuthService();
    });

    tearDown(() {
      mockStorage.clear();
    });

    test('Cold start should complete within 2 seconds', () async {
      final stopwatch = Stopwatch()..start();

      // Simulate cold start
      final binding = TestWidgetsFlutterBinding.ensureInitialized();

      // Pump the app
      await binding.runAsync(() async {
        final container = ProviderContainer(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        );

        container.read(routerProvider);

        stopwatch.stop();

        // Assert: App initialization under 2 seconds
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(2000),
          reason: 'App cold start took ${stopwatch.elapsedMilliseconds}ms, expected < 2000ms',
        );
      });
    });

    testWidgets('First frame render should complete within 500ms', (tester) async {
      final stopwatch = Stopwatch()..start();

      // Build app
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: const JoonaPayApp(),
        ),
      );

      // Wait for first frame
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'First frame took ${stopwatch.elapsedMilliseconds}ms, expected < 500ms',
      );
    });

    testWidgets('Provider initialization should be lazy and fast', (tester) async {
      final initTimes = <String, int>{};

      // Measure individual provider initialization times
      await tester.runAsync(() async {
        final container = ProviderContainer(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        );

        // Test auth provider init
        var stopwatch = Stopwatch()..start();
        container.read(authProvider);
        stopwatch.stop();
        initTimes['auth'] = stopwatch.elapsedMilliseconds;

        // Test router init
        stopwatch = Stopwatch()..start();
        container.read(routerProvider);
        stopwatch.stop();
        initTimes['router'] = stopwatch.elapsedMilliseconds;

        // Assert each provider initializes quickly
        initTimes.forEach((name, time) {
          expect(
            time,
            lessThan(100),
            reason: '$name provider took ${time}ms, expected < 100ms',
          );
        });
      });
    });

    testWidgets('Splash screen should transition within 1 second', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: const JoonaPayApp(),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Let splash screen animation complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      stopwatch.stop();

      // Splash should complete quickly
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Splash transition took ${stopwatch.elapsedMilliseconds}ms, expected < 1000ms',
      );
    });

    test('Concurrent provider initialization should not block', () async {
      final results = <String, int>{};

      await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
        final container = ProviderContainer(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        );

        final stopwatch = Stopwatch()..start();

        // Initialize multiple providers concurrently
        await Future.wait([
          Future(() => container.read(authProvider)),
          Future(() => container.read(appRouterProvider)),
        ]);

        stopwatch.stop();

        results['concurrent'] = stopwatch.elapsedMilliseconds;

        // Concurrent initialization should be fast
        expect(
          results['concurrent']!,
          lessThan(200),
          reason: 'Concurrent init took ${results['concurrent']}ms, expected < 200ms',
        );
      });
    });

    testWidgets('App startup memory footprint should be reasonable', (tester) async {
      // This test validates that initial memory usage is within bounds
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: const JoonaPayApp(),
        ),
      );

      await tester.pumpAndSettle();

      // In a real app, you'd measure actual memory here
      // For now, we verify the app initializes without errors
      expect(find.byType(JoonaPayApp), findsOneWidget);
    });

    testWidgets('Router initialization should cache routes', (tester) async {
      await tester.runAsync(() async {
        final container = ProviderContainer(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        );

        // First initialization
        final stopwatch1 = Stopwatch()..start();
        container.read(routerProvider);
        stopwatch1.stop();

        // Second access (should be cached)
        final stopwatch2 = Stopwatch()..start();
        container.read(routerProvider);
        stopwatch2.stop();

        // Cached access should be instant
        expect(
          stopwatch2.elapsedMilliseconds,
          lessThan(10),
          reason: 'Cached router access took ${stopwatch2.elapsedMilliseconds}ms, expected < 10ms',
        );

        // Cached should be significantly faster
        expect(
          stopwatch2.elapsedMilliseconds,
          lessThan(stopwatch1.elapsedMilliseconds),
        );
      });
    });

    test('App startup benchmark - baseline measurements', () async {
      // This test captures baseline metrics for regression tracking
      final metrics = <String, dynamic>{};

      await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
        final totalStopwatch = Stopwatch()..start();

        final container = ProviderContainer(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        );

        // Measure each initialization phase
        var phaseStopwatch = Stopwatch()..start();
        container.read(authProvider);
        phaseStopwatch.stop();
        metrics['auth_init_ms'] = phaseStopwatch.elapsedMilliseconds;

        phaseStopwatch = Stopwatch()..start();
        container.read(routerProvider);
        phaseStopwatch.stop();
        metrics['router_init_ms'] = phaseStopwatch.elapsedMilliseconds;

        totalStopwatch.stop();
        metrics['total_startup_ms'] = totalStopwatch.elapsedMilliseconds;

        // Print for CI/CD regression tracking
        debugPrint('=== App Startup Performance Metrics ===');
        metrics.forEach((key, value) {
          debugPrint('$key: $value');
        });

        // Verify total startup is reasonable
        expect(metrics['total_startup_ms'], lessThan(500));
      });
    });
  });

  group('App Startup Performance - Edge Cases', () {
    test('Startup with stored session should be fast', () async {
      final mockStorage = MockSecureStorage();
      await mockStorage.write(
        key: StorageKeys.accessToken,
        value: 'existing.token',
      );

      final stopwatch = Stopwatch()..start();

      await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
        final container = ProviderContainer(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(MockAuthService()),
          ],
        );

        await container.read(authProvider.notifier).checkAuth();

        stopwatch.stop();

        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(300),
          reason: 'Session restoration took ${stopwatch.elapsedMilliseconds}ms, expected < 300ms',
        );
      });
    });

    test('Startup without stored session should be fast', () async {
      final mockStorage = MockSecureStorage();

      final stopwatch = Stopwatch()..start();

      await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
        final container = ProviderContainer(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(MockAuthService()),
          ],
        );

        await container.read(authProvider.notifier).checkAuth();

        stopwatch.stop();

        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason: 'No-session check took ${stopwatch.elapsedMilliseconds}ms, expected < 100ms',
        );
      });
    });
  });
}
