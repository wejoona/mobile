import 'package:dio/dio.dart';
import 'package:usdc_wallet/features/limits/models/transaction_limits.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

class MoneyFlowLimitException implements Exception {
  const MoneyFlowLimitException(
    this.message, {
    this.operation,
    this.reviewRequired = false,
    this.canonicalEndpoint,
  });

  final String message;
  final TransactionLimitOperation? operation;
  final bool reviewRequired;
  final String? canonicalEndpoint;

  @override
  String toString() => message;
}

MoneyFlowLimitException? moneyFlowLimitExceptionFromError(
  Object error, {
  required TransactionLimitOperation operation,
}) {
  final apiError = error is ApiException
      ? error
      : error is DioException
      ? ApiException.fromDioError(error)
      : null;
  final payload = _mapOf(apiError?.data);
  if (payload == null) {
    return null;
  }

  final reason = _stringOf(payload, const ['reason']);
  if (reason != 'money_flow_permission_blocked') {
    return null;
  }

  final permissions = MoneyFlowPermissions.fromJson(
    _mapOf(payload['permissions']),
  );
  final backendOperation = _operationFromBackendValue(
    _stringOf(payload, const ['operation']),
  );
  final blockReason = _stringOf(payload, const ['blockReason', 'block_reason']);
  final message = (blockReason?.isNotEmpty ?? false)
      ? blockReason!
      : apiError?.message ?? 'Money movement is paused for this account.';

  return MoneyFlowLimitException(
    message,
    operation: backendOperation ?? operation,
    reviewRequired:
        _boolOf(payload, const ['reviewRequired', 'review_required']) ??
        permissions.reviewRequired,
    canonicalEndpoint: _stringOf(payload, const [
      'canonicalEndpoint',
      'canonical_endpoint',
    ]),
  );
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
    TransactionLimitOperation.receive => 'receiving money',
  };
  final unit = switch (operation) {
    TransactionLimitOperation.send => 'transfer',
    TransactionLimitOperation.deposit => 'deposit',
    TransactionLimitOperation.withdraw => 'withdrawal',
    TransactionLimitOperation.receive => 'receive request',
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

Map<String, dynamic>? _mapOf(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

String? _stringOf(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) {
      return value.toString().trim();
    }
  }
  return null;
}

bool? _boolOf(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') {
        return true;
      }
      if (normalized == 'false') {
        return false;
      }
    }
  }
  return null;
}

TransactionLimitOperation? _operationFromBackendValue(String? value) {
  return switch (value) {
    'deposit' => TransactionLimitOperation.deposit,
    'withdrawal' => TransactionLimitOperation.withdraw,
    'transfer_internal' ||
    'transfer_external' ||
    'send' => TransactionLimitOperation.send,
    'receive' => TransactionLimitOperation.receive,
    _ => null,
  };
}
