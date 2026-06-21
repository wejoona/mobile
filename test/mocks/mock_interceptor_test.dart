import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/mocks/mock_registry.dart';

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
  });

  tearDown(() {
    MockRegistry.clear();
    MockConfig.useMocks = previousUseMocks;
    MockConfig.blockUnmockedRequests = previousBlockUnmocked;
    MockConfig.networkDelayMs = previousDelay;
  });

  test(
    'matches api-prefixed mock routes from app-local request paths',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'));
      final interceptor = MockInterceptor()
        ..register(
          method: 'GET',
          path: '/api/v1/beneficiaries/:id',
          handler: (_) async => MockResponse.success({'id': 'ben_123'}),
        );
      dio.interceptors.add(interceptor);

      final response = await dio.get('/beneficiaries/ben_123');

      expect(response.data, {'id': 'ben_123'});
    },
  );

  test('matches regex-style mock route registrations', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'));
    final interceptor = MockInterceptor()
      ..register(
        method: 'GET',
        path: r'/cards/[\w-]+',
        handler: (_) async => MockResponse.success({'id': 'card_123'}),
      );
    dio.interceptors.add(interceptor);

    final response = await dio.get('/cards/card_123');

    expect(response.data, {'id': 'card_123'});
  });

  test(
    'blocks unregistered mock routes with deterministic fallback data',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'));
      dio.interceptors.add(MockInterceptor());

      final response = await dio.get('/config/countries');
      final data = response.data as Map<String, dynamic>;

      expect(data['countries'], isNotEmpty);
    },
  );

  test('supports mocked login through wallet home core calls', () async {
    MockRegistry.initialize();
    MockRegistry.reset();

    final dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'));
    dio.interceptors.add(MockRegistry.interceptor);

    await dio.post('/auth/login', data: {'phone': '0748805663'});
    await dio.post(
      '/auth/verify-otp',
      data: {'phone': '0748805663', 'otp': '123456'},
    );

    final walletResponse = await dio.get('/wallet');
    final wallet = walletResponse.data as Map<String, dynamic>;
    final openingBalance = (wallet['balanceUsdc'] as num).toDouble();
    expect(wallet['balances'], isNotEmpty);

    final depositProvidersResponse = await dio.get('/deposits/providers');
    final depositProvidersBody =
        depositProvidersResponse.data as Map<String, dynamic>;
    final depositProviders = depositProvidersBody['providers'] as List<dynamic>;
    expect(depositProviders, isNotEmpty);

    final transferResponse = await dio.post(
      '/wallet/transfer/internal',
      data: {'toPhone': '+2250700000000', 'amount': 10, 'currency': 'USDC'},
      options: Options(headers: {'X-Pin-Token': 'mock_pin_token_test'}),
    );
    final transfer = transferResponse.data as Map<String, dynamic>;
    expect(transfer['status'], isNotEmpty);

    final updatedWalletResponse = await dio.get('/wallet');
    final updatedWallet = updatedWalletResponse.data as Map<String, dynamic>;
    expect(updatedWallet['balanceUsdc'], openingBalance - 10);

    final transactionsResponse = await dio.get('/wallet/transactions');
    final transactions = transactionsResponse.data as Map<String, dynamic>;
    final firstTransaction =
        (transactions['transactions'] as List<dynamic>).first
            as Map<String, dynamic>;
    expect(firstTransaction['type'], 'transfer_internal');
    expect(firstTransaction['amount'], -10);
    expect(firstTransaction['recipientPhone'], '+2250700000000');
  });

  test('serves device list from the canonical devices mock', () async {
    MockRegistry.initialize();
    MockRegistry.reset();

    final dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'));
    dio.interceptors.add(MockRegistry.interceptor);

    final initialResponse = await dio.get('/devices');
    final initialData = initialResponse.data as Map<String, dynamic>;
    final initialDevices = (initialData['devices'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    expect(initialDevices.length, 3);
    expect(
      initialDevices.map((device) => device['model']),
      containsAll(['iPhone 15 Pro', 'MacBook Pro', 'Galaxy S23']),
    );

    await dio.post(
      '/devices/register',
      data: {
        'deviceIdentifier': 'simulator-device',
        'model': 'iPhone 16e',
        'platform': 'ios',
      },
    );

    final registeredResponse = await dio.get('/devices');
    final registeredData = registeredResponse.data as Map<String, dynamic>;
    expect(registeredData['devices'], hasLength(4));

    MockRegistry.reset();

    final resetResponse = await dio.get('/devices');
    final resetData = resetResponse.data as Map<String, dynamic>;
    expect(resetData['devices'], hasLength(3));
  });

  test('supports notification preference read and update routes', () async {
    MockRegistry.initialize();
    MockRegistry.reset();

    final dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'));
    dio.interceptors.add(MockRegistry.interceptor);

    final initialResponse = await dio.get('/notifications/preferences');
    final initialPrefs = initialResponse.data as Map<String, dynamic>;
    expect(initialPrefs['pushMarketing'], isFalse);

    final updateResponse = await dio.put(
      '/notifications/preferences',
      data: {
        'categories': {'marketing': true},
      },
    );
    final updatedPrefs = updateResponse.data as Map<String, dynamic>;
    expect(updatedPrefs['pushMarketing'], isTrue);
    expect(updatedPrefs['categories'], containsPair('marketing', true));

    final persistedResponse = await dio.get('/notifications/preferences');
    final persistedPrefs = persistedResponse.data as Map<String, dynamic>;
    expect(persistedPrefs['pushMarketing'], isTrue);
    expect(persistedPrefs['categories'], containsPair('marketing', true));

    MockRegistry.reset();

    final resetResponse = await dio.get('/notifications/preferences');
    final resetPrefs = resetResponse.data as Map<String, dynamic>;
    expect(resetPrefs['pushMarketing'], isFalse);
  });

  test(
    'serves contacts with Korido account identifiers for send flows',
    () async {
      MockRegistry.initialize();
      MockRegistry.reset();

      final dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'));
      dio.interceptors.add(MockRegistry.interceptor);

      final response = await dio.get('/contacts');
      final data = response.data as Map<String, dynamic>;
      final contacts = (data['data'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final koridoUsers = contacts
          .where((contact) => contact['isKoridoUser'] == true)
          .toList();
      final invitees = contacts
          .where((contact) => contact['isKoridoUser'] != true)
          .toList();

      expect(koridoUsers, hasLength(3));
      expect(invitees, hasLength(2));
      expect(
        koridoUsers.map((contact) => contact['joonaPayUserId']),
        everyElement(isA<String>().having((id) => id, 'id', isNotEmpty)),
      );
    },
  );

  test('serves Korido user lookup results for recipient search', () async {
    MockRegistry.initialize();
    MockRegistry.reset();

    final dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'));
    dio.interceptors.add(MockRegistry.interceptor);

    final response = await dio.get(
      '/contacts/lookup',
      queryParameters: {'query': 'ama'},
    );
    final data = response.data as Map<String, dynamic>;
    final users = (data['users'] as List<dynamic>).cast<Map<String, dynamic>>();

    expect(users, isNotEmpty);
    expect(users.first['name'], contains('Amadou'));
    expect(users.first['phone'], startsWith('+'));
    expect(users.first['isKoridoUser'], isTrue);
  });

  test(
    'persists profile updates against the authenticated mock user',
    () async {
      MockRegistry.initialize();
      MockRegistry.reset();

      final dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'));
      dio.interceptors.add(MockRegistry.interceptor);

      await dio.post('/auth/login', data: {'phone': '0748805663'});
      await dio.post(
        '/auth/verify-otp',
        data: {'phone': '0748805663', 'otp': '123456'},
      );

      await dio.put(
        '/user/profile',
        data: {
          'firstName': 'Josue',
          'lastName': 'Kouakou',
          'email': 'josue.kouakou@example.com',
        },
      );

      final response = await dio.get('/user/profile');
      final profile = response.data as Map<String, dynamic>;

      expect(profile['phone'], '0748805663');
      expect(profile['firstName'], 'Josue');
      expect(profile['lastName'], 'Kouakou');
      expect(profile['displayName'], 'Josue Kouakou');
      expect(profile['email'], 'josue.kouakou@example.com');
    },
  );

  test('serves mock avatar data without network-only relative urls', () async {
    MockRegistry.initialize();
    MockRegistry.reset();

    final dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'));
    dio.interceptors.add(MockRegistry.interceptor);

    await dio.post('/auth/login', data: {'phone': '0748805663'});
    await dio.post(
      '/auth/verify-otp',
      data: {'phone': '0748805663', 'otp': '123456'},
    );

    final uploadResponse = await dio.post('/user/avatar', data: {});
    final upload = uploadResponse.data as Map<String, dynamic>;
    expect(upload['avatarUrl'], isNull);
    expect(upload['avatarThumb'], startsWith('data:image/png;base64,'));

    final profileResponse = await dio.get('/user/profile');
    final profile = profileResponse.data as Map<String, dynamic>;
    expect(profile['avatarUrl'], isNull);
    expect(profile['avatarThumb'], upload['avatarThumb']);

    await dio.delete('/user/avatar');

    final clearedResponse = await dio.get('/user/profile');
    final cleared = clearedResponse.data as Map<String, dynamic>;
    expect(cleared['avatarUrl'], isNull);
    expect(cleared['avatarThumb'], isNull);
  });

  test('required app routes return parseable mock contracts', () async {
    MockRegistry.initialize();
    MockRegistry.reset();

    final dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'));
    dio.interceptors.add(MockRegistry.interceptor);

    await dio.post('/auth/login', data: {'phone': '0748805663'});
    await dio.post(
      '/auth/verify-otp',
      data: {'phone': '0748805663', 'otp': '123456'},
    );

    final requiredRoutes = <({String method, String path, Object? data})>[
      (method: 'GET', path: '/wallet', data: null),
      (method: 'GET', path: '/wallet/transactions', data: null),
      (
        method: 'POST',
        path: '/wallet/transfer/internal',
        data: {'toPhone': '+2250708091011', 'amount': 5, 'currency': 'USDC'},
      ),
      (method: 'GET', path: '/deposits/providers', data: null),
      (
        method: 'POST',
        path: '/wallet/deposit',
        data: {
          'channelId': 'orange_money_ci',
          'amount': 5000,
          'sourceCurrency': 'XOF',
        },
      ),
      (method: 'GET', path: '/deposits', data: null),
      (method: 'GET', path: '/contacts', data: null),
      (
        method: 'POST',
        path: '/contacts/sync',
        data: {
          'phoneHashes': ['mock_hash_amadou', 'mock_hash_invitee'],
        },
      ),
      (method: 'GET', path: '/contacts/lookup', data: null),
      (method: 'GET', path: '/beneficiaries', data: null),
      (method: 'GET', path: '/devices', data: null),
      (method: 'GET', path: '/notifications/preferences', data: null),
      (method: 'GET', path: '/user/profile', data: null),
    ];

    for (final route in requiredRoutes) {
      final response = await _requestRoute(
        dio,
        method: route.method,
        path: route.path,
        data: route.data,
      );

      expect(
        response.statusCode,
        inInclusiveRange(200, 299),
        reason: '${route.method} ${route.path} should be registered',
      );
      _expectParseableRoute(route.path, response.data);
    }
  });

  test('deposit mocks reject retired legacy deposit writes', () async {
    MockRegistry.initialize();
    MockRegistry.reset();

    final dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'));
    dio.interceptors.add(MockRegistry.interceptor);

    await dio.post('/auth/login', data: {'phone': '0748805663'});
    await dio.post(
      '/auth/verify-otp',
      data: {'phone': '0748805663', 'otp': '123456'},
    );

    await expectLater(
      dio.post(
        '/deposits/initiate',
        data: {'provider': 'OMCI', 'amount': 5000},
      ),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'status',
          410,
        ),
      ),
    );
  });
}

Future<Response<dynamic>> _requestRoute(
  Dio dio, {
  required String method,
  required String path,
  Object? data,
}) {
  final options = Options(
    method: method,
    headers: method == 'POST' && path == '/wallet/transfer/internal'
        ? {'X-Pin-Token': 'mock_pin_token_test'}
        : null,
  );
  return dio.request(path, data: data, options: options);
}

void _expectParseableRoute(String path, Object? data) {
  switch (path) {
    case '/wallet':
      final wallet = _expectMap(path, data);
      expect(wallet['balanceUsdc'], isA<num>());
      expect(wallet['balances'], isA<List<dynamic>>());
      return;
    case '/wallet/transactions':
      expect(
        _extractList(path, data, ['transactions', 'data', 'items']),
        isNotEmpty,
      );
      return;
    case '/wallet/transfer/internal':
      final transfer = _expectMap(path, data);
      expect(transfer['id'], isA<String>());
      expect(transfer['status'], isA<String>());
      return;
    case '/deposits/providers':
      expect(
        _extractList(path, data, ['providers', 'data', 'items']),
        isNotEmpty,
      );
      return;
    case '/wallet/deposit':
      final deposit = _expectMap(path, data);
      expect(deposit['depositId'] ?? deposit['id'], isA<String>());
      expect(deposit['status'], isA<String>());
      return;
    case '/deposits':
      final deposits = _extractList(path, data, ['deposits', 'data', 'items']);
      expect(deposits, isA<List<dynamic>>());
      return;
    case '/contacts':
      final contacts = _extractList(path, data, ['contacts', 'data', 'items']);
      expect(contacts, isNotEmpty);
      expect(contacts.first, containsPair('isKoridoUser', isA<bool>()));
      return;
    case '/contacts/sync':
      final sync = _expectMap(path, data);
      expect(sync['matches'], isA<List<dynamic>>());
      expect(sync['totalChecked'], isA<int>());
      return;
    case '/contacts/lookup':
      final lookup = _expectMap(path, data);
      expect(lookup['users'], isA<List<dynamic>>());
      expect(lookup['total'], isA<int>());
      return;
    case '/beneficiaries':
      final beneficiaries = _extractList(path, data, [
        'beneficiaries',
        'data',
        'items',
      ]);
      expect(beneficiaries, isNotEmpty);
      expect(beneficiaries.first, containsPair('accountType', isA<String>()));
      return;
    case '/devices':
      expect(
        _extractList(path, data, ['devices', 'data', 'items']),
        isNotEmpty,
      );
      return;
    case '/notifications/preferences':
      final prefs = _expectMap(path, data);
      expect(prefs['channels'], isA<Map<String, dynamic>>());
      expect(prefs['categories'], isA<Map<String, dynamic>>());
      return;
    case '/user/profile':
      final profile = _expectMap(path, data);
      expect(profile['id'], isA<String>());
      expect(profile['phone'], isA<String>());
      return;
  }
  fail('No parse assertion registered for $path');
}

Map<String, dynamic> _expectMap(String path, Object? data) {
  expect(data, isA<Map<String, dynamic>>(), reason: path);
  return data! as Map<String, dynamic>;
}

List<dynamic> _extractList(String path, Object? data, List<String> keys) {
  if (data is List<dynamic>) return data;
  if (data is Map<String, dynamic>) {
    for (final key in keys) {
      final value = data[key];
      if (value is List<dynamic>) return value;
    }
  }
  fail('$path did not expose a parseable list envelope');
}
