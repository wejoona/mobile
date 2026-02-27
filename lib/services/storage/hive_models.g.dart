// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedWalletAdapter extends TypeAdapter<CachedWallet> {
  @override
  final int typeId = 0;

  @override
  CachedWallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedWallet(
      walletId: fields[0] as String,
      address: fields[1] as String?,
      usdcBalance: fields[2] as double,
      usdBalance: fields[3] as double,
      pendingBalance: fields[4] as double,
      blockchain: fields[5] as String,
      cachedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CachedWallet obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.walletId)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.usdcBalance)
      ..writeByte(3)
      ..write(obj.usdBalance)
      ..writeByte(4)
      ..write(obj.pendingBalance)
      ..writeByte(5)
      ..write(obj.blockchain)
      ..writeByte(6)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedWalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CachedTransactionAdapter extends TypeAdapter<CachedTransaction> {
  @override
  final int typeId = 1;

  @override
  CachedTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedTransaction(
      id: fields[0] as String,
      walletId: fields[1] as String,
      type: fields[2] as String,
      amount: fields[3] as double,
      currency: fields[4] as String,
      status: fields[5] as String,
      recipientPhone: fields[6] as String?,
      recipientAddress: fields[7] as String?,
      description: fields[8] as String?,
      externalReference: fields[9] as String?,
      failureReason: fields[10] as String?,
      fee: fields[11] as double?,
      createdAt: fields[12] as DateTime,
      completedAt: fields[13] as DateTime?,
      cachedAt: fields[14] as DateTime,
      recipientWalletId: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CachedTransaction obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.walletId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.recipientPhone)
      ..writeByte(7)
      ..write(obj.recipientAddress)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.externalReference)
      ..writeByte(10)
      ..write(obj.failureReason)
      ..writeByte(11)
      ..write(obj.fee)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.completedAt)
      ..writeByte(14)
      ..write(obj.cachedAt)
      ..writeByte(15)
      ..write(obj.recipientWalletId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CachedUserProfileAdapter extends TypeAdapter<CachedUserProfile> {
  @override
  final int typeId = 2;

  @override
  CachedUserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedUserProfile(
      userId: fields[0] as String,
      phone: fields[1] as String?,
      firstName: fields[2] as String?,
      lastName: fields[3] as String?,
      email: fields[4] as String?,
      emailVerified: fields[5] as bool,
      avatarUrl: fields[6] as String?,
      countryCode: fields[7] as String,
      kycStatus: fields[8] as String,
      cachedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CachedUserProfile obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.emailVerified)
      ..writeByte(6)
      ..write(obj.avatarUrl)
      ..writeByte(7)
      ..write(obj.countryCode)
      ..writeByte(8)
      ..write(obj.kycStatus)
      ..writeByte(9)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedUserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PendingOperationAdapter extends TypeAdapter<PendingOperation> {
  @override
  final int typeId = 3;

  @override
  PendingOperation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingOperation(
      id: fields[0] as String,
      type: fields[1] as String,
      toAddress: fields[2] as String?,
      amount: fields[3] as double,
      currency: fields[4] as String,
      memo: fields[5] as String?,
      status: fields[6] as String,
      createdAt: fields[7] as DateTime,
      retryCount: fields[8] as int,
      lastError: fields[9] as String?,
      recipientPhone: fields[10] as String?,
      pinToken: fields[11] as String?,
      idempotencyKey: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PendingOperation obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.toAddress)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.memo)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.retryCount)
      ..writeByte(9)
      ..write(obj.lastError)
      ..writeByte(10)
      ..write(obj.recipientPhone)
      ..writeByte(11)
      ..write(obj.pinToken)
      ..writeByte(12)
      ..write(obj.idempotencyKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncMetaAdapter extends TypeAdapter<SyncMeta> {
  @override
  final int typeId = 4;

  @override
  SyncMeta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncMeta(
      entityType: fields[0] as String,
      lastSyncAt: fields[1] as DateTime,
      etag: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncMeta obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.entityType)
      ..writeByte(1)
      ..write(obj.lastSyncAt)
      ..writeByte(2)
      ..write(obj.etag);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncMetaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
