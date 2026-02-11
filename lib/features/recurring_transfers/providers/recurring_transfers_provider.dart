import 'dart:async';
import 'package:usdc_wallet/features/recurring_transfers/models/transfer_frequency.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/recurring_transfer.dart';
import 'package:usdc_wallet/features/kyc/models/missing_states.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/execution_history.dart';
import 'package:usdc_wallet/services/service_providers.dart';

/// Recurring transfers list provider — wired to RecurringTransfersService.
final recurringTransfersProvider = FutureProvider<List<RecurringTransfer>>((ref) async {
  final service = ref.watch(recurringTransfersServiceProvider);
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 2), () => link.close());

  return await service.getRecurringTransfers();
});

/// Active recurring transfers only.
final activeRecurringTransfersProvider = Provider<List<RecurringTransfer>>((ref) {
  final transfers = ref.watch(recurringTransfersProvider).value ?? [];
  return transfers.where((t) => t.isActive).toList();
});

/// Total monthly recurring amount.
final monthlyRecurringAmountProvider = Provider<double>((ref) {
  final transfers = ref.watch(activeRecurringTransfersProvider);
  return transfers.fold(0.0, (sum, t) {
    switch (t.frequency) {
      case TransferFrequency.daily: return sum + t.amount * 30;
      case TransferFrequency.weekly: return sum + t.amount * 4;
      case TransferFrequency.biweekly: return sum + t.amount * 2;
      case TransferFrequency.monthly: return sum + t.amount;
      case TransferFrequency.quarterly: return sum + t.amount / 3;
    }
  });
});

/// Recurring transfer actions delegate.
final recurringTransferActionsProvider = Provider((ref) => ref.watch(recurringTransfersServiceProvider));

/// Single recurring transfer detail provider.
final recurringTransferDetailProvider = FutureProvider.family<RecurringTransferDetailState, String>((ref, id) async {
  final service = ref.watch(recurringTransfersServiceProvider);
  try {
    final transfer = await service.getRecurringTransfer(id);
    final history = await service.getExecutionHistory(id);
    return RecurringTransferDetailState(transfer: transfer, history: history);
  } catch (e) {
    return RecurringTransferDetailState(error: e.toString());
  }
});
