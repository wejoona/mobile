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
  none,
  pending,
  verified,
  rejected,
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
