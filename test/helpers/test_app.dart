import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wraps a widget in MaterialApp + ProviderScope for testing.
Widget buildTestApp(
  Widget child, {
  List<Override> overrides = const [],
  NavigatorObserver? navigatorObserver,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
      navigatorObservers: [
        if (navigatorObserver != null) navigatorObserver,
      ],
    ),
  );
}

/// Wraps a widget in Scaffold for isolated widget tests.
Widget buildTestWidget(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return buildTestApp(
    Scaffold(body: child),
    overrides: overrides,
  );
}
