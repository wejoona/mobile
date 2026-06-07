import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

class DepositMockState {
  static final List<Map<String, dynamic>> deposits = [];

  static void reset() {
    deposits.clear();
  }
}

/// Deposit Mock
class DepositMock {
  static final Map<String, Map<String, dynamic>> _deposits = {};

  static void register(MockInterceptor interceptor) {
    // GET /deposits/providers - List available deposit providers
    interceptor.register(
      method: 'GET',
      path: '/deposits/providers',
      handler: _handleGetProviders,
    );

    // POST /deposits/initiate - Initiate canonical deposit flow
    interceptor.register(
      method: 'POST',
      path: '/deposits/initiate',
      handler: _handleInitiateDeposit,
    );

    // GET /deposits - List deposits
    interceptor.register(
      method: 'GET',
      path: '/deposits',
      handler: _handleListDeposits,
    );

    // GET /deposits/:id - Get canonical deposit status
    interceptor.register(
      method: 'GET',
      path: r'/deposits/[\w-]+',
      handler: _handleDepositStatus,
    );

    // POST /api/v1/wallet/deposit - Initiate deposit
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

  static Future<MockResponse> _handleGetProviders(options) async {
    return MockResponse.success([
      {
        'code': 'OMCI',
        'name': "Orange Money Cote d'Ivoire",
        'paymentMethodType': 'OTP',
        'country': 'CI',
        'rail': 'mobile_money',
        'supportedCurrencies': ['XOF'],
      },
      {
        'code': 'MTNCI',
        'name': "MTN Mobile Money Cote d'Ivoire",
        'paymentMethodType': 'PUSH',
        'country': 'CI',
        'rail': 'mobile_money',
        'supportedCurrencies': ['XOF'],
      },
      {
        'code': 'MOOVCI',
        'name': "Moov Money Cote d'Ivoire",
        'paymentMethodType': 'PUSH',
        'country': 'CI',
        'rail': 'mobile_money',
        'supportedCurrencies': ['XOF'],
      },
      {
        'code': 'WAVECI',
        'name': "Wave Cote d'Ivoire",
        'paymentMethodType': 'QR_LINK',
        'country': 'CI',
        'rail': 'mobile_money',
        'supportedCurrencies': ['XOF'],
      },
      {
        'code': 'US_CARD',
        'name': 'Debit or credit card',
        'paymentMethodType': 'CARD',
        'country': 'US',
        'rail': 'card',
        'supportedCurrencies': ['USD'],
        'minAmount': 5,
        'maxAmount': 10000,
      },
      {
        'code': 'US_ACH',
        'name': 'US bank transfer',
        'paymentMethodType': 'ACH',
        'country': 'US',
        'rail': 'bank_transfer',
        'supportedCurrencies': ['USD'],
        'minAmount': 10,
        'maxAmount': 10000,
      },
      {
        'code': 'USDC_CRYPTO',
        'name': 'USDC wallet transfer',
        'paymentMethodType': 'CRYPTO',
        'country': 'US',
        'rail': 'crypto',
        'supportedCurrencies': ['USD'],
        'minAmount': 5,
        'maxAmount': 10000,
      },
    ]);
  }

  static Future<MockResponse> _handleInitiateDeposit(
    RequestOptions options,
  ) async {
    final data = options.data as Map<String, dynamic>;
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final currency = data['currency'] as String?;
    final providerCode = data['providerCode'] as String?;

    if (amount <= 0) {
      return MockResponse.badRequest('Invalid amount');
    }
    if (currency == null || !['XOF', 'XAF', 'USD'].contains(currency)) {
      return MockResponse.badRequest('Currency must be XOF, XAF, or USD');
    }
    final validProviders = [
      'OMCI',
      'MTNCI',
      'MOOVCI',
      'WAVECI',
      'US_CARD',
      'US_ACH',
      'USDC_CRYPTO',
    ];
    if (providerCode == null || !validProviders.contains(providerCode)) {
      return MockResponse.badRequest('Invalid providerCode');
    }

    final depositId = 'dep_${DateTime.now().millisecondsSinceEpoch}';
    final exchangeRate = currency == 'USD' ? 1.0 : 600.0;
    final deposit = {
      'depositId': depositId,
      'token': 'mock_deposit_token_$depositId',
      'paymentMethodType': _paymentMethodType(providerCode),
      'instructions': _instructions(providerCode, amount, currency),
      'qrCodeData': providerCode == 'WAVECI'
          ? 'wave://pay?ref=$depositId'
          : null,
      'deepLinkUrl': providerCode == 'WAVECI'
          ? 'https://wave.com/pay?ref=$depositId'
          : null,
      'expiresAt': DateTime.now()
          .add(const Duration(minutes: 30))
          .toIso8601String(),
      'status': 'initiated',
      'amount': amount,
      'usdcAmount': amount / exchangeRate,
      'exchangeRate': exchangeRate,
      'currency': currency,
      'providerCode': providerCode,
      'phoneNumber': data['phoneNumber'] as String?,
      'createdAt': DateTime.now().toIso8601String(),
    };
    DepositMockState.deposits.insert(0, deposit);
    return MockResponse.created(deposit);
  }

  static Future<MockResponse> _handleDepositStatus(
    RequestOptions options,
  ) async {
    final path = options.path;
    final depositId = path.split('/').last;
    final isConfirmedDeposit = depositId.startsWith('dep_confirmed_');
    final isPending = !isConfirmedDeposit && DateTime.now().second % 5 == 0;
    final deposit = DepositMockState.deposits.firstWhere(
      (item) => item['depositId'] == depositId,
      orElse: () => const <String, dynamic>{},
    );
    return MockResponse.success({
      'id': depositId.isEmpty ? 'dep_123456' : depositId,
      'depositId': depositId.isEmpty ? 'dep_123456' : depositId,
      'status': isPending ? 'processing' : 'completed',
      'amount': deposit['amount'] as num? ?? 6000,
      'usdcAmount': deposit['usdcAmount'] as num? ?? 10,
      'exchangeRate': deposit['exchangeRate'] as num? ?? 600,
      'currency': deposit['currency'] as String? ?? 'XOF',
      'providerCode': deposit['providerCode'] as String? ?? 'OMCI',
      'paymentMethodType': deposit['paymentMethodType'] as String? ?? 'OTP',
      'providerReference': 'OM123456',
      'createdAt': DateTime.now()
          .subtract(const Duration(minutes: 5))
          .toIso8601String(),
      'completedAt': isPending ? null : DateTime.now().toIso8601String(),
    });
  }

  static Future<MockResponse> _handleListDeposits(
    RequestOptions options,
  ) async {
    final limit =
        int.tryParse(options.queryParameters['limit']?.toString() ?? '20') ??
        20;
    final offset =
        int.tryParse(options.queryParameters['offset']?.toString() ?? '0') ?? 0;
    final deposits = DepositMockState.deposits
        .skip(offset)
        .take(limit)
        .toList();

    return MockResponse.success({
      'deposits': deposits,
      'total': DepositMockState.deposits.length,
      'hasMore': offset + limit < DepositMockState.deposits.length,
    });
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
    } else if (channelId.contains('US_CARD')) {
      return 'Enter your card details in the secure payment screen to complete the deposit.';
    } else if (channelId.contains('US_ACH')) {
      return 'Connect your US bank account and confirm the bank transfer.';
    } else if (channelId.contains('USDC_CRYPTO')) {
      return 'Send USDC from your wallet using the generated deposit address.';
    }
    return 'Follow the instructions from your mobile money provider';
  }

  static String _paymentMethodType(String providerCode) {
    switch (providerCode) {
      case 'OMCI':
        return 'OTP';
      case 'WAVECI':
        return 'QR_LINK';
      case 'US_CARD':
        return 'CARD';
      case 'US_ACH':
        return 'ACH';
      case 'USDC_CRYPTO':
        return 'CRYPTO';
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

  static String _generateReference(String seed) {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch + seed.length;
    return 'OM${chars[random % chars.length]}${chars[(random ~/ 10) % chars.length]}${random % 100000}';
  }
}
