import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// Deposit Mock
class DepositMock {
  static void register(MockInterceptor interceptor) {
    // POST /api/v1/wallet/deposit - Initiate deposit
    interceptor.register(
      method: 'POST',
      path: '/api/v1/wallet/deposit',
      handler: (options) async {
        final data = options.data as Map<String, dynamic>;
        final amount = data['amount'] as double;
        final sourceCurrency = data['sourceCurrency'] as String;
        final channelId = data['channelId'] as String;

        // Simulate 3-second delay
        await Future.delayed(const Duration(seconds: 3));

        final rate = 655.957; // 1 USD = 655.957 XOF (realistic rate)
        final fee = amount * 0.01; // 1% fee
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
            'reference': _generateReference(),
            'instructions': _getInstructions(channelId),
            'qrCode': null,
          },
          'expiresAt': DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
        });
      },
    );

    // GET /api/v1/wallet/deposit/:id - Get deposit status
    interceptor.register(
      method: 'GET',
      path: r'/api/v1/wallet/deposit/[\w-]+',
      handler: (options) async {
        // Simulate random status (80% success, 20% pending)
        final isPending = DateTime.now().second % 5 == 0;

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
            'instructions': '''1. Dial #144# on your Orange Money registered phone
2. Select "Transfer Money"
3. Enter the reference number: OM123456
4. Enter the amount: 60000 XOF
5. Confirm with your PIN''',
            'qrCode': null,
          },
          'expiresAt': DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
          'status': isPending ? 'pending' : 'completed',
        });
      },
    );

    // GET /api/v1/wallet/exchange-rate - Get exchange rate
    interceptor.register(
      method: 'GET',
      path: '/api/v1/wallet/exchange-rate',
      handler: (options) async {
        return MockResponse.success({
          'fromCurrency': 'XOF',
          'toCurrency': 'USD',
          'rate': 600.0, // 1 USD = 600 XOF
          'timestamp': DateTime.now().toIso8601String(),
        });
      },
    );
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

  static String? _getAccountNumber(String channelId) {
    if (channelId.contains('orange')) {
      return '+225XXXXXXXX';
    } else if (channelId.contains('mtn')) {
      return '+225YYYYYYYY';
    } else if (channelId.contains('wave')) {
      return '+225ZZZZZZZZ';
    }
    return null;
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

  static String _generateReference() {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return 'OM${chars[random % chars.length]}${chars[(random ~/ 10) % chars.length]}${random % 100000}';
  }
}
