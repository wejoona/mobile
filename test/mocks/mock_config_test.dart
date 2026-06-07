import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/config/environment_config.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';

void main() {
  group('MockConfig', () {
    test('initializes from USE_MOCKS dart define', () {
      expect(MockConfig.useMocks, EnvironmentConfig.useMocks);
    });
  });
}
