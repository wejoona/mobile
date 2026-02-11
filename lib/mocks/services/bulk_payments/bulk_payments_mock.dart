import 'package:usdc_wallet/features/bulk_payments/models/bulk_batch.dart';
import 'package:usdc_wallet/features/bulk_payments/models/bulk_payment.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

class BulkPaymentsMock {
  static void register(MockInterceptor interceptor) {
    // GET /bulk-payments/batches
    interceptor.register(
      method: 'GET',
      path: r'^/bulk-payments/batches$',
      handler: (options) async {
        return MockResponse.success({
          'batches': BulkPaymentsMockState.batches
              .map((batch) => batch.toJson())
              .toList(),
        });
      },
    );

    // POST /bulk-payments/batches
    interceptor.register(
      method: 'POST',
      path: r'^/bulk-payments/batches$',
      handler: (options) async {
        final data = options.data as Map<String, dynamic>;
        final name = data['name'] as String;
        final payments = (data['payments'] as List)
            .map((p) => BulkPayment(
                  phone: p['phone'] as String,
                  amount: (p['amount'] as num).toDouble(),
                  description: p['description'] as String,
                ))
            .toList();

        final batch = BulkBatch.fromPayments(
          id: 'batch_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          payments: payments,
        ).copyWith(
          status: BatchStatus.pending,
        );

        BulkPaymentsMockState.batches.add(batch);

        // Simulate processing after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          _processBatch(batch.id);
        });

        return MockResponse.success(batch.toJson());
      },
    );

    // GET /bulk-payments/batches/:id
    interceptor.register(
      method: 'GET',
      path: r'^/bulk-payments/batches/[\w-]+$',
      handler: (options) async {
        final batchId = options.path.split('/').last;
        final batch = BulkPaymentsMockState.batches.firstWhere(
          (b) => b.id == batchId,
          orElse: () => throw Exception('Batch not found'),
        );

        return MockResponse.success(batch.toJson());
      },
    );

    // GET /bulk-payments/batches/:id/failed-report
    interceptor.register(
      method: 'GET',
      path: r'^/bulk-payments/batches/[\w-]+/failed-report$',
      handler: (options) async {
        final batchId = options.path.split('/')[3];
        final batch = BulkPaymentsMockState.batches.firstWhere(
          (b) => b.id == batchId,
          orElse: () => throw Exception('Batch not found'),
        );

        final failedPayments = batch.payments.where((p) => !p.isValid).toList();

        final csv = StringBuffer();
        csv.writeln('phone,amount,description,error');
        for (final payment in failedPayments) {
          csv.writeln(
            '${payment.phone},${payment.amount},${payment.description},${payment.error ?? ""}',
          );
        }

        return MockResponse.success({'csv': csv.toString()});
      },
    );
  }

  static void _processBatch(String batchId) {
    final batchIndex =
        BulkPaymentsMockState.batches.indexWhere((b) => b.id == batchId);
    if (batchIndex == -1) return;

    final batch = BulkPaymentsMockState.batches[batchIndex];

    // Update to processing
    BulkPaymentsMockState.batches[batchIndex] = batch.copyWith(
      status: BatchStatus.processing,
    );

    // Simulate processing
    Future.delayed(const Duration(seconds: 5), () {
      final successCount = batch.totalCount;
      final failedCount = 0;

      // Mark as completed
      final completedBatch = batch.copyWith(
        status: BatchStatus.completed,
        successCount: successCount,
        failedCount: failedCount,
        processedAt: DateTime.now(),
      );

      final index =
          BulkPaymentsMockState.batches.indexWhere((b) => b.id == batchId);
      if (index != -1) {
        BulkPaymentsMockState.batches[index] = completedBatch;
      }
    });
  }
}

class BulkPaymentsMockState {
  static final List<BulkBatch> batches = [
    BulkBatch(
      id: 'batch_1',
      name: 'January Salaries.csv',
      payments: [
        const BulkPayment(
          phone: '+2250701234567',
          amount: 500.00,
          description: 'Salary - January',
        ),
        const BulkPayment(
          phone: '+2250707654321',
          amount: 750.00,
          description: 'Salary - January',
        ),
        const BulkPayment(
          phone: '+2250708888888',
          amount: 600.00,
          description: 'Salary - January',
        ),
      ],
      status: BatchStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      processedAt: DateTime.now().subtract(const Duration(days: 7, hours: 1)),
      totalCount: 3,
      successCount: 3,
      failedCount: 0,
      totalAmount: 1850.00,
    ),
    BulkBatch(
      id: 'batch_2',
      name: 'Bonuses.csv',
      payments: [
        const BulkPayment(
          phone: '+2250701111111',
          amount: 100.00,
          description: 'Bonus - Q1',
        ),
        const BulkPayment(
          phone: '+2250702222222',
          amount: 150.00,
          description: 'Bonus - Q1',
        ),
      ],
      status: BatchStatus.processing,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      totalCount: 2,
      successCount: 1,
      failedCount: 0,
      totalAmount: 250.00,
    ),
  ];

  static void reset() {
    batches.clear();
  }
}
