import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/recurring_transfer.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/create_recurring_transfer_request.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/transfer_frequency.dart';
import 'package:usdc_wallet/services/service_providers.dart';
import 'package:usdc_wallet/features/recurring_transfers/providers/recurring_transfers_provider.dart';

/// Create recurring transfer flow state.
class CreateRecurringState {
  final bool isLoading;
  final String? error;
  final String? recipientPhone;
  final String? recipientName;
  final double? amount;
  final RecurringFrequency frequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? note;
  final bool isComplete;

  const CreateRecurringState({
    this.isLoading = false, this.error, this.recipientPhone, this.recipientName,
    this.amount, this.frequency = RecurringFrequency.monthly, this.startDate,
    this.endDate, this.note, this.isComplete = false,
  });

  CreateRecurringState copyWith({
    bool? isLoading, String? error, String? recipientPhone, String? recipientName,
    double? amount, RecurringFrequency? frequency, DateTime? startDate,
    DateTime? endDate, String? note, bool? isComplete,
  }) => CreateRecurringState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    recipientPhone: recipientPhone ?? this.recipientPhone,
    recipientName: recipientName ?? this.recipientName,
    amount: amount ?? this.amount,
    frequency: frequency ?? this.frequency,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    note: note ?? this.note,
    isComplete: isComplete ?? this.isComplete,
  );
}

/// Create recurring transfer notifier.
class CreateRecurringNotifier extends Notifier<CreateRecurringState> {
  @override
  CreateRecurringState build() => CreateRecurringState(startDate: DateTime.now().add(const Duration(days: 1)));

  void setRecipient(String phone, {String? name}) => state = state.copyWith(recipientPhone: phone, recipientName: name);
  void setAmount(double amount) => state = state.copyWith(amount: amount);
  void setFrequency(RecurringFrequency freq) => state = state.copyWith(frequency: freq);
  void setStartDate(DateTime date) => state = state.copyWith(startDate: date);
  void setEndDate(DateTime? date) => state = state.copyWith(endDate: date);
  void setNote(String note) => state = state.copyWith(note: note);

  Future<void> create() async {
    if (state.recipientPhone == null || state.amount == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(recurringTransfersServiceProvider);
      await service.createRecurringTransfer(
        CreateRecurringTransferRequest(
          recipientPhone: state.recipientPhone!,
          recipientName: state.recipientName ?? '',
          amount: state.amount!,
          currency: 'USDC',
          frequency: TransferFrequency.values.firstWhere((f) => f.name == state.frequency.name, orElse: () => TransferFrequency.monthly),
          startDate: state.startDate ?? DateTime.now(),
        ),
      );
      state = state.copyWith(isLoading: false, isComplete: true);
      ref.invalidate(recurringTransfersProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = CreateRecurringState(startDate: DateTime.now().add(const Duration(days: 1)));
}

final createRecurringProvider = NotifierProvider<CreateRecurringNotifier, CreateRecurringState>(CreateRecurringNotifier.new);
