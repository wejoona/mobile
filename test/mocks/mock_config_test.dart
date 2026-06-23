import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/config/environment_config.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';

void main() {
  group('MockConfig', () {
    test('initializes from USE_MOCKS dart define', () {
      expect(MockConfig.useMocks, EnvironmentConfig.useMocks);
    });

    test('API mocks are limited to development builds', () {
      final source = File(
        'lib/config/environment_config.dart',
      ).readAsStringSync();

      expect(
        source,
        contains('static bool get useMocks => isDevelopment && _useMocks'),
      );
      expect(
        source,
        contains(
          "static const bool _useMocks = bool.fromEnvironment('USE_MOCKS')",
        ),
      );
    });
  });
}
