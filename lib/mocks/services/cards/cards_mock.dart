/// Cards Mock Implementation
///
/// Mock handlers for virtual cards endpoints
library;

import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_data_generator.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/services/auth/auth_mock.dart';

/// Cards mock state
class CardsMockState {
  static final Map<String, List<Map<String, dynamic>>> userCards = {};
  static final Map<String, List<Map<String, dynamic>>> cardTransactions = {};

  static void reset() {
    userCards.clear();
    cardTransactions.clear();
  }

  /// Get user's cards
  static List<Map<String, dynamic>> getCards(String userId) {
    return userCards[userId] ?? [];
  }

  /// Add card for user
  static Map<String, dynamic> createCard(
    String userId, {
    required String cardholderName,
    required double spendingLimit,
  }) {
    final cardNumber = _generateCardNumber();
    final now = DateTime.now();
    final expiryYear = (now.year + 3).toString().substring(2);

    final card = {
      'id': MockDataGenerator.uuid(),
      'userId': userId,
      'cardNumber': cardNumber,
      'cvv': _generateCVV(),
      'expiryMonth': '12',
      'expiryYear': expiryYear,
      'cardholderName': cardholderName,
      'status': 'active',
      'spendingLimit': spendingLimit,
      'spentAmount': 0.0,
      'currency': 'USD',
      'createdAt': now.toIso8601String(),
      'frozenAt': null,
    };

    userCards[userId] ??= [];
    userCards[userId]!.add(card);

    // Create some mock transactions
    _createMockTransactions(card['id'] as String);

    return card;
  }

  /// Get card transactions
  static List<Map<String, dynamic>> getTransactions(String cardId) {
    return cardTransactions[cardId] ?? [];
  }

  /// Create mock transactions for card
  static void _createMockTransactions(String cardId) {
    final transactions = [
      {
        'id': MockDataGenerator.uuid(),
        'cardId': cardId,
        'merchantName': 'Amazon',
        'merchantCategory': 'Shopping',
        'amount': 45.99,
        'currency': 'USD',
        'status': 'completed',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': MockDataGenerator.uuid(),
        'cardId': cardId,
        'merchantName': 'Netflix',
        'merchantCategory': 'Entertainment',
        'amount': 15.99,
        'currency': 'USD',
        'status': 'completed',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': MockDataGenerator.uuid(),
        'cardId': cardId,
        'merchantName': 'Uber',
        'merchantCategory': 'Transport',
        'amount': 12.50,
        'currency': 'USD',
        'status': 'completed',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
    ];

    cardTransactions[cardId] = transactions;
  }

  /// Generate random card number
  static String _generateCardNumber() {
    final random = MockDataGenerator.integer(min: 1000, max: 9999);
    return '4532$random${random + 1000}${random + 2000}';
  }

  /// Generate random CVV
  static String _generateCVV() {
    return MockDataGenerator.integer(min: 100, max: 999).toString();
  }
}

/// Cards mock handlers
class CardsMock {
  /// Register all cards mock handlers
  static void register(MockInterceptor interceptor) {
    // GET /cards
    interceptor.register(
      method: 'GET',
      path: '/cards',
      handler: _handleGetCards,
    );

    // POST /cards
    interceptor.register(
      method: 'POST',
      path: '/cards',
      handler: _handleCreateCard,
    );

    // GET /cards/:id
    interceptor.register(
      method: 'GET',
      path: r'/cards/[\w-]+',
      handler: _handleGetCard,
    );

    // PUT /cards/:id/freeze
    interceptor.register(
      method: 'PUT',
      path: r'/cards/[\w-]+/freeze',
      handler: _handleFreezeCard,
    );

    // PUT /cards/:id/unfreeze
    interceptor.register(
      method: 'PUT',
      path: r'/cards/[\w-]+/unfreeze',
      handler: _handleUnfreezeCard,
    );

    // PUT /cards/:id/limit
    interceptor.register(
      method: 'PUT',
      path: r'/cards/[\w-]+/limit',
      handler: _handleUpdateLimit,
    );

    // GET /cards/:id/transactions
    interceptor.register(
      method: 'GET',
      path: r'/cards/[\w-]+/transactions',
      handler: _handleGetTransactions,
    );
  }

  static Future<MockResponse> _handleGetCards(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final cards = CardsMockState.getCards(userId);
    return MockResponse.success({'cards': cards});
  }

  static Future<MockResponse> _handleCreateCard(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final data = options.data as Map<String, dynamic>?;
    final cardholderName = data?['cardholderName'] as String?;
    final spendingLimit = (data?['spendingLimit'] as num?)?.toDouble();

    if (cardholderName == null || cardholderName.isEmpty) {
      return MockResponse.badRequest('Cardholder name is required');
    }

    if (spendingLimit == null || spendingLimit <= 0) {
      return MockResponse.badRequest('Invalid spending limit');
    }

    if (spendingLimit < 10) {
      return MockResponse.badRequest('Spending limit must be at least \$10');
    }

    if (spendingLimit > 10000) {
      return MockResponse.badRequest('Spending limit cannot exceed \$10,000');
    }

    // Check if user already has a card (limit 1 per user for now)
    final existingCards = CardsMockState.getCards(userId);
    if (existingCards.isNotEmpty) {
      return MockResponse.badRequest('User already has a virtual card');
    }

    final card = CardsMockState.createCard(
      userId,
      cardholderName: cardholderName,
      spendingLimit: spendingLimit,
    );

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 1));

    return MockResponse.created(card);
  }

  static Future<MockResponse> _handleGetCard(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final cardId = options.path.split('/').last;
    final cards = CardsMockState.getCards(userId);
    final card = cards.where((c) => c['id'] == cardId).firstOrNull;

    if (card == null) {
      return MockResponse.notFound('Card not found');
    }

    return MockResponse.success(card);
  }

  static Future<MockResponse> _handleFreezeCard(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final cardId = options.path.split('/')[2];
    final cards = CardsMockState.getCards(userId);
    final cardIndex = cards.indexWhere((c) => c['id'] == cardId);

    if (cardIndex == -1) {
      return MockResponse.notFound('Card not found');
    }

    cards[cardIndex]['status'] = 'frozen';
    cards[cardIndex]['frozenAt'] = DateTime.now().toIso8601String();

    return MockResponse.success(cards[cardIndex]);
  }

  static Future<MockResponse> _handleUnfreezeCard(
    RequestOptions options,
  ) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final cardId = options.path.split('/')[2];
    final cards = CardsMockState.getCards(userId);
    final cardIndex = cards.indexWhere((c) => c['id'] == cardId);

    if (cardIndex == -1) {
      return MockResponse.notFound('Card not found');
    }

    cards[cardIndex]['status'] = 'active';
    cards[cardIndex]['frozenAt'] = null;

    return MockResponse.success(cards[cardIndex]);
  }

  static Future<MockResponse> _handleUpdateLimit(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final cardId = options.path.split('/')[2];
    final cards = CardsMockState.getCards(userId);
    final cardIndex = cards.indexWhere((c) => c['id'] == cardId);

    if (cardIndex == -1) {
      return MockResponse.notFound('Card not found');
    }

    final data = options.data as Map<String, dynamic>?;
    final newLimit = (data?['spendingLimit'] as num?)?.toDouble();

    if (newLimit == null || newLimit <= 0) {
      return MockResponse.badRequest('Invalid spending limit');
    }

    if (newLimit < 10) {
      return MockResponse.badRequest('Spending limit must be at least \$10');
    }

    if (newLimit > 10000) {
      return MockResponse.badRequest('Spending limit cannot exceed \$10,000');
    }

    cards[cardIndex]['spendingLimit'] = newLimit;

    return MockResponse.success(cards[cardIndex]);
  }

  static Future<MockResponse> _handleGetTransactions(
    RequestOptions options,
  ) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final cardId = options.path.split('/')[2];
    final cards = CardsMockState.getCards(userId);
    final cardExists = cards.any((c) => c['id'] == cardId);

    if (!cardExists) {
      return MockResponse.notFound('Card not found');
    }

    final transactions = CardsMockState.getTransactions(cardId);
    return MockResponse.success({'transactions': transactions});
  }
}
