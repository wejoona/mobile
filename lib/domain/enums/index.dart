export 'package:usdc_wallet/domain/enums/account_type.dart';

/// Transaction status enum - mirrors backend
enum TransactionStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

/// Transaction type enum - mirrors backend
enum TransactionType {
  deposit,
  withdrawal,
  transferInternal,
  transferExternal,
}

/// KYC status enum - mirrors backend
enum KycStatus {
  /// No KYC started
  none,
  /// KYC pending (documents not yet submitted)
  pending,
  /// Documents submitted, awaiting upload
  documentsPending,
  /// All documents submitted, under review
  submitted,
  /// KYC approved / verified
  verified,
  /// KYC rejected
  rejected,
  /// Additional info needed
  additionalInfoNeeded,
}

/// User role enum - mirrors backend
enum UserRole {
  user,
  admin,
  superAdmin,
}

/// User status enum - mirrors backend
enum UserStatus {
  active,
  suspended,
  deactivated,
}

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
enum AlertSeverity {
  info,
  warning,
  critical,
}

/// Alert visual variant
enum AlertVariant {
  info,
  warning,
  error,
  success,
}
