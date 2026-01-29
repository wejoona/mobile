import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sub_business.dart';
import '../../../services/api/api_client.dart';

/// State for sub-business management
class SubBusinessState {
  final bool isLoading;
  final String? error;
  final List<SubBusiness> subBusinesses;
  final Map<String, List<StaffMember>> staffBySubBusiness;

  const SubBusinessState({
    this.isLoading = false,
    this.error,
    this.subBusinesses = const [],
    this.staffBySubBusiness = const {},
  });

  SubBusinessState copyWith({
    bool? isLoading,
    String? error,
    List<SubBusiness>? subBusinesses,
    Map<String, List<StaffMember>>? staffBySubBusiness,
  }) {
    return SubBusinessState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
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
      final List<dynamic> data = response.data['subBusinesses'];
      final subBusinesses =
          data.map((json) => SubBusiness.fromJson(json)).toList();
      state = state.copyWith(
        isLoading: false,
        subBusinesses: subBusinesses,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
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
      final response = await dio.post('/sub-businesses', data: {
        'name': name,
        'description': description,
        'type': type.name,
      });
      final newSubBusiness = SubBusiness.fromJson(response.data);
      state = state.copyWith(
        isLoading: false,
        subBusinesses: [...state.subBusinesses, newSubBusiness],
      );
      return newSubBusiness;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Load staff members for a sub-business
  Future<void> loadStaff(String subBusinessId) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/sub-businesses/$subBusinessId/staff');
      final List<dynamic> data = response.data['staff'];
      final staff = data.map((json) => StaffMember.fromJson(json)).toList();

      final updatedStaff = Map<String, List<StaffMember>>.from(
        state.staffBySubBusiness,
      );
      updatedStaff[subBusinessId] = staff;

      state = state.copyWith(staffBySubBusiness: updatedStaff);
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
        data: {
          'phoneNumber': phoneNumber,
          'role': role.name,
        },
      );
      final newStaff = StaffMember.fromJson(response.data);

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
            name: sb.name,
            description: sb.description,
            balance: sb.balance,
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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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
      updatedStaff[subBusinessId] = staff.where((s) => s.id != staffId).toList();

      // Update staff count
      final updatedSubBusinesses = state.subBusinesses.map((sb) {
        if (sb.id == subBusinessId) {
          return SubBusiness(
            id: sb.id,
            name: sb.name,
            description: sb.description,
            balance: sb.balance,
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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Transfer between sub-businesses
  Future<bool> transferBetweenSubBusinesses({
    required String fromSubBusinessId,
    required String toSubBusinessId,
    required double amount,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/sub-businesses/transfer', data: {
        'fromSubBusinessId': fromSubBusinessId,
        'toSubBusinessId': toSubBusinessId,
        'amount': amount,
      });

      // Update balances locally
      final updatedSubBusinesses = state.subBusinesses.map((sb) {
        if (sb.id == fromSubBusinessId) {
          return SubBusiness(
            id: sb.id,
            name: sb.name,
            description: sb.description,
            balance: sb.balance - amount,
            type: sb.type,
            staffCount: sb.staffCount,
            createdAt: sb.createdAt,
            updatedAt: DateTime.now(),
          );
        } else if (sb.id == toSubBusinessId) {
          return SubBusiness(
            id: sb.id,
            name: sb.name,
            description: sb.description,
            balance: sb.balance + amount,
            type: sb.type,
            staffCount: sb.staffCount,
            createdAt: sb.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        return sb;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        subBusinesses: updatedSubBusinesses,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}

/// Provider for sub-business management
final subBusinessProvider =
    NotifierProvider<SubBusinessNotifier, SubBusinessState>(
  SubBusinessNotifier.new,
);
