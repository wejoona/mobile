export 'package:usdc_wallet/domain/enums/account_type.dart';
export 'package:usdc_wallet/features/kyc/models/kyc_status.dart';

/// Transaction status enum - mirrors backend
enum TransactionStatus { pending, processing, completed, failed, cancelled }

/// Transaction type enum - mirrors backend
enum TransactionType {
  deposit,
  withdrawal,
  transferInternal,
  transferExternal,
  billPayment,
  unknown,
}

TransactionType parseTransactionType(String? value) {
  final normalized = value?.trim().toLowerCase().replaceAll('-', '_');

  switch (normalized) {
    case 'deposit':
    case 'mobile_money_deposit':
      return TransactionType.deposit;
    case 'withdrawal':
    case 'mobile_money_withdrawal':
      return TransactionType.withdrawal;
    case 'transfer_internal':
    case 'transferinternal':
    case 'internal_transfer_sent':
    case 'internal_transfer_received':
    case 'transfer_in':
    case 'transfer_out':
    case 'internal':
      return TransactionType.transferInternal;
    case 'transfer_external':
    case 'transferexternal':
    case 'external_transfer':
    case 'external':
      return TransactionType.transferExternal;
    case 'bill_payment':
    case 'billpayment':
    case 'bill_pay':
      return TransactionType.billPayment;
    default:
      return TransactionType.unknown;
  }
}

extension TransactionTypeContract on TransactionType {
  String get wireName {
    switch (this) {
      case TransactionType.deposit:
        return 'deposit';
      case TransactionType.withdrawal:
        return 'withdrawal';
      case TransactionType.transferInternal:
        return 'transfer_internal';
      case TransactionType.transferExternal:
        return 'transfer_external';
      case TransactionType.billPayment:
        return 'bill_payment';
      case TransactionType.unknown:
        return 'unknown';
    }
  }

  String get displayLabel {
    switch (this) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.transferInternal:
        return 'Transfer';
      case TransactionType.transferExternal:
        return 'External transfer';
      case TransactionType.billPayment:
        return 'Bill payment';
      case TransactionType.unknown:
        return 'Transaction';
    }
  }

  bool get isFilterable => this != TransactionType.unknown;
}

// KycStatus re-export moved to top of file

/// User role enum - mirrors backend
enum UserRole { user, admin, superAdmin }

/// User status enum - mirrors backend
enum UserStatus { active, suspended, deactivated }

/// Notification type enum - mirrors backend
enum NotificationType {
  transactionComplete,
  transactionFailed,
  securityAlert,
  promotion,
  lowBalance,
  general,
  // Aliases used by UI widgets
  transfer,
  deposit,
  withdrawal,
  security,
  kyc,
  // Enhanced notification types
  newDeviceLogin,
  largeTransaction,
  withdrawalPending,
  addressWhitelisted,
  priceAlert,
  weeklySpendingSummary,
  // Transaction monitoring alert types
  unusualLocation,
  rapidTransactions,
  newRecipient,
  suspiciousPattern,
  failedAttempts,
  accountChange,
  balanceThreshold,
  externalWithdrawal,
  timeAnomaly,
  roundAmount,
  cumulativeDaily,
  velocityLimit,
}

/// Alert severity enum - mirrors backend
enum AlertSeverity { info, warning, critical }

/// Alert visual variant
enum AlertVariant { info, warning, error, success }
