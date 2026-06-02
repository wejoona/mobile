// ignore_for_file: deprecated_member_use
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';

/// Mock data for savings pots feature
class SavingsPotsMock {
  static final List<Map<String, dynamic>> _pots = [];
  static final Map<String, List<Map<String, dynamic>>> _transactions = {};

  static void reset() {
    final now = DateTime.now();
    _pots
      ..clear()
      ..addAll([
        {
          'id': 'pot-1',
          'userId': 'mock-user',
          'name': 'Vacation',
          'emoji': '✈️',
          'color': const Color(0xFF4A90E2).value,
          'currentAmount': 500.0,
          'targetAmount': 1000.0,
          'currency': 'XOF',
          'status': 'active',
          'createdAt': now.subtract(const Duration(days: 30)).toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'pot-2',
          'userId': 'mock-user',
          'name': 'New Phone',
          'emoji': '📱',
          'color': const Color(0xFF9B59B6).value,
          'currentAmount': 200.0,
          'targetAmount': 800.0,
          'currency': 'XOF',
          'status': 'active',
          'createdAt': now.subtract(const Duration(days: 15)).toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'pot-3',
          'userId': 'mock-user',
          'name': 'Emergency Fund',
          'emoji': '🏥',
          'color': const Color(0xFFE74C3C).value,
          'currentAmount': 1500.0,
          'targetAmount': null,
          'currency': 'XOF',
          'status': 'active',
          'createdAt': now.subtract(const Duration(days: 60)).toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
      ]);

    _transactions
      ..clear()
      ..addAll({
        'pot-1': [
          {
            'id': 'tx-1',
            'potId': 'pot-1',
            'type': 'deposit',
            'amount': 300.0,
            'timestamp': DateTime.now()
                .subtract(const Duration(days: 20))
                .toIso8601String(),
          },
          {
            'id': 'tx-2',
            'potId': 'pot-1',
            'type': 'deposit',
            'amount': 200.0,
            'timestamp': DateTime.now()
                .subtract(const Duration(days: 10))
                .toIso8601String(),
          },
        ],
        'pot-2': [
          {
            'id': 'tx-3',
            'potId': 'pot-2',
            'type': 'deposit',
            'amount': 200.0,
            'timestamp': DateTime.now()
                .subtract(const Duration(days: 5))
                .toIso8601String(),
          },
        ],
        'pot-3': [
          {
            'id': 'tx-4',
            'potId': 'pot-3',
            'type': 'deposit',
            'amount': 1000.0,
            'timestamp': DateTime.now()
                .subtract(const Duration(days: 50))
                .toIso8601String(),
          },
          {
            'id': 'tx-5',
            'potId': 'pot-3',
            'type': 'deposit',
            'amount': 500.0,
            'timestamp': DateTime.now()
                .subtract(const Duration(days: 30))
                .toIso8601String(),
          },
        ],
      });
  }

  static void register(MockInterceptor interceptor) {
    if (_pots.isEmpty) reset();

    // GET /savings-pots - Get all pots
    interceptor.register(
      method: 'GET',
      path: '/savings-pots',
      handler: _handleGetAll,
    );

    // GET /savings-pots/active - Get active pots
    interceptor.register(
      method: 'GET',
      path: '/savings-pots/active',
      handler: _handleGetActive,
    );

    // GET /savings-pots/:id - Get one pot
    interceptor.register(
      method: 'GET',
      path: '/savings-pots/:id',
      handler: _handleGetById,
    );

    // POST /savings-pots - Create new pot
    interceptor.register(
      method: 'POST',
      path: '/savings-pots',
      handler: _handleCreate,
    );

    // PUT /savings-pots/:id - Update pot
    interceptor.register(
      method: 'PUT',
      path: '/savings-pots/:id',
      handler: _handleUpdate,
    );

    // Legacy PATCH /savings-pots/:id - Update pot
    interceptor.register(
      method: 'PATCH',
      path: '/savings-pots/:id',
      handler: _handleUpdate,
    );

    // DELETE /savings-pots/:id - Delete pot
    interceptor.register(
      method: 'DELETE',
      path: '/savings-pots/:id',
      handler: _handleDelete,
    );

    // POST /savings-pots/:id/deposit - Add money to pot
    interceptor.register(
      method: 'POST',
      path: '/savings-pots/:id/deposit',
      handler: _handleDeposit,
    );

    // POST /savings-pots/:id/withdraw - Withdraw money from pot
    interceptor.register(
      method: 'POST',
      path: '/savings-pots/:id/withdraw',
      handler: _handleWithdraw,
    );

    // POST /savings-pots/:id/withdraw-all - Withdraw all money
    interceptor.register(
      method: 'POST',
      path: '/savings-pots/:id/withdraw-all',
      handler: _handleWithdrawAll,
    );

    // GET /savings-pots/:id/transactions - Get pot transaction history
    interceptor.register(
      method: 'GET',
      path: '/savings-pots/:id/transactions',
      handler: _handleGetTransactions,
    );
  }

  static Future<MockResponse> _handleGetAll(RequestOptions options) async {
    return MockResponse.success(List<Map<String, dynamic>>.from(_pots));
  }

  static Future<MockResponse> _handleGetActive(RequestOptions options) async {
    final active = _pots.where((pot) => pot['status'] == 'active').toList();
    return MockResponse.success(active);
  }

  static Future<MockResponse> _handleGetById(RequestOptions options) async {
    final params = options.extractPathParams('/savings-pots/:id');
    final id = params['id'];
    final pot = _pots.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item?['id'] == id,
      orElse: () => null,
    );

    if (pot == null) {
      return MockResponse.notFound('Pot not found');
    }

    return MockResponse.success(pot);
  }

  static Future<MockResponse> _handleCreate(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>;
    final now = DateTime.now();
    final newPot = {
      'id': 'pot-${now.microsecondsSinceEpoch}',
      'userId': 'mock-user',
      'name': data['name'],
      'emoji': data['emoji'] ?? '💰',
      'color': data['color'] ?? const Color(0xFFD4A843).value,
      'currentAmount': 0.0,
      'targetAmount': data['targetAmount'],
      'currency': data['currency'] ?? 'USDC',
      'targetDate': data['targetDate'],
      'status': 'active',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
    _pots.add(newPot);
    _transactions[newPot['id'] as String] = [];
    return MockResponse.success(newPot);
  }

  static Future<MockResponse> _handleUpdate(RequestOptions options) async {
    final params = options.extractPathParams('/savings-pots/:id');
    final id = params['id'];
    final data = options.data as Map<String, dynamic>;
    final potIndex = _pots.indexWhere((p) => p['id'] == id);

    if (potIndex == -1) {
      return MockResponse.notFound('Pot not found');
    }

    final pot = Map<String, dynamic>.from(_pots[potIndex]);
    if (data.containsKey('name')) pot['name'] = data['name'];
    if (data.containsKey('emoji')) pot['emoji'] = data['emoji'];
    if (data.containsKey('color')) pot['color'] = data['color'];
    if (data.containsKey('targetAmount'))
      pot['targetAmount'] = data['targetAmount'];
    pot['updatedAt'] = DateTime.now().toIso8601String();

    _pots[potIndex] = pot;
    return MockResponse.success(pot);
  }

  static Future<MockResponse> _handleDelete(RequestOptions options) async {
    final params = options.extractPathParams('/savings-pots/:id');
    final id = params['id'];
    final removed = _pots.any((p) => p['id'] == id);
    if (!removed) {
      return MockResponse.notFound('Pot not found');
    }

    _pots.removeWhere((p) => p['id'] == id);
    _transactions.remove(id);
    return MockResponse.success({'success': true});
  }

  static Future<MockResponse> _handleDeposit(RequestOptions options) async {
    final params = options.extractPathParams('/savings-pots/:id/deposit');
    final id = params['id']!;
    final data = options.data as Map<String, dynamic>;
    final amount = (data['amount'] as num).toDouble();
    final potIndex = _pots.indexWhere((p) => p['id'] == id);

    if (potIndex == -1) {
      return MockResponse.notFound('Pot not found');
    }

    final pot = Map<String, dynamic>.from(_pots[potIndex]);
    pot['currentAmount'] = (pot['currentAmount'] as double) + amount;
    pot['updatedAt'] = DateTime.now().toIso8601String();
    _pots[potIndex] = pot;

    // Add transaction record
    if (!_transactions.containsKey(id)) {
      _transactions[id] = [];
    }
    _transactions[id]!.add({
      'id': 'tx-${DateTime.now().millisecondsSinceEpoch}',
      'potId': id,
      'type': 'deposit',
      'amount': amount,
      'timestamp': DateTime.now().toIso8601String(),
    });

    return MockResponse.success(pot);
  }

  static Future<MockResponse> _handleWithdraw(RequestOptions options) async {
    final params = options.extractPathParams('/savings-pots/:id/withdraw');
    final id = params['id']!;
    final data = options.data as Map<String, dynamic>;
    final amount = (data['amount'] as num).toDouble();
    final potIndex = _pots.indexWhere((p) => p['id'] == id);

    if (potIndex == -1) {
      return MockResponse.notFound('Pot not found');
    }

    final pot = Map<String, dynamic>.from(_pots[potIndex]);
    final currentAmount = pot['currentAmount'] as double;

    if (amount > currentAmount) {
      return MockResponse.badRequest('Insufficient pot balance');
    }

    pot['currentAmount'] = currentAmount - amount;
    pot['updatedAt'] = DateTime.now().toIso8601String();
    _pots[potIndex] = pot;

    // Add transaction record
    if (!_transactions.containsKey(id)) {
      _transactions[id] = [];
    }
    _transactions[id]!.add({
      'id': 'tx-${DateTime.now().millisecondsSinceEpoch}',
      'potId': id,
      'type': 'withdraw',
      'amount': amount,
      'timestamp': DateTime.now().toIso8601String(),
    });

    return MockResponse.success(pot);
  }

  static Future<MockResponse> _handleWithdrawAll(RequestOptions options) async {
    final params = options.extractPathParams('/savings-pots/:id/withdraw-all');
    final id = params['id']!;
    final potIndex = _pots.indexWhere((p) => p['id'] == id);

    if (potIndex == -1) {
      return MockResponse.notFound('Pot not found');
    }

    final pot = Map<String, dynamic>.from(_pots[potIndex]);
    final amount = (pot['currentAmount'] as num).toDouble();
    pot['currentAmount'] = 0.0;
    pot['updatedAt'] = DateTime.now().toIso8601String();
    _pots[potIndex] = pot;

    if (!_transactions.containsKey(id)) {
      _transactions[id] = [];
    }
    _transactions[id]!.add({
      'id': 'tx-${DateTime.now().millisecondsSinceEpoch}',
      'potId': id,
      'type': 'withdraw',
      'amount': amount,
      'timestamp': DateTime.now().toIso8601String(),
    });

    return MockResponse.success(pot);
  }

  static Future<MockResponse> _handleGetTransactions(
    RequestOptions options,
  ) async {
    final params = options.extractPathParams('/savings-pots/:id/transactions');
    final id = params['id'];
    final transactions = _transactions[id] ?? [];
    return MockResponse.success({'transactions': transactions});
  }
}
