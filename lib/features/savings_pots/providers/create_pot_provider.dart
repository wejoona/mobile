import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/savings_pots/savings_pots_service.dart';
import 'package:usdc_wallet/features/savings_pots/providers/savings_pots_provider.dart';

/// Create savings pot flow state.
class CreatePotState {
  final bool isLoading;
  final String? error;
  final String? name;
  final double? targetAmount;
  final DateTime? targetDate;
  final bool isComplete;

  const CreatePotState({this.isLoading = false, this.error, this.name, this.targetAmount, this.targetDate, this.isComplete = false});

  CreatePotState copyWith({bool? isLoading, String? error, String? name, double? targetAmount, DateTime? targetDate, bool? isComplete}) => CreatePotState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    name: name ?? this.name,
    targetAmount: targetAmount ?? this.targetAmount,
    targetDate: targetDate ?? this.targetDate,
    isComplete: isComplete ?? this.isComplete,
  );
}

/// Create pot notifier.
class CreatePotNotifier extends Notifier<CreatePotState> {
  @override
  CreatePotState build() => const CreatePotState();

  void setName(String name) => state = state.copyWith(name: name);
  void setTargetAmount(double amount) => state = state.copyWith(targetAmount: amount);
  void setTargetDate(DateTime? date) => state = state.copyWith(targetDate: date);

  Future<void> create() async {
    if (state.name == null || state.name!.isEmpty) {
      state = state.copyWith(error: 'Veuillez saisir un nom');
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(savingsPotsServiceProvider);
      await service.create(
        name: state.name!,
        targetAmount: state.targetAmount ?? 0,
        targetDate: state.targetDate,
      );
      state = state.copyWith(isLoading: false, isComplete: true);
      ref.invalidate(savingsPotsProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const CreatePotState();
}

final createPotProvider = NotifierProvider<CreatePotNotifier, CreatePotState>(CreatePotNotifier.new);
