import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/savings_pot.dart';
import '../models/pot_transaction.dart';
import '../services/savings_pots_service.dart';
import '../../../services/api/api_client.dart';

/// State for savings pots feature
class SavingsPotsState {
  final bool isLoading;
  final String? error;
  final List<SavingsPot> pots;
  final SavingsPot? selectedPot;
  final List<PotTransaction>? selectedPotTransactions;

  const SavingsPotsState({
    this.isLoading = false,
    this.error,
    this.pots = const [],
    this.selectedPot,
    this.selectedPotTransactions,
  });

  /// Total amount saved across all pots
  double get totalSaved => pots.fold(0.0, (sum, pot) => sum + pot.currentAmount);

  SavingsPotsState copyWith({
    bool? isLoading,
    String? error,
    List<SavingsPot>? pots,
    SavingsPot? selectedPot,
    List<PotTransaction>? selectedPotTransactions,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return SavingsPotsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      pots: pots ?? this.pots,
      selectedPot: clearSelected ? null : (selectedPot ?? this.selectedPot),
      selectedPotTransactions: clearSelected
          ? null
          : (selectedPotTransactions ?? this.selectedPotTransactions),
    );
  }
}

/// Notifier for managing savings pots
class SavingsPotsNotifier extends Notifier<SavingsPotsState> {
  late final SavingsPotsService _service;

  @override
  SavingsPotsState build() {
    final dio = ref.read(dioProvider);
    _service = SavingsPotsService(dio);
    return const SavingsPotsState();
  }

  /// Load all pots
  Future<void> loadPots() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final pots = await _service.getPots();
      state = state.copyWith(isLoading: false, pots: pots);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new pot
  Future<bool> createPot({
    required String name,
    required String emoji,
    required Color color,
    double? targetAmount,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final pot = await _service.createPot(
        name: name,
        emoji: emoji,
        colorValue: color.value,
        targetAmount: targetAmount,
      );

      final updatedPots = [...state.pots, pot];
      state = state.copyWith(isLoading: false, pots: updatedPots);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Update an existing pot
  Future<bool> updatePot({
    required String id,
    String? name,
    String? emoji,
    Color? color,
    double? targetAmount,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final pot = await _service.updatePot(
        id: id,
        name: name,
        emoji: emoji,
        colorValue: color?.value,
        targetAmount: targetAmount,
      );

      final updatedPots = state.pots.map((p) => p.id == id ? pot : p).toList();
      state = state.copyWith(
        isLoading: false,
        pots: updatedPots,
        selectedPot: state.selectedPot?.id == id ? pot : state.selectedPot,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Delete a pot
  Future<bool> deletePot(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.deletePot(id);

      final updatedPots = state.pots.where((p) => p.id != id).toList();
      state = state.copyWith(isLoading: false, pots: updatedPots);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Add money to a pot
  Future<bool> addToPot(String potId, double amount) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final pot = await _service.addToPot(potId: potId, amount: amount);

      final updatedPots = state.pots.map((p) => p.id == potId ? pot : p).toList();
      state = state.copyWith(
        isLoading: false,
        pots: updatedPots,
        selectedPot: state.selectedPot?.id == potId ? pot : state.selectedPot,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Withdraw money from a pot
  Future<bool> withdrawFromPot(String potId, double amount) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final pot = await _service.withdrawFromPot(potId: potId, amount: amount);

      final updatedPots = state.pots.map((p) => p.id == potId ? pot : p).toList();
      state = state.copyWith(
        isLoading: false,
        pots: updatedPots,
        selectedPot: state.selectedPot?.id == potId ? pot : state.selectedPot,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Select a pot for detail view
  Future<void> selectPot(String potId) async {
    final pot = state.pots.firstWhere((p) => p.id == potId);
    state = state.copyWith(selectedPot: pot, isLoading: true, clearError: true);

    try {
      final transactions = await _service.getPotTransactions(potId);
      state = state.copyWith(
        isLoading: false,
        selectedPotTransactions: transactions,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clear selected pot
  void clearSelection() {
    state = state.copyWith(clearSelected: true);
  }
}

/// Provider for savings pots
final savingsPotsProvider = NotifierProvider<SavingsPotsNotifier, SavingsPotsState>(
  SavingsPotsNotifier.new,
);
