import 'package:dio/dio.dart';
import '../../base/mock_interceptor.dart';
import '../../base/api_contract.dart';

/// Mock data for sub-business feature
class SubBusinessMock {
  static final _subBusinesses = [
    {
      'id': 'sb-1',
      'name': 'Sales Department',
      'description': 'Main sales and customer relations',
      'balance': 15000.0,
      'type': 'department',
      'staffCount': 5,
      'createdAt': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'sb-2',
      'name': 'Abidjan Branch',
      'description': 'Abidjan office operations',
      'balance': 28000.0,
      'type': 'branch',
      'staffCount': 8,
      'createdAt': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'sb-3',
      'name': 'Marketing Team',
      'description': null,
      'balance': 5000.0,
      'type': 'team',
      'staffCount': 3,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
  ];

  static final _staff = <String, List<Map<String, dynamic>>>{
    'sb-1': [
      {
        'id': 'staff-1',
        'subBusinessId': 'sb-1',
        'userId': 'user-1',
        'name': 'Amadou Diallo',
        'phoneNumber': '+225 01 23 45 67',
        'role': 'owner',
        'addedAt': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'staff-2',
        'subBusinessId': 'sb-1',
        'userId': 'user-2',
        'name': 'Fatou Koné',
        'phoneNumber': '+225 07 89 12 34',
        'role': 'admin',
        'addedAt': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'staff-3',
        'subBusinessId': 'sb-1',
        'userId': 'user-3',
        'name': 'Ibrahim Touré',
        'phoneNumber': '+225 05 67 89 01',
        'role': 'viewer',
        'addedAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'staff-4',
        'subBusinessId': 'sb-1',
        'userId': 'user-4',
        'name': 'Aissata Sow',
        'phoneNumber': '+225 02 34 56 78',
        'role': 'viewer',
        'addedAt': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'staff-5',
        'subBusinessId': 'sb-1',
        'userId': 'user-5',
        'name': 'Moussa Bamba',
        'phoneNumber': '+225 03 45 67 89',
        'role': 'admin',
        'addedAt': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        'isActive': true,
      },
    ],
    'sb-2': [
      {
        'id': 'staff-6',
        'subBusinessId': 'sb-2',
        'userId': 'user-6',
        'name': 'Mariam Coulibaly',
        'phoneNumber': '+225 04 56 78 90',
        'role': 'owner',
        'addedAt': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'staff-7',
        'subBusinessId': 'sb-2',
        'userId': 'user-7',
        'name': 'Ousmane Traoré',
        'phoneNumber': '+225 06 78 90 12',
        'role': 'admin',
        'addedAt': DateTime.now().subtract(const Duration(days: 100)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'staff-8',
        'subBusinessId': 'sb-2',
        'userId': 'user-8',
        'name': 'Kadiatou Diarra',
        'phoneNumber': '+225 08 90 12 34',
        'role': 'admin',
        'addedAt': DateTime.now().subtract(const Duration(days: 80)).toIso8601String(),
        'isActive': true,
      },
    ],
    'sb-3': [
      {
        'id': 'staff-9',
        'subBusinessId': 'sb-3',
        'userId': 'user-9',
        'name': 'Sekou Kante',
        'phoneNumber': '+225 09 01 23 45',
        'role': 'owner',
        'addedAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'staff-10',
        'subBusinessId': 'sb-3',
        'userId': 'user-10',
        'name': 'Awa Sanogo',
        'phoneNumber': '+225 01 12 23 34',
        'role': 'viewer',
        'addedAt': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'staff-11',
        'subBusinessId': 'sb-3',
        'userId': 'user-11',
        'name': 'Bakary Camara',
        'phoneNumber': '+225 02 23 34 45',
        'role': 'viewer',
        'addedAt': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        'isActive': true,
      },
    ],
  };

  static void register(MockInterceptor interceptor) {
    // GET /sub-businesses - Get all sub-businesses
    interceptor.register(
      method: 'GET',
      path: '/sub-businesses',
      handler: _handleGetAll,
    );

    // POST /sub-businesses - Create new sub-business
    interceptor.register(
      method: 'POST',
      path: '/sub-businesses',
      handler: _handleCreate,
    );

    // GET /sub-businesses/:id/staff - Get staff for sub-business
    interceptor.register(
      method: 'GET',
      path: '/sub-businesses/:id/staff',
      handler: _handleGetStaff,
    );

    // POST /sub-businesses/:id/staff - Add staff member
    interceptor.register(
      method: 'POST',
      path: '/sub-businesses/:id/staff',
      handler: _handleAddStaff,
    );

    // PATCH /sub-businesses/:id/staff/:staffId - Update staff role
    interceptor.register(
      method: 'PATCH',
      path: '/sub-businesses/:id/staff/:staffId',
      handler: _handleUpdateStaff,
    );

    // DELETE /sub-businesses/:id/staff/:staffId - Remove staff member
    interceptor.register(
      method: 'DELETE',
      path: '/sub-businesses/:id/staff/:staffId',
      handler: _handleRemoveStaff,
    );

    // POST /sub-businesses/transfer - Transfer between sub-businesses
    interceptor.register(
      method: 'POST',
      path: '/sub-businesses/transfer',
      handler: _handleTransfer,
    );
  }

  static Future<MockResponse> _handleGetAll(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockResponse.success({
      'subBusinesses': _subBusinesses,
    });
  }

  static Future<MockResponse> _handleCreate(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final data = options.data as Map<String, dynamic>;
    final newSubBusiness = {
      'id': 'sb-${_subBusinesses.length + 1}',
      'name': data['name'],
      'description': data['description'],
      'balance': 0.0,
      'type': data['type'],
      'staffCount': 1, // Creator is automatically added as owner
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _subBusinesses.add(newSubBusiness);

    // Add creator as owner
    _staff[newSubBusiness['id'] as String] = [
      {
        'id': 'staff-${DateTime.now().millisecondsSinceEpoch}',
        'subBusinessId': newSubBusiness['id'],
        'userId': 'current-user',
        'name': 'You',
        'phoneNumber': '+225 01 23 45 67',
        'role': 'owner',
        'addedAt': DateTime.now().toIso8601String(),
        'isActive': true,
      },
    ];

    return MockResponse.success(newSubBusiness);
  }

  static Future<MockResponse> _handleGetStaff(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final params = options.extractPathParams('/sub-businesses/:id/staff');
    final id = params['id'];
    final staff = _staff[id] ?? [];
    return MockResponse.success({'staff': staff});
  }

  static Future<MockResponse> _handleAddStaff(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final params = options.extractPathParams('/sub-businesses/:id/staff');
    final id = params['id']!;
    final data = options.data as Map<String, dynamic>;

    final newStaff = {
      'id': 'staff-${DateTime.now().millisecondsSinceEpoch}',
      'subBusinessId': id,
      'userId': 'user-${DateTime.now().millisecondsSinceEpoch}',
      'name': 'New Staff Member',
      'phoneNumber': data['phoneNumber'],
      'role': data['role'],
      'addedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    };

    if (!_staff.containsKey(id)) {
      _staff[id] = [];
    }
    _staff[id]!.add(newStaff);

    // Update staff count
    final sbIndex = _subBusinesses.indexWhere((sb) => sb['id'] == id);
    if (sbIndex != -1) {
      _subBusinesses[sbIndex]['staffCount'] =
          (_subBusinesses[sbIndex]['staffCount'] as int) + 1;
    }

    return MockResponse.success(newStaff);
  }

  static Future<MockResponse> _handleUpdateStaff(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final params =
        options.extractPathParams('/sub-businesses/:id/staff/:staffId');
    final id = params['id']!;
    final staffId = params['staffId']!;
    final data = options.data as Map<String, dynamic>;

    final staff = _staff[id];
    if (staff == null) {
      return MockResponse.notFound('Sub-business not found');
    }

    final staffIndex = staff.indexWhere((s) => s['id'] == staffId);
    if (staffIndex == -1) {
      return MockResponse.notFound('Staff member not found');
    }

    staff[staffIndex]['role'] = data['role'];
    return MockResponse.success(staff[staffIndex]);
  }

  static Future<MockResponse> _handleRemoveStaff(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final params =
        options.extractPathParams('/sub-businesses/:id/staff/:staffId');
    final id = params['id']!;
    final staffId = params['staffId']!;

    final staff = _staff[id];
    if (staff == null) {
      return MockResponse.notFound('Sub-business not found');
    }

    staff.removeWhere((s) => s['id'] == staffId);

    // Update staff count
    final sbIndex = _subBusinesses.indexWhere((sb) => sb['id'] == id);
    if (sbIndex != -1) {
      _subBusinesses[sbIndex]['staffCount'] =
          (_subBusinesses[sbIndex]['staffCount'] as int) - 1;
    }

    return MockResponse.success({'success': true});
  }

  static Future<MockResponse> _handleTransfer(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final data = options.data as Map<String, dynamic>;
    final fromId = data['fromSubBusinessId'] as String;
    final toId = data['toSubBusinessId'] as String;
    final amount = (data['amount'] as num).toDouble();

    final fromIndex = _subBusinesses.indexWhere((sb) => sb['id'] == fromId);
    final toIndex = _subBusinesses.indexWhere((sb) => sb['id'] == toId);

    if (fromIndex == -1 || toIndex == -1) {
      return MockResponse.notFound('Sub-business not found');
    }

    final fromBalance = _subBusinesses[fromIndex]['balance'] as double;
    if (amount > fromBalance) {
      return MockResponse.badRequest('Insufficient balance');
    }

    _subBusinesses[fromIndex]['balance'] = fromBalance - amount;
    _subBusinesses[fromIndex]['updatedAt'] = DateTime.now().toIso8601String();

    _subBusinesses[toIndex]['balance'] =
        (_subBusinesses[toIndex]['balance'] as double) + amount;
    _subBusinesses[toIndex]['updatedAt'] = DateTime.now().toIso8601String();

    return MockResponse.success({
      'success': true,
      'transactionId': 'tx-${DateTime.now().millisecondsSinceEpoch}',
    });
  }
}
