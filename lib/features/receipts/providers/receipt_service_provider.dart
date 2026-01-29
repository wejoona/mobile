import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/receipt_service.dart';

/// Provider for receipt service
final receiptServiceProvider = Provider<ReceiptService>((ref) {
  return ReceiptService();
});
