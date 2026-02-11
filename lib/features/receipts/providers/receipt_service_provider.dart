import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/receipts/services/receipt_service.dart';

/// Provider for receipt service
final receiptServiceProvider = Provider<ReceiptService>((ref) {
  return ReceiptService();
});
