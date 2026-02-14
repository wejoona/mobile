import 'package:usdc_wallet/features/recurring_transfers/models/recurring_transfer.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/execution_history.dart';

class RecurringTransferDetailState {
  final bool isLoading;
  final String? error;
  final RecurringTransfer? transfer;
  final List<DateTime> nextDates;
  final List<ExecutionHistory> history;

  const RecurringTransferDetailState({this.isLoading = false, this.error, this.transfer, this.nextDates = const [], this.history = const []});
  RecurringTransferDetailState copyWith({bool? isLoading, String? error, RecurringTransfer? transfer, List<DateTime>? nextDates, List<ExecutionHistory>? history}) =>
    RecurringTransferDetailState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, transfer: transfer ?? this.transfer, nextDates: nextDates ?? this.nextDates, history: history ?? this.history);
}
