import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/recurring_transfer.dart';
import 'package:usdc_wallet/services/service_providers.dart';

/// Recurring transfers list provider — wired to RecurringTransfersService.
final recurringTransfersProvider = FutureProvider<List<RecurringTransfer>>((ref) async {
  final service = ref.watch(recurringTransfersServiceProvider);
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 2), () => link.close());

  final data = await service.getRecurringTransfers();
  final items = (data['data'] as List?) ?? [];
  return items.map((e) => RecurringTransfer.fromJson(e as Map<String, dynamic>)).toList();
});

/// Active recurring transfers only.
final activeRecurringTransfersProvider = Provider<List<RecurringTransfer>>((ref) {
  final transfers = ref.watch(recurringTransfersProvider).valueOrNull ?? [];
  return transfers.where((t) => t.isActive).toList();
});

/// Total monthly recurring amount.
final monthlyRecurringAmountProvider = Provider<double>((ref) {
  final transfers = ref.watch(activeRecurringTransfersProvider);
  return transfers.fold(0.0, (sum, t) {
    switch (t.frequency) {
      case RecurringFrequency.daily: return sum + t.amount * 30;
      case RecurringFrequency.weekly: return sum + t.amount * 4;
      case RecurringFrequency.biweekly: return sum + t.amount * 2;
      case RecurringFrequency.monthly: return sum + t.amount;
      case RecurringFrequency.quarterly: return sum + t.amount / 3;
    }
  });
});

/// Recurring transfer actions delegate.
final recurringTransferActionsProvider = Provider((ref) => ref.watch(recurringTransfersServiceProvider));
