import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/transfer.dart';

/// Run 350: Scheduled transfers provider
class ScheduledTransfer {
  final String id;
  final String recipientId;
  final String recipientName;
  final double amount;
  final String currency;
  final DateTime scheduledDate;
  final String? note;
  final ScheduledTransferStatus status;

  const ScheduledTransfer({
    required this.id,
    required this.recipientId,
    required this.recipientName,
    required this.amount,
    this.currency = 'USDC',
    required this.scheduledDate,
    this.note,
    this.status = ScheduledTransferStatus.pending,
  });

  bool get isPast => scheduledDate.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }
}

enum ScheduledTransferStatus { pending, processing, completed, cancelled, failed }

class ScheduledTransfersState {
  final List<ScheduledTransfer> transfers;
  final bool isLoading;
  final String? error;

  const ScheduledTransfersState({
    this.transfers = const [],
    this.isLoading = false,
    this.error,
  });

  List<ScheduledTransfer> get upcoming =>
      transfers.where((t) => !t.isPast && t.status == ScheduledTransferStatus.pending).toList()
        ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

  List<ScheduledTransfer> get past =>
      transfers.where((t) => t.isPast || t.status != ScheduledTransferStatus.pending).toList()
        ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

  ScheduledTransfersState copyWith({
    List<ScheduledTransfer>? transfers,
    bool? isLoading,
    String? error,
  }) => ScheduledTransfersState(
    transfers: transfers ?? this.transfers,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class ScheduledTransfersNotifier extends StateNotifier<ScheduledTransfersState> {
  ScheduledTransfersNotifier() : super(const ScheduledTransfersState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      state = state.copyWith(isLoading: false, transfers: []);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> schedule(ScheduledTransfer transfer) async {
    state = state.copyWith(transfers: [...state.transfers, transfer]);
  }

  Future<void> cancel(String id) async {
    final updated = state.transfers.map((t) {
      if (t.id == id) {
        return ScheduledTransfer(
          id: t.id,
          recipientId: t.recipientId,
          recipientName: t.recipientName,
          amount: t.amount,
          currency: t.currency,
          scheduledDate: t.scheduledDate,
          note: t.note,
          status: ScheduledTransferStatus.cancelled,
        );
      }
      return t;
    }).toList();
    state = state.copyWith(transfers: updated);
  }
}

final scheduledTransfersProvider =
    StateNotifierProvider<ScheduledTransfersNotifier, ScheduledTransfersState>((ref) {
  final notifier = ScheduledTransfersNotifier();
  notifier.load();
  return notifier;
});
