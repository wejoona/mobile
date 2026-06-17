import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/mocks/mock_registry.dart';
import 'package:usdc_wallet/mocks/services/auth/auth_mock.dart';
import 'package:usdc_wallet/mocks/services/wallet/wallet_mock.dart';

void main() {
  late bool previousUseMocks;
  late bool previousBlockUnmocked;
  late int previousDelay;

  setUp(() {
    previousUseMocks = MockConfig.useMocks;
    previousBlockUnmocked = MockConfig.blockUnmockedRequests;
    previousDelay = MockConfig.networkDelayMs;
    MockConfig.useMocks = true;
    MockConfig.blockUnmockedRequests = true;
    MockConfig.networkDelayMs = 0;
    MockRegistry.initialize();
    MockRegistry.reset();
  });

  tearDown(() {
    MockRegistry.clear();
    MockConfig.useMocks = previousUseMocks;
    MockConfig.blockUnmockedRequests = previousBlockUnmocked;
    MockConfig.networkDelayMs = previousDelay;
  });

  test('internal transfer requires a PIN token', () async {
    final dio = await _authenticatedDio();

    await expectLater(
      dio.post(
        '/wallet/transfer/internal',
        data: {'toPhone': '+2250708091011', 'amount': 5, 'currency': 'USDC'},
      ),
      throwsA(
        isA<DioException>()
            .having((error) => error.response?.statusCode, 'status', 400)
            .having(
              (error) => error.response?.data,
              'data',
              containsPair(
                'error',
                'PIN verification required for this operation',
              ),
            ),
      ),
    );
  });

  test(
    'internal transfer updates wallet and canonical history together',
    () async {
      final dio = await _authenticatedDio();
      _ensureCurrentWalletBalance(minUsdc: 50);

      final walletBefore = await dio.get('/wallet');
      final openingBalance = _balanceUsdc(walletBefore.data);

      final transferResponse = await dio.post(
        '/wallet/transfer/internal',
        data: {
          'toPhone': '+2250708091011',
          'amount': 12.25,
          'currency': 'USDC',
          'note': 'Mock invariant check',
        },
        options: Options(headers: {'X-Pin-Token': 'mock_pin_token_test'}),
      );

      final transfer = transferResponse.data as Map<String, dynamic>;
      expect(transfer['status'], 'completed');
      expect(transfer['type'], 'internal');
      expect(transfer['amount'], 12.25);
      expect(transfer['recipientPhone'], '+2250708091011');

      final walletAfter = await dio.get('/wallet');
      expect(
        _balanceUsdc(walletAfter.data),
        closeTo(openingBalance - 12.25, 0.001),
      );

      final historyResponse = await dio.get('/wallet/transactions');
      final transactions =
          (historyResponse.data as Map<String, dynamic>)['transactions']
              as List<dynamic>;
      final firstTransaction = transactions.first as Map<String, dynamic>;
      expect(firstTransaction['type'], 'transfer_internal');
      expect(firstTransaction['status'], 'completed');
      expect(firstTransaction['amount'], -12.25);
      expect(firstTransaction['recipientPhone'], '+2250708091011');
    },
  );

  test(
    'deposit initiation returns status payload addressable by deposit id',
    () async {
      final dio = await _authenticatedDio();

      final initiateResponse = await dio.post(
        '/deposits/initiate',
        data: {'providerCode': 'OMCI', 'amount': 5000, 'currency': 'XOF'},
      );
      final deposit = initiateResponse.data as Map<String, dynamic>;
      final depositId = deposit['depositId'] as String;

      final statusResponse = await dio.get('/deposits/$depositId');
      final status = statusResponse.data as Map<String, dynamic>;

      expect(depositId, isNotEmpty);
      expect(status['depositId'] ?? status['id'], isA<String>());
      expect(status['status'], isA<String>());
      expect(status['amount'], isA<num>());
    },
  );
}

Future<Dio> _authenticatedDio() async {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'));
  dio.interceptors.add(MockRegistry.interceptor);

  await dio.post('/auth/login', data: {'phone': '0748805663'});
  await dio.post(
    '/auth/verify-otp',
    data: {'phone': '0748805663', 'otp': '123456'},
  );

  return dio;
}

double _balanceUsdc(Object? data) {
  final wallet = data! as Map<String, dynamic>;
  return (wallet['balanceUsdc'] as num).toDouble();
}

void _ensureCurrentWalletBalance({required double minUsdc}) {
  final userId = AuthMockState.currentUserId;
  if (userId == null) {
    return;
  }

  final wallet =
      WalletMockState.getWallet(userId) ?? WalletMockState.createWallet(userId);
  if (wallet.balanceUsdc < minUsdc) {
    final delta = minUsdc - wallet.balanceUsdc;
    WalletMockState.updateBalance(userId, delta, delta * 655.957);
  }
}
