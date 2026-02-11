import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/transfer_frequency.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/create_recurring_transfer_request.dart';

enum EndCondition {
  never,
  afterOccurrences,
  untilDate,
}

class CreateRecurringTransferFormState {
  final String recipientPhone;
  final String recipientName;
  final double? amount;
  final String currency;
  final TransferFrequency frequency;
  final DateTime startDate;
  final EndCondition endCondition;
  final DateTime? endDate;
  final int? occurrences;
  final String? note;
  final int? dayOfWeek;
  final int? dayOfMonth;

  CreateRecurringTransferFormState({
    this.recipientPhone = '',
    this.recipientName = '',
    this.amount,
    this.currency = 'XOF',
    this.frequency = TransferFrequency.weekly,
    DateTime? startDate,
    this.endCondition = EndCondition.never,
    this.endDate,
    this.occurrences,
    this.note,
    this.dayOfWeek = 1, // Default to Monday
    this.dayOfMonth = 1, // Default to 1st
  }) : startDate = startDate ?? DateTime.now();

  CreateRecurringTransferFormState copyWith({
    String? recipientPhone,
    String? recipientName,
    double? amount,
    String? currency,
    TransferFrequency? frequency,
    DateTime? startDate,
    EndCondition? endCondition,
    DateTime? endDate,
    int? occurrences,
    String? note,
    int? dayOfWeek,
    int? dayOfMonth,
  }) {
    return CreateRecurringTransferFormState(
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientName: recipientName ?? this.recipientName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endCondition: endCondition ?? this.endCondition,
      endDate: endDate ?? this.endDate,
      occurrences: occurrences ?? this.occurrences,
      note: note ?? this.note,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    );
  }

  bool get isValid {
    if (recipientPhone.isEmpty || recipientName.isEmpty) return false;
    if (amount == null || amount! <= 0) return false;

    switch (endCondition) {
      case EndCondition.never:
        return true;
      case EndCondition.afterOccurrences:
        return occurrences != null && occurrences! > 0;
      case EndCondition.untilDate:
        return endDate != null && endDate!.isAfter(startDate);
    }
  }

  CreateRecurringTransferRequest toRequest() {
    return CreateRecurringTransferRequest(
      recipientPhone: recipientPhone,
      recipientName: recipientName,
      amount: amount!,
      currency: currency,
      frequency: frequency,
      startDate: startDate,
      endDate: endCondition == EndCondition.untilDate ? endDate : null,
      occurrences: endCondition == EndCondition.afterOccurrences ? occurrences : null,
      note: note,
      dayOfWeek: (frequency == TransferFrequency.weekly ||
              frequency == TransferFrequency.biweekly)
          ? dayOfWeek
          : null,
      dayOfMonth: frequency == TransferFrequency.monthly ? dayOfMonth : null,
    );
  }
}

class CreateRecurringTransferNotifier
    extends Notifier<CreateRecurringTransferFormState> {
  @override
  CreateRecurringTransferFormState build() =>
      CreateRecurringTransferFormState();

  void setRecipient(String phone, String name) {
    state = state.copyWith(recipientPhone: phone, recipientName: name);
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void setFrequency(TransferFrequency frequency) {
    state = state.copyWith(frequency: frequency);
  }

  void setStartDate(DateTime date) {
    state = state.copyWith(startDate: date);
  }

  void setEndCondition(EndCondition condition) {
    state = state.copyWith(endCondition: condition);
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
  }

  void setOccurrences(int? count) {
    state = state.copyWith(occurrences: count);
  }

  void setNote(String? note) {
    state = state.copyWith(note: note);
  }

  void setDayOfWeek(int day) {
    state = state.copyWith(dayOfWeek: day);
  }

  void setDayOfMonth(int day) {
    state = state.copyWith(dayOfMonth: day);
  }

  void reset() {
    state = CreateRecurringTransferFormState();
  }

  void loadFromExisting(String phone, String name, {double? amount}) {
    state = state.copyWith(
      recipientPhone: phone,
      recipientName: name,
      amount: amount,
    );
  }
}

final createRecurringTransferProvider = NotifierProvider<
    CreateRecurringTransferNotifier,
    CreateRecurringTransferFormState>(
  CreateRecurringTransferNotifier.new,
);
