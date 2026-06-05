import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final driver = await FlutterDriver.connect();
  await integrationDriver(
    driver: driver,
    onScreenshot: (name, bytes, [args]) async {
      final safeName = name.replaceAll(RegExp('[^a-zA-Z0-9_.-]'), '_');
      final file = File(
        'build/screenshots/korido_live_visual_sweep/$safeName.png',
      );
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
