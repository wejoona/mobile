import 'package:hive/hive.dart';

part 'hive_models.g.dart';

/// Cached wallet state
@HiveType(typeId: 0)
class CachedWallet extends HiveObject {
  @HiveField(0)
  final String walletId;

  @HiveField(1)
  final String? address;

  @HiveField(2)
  final double usdcBalance;

  @HiveField(3)
  final double usdBalance;

  @HiveField(4)
  final double pendingBalance;

  @HiveField(5)
  final String blockchain;

  @HiveField(6)
  final DateTime cachedAt;

  CachedWallet({
    required this.walletId,
    this.address,
    required this.usdcBalance,
    required this.usdBalance,
    required this.pendingBalance,
    required this.blockchain,
    required this.cachedAt,
  });

  bool isStale(Duration maxAge) {
    return DateTime.now().difference(cachedAt) > maxAge;
  }
}

/// Cached transaction
@HiveType(typeId: 1)
class CachedTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String walletId;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final String currency;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final String? recipientPhone;

  @HiveField(7)
  final String? recipientAddress;

  @HiveField(8)
  final String? description;

  @HiveField(9)
  final String? externalReference;

  @HiveField(10)
  final String? failureReason;

  @HiveField(11)
  final double? fee;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final DateTime? completedAt;

  @HiveField(14)
  final DateTime cachedAt;

  @HiveField(15)
  final String? recipientWalletId;

  CachedTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    this.recipientPhone,
    this.recipientAddress,
    this.description,
    this.externalReference,
    this.failureReason,
    this.fee,
    required this.createdAt,
    this.completedAt,
    required this.cachedAt,
    this.recipientWalletId,
  });

  bool isStale(Duration maxAge) {
    return DateTime.now().difference(cachedAt) > maxAge;
  }
}

/// Cached user profile
@HiveType(typeId: 2)
class CachedUserProfile extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String? phone;

  @HiveField(2)
  final String? firstName;

  @HiveField(3)
  final String? lastName;

  @HiveField(4)
  final String? email;

  @HiveField(5)
  final bool emailVerified;

  @HiveField(6)
  final String? avatarUrl;

  @HiveField(7)
  final String countryCode;

  @HiveField(8)
  final String kycStatus;

  @HiveField(9)
  final DateTime cachedAt;

  CachedUserProfile({
    required this.userId,
    this.phone,
    this.firstName,
    this.lastName,
    this.email,
    this.emailVerified = false,
    this.avatarUrl,
    required this.countryCode,
    required this.kycStatus,
    required this.cachedAt,
  });

  bool isStale(Duration maxAge) {
    return DateTime.now().difference(cachedAt) > maxAge;
  }
}

/// Pending offline operation
@HiveType(typeId: 3)
class PendingOperation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // send, payment, withdrawal

  @HiveField(2)
  final String? toAddress;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final String currency;

  @HiveField(5)
  final String? memo;

  @HiveField(6)
  String status; // queued, submitting, failed

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  int retryCount;

  @HiveField(9)
  String? lastError;

  @HiveField(10)
  final String? recipientPhone;

  @HiveField(11)
  final String? pinToken;

  @HiveField(12)
  final String? idempotencyKey;

  PendingOperation({
    required this.id,
    required this.type,
    this.toAddress,
    required this.amount,
    required this.currency,
    this.memo,
    this.status = 'queued',
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
    this.recipientPhone,
    this.pinToken,
    this.idempotencyKey,
  });
}

/// Sync metadata per entity type
@HiveType(typeId: 4)
class SyncMeta extends HiveObject {
  @HiveField(0)
  final String entityType;

  @HiveField(1)
  DateTime lastSyncAt;

  @HiveField(2)
  String? etag;

  SyncMeta({
    required this.entityType,
    required this.lastSyncAt,
    this.etag,
  });
}
