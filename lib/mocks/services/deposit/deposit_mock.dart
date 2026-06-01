import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// Deposit Mock
class DepositMock {
  static void register(MockInterceptor interceptor) {
    // GET /wallet/deposit/channels - Mobile app contract.
    interceptor.register(
      method: 'GET',
      path: '/wallet/deposit/channels',
      handler: _handleGetChannels,
    );

    // Keep the historical absolute mock path supported for older tests/tools.
    interceptor.register(
      method: 'GET',
      path: '/api/v1/wallet/deposit/channels',
      handler: _handleGetChannels,
    );

    // POST /wallet/deposit - Initiate deposit.
    interceptor.register(
      method: 'POST',
      path: '/wallet/deposit',
      handler: _handleInitiateDeposit,
    );

    interceptor.register(
      method: 'POST',
      path: '/api/v1/wallet/deposit',
      handler: _handleInitiateDeposit,
    );

    // POST /deposits/initiate - Legacy deposit feature contract.
    interceptor.register(
      method: 'POST',
      path: '/deposits/initiate',
      handler: _handleInitiateMobileMoneyDeposit,
    );

    // POST /deposits/confirm - Confirm a provider-side payment.
    interceptor.register(
      method: 'POST',
      path: '/deposits/confirm',
      handler: _handleConfirmDeposit,
    );

    // GET /deposits/providers - Legacy provider list.
    interceptor.register(
      method: 'GET',
      path: '/deposits/providers',
      handler: _handleGetProviders,
    );

    // GET /deposits - Legacy user deposit list.
    interceptor.register(
      method: 'GET',
      path: '/deposits',
      handler: _handleListDeposits,
    );

    // GET /deposits/:id - Legacy deposit status.
    interceptor.register(
      method: 'GET',
      path: r'/deposits/[\w-]+',
      handler: _handleGetLegacyDepositStatus,
    );

    // GET /api/v1/wallet/deposit/:id - Get deposit status
    interceptor.register(
      method: 'GET',
      path: r'/wallet/deposit/[\w-]+',
      handler: _handleGetDepositStatus,
    );

    interceptor.register(
      method: 'GET',
      path: r'/api/v1/wallet/deposit/[\w-]+',
      handler: _handleGetDepositStatus,
    );

    // GET /wallet/rate - Get exchange rate.
    interceptor.register(
      method: 'GET',
      path: '/wallet/rate',
      handler: _handleGetRate,
    );

    interceptor.register(
      method: 'GET',
      path: '/wallet/exchange-rate',
      handler: _handleGetRate,
    );

    interceptor.register(
      method: 'GET',
      path: '/deposits/rate',
      handler: _handleGetDepositRate,
    );

    interceptor.register(
      method: 'GET',
      path: '/api/v1/wallet/exchange-rate',
      handler: _handleGetRate,
    );
  }

  static Future<MockResponse<dynamic>> _handleGetChannels(
    RequestOptions options,
  ) async {
    final currency = options.queryParameters['currency'] as String?;
    final channels = _depositChannels
        .where((channel) => currency == null || channel['currency'] == currency)
        .toList();

    return MockResponse.success({'channels': channels});
  }

  static Future<MockResponse<dynamic>> _handleInitiateDeposit(
    RequestOptions options,
  ) async {
    final data = options.data as Map<String, dynamic>;
    final amount = (data['amount'] as num).toDouble();
    final sourceCurrency = data['sourceCurrency'] as String;
    final channelId = data['channelId'] as String;
    final rate = _rateFor(sourceCurrency);
    final fee = amount * 0.01;
    final estimatedAmount = (amount - fee) / rate;

    return MockResponse.success({
      'transactionId': 'txn_${DateTime.now().millisecondsSinceEpoch}',
      'depositId': 'dep_${DateTime.now().millisecondsSinceEpoch}',
      'amount': amount,
      'sourceCurrency': sourceCurrency,
      'targetCurrency': 'USD',
      'rate': rate,
      'fee': fee,
      'estimatedAmount': estimatedAmount,
      'paymentInstructions': {
        'type': _getChannelType(channelId),
        'provider': _getProviderName(channelId),
        'accountNumber': _getAccountNumber(channelId),
        'reference': _generateReference(channelId),
        'instructions': _getInstructions(channelId),
        'qrCode': null,
      },
      'expiresAt': DateTime.now()
          .add(const Duration(minutes: 30))
          .toIso8601String(),
    });
  }

  static Future<MockResponse<dynamic>> _handleInitiateMobileMoneyDeposit(
    RequestOptions options,
  ) async {
    final data = options.data as Map<String, dynamic>? ?? {};
    final amount = _valueAsDouble(data['amount']) ?? 0;
    final currency = data['currency'] as String? ?? 'XOF';
    final providerCode = data['providerCode'] as String? ?? 'OMCI';
    final provider = _providerForCode(providerCode);

    return MockResponse.success({
      'depositId': 'dep_${DateTime.now().millisecondsSinceEpoch}',
      'token': 'dep_token_${DateTime.now().millisecondsSinceEpoch}',
      'paymentMethodType': provider['paymentMethodType'],
      'instructions': _getProviderInstructions(providerCode),
      'qrCodeData': providerCode == 'WAVECI'
          ? 'korido://deposit/${DateTime.now().millisecondsSinceEpoch}'
          : null,
      'deepLinkUrl': providerCode == 'WAVECI'
          ? 'wave://pay?ref=${_generateReference(providerCode)}'
          : null,
      'expiresAt': DateTime.now()
          .add(const Duration(minutes: 15))
          .toIso8601String(),
      'status': 'processing',
      'amount': amount,
      'currency': currency,
      'convertedAmount': currency == 'USD'
          ? amount
          : (amount * 0.99) / _rateFor(currency),
      'convertedCurrency': 'USD',
      'providerCode': providerCode,
      'providerName': provider['name'],
      'reference': _generateReference(providerCode),
    });
  }

  static Future<MockResponse<dynamic>> _handleConfirmDeposit(
    RequestOptions options,
  ) async {
    final data = options.data as Map<String, dynamic>? ?? {};
    return MockResponse.success({
      'depositId':
          data['depositId'] as String? ??
          'dep_${DateTime.now().millisecondsSinceEpoch}',
      'token': data['token'] as String? ?? '',
      'paymentMethodType': 'OTP',
      'instructions': 'Payment confirmed. Your balance will update shortly.',
      'expiresAt': DateTime.now()
          .add(const Duration(minutes: 15))
          .toIso8601String(),
      'status': 'completed',
      'amount': _valueAsDouble(data['amount']) ?? 0,
      'currency': data['currency'] as String? ?? 'XOF',
      'convertedCurrency': 'USD',
      'providerCode': data['providerCode'] as String? ?? 'OMCI',
    });
  }

  static Future<MockResponse<dynamic>> _handleGetDepositStatus(
    RequestOptions options,
  ) async {
    final isPending = DateTime.now().second % 5 == 0;
    final amount = 60000.0;
    final rate = _rateFor('XOF');
    final fee = amount * 0.01;
    final estimatedAmount = (amount - fee) / rate;

    return MockResponse.success({
      'transactionId': 'txn_123456',
      'depositId': 'dep_123456',
      'amount': amount,
      'sourceCurrency': 'XOF',
      'targetCurrency': 'USD',
      'rate': rate,
      'fee': fee,
      'estimatedAmount': estimatedAmount,
      'paymentInstructions': {
        'type': 'mobile_money',
        'provider': 'Orange Money',
        'accountNumber': '+225XXXXXXXX',
        'reference': 'OM123456',
        'instructions': '''1. Dial #144# on your Orange Money registered phone
2. Select "Transfer Money"
3. Enter the reference number: OM123456
4. Enter the amount: 60000 XOF
5. Confirm with your PIN''',
        'qrCode': null,
      },
      'expiresAt': DateTime.now()
          .add(const Duration(minutes: 30))
          .toIso8601String(),
      'status': isPending ? 'pending' : 'completed',
    });
  }

  static Future<MockResponse<dynamic>> _handleGetLegacyDepositStatus(
    RequestOptions options,
  ) async {
    final depositId = options.path.split('/').last;
    return MockResponse.success(_legacyDepositStatus(depositId));
  }

  static Future<MockResponse<dynamic>> _handleListDeposits(
    RequestOptions options,
  ) async {
    return MockResponse.success({
      'deposits': [
        _legacyDepositStatus('dep_mock_completed_1', status: 'completed'),
        _legacyDepositStatus('dep_mock_processing_2', status: 'processing'),
      ],
      'total': 2,
      'hasMore': false,
    });
  }

  static Future<MockResponse<dynamic>> _handleGetProviders(
    RequestOptions options,
  ) async {
    return MockResponse.success({'providers': _legacyProviders});
  }

  static Future<MockResponse<dynamic>> _handleGetRate(
    RequestOptions options,
  ) async {
    final sourceCurrency =
        options.queryParameters['sourceCurrency'] as String? ?? 'XOF';
    final targetCurrency =
        options.queryParameters['targetCurrency'] as String? ?? 'USD';
    final amount = _valueAsDouble(options.queryParameters['amount']) ?? 0;
    final rate = _rateFor(sourceCurrency);
    final fee = amount * 0.01;

    return MockResponse.success({
      'sourceCurrency': sourceCurrency,
      'targetCurrency': targetCurrency,
      'fromCurrency': sourceCurrency,
      'toCurrency': targetCurrency,
      'rate': rate,
      'sourceAmount': amount,
      'targetAmount': amount > 0 ? (amount - fee) / rate : 0,
      'fee': fee,
      'timestamp': DateTime.now().toIso8601String(),
      'expiresAt': DateTime.now()
          .add(const Duration(minutes: 5))
          .toIso8601String(),
    });
  }

  static Future<MockResponse<dynamic>> _handleGetDepositRate(
    RequestOptions options,
  ) async {
    final sourceCurrency =
        options.queryParameters['sourceCurrency'] as String? ?? 'XOF';
    final targetCurrency =
        options.queryParameters['targetCurrency'] as String? ?? 'USD';

    return MockResponse.success({
      'fromCurrency': sourceCurrency,
      'toCurrency': targetCurrency,
      'sourceCurrency': sourceCurrency,
      'targetCurrency': targetCurrency,
      'rate': _rateFor(sourceCurrency),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static final List<Map<String, dynamic>> _legacyProviders = [
    {
      'code': 'OMCI',
      'id': 'orange-money-ci',
      'name': "Orange Money Cote d'Ivoire",
      'provider': 'Orange Money',
      'paymentMethodType': 'OTP',
      'country': 'CI',
      'currency': 'XOF',
      'minAmount': 500,
      'maxAmount': 5000000,
      'fee': 1.0,
    },
    {
      'code': 'MTNCI',
      'id': 'mtn-momo-ci',
      'name': 'MTN Mobile Money',
      'provider': 'MTN MoMo',
      'paymentMethodType': 'PUSH',
      'country': 'CI',
      'currency': 'XOF',
      'minAmount': 500,
      'maxAmount': 3000000,
      'fee': 1.2,
    },
    {
      'code': 'WAVECI',
      'id': 'wave-ci',
      'name': "Wave Cote d'Ivoire",
      'provider': 'Wave',
      'paymentMethodType': 'QR_LINK',
      'country': 'CI',
      'currency': 'XOF',
      'minAmount': 500,
      'maxAmount': 5000000,
      'fee': 0.0,
    },
    {
      'code': 'BANK',
      'id': 'bank-ci',
      'name': 'Local bank transfer',
      'provider': 'Korido Bank Rail',
      'paymentMethodType': 'PUSH',
      'country': 'CI',
      'currency': 'XOF',
      'minAmount': 5000,
      'maxAmount': 10000000,
      'fee': 0.0,
    },
  ];

  static final List<Map<String, dynamic>> _depositChannels = [
    {
      'id': 'orange-money-ci',
      'name': "Orange Money Cote d'Ivoire",
      'type': 'mobile_money',
      'provider': 'Orange Money',
      'country': 'CI',
      'minAmount': 500,
      'maxAmount': 5000000,
      'fee': 1.0,
      'feeType': 'percentage',
      'currency': 'XOF',
    },
    {
      'id': 'wave-ci',
      'name': "Wave Cote d'Ivoire",
      'type': 'mobile_money',
      'provider': 'Wave',
      'country': 'CI',
      'minAmount': 500,
      'maxAmount': 5000000,
      'fee': 0.0,
      'feeType': 'percentage',
      'currency': 'XOF',
    },
    {
      'id': 'mtn-momo-ci',
      'name': 'MTN Mobile Money',
      'type': 'mobile_money',
      'provider': 'MTN MoMo',
      'country': 'CI',
      'minAmount': 500,
      'maxAmount': 3000000,
      'fee': 1.2,
      'feeType': 'percentage',
      'currency': 'XOF',
    },
    {
      'id': 'bank-ci',
      'name': 'Local bank transfer',
      'type': 'bank_transfer',
      'provider': 'Korido Bank Rail',
      'country': 'CI',
      'minAmount': 5000,
      'maxAmount': 10000000,
      'fee': 0.0,
      'feeType': 'fixed',
      'currency': 'XOF',
    },
    {
      'id': 'mobile-money-gh',
      'name': 'Mobile Money Ghana',
      'type': 'mobile_money',
      'provider': 'MTN MoMo',
      'country': 'GH',
      'minAmount': 10,
      'maxAmount': 50000,
      'fee': 1.2,
      'feeType': 'percentage',
      'currency': 'GHS',
    },
    {
      'id': 'mobile-money-ng',
      'name': 'Bank transfer Nigeria',
      'type': 'bank_transfer',
      'provider': 'Korido Bank Rail',
      'country': 'NG',
      'minAmount': 1000,
      'maxAmount': 10000000,
      'fee': 0.0,
      'feeType': 'fixed',
      'currency': 'NGN',
    },
    {
      'id': 'ach-us',
      'name': 'US bank transfer',
      'type': 'bank_transfer',
      'provider': 'ACH',
      'country': 'US',
      'minAmount': 1,
      'maxAmount': 25000,
      'fee': 0.0,
      'feeType': 'fixed',
      'currency': 'USD',
    },
    {
      'id': 'card-us',
      'name': 'Debit card',
      'type': 'card',
      'provider': 'Visa/Mastercard',
      'country': 'US',
      'minAmount': 1,
      'maxAmount': 5000,
      'fee': 2.9,
      'feeType': 'percentage',
      'currency': 'USD',
    },
  ];

  static double _rateFor(String sourceCurrency) {
    switch (sourceCurrency) {
      case 'XOF':
        return 655.957;
      case 'NGN':
        return 1450;
      case 'GHS':
        return 15.2;
      case 'USD':
        return 1;
      default:
        return 655.957;
    }
  }

  static double? _valueAsDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static Map<String, dynamic> _providerForCode(String providerCode) {
    return _legacyProviders.firstWhere(
      (provider) => provider['code'] == providerCode,
      orElse: () => _legacyProviders.first,
    );
  }

  static Map<String, dynamic> _legacyDepositStatus(
    String depositId, {
    String status = 'processing',
  }) {
    return {
      'depositId': depositId,
      'token': 'dep_token_$depositId',
      'paymentMethodType': 'PUSH',
      'instructions': 'Approve the payment from your mobile money app.',
      'expiresAt': DateTime.now()
          .add(const Duration(minutes: 15))
          .toIso8601String(),
      'status': status,
      'amount': 50000,
      'currency': 'XOF',
      'convertedAmount': (50000 * 0.99) / _rateFor('XOF'),
      'convertedCurrency': 'USD',
      'providerCode': 'WAVECI',
      'reference': _generateReference('WAVECI'),
    };
  }

  static String _getChannelType(String channelId) {
    if (channelId.contains('bank')) {
      return 'bank_transfer';
    } else if (channelId.contains('card')) {
      return 'card';
    }
    return 'mobile_money';
  }

  static String _getProviderName(String channelId) {
    if (channelId.contains('orange')) {
      return 'Orange Money';
    } else if (channelId.contains('mtn')) {
      return 'MTN MoMo';
    } else if (channelId.contains('wave')) {
      return 'Wave';
    }
    return 'Mobile Money';
  }

  static String _getAccountNumber(String channelId) {
    if (channelId.contains('orange')) {
      return '+225XXXXXXXX';
    } else if (channelId.contains('mtn')) {
      return '+225YYYYYYYY';
    } else if (channelId.contains('wave')) {
      return '+225ZZZZZZZZ';
    }
    return 'mock-korido-rail';
  }

  static String _getInstructions(String channelId) {
    if (channelId.contains('orange')) {
      return '''1. Dial #144# on your Orange Money registered phone
2. Select "Transfer Money"
3. Enter the reference number
4. Enter the amount
5. Confirm with your PIN''';
    } else if (channelId.contains('mtn')) {
      return '''1. Dial *133# on your MTN registered phone
2. Select "Transfer Money"
3. Enter the reference number
4. Enter the amount
5. Confirm with your PIN''';
    } else if (channelId.contains('wave')) {
      return '''1. Open the Wave app
2. Tap "Send Money"
3. Enter the reference number
4. Enter the amount
5. Confirm the transaction''';
    }
    return 'Follow the instructions from your mobile money provider';
  }

  static String _getProviderInstructions(String providerCode) {
    switch (providerCode) {
      case 'OMCI':
        return _getInstructions('orange-money-ci');
      case 'MTNCI':
        return _getInstructions('mtn-momo-ci');
      case 'WAVECI':
        return _getInstructions('wave-ci');
      default:
        return 'Follow the in-app payment instructions to complete deposit.';
    }
  }

  static String _generateReference(String channelId) {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final prefix = _getProviderName(channelId).split(' ').first.toUpperCase();
    final prefixCode = prefix.length <= 4 ? prefix : prefix.substring(0, 4);
    return '$prefixCode${chars[random % chars.length]}${chars[(random ~/ 10) % chars.length]}${random % 100000}';
  }
}
