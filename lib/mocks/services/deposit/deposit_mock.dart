import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// Deposit Mock
class DepositMock {
  static final Map<String, Map<String, dynamic>> _deposits = {};

  static void register(MockInterceptor interceptor) {
    interceptor.register(
      method: 'GET',
      path: '/deposits/providers',
      handler: (options) async => MockResponse.success(_providers),
    );

    interceptor.register(
      method: 'POST',
      path: '/deposits/initiate',
      handler: (options) async {
        if (options.headers['X-Idempotency-Key'] == null) {
          return MockResponse.badRequest('X-Idempotency-Key is required');
        }

        final data = options.data as Map<String, dynamic>;
        final amount = (data['amount'] as num?)?.toDouble();
        final currency = data['currency'] as String?;
        final providerCode = data['providerCode'] as String?;

        if (amount == null || amount <= 0) {
          return MockResponse.badRequest('amount must be positive');
        }
        if (currency != 'XOF' && currency != 'XAF') {
          return MockResponse.badRequest('currency must be XOF or XAF');
        }
        if (!_supportedProviderCodes.contains(providerCode)) {
          return MockResponse.badRequest('providerCode is not supported');
        }

        final depositId =
            'dep_${DateTime.now().microsecondsSinceEpoch.toString()}';
        final paymentMethodType = _paymentMethodType(providerCode!);
        final response = {
          'depositId': depositId,
          'token': 'tok_$depositId',
          'paymentMethodType': paymentMethodType,
          'instructions': _instructions(providerCode, amount, currency!),
          'qrCodeData': paymentMethodType == 'QR_LINK'
              ? 'korido://deposit/$depositId'
              : null,
          'deepLinkUrl': paymentMethodType == 'QR_LINK'
              ? 'wave://pay?ref=$depositId'
              : null,
          'expiresAt': DateTime.now()
              .add(const Duration(minutes: 15))
              .toIso8601String(),
          'amount': amount,
          'currency': currency,
          'providerCode': providerCode,
          'status': paymentMethodType == 'OTP'
              ? 'pending_otp'
              : 'pending_confirmation',
        };

        _deposits[depositId] = response;
        return MockResponse.created(response);
      },
    );

    interceptor.register(
      method: 'POST',
      path: '/deposits/confirm',
      handler: (options) async {
        final data = options.data as Map<String, dynamic>;
        final token = data['token'] as String?;
        final depositId = token?.replaceFirst('tok_', '');
        if (depositId == null) {
          return MockResponse.notFound('Deposit not found');
        }
        final deposit = _deposits[depositId];
        if (deposit == null) {
          return MockResponse.notFound('Deposit not found');
        }

        final response = {
          ...deposit,
          'id': depositId,
          'depositId': depositId,
          'status': 'completed',
          'providerReference': _generateReference(
            deposit['providerCode'] as String,
          ),
          'createdAt': DateTime.now()
              .subtract(const Duration(minutes: 1))
              .toIso8601String(),
          'completedAt': DateTime.now().toIso8601String(),
        };
        _deposits[depositId] = response;
        return MockResponse.success(response);
      },
    );

    interceptor.register(
      method: 'GET',
      path: '/deposits/:id',
      handler: (options) async {
        final depositId = options.extractPathParams('/deposits/:id')['id'];
        final deposit = _deposits[depositId];
        if (deposit == null) {
          return MockResponse.notFound('Deposit not found');
        }

        return MockResponse.success(deposit);
      },
    );

    interceptor.register(
      method: 'GET',
      path: '/deposits',
      handler: (options) async {
        final limit =
            int.tryParse('${options.queryParameters['limit'] ?? '20'}') ?? 20;
        final offset =
            int.tryParse('${options.queryParameters['offset'] ?? '0'}') ?? 0;
        final deposits = _deposits.values.toList().reversed.toList();
        final page = deposits.skip(offset).take(limit).toList();

        return MockResponse.success({
          'deposits': page,
          'total': deposits.length,
          'hasMore': offset + page.length < deposits.length,
        });
      },
    );

    interceptor.register(
      method: 'GET',
      path: '/wallet/exchange-rate',
      handler: (options) async {
        return MockResponse.success({
          'fromCurrency': options.queryParameters['sourceCurrency'] ?? 'XOF',
          'toCurrency': options.queryParameters['targetCurrency'] ?? 'USD',
          'rate': 655.957,
          'timestamp': DateTime.now().toIso8601String(),
        });
      },
    );

    _registerLegacyWalletDepositRoutes(interceptor);
  }

  static void reset() {
    _deposits.clear();
  }

  static void _registerLegacyWalletDepositRoutes(MockInterceptor interceptor) {
    interceptor.register(
      method: 'POST',
      path: '/wallet/deposit',
      handler: (options) async {
        final data = options.data as Map<String, dynamic>;
        final amount = (data['amount'] as num).toDouble();
        final sourceCurrency = data['sourceCurrency'] as String;
        final channelId = data['channelId'] as String;
        final rate = 655.957;
        final fee = amount * 0.01;
        final estimatedAmount = (amount / rate) - (fee / rate);

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
            'instructions': _legacyInstructions(channelId),
            'qrCode': null,
          },
          'expiresAt': DateTime.now()
              .add(const Duration(minutes: 30))
              .toIso8601String(),
        });
      },
    );

    interceptor.register(
      method: 'GET',
      path: '/wallet/deposit/:id',
      handler: (options) async {
        final amount = 60000.0;
        final rate = 655.957;
        final fee = amount * 0.01;
        final estimatedAmount = (amount / rate) - (fee / rate);

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
            'instructions': _legacyInstructions('orange'),
            'qrCode': null,
          },
          'expiresAt': DateTime.now()
              .add(const Duration(minutes: 30))
              .toIso8601String(),
          'status': 'completed',
        });
      },
    );

    interceptor.register(
      method: 'GET',
      path: '/wallet/exchange-rate',
      handler: (options) async {
        return MockResponse.success({
          'fromCurrency': options.queryParameters['sourceCurrency'] ?? 'XOF',
          'toCurrency': options.queryParameters['targetCurrency'] ?? 'USD',
          'rate': 655.957,
          'timestamp': DateTime.now().toIso8601String(),
        });
      },
    );
  }

  static const _providers = [
    {
      'code': 'OMCI',
      'name': 'Orange Money',
      'paymentMethodType': 'OTP',
      'supportedCurrencies': ['XOF'],
    },
    {
      'code': 'MTNCI',
      'name': 'MTN MoMo',
      'paymentMethodType': 'PUSH',
      'supportedCurrencies': ['XOF'],
    },
    {
      'code': 'MOOVCI',
      'name': 'Moov Money',
      'paymentMethodType': 'PUSH',
      'supportedCurrencies': ['XOF'],
    },
    {
      'code': 'WAVECI',
      'name': 'Wave',
      'paymentMethodType': 'QR_LINK',
      'supportedCurrencies': ['XOF'],
    },
  ];

  static const _supportedProviderCodes = {'OMCI', 'MTNCI', 'MOOVCI', 'WAVECI'};

  static String _paymentMethodType(String providerCode) {
    switch (providerCode) {
      case 'OMCI':
        return 'OTP';
      case 'WAVECI':
        return 'QR_LINK';
      case 'MTNCI':
      case 'MOOVCI':
      default:
        return 'PUSH';
    }
  }

  static String _instructions(
    String providerCode,
    double amount,
    String currency,
  ) {
    switch (providerCode) {
      case 'OMCI':
        return 'Dial #144*82#, approve $amount $currency, then enter the OTP in Korido.';
      case 'MTNCI':
        return 'Approve the MTN MoMo payment request on your phone.';
      case 'MOOVCI':
        return 'Approve the Moov Money payment request on your phone.';
      case 'WAVECI':
        return 'Scan the QR code or open Wave to complete this deposit.';
      default:
        return 'Follow the instructions from your mobile money provider.';
    }
  }

  static String _getChannelType(String channelId) {
    if (channelId.contains('bank')) return 'bank_transfer';
    if (channelId.contains('card')) return 'card';
    return 'mobile_money';
  }

  static String _getProviderName(String channelId) {
    if (channelId.contains('orange')) return 'Orange Money';
    if (channelId.contains('mtn')) return 'MTN MoMo';
    if (channelId.contains('wave')) return 'Wave';
    return 'Mobile Money';
  }

  static String? _getAccountNumber(String channelId) {
    if (channelId.contains('orange')) return '+225XXXXXXXX';
    if (channelId.contains('mtn')) return '+225YYYYYYYY';
    if (channelId.contains('wave')) return '+225ZZZZZZZZ';
    return null;
  }

  static String _legacyInstructions(String channelId) {
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

  static String _generateReference(String seed) {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch + seed.length;
    return 'OM${chars[random % chars.length]}${chars[(random ~/ 10) % chars.length]}${random % 100000}';
  }
}
