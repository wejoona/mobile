import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

class RecurringTransfersMock {
  static final List<Map<String, dynamic>> _transfers = [];

  static void reset() {
    _transfers
      ..clear()
      ..addAll(_initialTransfers());
  }

  static void register(MockInterceptor interceptor) {
    if (_transfers.isEmpty) reset();

    // GET /recurring-transfers - List all
    interceptor.register(
      method: 'GET',
      path: '/recurring-transfers',
      handler: _handleGetAll,
    );

    // GET /recurring-transfers/:id - Get single
    interceptor.register(
      method: 'GET',
      path: '/recurring-transfers/:id',
      handler: _handleGetSingle,
    );

    // POST /recurring-transfers - Create
    interceptor.register(
      method: 'POST',
      path: '/recurring-transfers',
      handler: _handleCreate,
    );

    // PATCH /recurring-transfers/:id - Update
    interceptor.register(
      method: 'PATCH',
      path: '/recurring-transfers/:id',
      handler: _handleUpdate,
    );

    // POST /recurring-transfers/:id/pause - Pause
    interceptor.register(
      method: 'POST',
      path: '/recurring-transfers/:id/pause',
      handler: _handlePause,
    );

    // POST /recurring-transfers/:id/resume - Resume
    interceptor.register(
      method: 'POST',
      path: '/recurring-transfers/:id/resume',
      handler: _handleResume,
    );

    // DELETE /recurring-transfers/:id - Cancel
    interceptor.register(
      method: 'DELETE',
      path: '/recurring-transfers/:id',
      handler: _handleCancel,
    );

    // GET /recurring-transfers/:id/history - Execution history
    interceptor.register(
      method: 'GET',
      path: '/recurring-transfers/:id/history',
      handler: _handleGetHistory,
    );

    // GET /recurring-transfers/upcoming - Upcoming executions
    interceptor.register(
      method: 'GET',
      path: '/recurring-transfers/upcoming',
      handler: _handleGetUpcoming,
    );

    // GET /recurring-transfers/:id/next-dates - Next execution dates
    interceptor.register(
      method: 'GET',
      path: '/recurring-transfers/:id/next-dates',
      handler: _handleGetNextDates,
    );
  }

  static Future<MockResponse> _handleGetAll(RequestOptions options) async {
    return MockResponse.success({
      'transfers': List<Map<String, dynamic>>.from(_transfers),
    });
  }

  static Future<MockResponse> _handleGetSingle(RequestOptions options) async {
    final params = options.extractPathParams('/recurring-transfers/:id');
    final id = params['id'];

    final transfer = _transfers.cast<Map<String, dynamic>?>().firstWhere(
      (t) => t?['id'] == id,
      orElse: () => null,
    );

    if (transfer == null) {
      return MockResponse.notFound('Recurring transfer not found');
    }

    return MockResponse.success(transfer);
  }

  static Future<MockResponse> _handleCreate(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>;
    final now = DateTime.now();

    final transfer = {
      'id': 'rt_${DateTime.now().millisecondsSinceEpoch}',
      'recipientPhone': data['recipientPhone'],
      'recipientName': data['recipientName'],
      'amount': data['amount'],
      'currency': data['currency'],
      'frequency': data['frequency'],
      'startDate': data['startDate'],
      'endDate': data['endDate'],
      'nextExecutionDate': data['startDate'],
      'occurrencesRemaining': data['occurrences'],
      'status': 'active',
      'note': data['note'],
      'dayOfWeek': data['dayOfWeek'],
      'dayOfMonth': data['dayOfMonth'],
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'executedCount': 0,
    };
    _transfers.insert(0, transfer);

    return MockResponse.success(transfer);
  }

  static Future<MockResponse> _handleUpdate(RequestOptions options) async {
    final params = options.extractPathParams('/recurring-transfers/:id');
    final id = params['id'];
    final updates = options.data as Map<String, dynamic>;

    final transferIndex = _transfers.indexWhere((t) => t['id'] == id);
    if (transferIndex == -1) {
      return MockResponse.notFound('Recurring transfer not found');
    }

    final updated = {
      ..._transfers[transferIndex],
      ...updates,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _transfers[transferIndex] = updated;

    return MockResponse.success(updated);
  }

  static Future<MockResponse> _handlePause(RequestOptions options) async {
    final params = options.extractPathParams('/recurring-transfers/:id/pause');
    final id = params['id'];

    final transferIndex = _transfers.indexWhere((t) => t['id'] == id);
    if (transferIndex == -1) {
      return MockResponse.notFound('Recurring transfer not found');
    }

    final updated = {
      ..._transfers[transferIndex],
      'status': 'paused',
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _transfers[transferIndex] = updated;

    return MockResponse.success(updated);
  }

  static Future<MockResponse> _handleResume(RequestOptions options) async {
    final params = options.extractPathParams('/recurring-transfers/:id/resume');
    final id = params['id'];

    final transferIndex = _transfers.indexWhere((t) => t['id'] == id);
    if (transferIndex == -1) {
      return MockResponse.notFound('Recurring transfer not found');
    }

    final updated = {
      ..._transfers[transferIndex],
      'status': 'active',
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _transfers[transferIndex] = updated;

    return MockResponse.success(updated);
  }

  static Future<MockResponse> _handleCancel(RequestOptions options) async {
    final params = options.extractPathParams('/recurring-transfers/:id');
    final id = params['id'];
    final removed = _transfers.any((t) => t['id'] == id);
    if (!removed) {
      return MockResponse.notFound('Recurring transfer not found');
    }

    _transfers.removeWhere((t) => t['id'] == id);
    return MockResponse.success({'success': true});
  }

  static Future<MockResponse> _handleGetHistory(RequestOptions options) async {
    return MockResponse.success({'history': _getMockHistory()});
  }

  static Future<MockResponse> _handleGetUpcoming(RequestOptions options) async {
    return MockResponse.success({'upcoming': _getMockUpcoming()});
  }

  static Future<MockResponse> _handleGetNextDates(
    RequestOptions options,
  ) async {
    final count =
        int.tryParse(options.queryParameters['count']?.toString() ?? '3') ?? 3;

    final now = DateTime.now();
    final dates = List.generate(
      count,
      (i) => now.add(Duration(days: 7 * (i + 1))).toIso8601String(),
    );

    return MockResponse.success({'dates': dates});
  }

  static List<Map<String, dynamic>> _initialTransfers() {
    final now = DateTime.now();

    return [
      {
        'id': 'rt_001',
        'recipientPhone': '+225 07 45 67 89 12',
        'recipientName': 'Fatou Diallo',
        'amount': 25000,
        'currency': 'XOF',
        'frequency': 'weekly',
        'startDate': now.subtract(const Duration(days: 30)).toIso8601String(),
        'endDate': null,
        'nextExecutionDate': now.add(const Duration(days: 2)).toIso8601String(),
        'occurrencesRemaining': null,
        'status': 'active',
        'note': 'Weekly allowance for Fatou',
        'dayOfWeek': 1, // Monday
        'dayOfMonth': null,
        'createdAt': now.subtract(const Duration(days: 30)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 5)).toIso8601String(),
        'executedCount': 4,
      },
      {
        'id': 'rt_002',
        'recipientPhone': '+225 05 12 34 56 78',
        'recipientName': 'Amadou Traore',
        'amount': 100000,
        'currency': 'XOF',
        'frequency': 'monthly',
        'startDate': now.subtract(const Duration(days: 60)).toIso8601String(),
        'endDate': null,
        'nextExecutionDate': DateTime(
          now.year,
          now.month + 1,
          1,
        ).toIso8601String(),
        'occurrencesRemaining': null,
        'status': 'active',
        'note': 'Monthly rent payment',
        'dayOfWeek': null,
        'dayOfMonth': 1,
        'createdAt': now.subtract(const Duration(days: 60)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'executedCount': 2,
      },
      {
        'id': 'rt_003',
        'recipientPhone': '+225 01 98 76 54 32',
        'recipientName': 'Koffi Mensah',
        'amount': 15000,
        'currency': 'XOF',
        'frequency': 'biweekly',
        'startDate': now.subtract(const Duration(days: 14)).toIso8601String(),
        'endDate': now.add(const Duration(days: 90)).toIso8601String(),
        'nextExecutionDate': now.add(const Duration(days: 7)).toIso8601String(),
        'occurrencesRemaining': 5,
        'status': 'paused',
        'note': null,
        'dayOfWeek': 5, // Friday
        'dayOfMonth': null,
        'createdAt': now.subtract(const Duration(days: 14)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'executedCount': 1,
      },
    ];
  }

  static List<Map<String, dynamic>> _getMockHistory() {
    final now = DateTime.now();

    return [
      {
        'id': 'eh_001',
        'recurringTransferId': 'rt_001',
        'amount': 25000,
        'currency': 'XOF',
        'executedAt': now.subtract(const Duration(days: 7)).toIso8601String(),
        'success': true,
        'errorMessage': null,
        'transactionId': 'txn_abc123',
      },
      {
        'id': 'eh_002',
        'recurringTransferId': 'rt_001',
        'amount': 25000,
        'currency': 'XOF',
        'executedAt': now.subtract(const Duration(days: 14)).toIso8601String(),
        'success': true,
        'errorMessage': null,
        'transactionId': 'txn_def456',
      },
      {
        'id': 'eh_003',
        'recurringTransferId': 'rt_001',
        'amount': 25000,
        'currency': 'XOF',
        'executedAt': now.subtract(const Duration(days: 21)).toIso8601String(),
        'success': false,
        'errorMessage': 'Insufficient balance',
        'transactionId': null,
      },
    ];
  }

  static List<Map<String, dynamic>> _getMockUpcoming() {
    final now = DateTime.now();

    return [
      {
        'recurringTransferId': 'rt_001',
        'recipientName': 'Fatou Diallo',
        'amount': 25000,
        'currency': 'XOF',
        'scheduledDate': now.add(const Duration(days: 1)).toIso8601String(),
      },
      {
        'recurringTransferId': 'rt_002',
        'recipientName': 'Amadou Traore',
        'amount': 100000,
        'currency': 'XOF',
        'scheduledDate': now.add(const Duration(days: 5)).toIso8601String(),
      },
    ];
  }
}
