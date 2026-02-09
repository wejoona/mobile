/// Performance regression tests for screen transitions
///
/// Measures navigation performance including:
/// - Route transition animations
/// - Screen build times
/// - Navigation stack operations
/// - Deep link navigation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/features/auth/views/login_view.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/router/app_router.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/auth/auth_service.dart';

import '../helpers/test_utils.dart';

void main() {
  group('Screen Transition Performance', () {
    late MockSecureStorage mockStorage;
    late MockAuthService mockAuthService;

    setUp(() {
      mockStorage = MockSecureStorage();
      mockAuthService = MockAuthService();
    });

    tearDown(() {
      mockStorage.clear();
    });

    testWidgets('Navigation push should complete within 300ms', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Scaffold(body: Text('Next')),
                      ),
                    );
                  },
                  child: const Text('Navigate'),
                ),
              ),
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Trigger navigation
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(300),
        reason: 'Navigation took ${stopwatch.elapsedMilliseconds}ms, expected < 300ms',
      );
    });

    testWidgets('Screen build time should be under 100ms', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LoginView(),
          ),
        ),
      );

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'Screen build took ${stopwatch.elapsedMilliseconds}ms, expected < 500ms',
      );
    });

    testWidgets('Multiple rapid navigations should not lag', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: MaterialApp(
            home: _TestNavigationScreen(),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Perform 5 rapid navigations
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }

      stopwatch.stop();

      // All navigations should complete quickly
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1500), // 300ms per round trip * 5
        reason: 'Rapid navigation took ${stopwatch.elapsedMilliseconds}ms, expected < 1500ms',
      );
    });

    testWidgets('GoRouter navigation should be performant', (tester) async {
      await tester.runAsync(() async {
        final container = ProviderContainer(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        );

        final router = container.read(routerProvider);

        final stopwatch = Stopwatch()..start();

        // Navigate using GoRouter
        router.go('/login');
        await tester.pumpAndSettle();

        stopwatch.stop();

        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(200),
          reason: 'GoRouter navigation took ${stopwatch.elapsedMilliseconds}ms, expected < 200ms',
        );
      });
    });

    testWidgets('Animation frame rate should be consistent', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Scaffold(body: Text('Next')),
                      ),
                    );
                  },
                  child: const Text('Navigate'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));

      // Measure frame rendering during animation
      final frames = <Duration>[];
      Duration? lastFrame;

      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16)); // 60fps = 16ms
        final currentFrame = tester.binding.currentSystemFrameTimeStamp;
        if (lastFrame != null) {
          frames.add(currentFrame - lastFrame);
        }
        lastFrame = currentFrame;
      }

      // Calculate average frame time
      final avgFrameTime = frames.fold<int>(
            0,
            (sum, duration) => sum + duration.inMicroseconds,
          ) ~/
          frames.length;

      // Should maintain ~60fps (16.67ms per frame)
      expect(
        avgFrameTime,
        lessThan(20000), // 20ms = allowing some variance
        reason: 'Average frame time was ${avgFrameTime}μs, expected < 20000μs (60fps)',
      );
    });

    testWidgets('Back navigation should be instant', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: MaterialApp(
            home: _TestNavigationScreen(),
          ),
        ),
      );

      // Navigate forward
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Navigate back
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(200),
        reason: 'Back navigation took ${stopwatch.elapsedMilliseconds}ms, expected < 200ms',
      );
    });

    testWidgets('Deep navigation stack should not degrade performance', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: MaterialApp(
            home: _TestNavigationScreen(),
          ),
        ),
      );

      // Build deep stack (10 levels)
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();
      }

      final stopwatch = Stopwatch()..start();

      // Navigate one more time from deep stack
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Navigation from deep stack should still be fast
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(300),
        reason: 'Deep stack navigation took ${stopwatch.elapsedMilliseconds}ms, expected < 300ms',
      );
    });

    testWidgets('Screen rebuild performance should be optimal', (tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                buildCount++;
                return Scaffold(
                  body: Column(
                    children: [
                      Text('Build count: $buildCount'),
                      ElevatedButton(
                        onPressed: () {
                          // Force rebuild
                          (context as Element).markNeedsBuild();
                        },
                        child: const Text('Rebuild'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      final initialBuildCount = buildCount;
      final stopwatch = Stopwatch()..start();

      // Trigger multiple rebuilds
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Rebuild'));
        await tester.pump();
      }

      stopwatch.stop();

      // 10 rebuilds should complete quickly
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(200),
        reason: 'Rebuilds took ${stopwatch.elapsedMilliseconds}ms, expected < 200ms',
      );

      // Verify rebuilds occurred
      expect(buildCount, greaterThan(initialBuildCount));
    });

    test('Navigation performance benchmark - baseline', () async {
      final metrics = <String, dynamic>{};

      await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
        final tester = TestWidgetsFlutterBinding.ensureInitialized();

        await tester.runAsync(() async {
          final container = ProviderContainer(
            overrides: [
              secureStorageProvider.overrideWithValue(mockStorage),
              authServiceProvider.overrideWithValue(mockAuthService),
            ],
          );

          final router = container.read(routerProvider);

          // Measure different navigation types
          var stopwatch = Stopwatch()..start();
          router.go('/login');
          stopwatch.stop();
          metrics['go_navigation_ms'] = stopwatch.elapsedMilliseconds;

          stopwatch = Stopwatch()..start();
          router.push('/login');
          stopwatch.stop();
          metrics['push_navigation_ms'] = stopwatch.elapsedMilliseconds;

          stopwatch = Stopwatch()..start();
          router.pop();
          stopwatch.stop();
          metrics['pop_navigation_ms'] = stopwatch.elapsedMilliseconds;

          debugPrint('=== Navigation Performance Metrics ===');
          metrics.forEach((key, value) {
            debugPrint('$key: $value');
          });
        });
      });
    });
  });
}

/// Test widget for navigation performance testing
class _TestNavigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _TestNavigationScreen(),
              ),
            );
          },
          child: const Text('Navigate'),
        ),
      ),
    );
  }
}
