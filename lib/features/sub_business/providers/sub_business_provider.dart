import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/sub_business/models/sub_business.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

const _unset = Object();

/// State for sub-business management
class SubBusinessState {
  final bool isLoading;
  final String? error;
  final bool requiresBusinessProfile;
  final List<SubBusiness> subBusinesses;
  final Map<String, List<StaffMember>> staffBySubBusiness;

  const SubBusinessState({
    this.isLoading = false,
    this.error,
    this.requiresBusinessProfile = false,
    this.subBusinesses = const [],
    this.staffBySubBusiness = const {},
  });

  SubBusinessState copyWith({
    bool? isLoading,
    Object? error = _unset,
    bool? requiresBusinessProfile,
    List<SubBusiness>? subBusinesses,
    Map<String, List<StaffMember>>? staffBySubBusiness,
  }) {
    return SubBusinessState(
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
      requiresBusinessProfile:
          requiresBusinessProfile ?? this.requiresBusinessProfile,
      subBusinesses: subBusinesses ?? this.subBusinesses,
      staffBySubBusiness: staffBySubBusiness ?? this.staffBySubBusiness,
    );
  }
}

/// Notifier for sub-business management
class SubBusinessNotifier extends Notifier<SubBusinessState> {
  @override
  SubBusinessState build() => const SubBusinessState();

  /// Load all sub-businesses
  Future<void> loadSubBusinesses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/sub-businesses');
      final data = _extractList(response.data, const [
        'subBusinesses',
        'data',
        'items',
      ]);
      final subBusinesses = data
          .map((json) => SubBusiness.fromJson(_asStringMap(json)))
          .toList();
      state = state.copyWith(
        isLoading: false,
        error: null,
        requiresBusinessProfile: false,
        subBusinesses: subBusinesses,
      );
    } on DioException catch (e) {
      if (_requiresBusinessProfile(e)) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          requiresBusinessProfile: true,
          subBusinesses: const [],
        );
        return;
      }
      state = state.copyWith(
        isLoading: false,
        requiresBusinessProfile: false,
        error: _readDioMessage(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        requiresBusinessProfile: false,
        error: e.toString(),
      );
    }
  }

  /// Create new sub-business
  Future<SubBusiness?> createSubBusiness({
    required String name,
    String? description,
    required SubBusinessType type,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final walletId = await _currentWalletId(dio);
      final response = await dio.post(
        '/sub-businesses',
        data: {
          'walletId': walletId,
          'name': name,
          'description': description,
          'type': _backendSubBusinessType(type),
        },
      );
      final newSubBusiness = SubBusiness.fromJson(
        _extractObject(response.data, const ['subBusiness', 'data']),
      );
      state = state.copyWith(
        isLoading: false,
        subBusinesses: [...state.subBusinesses, newSubBusiness],
      );
      return newSubBusiness;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Load staff members for a sub-business
  Future<void> loadStaff(String subBusinessId) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/sub-businesses/$subBusinessId/staff');
      final data = _extractList(response.data, const [
        'staff',
        'data',
        'items',
      ]);
      final staff = data
          .map((json) => StaffMember.fromJson(_asStringMap(json)))
          .toList();

      final updatedStaff = Map<String, List<StaffMember>>.from(
        state.staffBySubBusiness,
      );
      updatedStaff[subBusinessId] = staff;

      state = state.copyWith(staffBySubBusiness: updatedStaff);
    } on DioException catch (e) {
      if (_isMissingEndpoint(e)) {
        final updatedStaff = Map<String, List<StaffMember>>.from(
          state.staffBySubBusiness,
        );
        updatedStaff[subBusinessId] = const [];
        state = state.copyWith(staffBySubBusiness: updatedStaff);
        return;
      }
      state = state.copyWith(error: e.toString());
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Add staff member to sub-business
  Future<bool> addStaff({
    required String subBusinessId,
    required String phoneNumber,
    required StaffRole role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/sub-businesses/$subBusinessId/staff',
        data: {'phoneNumber': phoneNumber, 'role': role.name},
      );
      final newStaff = StaffMember.fromJson(
        _extractObject(response.data, const ['staffMember', 'staff', 'data']),
      );

      final updatedStaff = Map<String, List<StaffMember>>.from(
        state.staffBySubBusiness,
      );
      final currentStaff = updatedStaff[subBusinessId] ?? [];
      updatedStaff[subBusinessId] = [...currentStaff, newStaff];

      // Update staff count
      final updatedSubBusinesses = state.subBusinesses.map((sb) {
        if (sb.id == subBusinessId) {
          return SubBusiness(
            id: sb.id,
            walletId: sb.walletId,
            name: sb.name,
            description: sb.description,
            balance: sb.balance,
            currency: sb.currency,
            status: sb.status,
            type: sb.type,
            staffCount: sb.staffCount + 1,
            createdAt: sb.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        return sb;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        staffBySubBusiness: updatedStaff,
        subBusinesses: updatedSubBusinesses,
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _isMissingEndpoint(e)
            ? 'Staff management is not available yet.'
            : e.toString(),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Update staff member role
  Future<bool> updateStaffRole({
    required String subBusinessId,
    required String staffId,
    required StaffRole newRole,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      await dio.patch(
        '/sub-businesses/$subBusinessId/staff/$staffId',
        data: {'role': newRole.name},
      );

      final updatedStaff = Map<String, List<StaffMember>>.from(
        state.staffBySubBusiness,
      );
      final staff = updatedStaff[subBusinessId] ?? [];
      updatedStaff[subBusinessId] = staff.map((s) {
        if (s.id == staffId) {
          return StaffMember(
            id: s.id,
            subBusinessId: s.subBusinessId,
            userId: s.userId,
            name: s.name,
            phoneNumber: s.phoneNumber,
            role: newRole,
            addedAt: s.addedAt,
            isActive: s.isActive,
          );
        }
        return s;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        staffBySubBusiness: updatedStaff,
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _isMissingEndpoint(e)
            ? 'Staff management is not available yet.'
            : e.toString(),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Remove staff member
  Future<bool> removeStaff({
    required String subBusinessId,
    required String staffId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/sub-businesses/$subBusinessId/staff/$staffId');

      final updatedStaff = Map<String, List<StaffMember>>.from(
        state.staffBySubBusiness,
      );
      final staff = updatedStaff[subBusinessId] ?? [];
      updatedStaff[subBusinessId] = staff
          .where((s) => s.id != staffId)
          .toList();

      // Update staff count
      final updatedSubBusinesses = state.subBusinesses.map((sb) {
        if (sb.id == subBusinessId) {
          return SubBusiness(
            id: sb.id,
            walletId: sb.walletId,
            name: sb.name,
            description: sb.description,
            balance: sb.balance,
            currency: sb.currency,
            status: sb.status,
            type: sb.type,
            staffCount: sb.staffCount - 1,
            createdAt: sb.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        return sb;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        staffBySubBusiness: updatedStaff,
        subBusinesses: updatedSubBusinesses,
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _isMissingEndpoint(e)
            ? 'Staff management is not available yet.'
            : e.toString(),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Transfer between sub-businesses
  Future<bool> transferBetweenSubBusinesses({
    required String fromSubBusinessId,
    required String toSubBusinessId,
    required double amount,
    String? note,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      await dio.post(
        '/sub-businesses/transfer',
        data: {
          'fromSubBusinessId': fromSubBusinessId,
          'toSubBusinessId': toSubBusinessId,
          'amount': amount,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
      );

      await loadSubBusinesses();
      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _isMissingEndpoint(e)
            ? 'Sub-business transfers are not available yet.'
            : _readDioMessage(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

/// Provider for sub-business management
final subBusinessProvider =
    NotifierProvider<SubBusinessNotifier, SubBusinessState>(
      SubBusinessNotifier.new,
    );

List<dynamic> _extractList(Object? data, List<String> keys) {
  if (data is List) return data;
  if (data is Map) {
    for (final key in keys) {
      final value = data[key];
      if (value is List) return value;
    }
  }
  return const [];
}

Map<String, dynamic> _extractObject(Object? data, List<String> keys) {
  Object? value = data;
  if (data is Map) {
    for (final key in keys) {
      if (data[key] is Map) {
        value = data[key];
        break;
      }
    }
  }
  return _asStringMap(value);
}

Map<String, dynamic> _asStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const FormatException('Expected sub-business JSON object');
}

Future<String> _currentWalletId(Dio dio) async {
  final response = await dio.get('/wallet');
  final data = response.data;
  if (data is Map) {
    final walletId = data['walletId'] as String? ?? data['id'] as String?;
    if (walletId != null && walletId.isNotEmpty) return walletId;
  }
  throw const FormatException('Current wallet id is required');
}

String _backendSubBusinessType(SubBusinessType type) {
  if (type == SubBusinessType.subsidiary) return SubBusinessType.branch.name;
  return type.name;
}

bool _isMissingEndpoint(DioException e) {
  final statusCode = e.response?.statusCode;
  return statusCode == 404 || statusCode == 405;
}

bool _requiresBusinessProfile(DioException e) {
  if (e.response?.statusCode != 404) return false;
  final message = _readDioMessage(e).toLowerCase();
  return message.contains('business profile') ||
      message.contains('create a business profile');
}

String _readDioMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
    final error = data['error'];
    if (error is String && error.isNotEmpty) return error;
  }
  return e.message ?? 'Request failed. Please try again.';
}
