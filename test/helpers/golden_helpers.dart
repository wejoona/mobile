import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helpers for golden (screenshot) tests.

/// Device sizes for golden tests.
class GoldenDevices {
  GoldenDevices._();

  static const Size iPhoneSE = Size(375, 667);
  static const Size iPhone14 = Size(390, 844);
  static const Size iPhone14ProMax = Size(430, 932);
  static const Size pixel7 = Size(412, 915);
  static const Size iPadMini = Size(744, 1133);
}

/// Check if golden file tests should run.
///
/// Goldens are intentionally opt-in. CI providers set `CI=true` for every
/// build, but visual baselines are platform-sensitive and should only gate a
/// deploy when the pipeline explicitly asks for them.
bool get shouldRunGoldens {
  return Platform.environment['RUN_GOLDENS'] == 'true' ||
      Platform.environment['UPDATE_GOLDENS'] == 'true' ||
      const bool.fromEnvironment('RUN_GOLDENS') ||
      const bool.fromEnvironment('UPDATE_GOLDENS');
}

String? get goldenSkipReason => shouldRunGoldens
    ? null
    : 'Set RUN_GOLDENS=true or UPDATE_GOLDENS=true to run golden tests';

void goldenGroup(String description, void Function() body) {
  group(description, body, skip: goldenSkipReason);
}

bool skipVisualSuiteIfDisabled() {
  if (shouldRunGoldens) return false;

  group('visual suite disabled', () {
    test(
      'enable golden snapshots explicitly',
      () {},
      skip:
          'Golden/snapshot tests are opt-in. Set RUN_GOLDENS=true or UPDATE_GOLDENS=true.',
    );
  });
  return true;
}

/// Wrap a widget for golden testing with a specific device size.
Widget goldenWrapper(
  Widget child, {
  Size size = GoldenDevices.iPhone14,
  Brightness brightness = Brightness.light,
}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: MaterialApp(
      theme: brightness == Brightness.light
          ? ThemeData.light()
          : ThemeData.dark(),
      home: child,
      debugShowCheckedModeBanner: false,
    ),
  );
}
