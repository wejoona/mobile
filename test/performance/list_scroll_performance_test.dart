@Skip("Performance tests are environment-sensitive; run manually")
library;

/// Performance regression tests for list scrolling
///
/// Measures scrolling performance including:
/// - ListView rendering
/// - Scroll frame rates
/// - Large dataset handling
/// - Lazy loading performance

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('List Scroll Performance', () {
    testWidgets('ListView with 100 items should render quickly', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('Item $index'),
                  subtitle: Text('Description for item $index'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'ListView render took ${stopwatch.elapsedMilliseconds}ms, expected < 500ms',
      );
    });

    testWidgets('Scrolling through 1000 items should be smooth', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 1000,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: Text('$index')),
                  title: Text('Transaction $index'),
                  subtitle: Text('Amount: \$${(index * 10).toStringAsFixed(2)}'),
                  trailing: Text('${index}h ago'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Scroll through items
      await tester.drag(find.byType(ListView), const Offset(0, -5000));
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Scroll operation took ${stopwatch.elapsedMilliseconds}ms, expected < 1000ms',
      );
    });

    testWidgets('Scroll frame rate should maintain 60fps', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 500,
              itemBuilder: (context, index) {
                return Container(
                  height: 80,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100 * (index % 9)],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text('Item $index'),
                    subtitle: Text('Subtitle $index'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final frames = <Duration>[];
      Duration? lastFrame;

      // Start scrolling
      final gesture = await tester.startGesture(const Offset(200, 300));
      await tester.pump();

      // Measure frames during scroll
      for (int i = 0; i < 20; i++) {
        await gesture.moveBy(const Offset(0, -50));
        await tester.pump(const Duration(milliseconds: 16));

        final currentFrame = tester.binding.currentSystemFrameTimeStamp;
        if (lastFrame != null) {
          frames.add(currentFrame - lastFrame);
        }
        lastFrame = currentFrame;
      }

      await gesture.up();
      await tester.pumpAndSettle();

      // Calculate average frame time
      final avgFrameTime = frames.fold<int>(
            0,
            (sum, duration) => sum + duration.inMicroseconds,
          ) ~/
          frames.length;

      // Should maintain ~60fps (16.67ms per frame)
      expect(
        avgFrameTime,
        lessThan(20000), // 20ms with some tolerance
        reason: 'Average scroll frame time was ${avgFrameTime}μs, expected < 20000μs',
      );
    });

    testWidgets('Fling scroll should be responsive', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 1000,
              itemBuilder: (context, index) {
                return ListTile(title: Text('Item $index'));
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Fling gesture
      await tester.fling(
        find.byType(ListView),
        const Offset(0, -500),
        1000, // velocity
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(2000),
        reason: 'Fling animation took ${stopwatch.elapsedMilliseconds}ms, expected < 2000ms',
      );
    });

    testWidgets('ListView with complex items should not drop frames', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 200,
              itemBuilder: (context, index) {
                return _ComplexListItem(index: index);
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Scroll through complex items
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump(const Duration(milliseconds: 100));

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(800),
        reason: 'Complex list scroll took ${stopwatch.elapsedMilliseconds}ms, expected < 800ms',
      );
    });

    testWidgets('Rapid scroll direction changes should be smooth', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 500,
              itemBuilder: (context, index) {
                return ListTile(title: Text('Item $index'));
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pump();

      // Scroll up
      await tester.drag(find.byType(ListView), const Offset(0, 1000));
      await tester.pump();

      // Scroll down again
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Directional changes took ${stopwatch.elapsedMilliseconds}ms, expected < 1000ms',
      );
    });

    testWidgets('GridView should perform well', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
              ),
              itemCount: 300,
              itemBuilder: (context, index) {
                return Card(
                  child: Center(child: Text('$index')),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(600),
        reason: 'GridView render took ${stopwatch.elapsedMilliseconds}ms, expected < 600ms',
      );
    });

    testWidgets('CustomScrollView with multiple slivers should be performant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const SliverAppBar(
                  title: Text('Performance Test'),
                  floating: true,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ListTile(title: Text('List Item $index')),
                    childCount: 100,
                  ),
                ),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Card(child: Center(child: Text('Grid $index'))),
                    childCount: 50,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Scroll through all slivers
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -5000));
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1500),
        reason: 'CustomScrollView scroll took ${stopwatch.elapsedMilliseconds}ms, expected < 1500ms',
      );
    });

    testWidgets('ListView.separated should be efficient', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.separated(
              itemCount: 200,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text('Contact $index'),
                  subtitle: Text('phone-$index@example.com'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'ListView.separated render took ${stopwatch.elapsedMilliseconds}ms, expected < 500ms',
      );
    });

    test('List scrolling benchmark - baseline metrics', () async {
      final metrics = <String, dynamic>{};

      // Simple baseline metrics without widget testing
      final stopwatch = Stopwatch()..start();

      // Measure list creation time
      final smallList = List.generate(50, (index) => 'Item $index');
      metrics['small_list_create_ms'] = stopwatch.elapsedMilliseconds;

      stopwatch.reset();
      stopwatch.start();

      final mediumList = List.generate(500, (index) => 'Item $index');
      stopwatch.stop();
      metrics['medium_list_create_ms'] = stopwatch.elapsedMilliseconds;

      debugPrint('=== List Scroll Performance Metrics ===');
      metrics.forEach((key, value) {
        debugPrint('$key: $value');
      });

      // Verify lists were created
      expect(smallList.length, equals(50));
      expect(mediumList.length, equals(500));
    });
  });

  group('List Performance - Transaction List Simulation', () {
    testWidgets('Transaction history list should scroll smoothly', (tester) async {
      // Simulate real-world transaction list
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: 500,
                itemBuilder: (context, index) {
                  return _TransactionListItem(
                    title: 'Transaction #$index',
                    amount: (index * 12.50).toStringAsFixed(2),
                    date: '2026-01-${30 - (index % 30)}',
                    type: index % 2 == 0 ? 'send' : 'receive',
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Scroll through transactions
      await tester.drag(find.byType(ListView), const Offset(0, -4000));
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Transaction list scroll took ${stopwatch.elapsedMilliseconds}ms, expected < 1000ms',
      );
    });
  });
}

/// Complex list item widget for performance testing
class _ComplexListItem extends StatelessWidget {
  final int index;

  const _ComplexListItem({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[100 * (index % 9)],
              child: Text('$index'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complex Item $index',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Description for item $index with multiple lines of text'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16),
                      const SizedBox(width: 4),
                      Text('${index % 5} stars'),
                      const Spacer(),
                      Text('${index}h ago'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction list item widget for realistic testing
class _TransactionListItem extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final String type;

  const _TransactionListItem({
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: type == 'send' ? Colors.red[100] : Colors.green[100],
        child: Icon(
          type == 'send' ? Icons.arrow_upward : Icons.arrow_downward,
          color: type == 'send' ? Colors.red : Colors.green,
        ),
      ),
      title: Text(title),
      subtitle: Text(date),
      trailing: Text(
        '${type == 'send' ? '-' : '+'}\$$amount',
        style: TextStyle(
          color: type == 'send' ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
