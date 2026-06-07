import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/mocks/services/config/config_mock.dart';

void main() {
  late Dio dio;

  setUp(() {
    MockConfig.enableAllMocks();
    MockConfig.networkDelayMs = 0;

    final interceptor = MockInterceptor();
    ConfigMock.register(interceptor);

    dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'));
    dio.interceptors.add(interceptor);
  });

  tearDown(() {
    MockConfig.disableAllMocks();
  });

  group('ConfigMock', () {
    test('handles the public /config/countries route', () async {
      final response = await dio.get('/config/countries');
      final countries = response.data['countries'] as List<dynamic>;

      expect(response.statusCode, 200);
      expect(countries, isNotEmpty);
      expect(
        countries,
        contains(
          isA<Map<String, dynamic>>()
              .having((country) => country['code'], 'code', 'CI')
              .having((country) => country['prefix'], 'prefix', '225')
              .having(
                (country) => country['currencies'],
                'currencies',
                contains('XOF'),
              ),
        ),
      );
      expect(
        countries,
        contains(
          isA<Map<String, dynamic>>()
              .having((country) => country['code'], 'code', 'US')
              .having((country) => country['prefix'], 'prefix', '1')
              .having(
                (country) => country['currencies'],
                'currencies',
                contains('USD'),
              ),
        ),
      );
    });
  });
}
