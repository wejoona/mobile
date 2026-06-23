import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/mocks/services/deposit/deposit_mock.dart';

void main() {
  late Dio dio;

  setUp(() {
    MockConfig.enableAllMocks();
    MockConfig.networkDelayMs = 0;

    final interceptor = MockInterceptor();
    DepositMock.register(interceptor);

    dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'));
    dio.interceptors.add(interceptor);
  });

  tearDown(() {
    MockConfig.disableAllMocks();
  });

  group('DepositMock', () {
    test('handles the mobile /wallet/deposit/channels route', () async {
      final response = await dio.get(
        '/wallet/deposit/channels',
        queryParameters: {'currency': 'XOF'},
      );

      final channels = response.data['channels'] as List<dynamic>;

      expect(response.statusCode, 200);
      expect(channels, isNotEmpty);
      expect(
        channels,
        contains(
          isA<Map<String, dynamic>>()
              .having((channel) => channel['id'], 'id', 'wave-ci')
              .having((channel) => channel['currency'], 'currency', 'XOF')
              .having((channel) => channel['type'], 'type', 'mobile_money'),
        ),
      );
    });

    test('handles the mobile /wallet/deposit route', () async {
      final response = await dio.post(
        '/wallet/deposit',
        data: {
          'amount': 50000,
          'sourceCurrency': 'XOF',
          'channelId': 'wave-ci',
        },
      );

      expect(response.statusCode, 200);
      expect(response.data['depositId'], isA<String>());
      expect(response.data['sourceCurrency'], 'XOF');
      expect(response.data['paymentInstructions']['provider'], 'Wave');
    });

    test('handles wallet rate aliases with string query amounts', () async {
      final response = await dio.get(
        '/wallet/exchange-rate',
        queryParameters: {
          'sourceCurrency': 'XOF',
          'targetCurrency': 'USD',
          'amount': '1000',
        },
      );

      expect(response.statusCode, 200);
      expect(response.data['sourceCurrency'], 'XOF');
      expect(response.data['fromCurrency'], 'XOF');
      expect(response.data['sourceAmount'], 1000);
    });

    test('handles legacy /deposits providers and rate routes', () async {
      final providersResponse = await dio.get('/deposits/providers');
      final rateResponse = await dio.get(
        '/deposits/rate',
        queryParameters: {'sourceCurrency': 'XOF', 'targetCurrency': 'USD'},
      );

      expect(providersResponse.statusCode, 200);
      expect(providersResponse.data['providers'], isA<List<dynamic>>());
      expect(
        providersResponse.data['providers'],
        contains(
          isA<Map<String, dynamic>>()
              .having((provider) => provider['code'], 'code', 'WAVECI')
              .having(
                (provider) => provider['paymentMethodType'],
                'paymentMethodType',
                'QR_LINK',
              ),
        ),
      );
      expect(rateResponse.statusCode, 200);
      expect(rateResponse.data['fromCurrency'], 'XOF');
      expect(rateResponse.data['toCurrency'], 'USD');
    });

    test(
      'handles canonical /wallet/deposit initiation and status routes',
      () async {
        final initiateResponse = await dio.post(
          '/wallet/deposit',
          data: {
            'amount': 50000,
            'sourceCurrency': 'XOF',
            'channelId': 'wave-ci',
          },
        );
        final depositId = initiateResponse.data['depositId'] as String;
        final statusResponse = await dio.get('/wallet/deposit/$depositId');

        expect(initiateResponse.statusCode, 200);
        expect(initiateResponse.data['paymentMethodType'], 'mobile_money');
        expect(initiateResponse.data['channelId'], 'wave-ci');
        expect(initiateResponse.data['status'], 'processing');
        expect(statusResponse.statusCode, 200);
        expect(statusResponse.data['depositId'], depositId);
      },
    );

    test('retired legacy /deposits/initiate rejects writes', () async {
      await expectLater(
        dio.post(
          '/deposits/initiate',
          data: {'amount': 50000, 'currency': 'XOF', 'providerCode': 'WAVECI'},
        ),
        throwsA(
          isA<DioException>()
              .having((error) => error.response?.statusCode, 'status', 410)
              .having(
                (error) => error.response?.data['error']['code'],
                'code',
                'DEPOSIT_WRITE_ENDPOINT_RETIRED',
              ),
        ),
      );
    });
  });
}
