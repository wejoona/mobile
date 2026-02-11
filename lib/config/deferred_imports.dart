/// SIZE OPTIMIZATION: Deferred loading configuration
///
/// This file configures deferred (lazy) loading for rarely-used features.
/// Features are only loaded when first accessed, reducing initial app size.
///
/// Usage:
/// ```dart
/// import 'config/deferred_imports.dart' as deferred;
///
/// // Later, when needed:
/// await deferred.loadInsights();
/// Navigator.push(context, deferred.InsightsView());
/// ```

library deferred_imports;

// RARELY USED FEATURES - Load on demand

/// Analytics & Insights (fl_chart dependency - 212KB)
import 'package:usdc_wallet/features/insights/views/insights_view.dart' deferred as insights;

/// PDF Receipts (pdf dependency - 156KB)
import 'package:usdc_wallet/features/receipts/views/receipt_view.dart' deferred as receipts;

/// Liveness Detection (camera + ML kit - heavy)
import 'package:usdc_wallet/features/liveness/views/liveness_check_view.dart' deferred as liveness;

/// Payment Links (low usage)
import 'package:usdc_wallet/features/payment_links/views/payment_links_list_view.dart' deferred as payment_links;

/// Bulk Payments (business feature)
import 'package:usdc_wallet/features/bulk_payments/views/bulk_payments_view.dart' deferred as bulk_payments;

/// Expenses Tracking (fl_chart dependency)
import 'package:usdc_wallet/features/expenses/views/expenses_view.dart' deferred as expenses;

// LOADING HELPERS

Future<void> loadInsights() => insights.loadLibrary();
Future<void> loadReceipts() => receipts.loadLibrary();
Future<void> loadLiveness() => liveness.loadLibrary();
Future<void> loadPaymentLinks() => payment_links.loadLibrary();
Future<void> loadBulkPayments() => bulk_payments.loadLibrary();
Future<void> loadExpenses() => expenses.loadLibrary();

// WIDGET ACCESSORS

/// Insights view (requires loadInsights() first)
dynamic get insightsView => insights.InsightsView;

/// Receipt view (requires loadReceipts() first)
dynamic get receiptView => receipts.ReceiptView;

/// Liveness check (requires loadLiveness() first)
dynamic get livenessCheckView => liveness.LivenessCheckView;

/// Payment links list (requires loadPaymentLinks() first)
dynamic get paymentLinksListView => payment_links.PaymentLinksListView;

/// Bulk payments (requires loadBulkPayments() first)
dynamic get bulkPaymentsView => bulk_payments.BulkPaymentsView;

/// Expenses view (requires loadExpenses() first)
dynamic get expensesView => expenses.ExpensesView;
