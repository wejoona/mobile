import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/recurring_transfer.dart';
import '../../../services/api/api_client.dart';

/// Recurring transfers list provider.
final recurringTransfersProvider =
    FutureProvider<List<RecurringTransfer>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();

  Timer(const Duration(minutes: 2), () => link.close());

  final response = await dio.get('/recurring-transfers');
  final data = response.data as Map<String, dynamic>;
  final items = data['data'] as List? ?? [];
  return items
      .map((e) => RecurringTransfer.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Active recurring transfers only.
final activeRecurringTransfersProvider =
    Provider<List<RecurringTransfer>>((ref) {
  final transfers =
      ref.watch(recurringTransfersProvider).valueOrNull ?? [];
  return transfers.where((t) => t.isActive).toList();
});

/// Total monthly recurring amount.
final monthlyRecurringAmountProvider = Provider<double>((ref) {
  final transfers = ref.watch(activeRecurringTransfersProvider);
  return transfers.fold(0.0, (sum, t) {
    switch (t.frequency) {
      case RecurringFrequency.daily:
        return sum + t.amount * 30;
      case RecurringFrequency.weekly:
        return sum + t.amount * 4;
      case RecurringFrequency.biweekly:
        return sum + t.amount * 2;
      case RecurringFrequency.monthly:
        return sum + t.amount;
      case RecurringFrequency.quarterly:
        return sum + t.amount / 3;
    }
  });
});

/// Recurring transfer actions.
class RecurringTransferActions {
  final Dio _dio;

  RecurringTransferActions(this._dio);

  Future<RecurringTransfer> create({
    required String recipientPhone,
    required double amount,
    required RecurringFrequency frequency,
    String? note,
    int? maxExecutions,
  }) async {
    final response = await _dio.post('/recurring-transfers', data: {
      'recipientPhone': recipientPhone,
      'amount': amount,
      'frequency': frequency.name,
      if (note != null) 'note': note,
      if (maxExecutions != null) 'maxExecutions': maxExecutions,
    });
    return RecurringTransfer.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<void> pause(String id) async {
    await _dio.patch('/recurring-transfers/$id/pause');
  }

  Future<void> resume(String id) async {
    await _dio.patch('/recurring-transfers/$id/resume');
  }

  Future<void> cancel(String id) async {
    await _dio.delete('/recurring-transfers/$id');
  }
}

final recurringTransferActionsProvider =
    Provider<RecurringTransferActions>((ref) {
  return RecurringTransferActions(ref.watch(dioProvider));
});
