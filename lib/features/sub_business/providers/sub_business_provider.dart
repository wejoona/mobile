import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/sub_business/models/sub_business.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

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
  static const _staffUnavailable = 'Staff management is not available yet.';
  static const _transferUnavailable =
      'Sub-business transfers are not available yet.';

  @override
  SubBusinessState build() => const SubBusinessState();

  /// Load all sub-businesses
  Future<void> loadSubBusinesses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/sub-businesses');
      // ignore: avoid_dynamic_calls
      final List<dynamic> data = response.data['subBusinesses'];
      final subBusinesses = data
          .map((json) => SubBusiness.fromJson(json))
          .toList();
      state = state.copyWith(isLoading: false, subBusinesses: subBusinesses);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
      final response = await dio.post(
        '/sub-businesses',
        data: {'name': name, 'description': description, 'type': type.name},
      );
      final newSubBusiness = SubBusiness.fromJson(response.data);
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
    final updatedStaff = Map<String, List<StaffMember>>.from(
      state.staffBySubBusiness,
    );
    updatedStaff[subBusinessId] = const [];
    state = state.copyWith(
      isLoading: false,
      error: null,
      staffBySubBusiness: updatedStaff,
    );
  }

  /// Add staff member to sub-business
  Future<bool> addStaff({
    required String subBusinessId,
    required String phoneNumber,
    required StaffRole role,
  }) async {
    state = state.copyWith(isLoading: false, error: _staffUnavailable);
    return false;
  }

  /// Update staff member role
  Future<bool> updateStaffRole({
    required String subBusinessId,
    required String staffId,
    required StaffRole newRole,
  }) async {
    state = state.copyWith(isLoading: false, error: _staffUnavailable);
    return false;
  }

  /// Remove staff member
  Future<bool> removeStaff({
    required String subBusinessId,
    required String staffId,
  }) async {
    state = state.copyWith(isLoading: false, error: _staffUnavailable);
    return false;
  }

  /// Transfer between sub-businesses
  Future<bool> transferBetweenSubBusinesses({
    required String fromSubBusinessId,
    required String toSubBusinessId,
    required double amount,
  }) async {
    state = state.copyWith(isLoading: false, error: _transferUnavailable);
    return false;
  }
}

/// Provider for sub-business management
final subBusinessProvider =
    NotifierProvider<SubBusinessNotifier, SubBusinessState>(
      SubBusinessNotifier.new,
    );
