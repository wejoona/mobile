class RecurringTransferDetailState {
  final bool isLoading;
  final String? error;
  final dynamic transfer;
  final List<DateTime> nextDates;
  final List<dynamic> history;

  const RecurringTransferDetailState({this.isLoading = false, this.error, this.transfer, this.nextDates = const [], this.history = const []});
  RecurringTransferDetailState copyWith({bool? isLoading, String? error, dynamic transfer, List<DateTime>? nextDates, List<dynamic>? history}) =>
    RecurringTransferDetailState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, transfer: transfer ?? this.transfer, nextDates: nextDates ?? this.nextDates, history: history ?? this.history);
}
