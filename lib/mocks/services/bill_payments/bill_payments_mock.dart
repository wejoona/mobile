/// Bill Payments Mock Implementation
///
/// Mock handlers for bill payment endpoints with Ivorian billers.
library;

import 'package:dio/dio.dart';
import '../../base/api_contract.dart';
import '../../base/mock_data_generator.dart';
import '../../base/mock_interceptor.dart';
import 'bill_payments_contract.dart';

/// Bill Payments mock state
class BillPaymentsMockState {
  static final List<Map<String, dynamic>> payments = [];

  static void reset() {
    payments.clear();
  }

  /// Add a payment
  static void addPayment(Map<String, dynamic> payment) {
    payments.insert(0, payment);
  }

  /// Get payment by ID
  static Map<String, dynamic>? getPayment(String id) {
    try {
      return payments.firstWhere((p) => p['paymentId'] == id);
    } catch (e) {
      return null;
    }
  }
}

/// Bill Payments mock handlers
class BillPaymentsMock {
  /// Register all bill payment mock handlers
  static void register(MockInterceptor interceptor) {
    // GET /bill-payments/providers
    interceptor.register(
      method: 'GET',
      path: '/bill-payments/providers',
      handler: _handleGetProviders,
    );

    // GET /bill-payments/categories
    interceptor.register(
      method: 'GET',
      path: '/bill-payments/categories',
      handler: _handleGetCategories,
    );

    // POST /bill-payments/validate
    interceptor.register(
      method: 'POST',
      path: '/bill-payments/validate',
      handler: _handleValidateAccount,
    );

    // POST /bill-payments/pay
    interceptor.register(
      method: 'POST',
      path: '/bill-payments/pay',
      handler: _handlePayBill,
    );

    // GET /bill-payments/history
    interceptor.register(
      method: 'GET',
      path: '/bill-payments/history',
      handler: _handleGetHistory,
    );

    // GET /bill-payments/:id/receipt
    interceptor.register(
      method: 'GET',
      path: '/bill-payments/:id/receipt',
      handler: _handleGetReceipt,
    );
  }

  /// Handle GET /bill-payments/providers
  static Future<MockResponse> _handleGetProviders(RequestOptions options) async {
    final providers = _getIvorianProviders();
    final category = options.queryParameters['category'] as String?;

    final filtered = category != null
        ? providers.where((p) => p['category'] == category).toList()
        : providers;

    final categories = providers
        .map((p) => p['category'] as String)
        .toSet()
        .toList();

    return MockResponse.success({
      'providers': filtered,
      'availableCountries': ['CI', 'SN', 'ML'],
      'availableCategories': categories,
    });
  }

  /// Handle GET /bill-payments/categories
  static Future<MockResponse> _handleGetCategories(RequestOptions options) async {
    final categories = [
      {
        'category': 'electricity',
        'displayName': 'Electricity',
        'description': 'Pay your electricity bills',
        'icon': 'bolt',
        'providerCount': 1,
      },
      {
        'category': 'water',
        'displayName': 'Water',
        'description': 'Pay your water bills',
        'icon': 'water_drop',
        'providerCount': 1,
      },
      {
        'category': 'phone_credit',
        'displayName': 'Airtime',
        'description': 'Buy mobile airtime',
        'icon': 'phone_android',
        'providerCount': 3,
      },
      {
        'category': 'internet',
        'displayName': 'Internet',
        'description': 'Pay your internet bills',
        'icon': 'wifi',
        'providerCount': 2,
      },
      {
        'category': 'tv',
        'displayName': 'TV',
        'description': 'Pay your TV subscription',
        'icon': 'tv',
        'providerCount': 2,
      },
    ];

    return MockResponse.success({'categories': categories});
  }

  /// Handle POST /bill-payments/validate
  static Future<MockResponse> _handleValidateAccount(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>;
    final accountNumber = data['accountNumber'] as String;

    // Simulate validation
    final isValid = accountNumber.isNotEmpty && accountNumber.length >= 5;

    return MockResponse.success({
      'isValid': isValid,
      'accountNumber': accountNumber,
      'customerName': isValid ? _generateCustomerName() : null,
      'accountType': isValid ? 'Prepaid' : null,
      'outstandingBalance': isValid ? MockDataGenerator.amount(min: 0, max: 50000) : null,
      'message': isValid ? 'Account verified successfully' : 'Invalid account number',
    });
  }

  /// Handle POST /bill-payments/pay
  static Future<MockResponse> _handlePayBill(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>;
    final amount = (data['amount'] as num).toDouble();
    final providerId = data['providerId'] as String;

    final provider = _getIvorianProviders().firstWhere(
      (p) => p['id'] == providerId,
      orElse: () => _getIvorianProviders().first,
    );

    final fee = (provider['processingFee'] as num).toDouble();
    final paymentId = MockDataGenerator.uuid();

    final payment = {
      'paymentId': paymentId,
      'transactionId': MockDataGenerator.transactionRef(),
      'status': 'completed',
      'receiptNumber': 'RCP${MockDataGenerator.integer(min: 100000000, max: 999999999)}',
      'providerReference': 'PRV${MockDataGenerator.integer(min: 100000000, max: 999999999)}',
      'tokenNumber': provider['category'] == 'electricity'
          ? _generateToken()
          : null,
      'units': provider['category'] == 'electricity'
          ? '${(amount / 100).toStringAsFixed(0)} kWh'
          : null,
      'amount': amount,
      'fee': fee,
      'totalAmount': amount + fee,
      'currency': provider['currency'],
      'paidAt': DateTime.now().toIso8601String(),
      'estimatedCompletionTime': 'Instant',
    };

    BillPaymentsMockState.addPayment({
      ...payment,
      'providerId': providerId,
      'providerName': provider['name'],
      'providerLogo': provider['logo'],
      'category': provider['category'],
      'accountNumber': data['accountNumber'],
      'customerName': data['customerName'],
      'createdAt': DateTime.now().toIso8601String(),
      'completedAt': DateTime.now().toIso8601String(),
    });

    return MockResponse.success(payment);
  }

  /// Handle GET /bill-payments/history
  static Future<MockResponse> _handleGetHistory(RequestOptions options) async {
    final page = int.tryParse(options.queryParameters['page']?.toString() ?? '1') ?? 1;
    final limit = int.tryParse(options.queryParameters['limit']?.toString() ?? '20') ?? 20;
    final category = options.queryParameters['category'] as String?;

    var items = List<Map<String, dynamic>>.from(BillPaymentsMockState.payments);

    // Filter by category
    if (category != null) {
      items = items.where((p) => p['category'] == category).toList();
    }

    // Paginate
    final total = items.length;
    final totalPages = (total / limit).ceil();
    final start = (page - 1) * limit;
    final end = start + limit;
    final paginatedItems = items.sublist(
      start,
      end > total ? total : end,
    );

    return MockResponse.success({
      'items': paginatedItems,
      'pagination': {
        'page': page,
        'limit': limit,
        'total': total,
        'totalPages': totalPages,
      },
    });
  }

  /// Handle GET /bill-payments/:id/receipt
  static Future<MockResponse> _handleGetReceipt(RequestOptions options) async {
    // Extract payment ID from path using path parameters
    final params = options.extractPathParams('/bill-payments/:id/receipt');
    final paymentId = params['id'];

    if (paymentId == null) {
      return MockResponse.badRequest('Payment ID is required');
    }

    final payment = BillPaymentsMockState.getPayment(paymentId);

    if (payment == null) {
      return MockResponse.notFound('Payment not found');
    }

    return MockResponse.success(payment);
  }

  /// Get Ivorian bill providers
  static List<Map<String, dynamic>> _getIvorianProviders() {
    return [
      // Electricity
      {
        'id': 'cie-ci',
        'name': 'Compagnie Ivoirienne d\'Électricité (CIE)',
        'shortName': 'CIE',
        'category': 'electricity',
        'country': 'CI',
        'logo': 'https://via.placeholder.com/100x100?text=CIE',
        'requiresAccountNumber': true,
        'requiresMeterNumber': true,
        'requiresCustomerName': false,
        'accountNumberLabel': 'Meter Number',
        'accountNumberPattern': r'^\d{10,12}$',
        'accountNumberLength': 11,
        'minimumAmount': 1000.0,
        'maximumAmount': 500000.0,
        'processingFee': 100.0,
        'processingFeeType': 'fixed',
        'currency': 'XOF',
        'isActive': true,
        'supportsValidation': true,
        'estimatedProcessingTime': 'Instant',
      },

      // Water
      {
        'id': 'sodeci-ci',
        'name': 'Société de Distribution d\'Eau de la Côte d\'Ivoire (SODECI)',
        'shortName': 'SODECI',
        'category': 'water',
        'country': 'CI',
        'logo': 'https://via.placeholder.com/100x100?text=SODECI',
        'requiresAccountNumber': true,
        'requiresMeterNumber': false,
        'requiresCustomerName': false,
        'accountNumberLabel': 'Account Number',
        'accountNumberPattern': r'^\d{8,10}$',
        'accountNumberLength': 9,
        'minimumAmount': 500.0,
        'maximumAmount': 300000.0,
        'processingFee': 100.0,
        'processingFeeType': 'fixed',
        'currency': 'XOF',
        'isActive': true,
        'supportsValidation': true,
        'estimatedProcessingTime': 'Instant',
      },

      // Airtime - Orange
      {
        'id': 'orange-ci',
        'name': 'Orange Côte d\'Ivoire',
        'shortName': 'Orange',
        'category': 'phone_credit',
        'country': 'CI',
        'logo': 'https://via.placeholder.com/100x100?text=Orange',
        'requiresAccountNumber': true,
        'requiresMeterNumber': false,
        'requiresCustomerName': false,
        'accountNumberLabel': 'Phone Number',
        'accountNumberPattern': r'^\+?225\d{8,10}$',
        'accountNumberLength': null,
        'minimumAmount': 100.0,
        'maximumAmount': 50000.0,
        'processingFee': 0.0,
        'processingFeeType': 'fixed',
        'currency': 'XOF',
        'isActive': true,
        'supportsValidation': false,
        'estimatedProcessingTime': 'Instant',
      },

      // Airtime - MTN
      {
        'id': 'mtn-ci',
        'name': 'MTN Côte d\'Ivoire',
        'shortName': 'MTN',
        'category': 'phone_credit',
        'country': 'CI',
        'logo': 'https://via.placeholder.com/100x100?text=MTN',
        'requiresAccountNumber': true,
        'requiresMeterNumber': false,
        'requiresCustomerName': false,
        'accountNumberLabel': 'Phone Number',
        'accountNumberPattern': r'^\+?225\d{8,10}$',
        'accountNumberLength': null,
        'minimumAmount': 100.0,
        'maximumAmount': 50000.0,
        'processingFee': 0.0,
        'processingFeeType': 'fixed',
        'currency': 'XOF',
        'isActive': true,
        'supportsValidation': false,
        'estimatedProcessingTime': 'Instant',
      },

      // Airtime - Moov
      {
        'id': 'moov-ci',
        'name': 'Moov Africa Côte d\'Ivoire',
        'shortName': 'Moov',
        'category': 'phone_credit',
        'country': 'CI',
        'logo': 'https://via.placeholder.com/100x100?text=Moov',
        'requiresAccountNumber': true,
        'requiresMeterNumber': false,
        'requiresCustomerName': false,
        'accountNumberLabel': 'Phone Number',
        'accountNumberPattern': r'^\+?225\d{8,10}$',
        'accountNumberLength': null,
        'minimumAmount': 100.0,
        'maximumAmount': 50000.0,
        'processingFee': 0.0,
        'processingFeeType': 'fixed',
        'currency': 'XOF',
        'isActive': true,
        'supportsValidation': false,
        'estimatedProcessingTime': 'Instant',
      },

      // Internet - Orange Fiber
      {
        'id': 'orange-fiber-ci',
        'name': 'Orange Fiber Côte d\'Ivoire',
        'shortName': 'Orange Fiber',
        'category': 'internet',
        'country': 'CI',
        'logo': 'https://via.placeholder.com/100x100?text=Orange',
        'requiresAccountNumber': true,
        'requiresMeterNumber': false,
        'requiresCustomerName': false,
        'accountNumberLabel': 'Account Number',
        'accountNumberPattern': r'^\d{8,12}$',
        'accountNumberLength': 10,
        'minimumAmount': 5000.0,
        'maximumAmount': 100000.0,
        'processingFee': 200.0,
        'processingFeeType': 'fixed',
        'currency': 'XOF',
        'isActive': true,
        'supportsValidation': true,
        'estimatedProcessingTime': 'Within 1 hour',
      },

      // Internet - MTN Fiber
      {
        'id': 'mtn-fiber-ci',
        'name': 'MTN Fiber Côte d\'Ivoire',
        'shortName': 'MTN Fiber',
        'category': 'internet',
        'country': 'CI',
        'logo': 'https://via.placeholder.com/100x100?text=MTN',
        'requiresAccountNumber': true,
        'requiresMeterNumber': false,
        'requiresCustomerName': false,
        'accountNumberLabel': 'Account Number',
        'accountNumberPattern': r'^\d{8,12}$',
        'accountNumberLength': 10,
        'minimumAmount': 5000.0,
        'maximumAmount': 100000.0,
        'processingFee': 200.0,
        'processingFeeType': 'fixed',
        'currency': 'XOF',
        'isActive': true,
        'supportsValidation': true,
        'estimatedProcessingTime': 'Within 1 hour',
      },

      // TV - Canal+
      {
        'id': 'canal-plus-ci',
        'name': 'Canal+ Côte d\'Ivoire',
        'shortName': 'Canal+',
        'category': 'tv',
        'country': 'CI',
        'logo': 'https://via.placeholder.com/100x100?text=Canal%2B',
        'requiresAccountNumber': true,
        'requiresMeterNumber': false,
        'requiresCustomerName': false,
        'accountNumberLabel': 'Decoder Number',
        'accountNumberPattern': r'^\d{10,12}$',
        'accountNumberLength': 10,
        'minimumAmount': 3000.0,
        'maximumAmount': 50000.0,
        'processingFee': 150.0,
        'processingFeeType': 'fixed',
        'currency': 'XOF',
        'isActive': true,
        'supportsValidation': true,
        'estimatedProcessingTime': 'Instant',
      },

      // TV - StarTimes
      {
        'id': 'startimes-ci',
        'name': 'StarTimes Côte d\'Ivoire',
        'shortName': 'StarTimes',
        'category': 'tv',
        'country': 'CI',
        'logo': 'https://via.placeholder.com/100x100?text=StarTimes',
        'requiresAccountNumber': true,
        'requiresMeterNumber': false,
        'requiresCustomerName': false,
        'accountNumberLabel': 'Smartcard Number',
        'accountNumberPattern': r'^\d{10,12}$',
        'accountNumberLength': 11,
        'minimumAmount': 2000.0,
        'maximumAmount': 30000.0,
        'processingFee': 100.0,
        'processingFeeType': 'fixed',
        'currency': 'XOF',
        'isActive': true,
        'supportsValidation': true,
        'estimatedProcessingTime': 'Instant',
      },
    ];
  }

  /// Generate a random customer name
  static String _generateCustomerName() {
    final firstNames = ['Amadou', 'Fatou', 'Kofi', 'Aya', 'Ibrahim', 'Aissata', 'Yao', 'Mariam'];
    final lastNames = ['Diallo', 'Traore', 'Kone', 'Kouassi', 'N\'Guessan', 'Ouattara', 'Toure', 'Bamba'];

    return '${(firstNames..shuffle()).first} ${(lastNames..shuffle()).first}';
  }

  /// Generate electricity token
  static String _generateToken() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final token = (random % 99999999999999).toString().padLeft(14, '0');
    return '${token.substring(0, 4)}-${token.substring(4, 8)}-${token.substring(8, 12)}-${token.substring(12)}';
  }
}
