import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/beneficiaries/models/beneficiary.dart';
import 'package:usdc_wallet/features/beneficiaries/repositories/beneficiaries_repository.dart';

/// Beneficiaries State
class BeneficiariesState {
  final bool isLoading;
  final String? error;
  final List<Beneficiary> beneficiaries;
  final BeneficiariesFilter currentFilter;
  final String searchQuery;

  const BeneficiariesState({
    this.isLoading = false,
    this.error,
    this.beneficiaries = const [],
    this.currentFilter = BeneficiariesFilter.all,
    this.searchQuery = '',
  });

  /// Get filtered beneficiaries based on current filter and search
  List<Beneficiary> get filteredBeneficiaries {
    var filtered = beneficiaries;

    // Apply filter
    switch (currentFilter) {
      case BeneficiariesFilter.favorites:
        filtered = filtered.where((b) => b.isFavorite).toList();
        break;
      case BeneficiariesFilter.recent:
        filtered = filtered.where((b) => b.lastTransferAt != null).toList();
        filtered.sort((a, b) =>
            b.lastTransferAt!.compareTo(a.lastTransferAt!));
        break;
      case BeneficiariesFilter.all:
        break;
    }

    // Apply search
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((b) {
        return b.name.toLowerCase().contains(query) ||
            (b.phoneE164?.contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  BeneficiariesState copyWith({
    bool? isLoading,
    String? error,
    List<Beneficiary>? beneficiaries,
    BeneficiariesFilter? currentFilter,
    String? searchQuery,
  }) {
    return BeneficiariesState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      beneficiaries: beneficiaries ?? this.beneficiaries,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Beneficiaries Filter
enum BeneficiariesFilter {
  all,
  favorites,
  recent,
}

/// Beneficiaries Notifier
class BeneficiariesNotifier extends Notifier<BeneficiariesState> {
  @override
  BeneficiariesState build() => const BeneficiariesState();

  BeneficiariesRepository get _repository =>
      ref.read(beneficiariesRepositoryProvider);

  /// Load all beneficiaries
  Future<void> loadBeneficiaries() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final beneficiaries = await _repository.getBeneficiaries();
      state = state.copyWith(isLoading: false, beneficiaries: beneficiaries);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh beneficiaries
  Future<void> refresh() async {
    await loadBeneficiaries();
  }

  /// Create a new beneficiary
  Future<Beneficiary?> createBeneficiary(
    CreateBeneficiaryRequest request,
  ) async {
    try {
      final beneficiary = await _repository.createBeneficiary(request);

      // Add to list
      final updatedList = [...state.beneficiaries, beneficiary];
      state = state.copyWith(beneficiaries: updatedList);

      return beneficiary;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Update a beneficiary
  Future<bool> updateBeneficiary(
    String id,
    UpdateBeneficiaryRequest request,
  ) async {
    try {
      final updated = await _repository.updateBeneficiary(id, request);

      // Update in list
      final updatedList = state.beneficiaries.map((b) {
        return b.id == id ? updated : b;
      }).toList();
      state = state.copyWith(beneficiaries: updatedList);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete a beneficiary
  Future<bool> deleteBeneficiary(String id) async {
    try {
      await _repository.deleteBeneficiary(id);

      // Remove from list
      final updatedList = state.beneficiaries.where((b) => b.id != id).toList();
      state = state.copyWith(beneficiaries: updatedList);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    try {
      final updated = await _repository.toggleFavorite(id);

      // Update in list
      final updatedList = state.beneficiaries.map((b) {
        return b.id == id ? updated : b;
      }).toList();
      state = state.copyWith(beneficiaries: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Set filter
  void setFilter(BeneficiariesFilter filter) {
    state = state.copyWith(currentFilter: filter);
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear search
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }
}

/// Beneficiaries Provider
final beneficiariesProvider =
    NotifierProvider<BeneficiariesNotifier, BeneficiariesState>(
  BeneficiariesNotifier.new,
);
