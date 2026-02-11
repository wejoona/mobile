import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper extensions for WidgetTester.
extension PumpHelpers on WidgetTester {
  /// Pump and settle with a timeout.
  Future<void> pumpAndSettleWithTimeout({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      timeout,
    );
  }

  /// Pump until a widget of type T appears.
  Future<void> pumpUntilFound<T extends Widget>({
    int maxPumps = 50,
  }) async {
    for (var i = 0; i < maxPumps; i++) {
      await pump(const Duration(milliseconds: 100));
      if (find.byType(T).evaluate().isNotEmpty) return;
    }
    throw Exception('Widget $T not found after $maxPumps pumps');
  }

  /// Tap and pump.
  Future<void> tapAndPump(Finder finder) async {
    await tap(finder);
    await pump();
  }

  /// Enter text into a field and pump.
  Future<void> enterTextAndPump(Finder finder, String text) async {
    await enterText(finder, text);
    await pump();
  }
}
