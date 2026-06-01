import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/mocks/services/devices/devices_mock.dart';

void main() {
  late Dio dio;

  setUp(() {
    MockConfig.enableAllMocks();
    MockConfig.networkDelayMs = 0;

    final interceptor = MockInterceptor();
    DevicesMock.register(interceptor);

    dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'));
    dio.interceptors.add(interceptor);
  });

  tearDown(() {
    MockConfig.disableAllMocks();
  });

  group('DevicesMock', () {
    test('handles the mobile /devices/register route', () async {
      final response = await dio.post(
        '/devices/register',
        data: {
          'deviceIdentifier': 'ios-vendor-id',
          'brand': 'Apple',
          'model': 'iPhone 16e',
          'platform': 'ios',
          'osVersion': '26.2',
          'appVersion': '1.0.0',
        },
      );

      expect(response.statusCode, 200);
      expect(response.data, containsPair('deviceIdentifier', 'ios-vendor-id'));
      expect(response.data, containsPair('platform', 'ios'));
    });

    test('handles the mobile /devices list route', () async {
      final response = await dio.get('/devices');

      expect(response.statusCode, 200);
      expect(response.data['devices'], isA<List<dynamic>>());
    });
  });
}
