import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/config/api_config.dart';

void main() {
  group('ApiConfiguration', () {
    test('defaults development builds to the local Korido API', () {
      expect(ApiConfiguration.baseUrl, 'http://127.0.0.1:3401/api/v1');
    });

    test('derives Socket.IO namespace URL from the resolved API URL', () {
      expect(ApiConfiguration.wsUrl, 'http://127.0.0.1:3401/ws');
    });
  });
}
