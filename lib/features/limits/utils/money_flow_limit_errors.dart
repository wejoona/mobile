import 'package:usdc_wallet/features/limits/models/transaction_limits.dart';

class MoneyFlowLimitException implements Exception {
  const MoneyFlowLimitException(this.message);

  final String message;

  @override
  String toString() => message;
}

String moneyFlowLimitErrorFor(
  String limitHit,
  TransactionLimits limits,
  TransactionLimitOperation operation,
) {
  final action = switch (operation) {
    TransactionLimitOperation.send => 'sending money',
    TransactionLimitOperation.deposit => 'depositing money',
    TransactionLimitOperation.withdraw => 'withdrawing money',
  };
  final unit = switch (operation) {
    TransactionLimitOperation.send => 'transfer',
    TransactionLimitOperation.deposit => 'deposit',
    TransactionLimitOperation.withdraw => 'withdrawal',
  };
  final operationLimit = operation == TransactionLimitOperation.withdraw
      ? limits.withdrawalLimit
      : limits.singleTransactionLimit;

  return switch (limitHit) {
    'manual_review_required' =>
      (limits.permissions.blockReason?.isNotEmpty ?? false)
          ? limits.permissions.blockReason!
          : 'Manual review required before $action',
    'kyc_required' =>
      (limits.permissions.blockReason?.isNotEmpty ?? false)
          ? limits.permissions.blockReason!
          : 'Verification required before $action',
    'single_transaction' =>
      'Maximum $unit: ${_formatLimit(operationLimit, limits.currency)}',
    'daily' =>
      'Daily remaining: ${_formatLimit(limits.dailyRemainingFor(operation), limits.currency)}',
    'monthly' =>
      'Monthly remaining: ${_formatLimit(limits.monthlyRemaining, limits.currency)}',
    _ => 'Amount is above your current limits',
  };
}

String _formatLimit(double amount, String currency) {
  final normalizedCurrency = currency.toUpperCase();
  final decimals = normalizedCurrency == 'XOF' ? 0 : 2;
  return '${amount.toStringAsFixed(decimals)} $normalizedCurrency';
}
