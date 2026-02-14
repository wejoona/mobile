import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/domain/entities/bulk_payment.dart';
import 'package:usdc_wallet/features/bulk_payments/models/bulk_batch.dart';
import 'package:usdc_wallet/services/service_providers.dart';

/// Bulk payments list provider — wired to BulkPaymentsService.
final bulkPaymentsProvider = FutureProvider<List<BulkPayment>>((ref) async {
  final service = ref.watch(bulkPaymentsServiceProvider);
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 2), () => link.close());

  final data = await service.getBulkPayments();
  return data.map((e) => BulkPayment.fromJson(e as Map<String, dynamic>)).toList();
});

/// Bulk payment actions delegate.
final bulkPaymentActionsProvider = Provider((ref) => ref.watch(bulkPaymentsServiceProvider));

/// Batch detail provider.
final batchDetailProvider = FutureProvider.family<dynamic, String>((ref, batchId) async {
  final service = ref.watch(bulkPaymentsServiceProvider);
  return service.getBatchStatus(batchId);
});

/// Draft batch state for the preview flow.
/// Set after CSV parsing, consumed by BulkPreviewView.
final draftBatchProvider = StateProvider<BulkBatch?>((ref) => null);
