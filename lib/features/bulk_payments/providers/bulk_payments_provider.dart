import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bulk_payment.dart';
import '../models/bulk_batch.dart';
import '../../../services/bulk_payments/bulk_payments_service.dart';
import '../../../services/api/api_client.dart';

// Service provider
final bulkPaymentsServiceProvider = Provider<BulkPaymentsService>((ref) {
  final dio = ref.watch(dioProvider);
  return BulkPaymentsService(dio);
});

// State classes
class BulkPaymentsState {
  final bool isLoading;
  final String? error;
  final List<BulkBatch> batches;
  final BulkBatch? currentBatch;
  final bool isProcessing;

  const BulkPaymentsState({
    this.isLoading = false,
    this.error,
    this.batches = const [],
    this.currentBatch,
    this.isProcessing = false,
  });

  BulkPaymentsState copyWith({
    bool? isLoading,
    String? error,
    List<BulkBatch>? batches,
    BulkBatch? currentBatch,
    bool? isProcessing,
  }) {
    return BulkPaymentsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      batches: batches ?? this.batches,
      currentBatch: currentBatch ?? this.currentBatch,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  List<BulkBatch> get activeBatches => batches
      .where((b) =>
          b.status == BatchStatus.pending || b.status == BatchStatus.processing)
      .toList();

  List<BulkBatch> get completedBatches =>
      batches.where((b) => b.status == BatchStatus.completed).toList();

  List<BulkBatch> get failedBatches =>
      batches.where((b) => b.status == BatchStatus.failed).toList();
}

// Main provider
class BulkPaymentsNotifier extends Notifier<BulkPaymentsState> {
  @override
  BulkPaymentsState build() => const BulkPaymentsState();

  BulkPaymentsService get _service => ref.read(bulkPaymentsServiceProvider);

  Future<void> loadBatches() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final batches = await _service.getBatches();
      state = state.copyWith(isLoading: false, batches: batches);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<BulkBatch?> parseCsvFile(String csvContent, String fileName) async {
    try {
      final lines = csvContent.split('\n');
      if (lines.isEmpty) {
        state = state.copyWith(error: 'CSV file is empty');
        return null;
      }

      // Skip header row
      final dataRows = lines.skip(1).where((line) => line.trim().isNotEmpty);

      final payments = <BulkPayment>[];
      int rowIndex = 1;

      for (final line in dataRows) {
        final row = line.split(',');
        final payment = BulkPayment.fromCsvRow(row, rowIndex);
        payments.add(payment);
        rowIndex++;
      }

      if (payments.isEmpty) {
        state = state.copyWith(error: 'No valid payments found in CSV');
        return null;
      }

      final batch = BulkBatch.fromPayments(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: fileName,
        payments: payments,
      );

      state = state.copyWith(currentBatch: batch);
      return batch;
    } catch (e) {
      state = state.copyWith(error: 'Failed to parse CSV: ${e.toString()}');
      return null;
    }
  }

  void clearCurrentBatch() {
    state = state.copyWith(currentBatch: null);
  }

  Future<bool> submitBatch(BulkBatch batch) async {
    state = state.copyWith(isProcessing: true, error: null);
    try {
      final submittedBatch = await _service.submitBatch(batch);
      state = state.copyWith(
        isProcessing: false,
        batches: [...state.batches, submittedBatch],
        currentBatch: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
      return false;
    }
  }

  Future<BulkBatch?> getBatchStatus(String batchId) async {
    try {
      final batch = await _service.getBatchStatus(batchId);
      // Update batch in list
      final updatedBatches = state.batches.map((b) {
        return b.id == batchId ? batch : b;
      }).toList();
      state = state.copyWith(batches: updatedBatches);
      return batch;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<String?> downloadFailedPayments(String batchId) async {
    try {
      final csvContent = await _service.downloadFailedPayments(batchId);
      return csvContent;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

final bulkPaymentsProvider =
    NotifierProvider<BulkPaymentsNotifier, BulkPaymentsState>(
  BulkPaymentsNotifier.new,
);

// Detail provider for a single batch
final batchDetailProvider =
    FutureProvider.autoDispose.family<BulkBatch?, String>(
  (ref, batchId) async {
    final service = ref.read(bulkPaymentsServiceProvider);
    try {
      return await service.getBatchStatus(batchId);
    } catch (e) {
      return null;
    }
  },
);
