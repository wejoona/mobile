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
}
