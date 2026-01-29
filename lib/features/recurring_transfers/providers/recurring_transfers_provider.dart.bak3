import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recurring_transfer.dart';
import '../models/create_recurring_transfer_request.dart';
import '../models/update_recurring_transfer_request.dart';
import '../models/execution_history.dart';
import '../models/upcoming_execution.dart';
import '../../../services/recurring_transfers/recurring_transfers_service.dart';
import '../../../services/api/api_client.dart';

// Service provider
final recurringTransfersServiceProvider = Provider<RecurringTransfersService>((ref) {
  final dio = ref.watch(dioProvider);
  return RecurringTransfersService(dio);
});

// State classes
class RecurringTransfersState {
  final bool isLoading;
  final String? error;
  final List<RecurringTransfer> transfers;
  final List<UpcomingExecution> upcoming;

  const RecurringTransfersState({
    this.isLoading = false,
    this.error,
    this.transfers = const [],
    this.upcoming = const [],
  });

  RecurringTransfersState copyWith({
    bool? isLoading,
    String? error,
    List<RecurringTransfer>? transfers,
    List<UpcomingExecution>? upcoming,
  }) {
    return RecurringTransfersState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      transfers: transfers ?? this.transfers,
      upcoming: upcoming ?? this.upcoming,
    );
  }

  List<RecurringTransfer> get activeTransfers =>
      transfers.where((t) => t.isActive).toList();

  List<RecurringTransfer> get pausedTransfers =>
      transfers.where((t) => t.isPaused).toList();

  List<RecurringTransfer> get inactiveTransfers =>
      transfers.where((t) => t.isCompleted || t.isCancelled).toList();
}

// Main provider
class RecurringTransfersNotifier extends Notifier<RecurringTransfersState> {
  @override
  RecurringTransfersState build() => const RecurringTransfersState();

  RecurringTransfersService get _service =>
      ref.read(recurringTransfersServiceProvider);

  Future<void> loadRecurringTransfers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transfers = await _service.getRecurringTransfers();
      state = state.copyWith(isLoading: false, transfers: transfers);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadUpcoming() async {
    try {
      final upcoming = await _service.getUpcomingExecutions();
      state = state.copyWith(upcoming: upcoming);
    } catch (e) {
      // Silently fail for upcoming - not critical
    }
  }

  Future<RecurringTransfer?> createRecurringTransfer(
    CreateRecurringTransferRequest request,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transfer = await _service.createRecurringTransfer(request);
      state = state.copyWith(
        isLoading: false,
        transfers: [...state.transfers, transfer],
      );
      return transfer;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> updateRecurringTransfer(
    String id,
    UpdateRecurringTransferRequest request,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _service.updateRecurringTransfer(id, request);
      final transfers = state.transfers.map((t) {
        return t.id == id ? updated : t;
      }).toList();
      state = state.copyWith(isLoading: false, transfers: transfers);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> pauseRecurringTransfer(String id) async {
    try {
      final updated = await _service.pauseRecurringTransfer(id);
      final transfers = state.transfers.map((t) {
        return t.id == id ? updated : t;
      }).toList();
      state = state.copyWith(transfers: transfers);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> resumeRecurringTransfer(String id) async {
    try {
      final updated = await _service.resumeRecurringTransfer(id);
      final transfers = state.transfers.map((t) {
        return t.id == id ? updated : t;
      }).toList();
      state = state.copyWith(transfers: transfers);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> cancelRecurringTransfer(String id) async {
    try {
      await _service.cancelRecurringTransfer(id);
      final transfers = state.transfers.where((t) => t.id != id).toList();
      state = state.copyWith(transfers: transfers);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final recurringTransfersProvider =
    NotifierProvider<RecurringTransfersNotifier, RecurringTransfersState>(
  RecurringTransfersNotifier.new,
);

// Detail provider for a single transfer
class RecurringTransferDetailState {
  final bool isLoading;
  final String? error;
  final RecurringTransfer? transfer;
  final List<ExecutionHistory> history;
  final List<DateTime> nextDates;

  const RecurringTransferDetailState({
    this.isLoading = false,
    this.error,
    this.transfer,
    this.history = const [],
    this.nextDates = const [],
  });

  RecurringTransferDetailState copyWith({
    bool? isLoading,
    String? error,
    RecurringTransfer? transfer,
    List<ExecutionHistory>? history,
    List<DateTime>? nextDates,
  }) {
    return RecurringTransferDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      transfer: transfer ?? this.transfer,
      history: history ?? this.history,
      nextDates: nextDates ?? this.nextDates,
    );
  }
}

// Detail provider using FutureProvider.family
final recurringTransferDetailProvider =
    FutureProvider.autoDispose.family<RecurringTransferDetailState, String>(
  (ref, transferId) async {
    final service = ref.read(recurringTransfersServiceProvider);

    try {
      final transfer = await service.getRecurringTransfer(transferId);
      final history = await service.getExecutionHistory(transferId);
      final nextDates = await service.getNextExecutionDates(transferId);

      return RecurringTransferDetailState(
        isLoading: false,
        transfer: transfer,
        history: history,
        nextDates: nextDates,
      );
    } catch (e) {
      return RecurringTransferDetailState(
        isLoading: false,
        error: e.toString(),
      );
    }
  },
);
