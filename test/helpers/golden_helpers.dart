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

/// Check if golden file tests should run (CI only by default).
bool get shouldRunGoldens {
  return Platform.environment['CI'] == 'true' ||
      Platform.environment['UPDATE_GOLDENS'] == 'true';
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
