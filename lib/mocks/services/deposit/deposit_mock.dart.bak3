import '../../base/api_contract.dart';
import '../../base/mock_interceptor.dart';

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
        final provider = data['provider'] as String;

        // Simulate 3-second delay
        await Future.delayed(const Duration(seconds: 3));

        return MockResponse.success({
          'depositId': 'dep_${DateTime.now().millisecondsSinceEpoch}',
          'paymentInstructions': {
            'provider': _getProviderName(provider),
            'ussdCode': _getUssdCode(provider),
            'deepLink': _getDeepLink(provider),
            'referenceNumber': _generateReference(),
            'amountToPay': amount,
            'currency': 'XOF',
            'instructions': _getInstructions(provider),
          },
          'expiresAt': DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
          'status': 'pending',
          'amount': amount,
          'convertedAmount': amount / 600, // Mock 1 USD = 600 XOF
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

        return MockResponse.success({
          'depositId': 'dep_123456',
          'paymentInstructions': {
            'provider': 'Orange Money',
            'ussdCode': '#144#',
            'deepLink': 'orangemoney://',
            'referenceNumber': 'OM123456',
            'amountToPay': 60000.0,
            'currency': 'XOF',
            'instructions': 'Dial #144# and follow the prompts',
          },
          'expiresAt': DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
          'status': isPending ? 'pending' : 'completed',
          'amount': 60000.0,
          'convertedAmount': 100.0,
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

  static String _getProviderName(String provider) {
    switch (provider) {
      case 'orange_money':
        return 'Orange Money';
      case 'wave':
        return 'Wave';
      case 'mtn_momo':
        return 'MTN MoMo';
      default:
        return 'Mobile Money';
    }
  }

  static String? _getUssdCode(String provider) {
    switch (provider) {
      case 'orange_money':
        return '#144#';
      case 'mtn_momo':
        return '*133#';
      default:
        return null;
    }
  }

  static String? _getDeepLink(String provider) {
    switch (provider) {
      case 'orange_money':
        return 'orangemoney://';
      case 'wave':
        return 'wave://';
      case 'mtn_momo':
        return 'momo://';
      default:
        return null;
    }
  }

  static String _getInstructions(String provider) {
    switch (provider) {
      case 'orange_money':
        return '''1. Dial #144# on your Orange Money registered phone
2. Select "Transfer Money"
3. Enter the reference number
4. Enter the amount
5. Confirm with your PIN''';
      case 'wave':
        return '''1. Open the Wave app
2. Tap "Send Money"
3. Enter the reference number
4. Enter the amount
5. Confirm the transaction''';
      case 'mtn_momo':
        return '''1. Dial *133# on your MTN registered phone
2. Select "Transfer Money"
3. Enter the reference number
4. Enter the amount
5. Confirm with your PIN''';
      default:
        return 'Follow the instructions from your mobile money provider';
    }
  }

  static String _generateReference() {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return 'OM${chars[random % chars.length]}${chars[(random ~/ 10) % chars.length]}${random % 100000}';
  }
}
