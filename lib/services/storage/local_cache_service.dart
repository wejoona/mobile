import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:usdc_wallet/services/storage/hive_models.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Local cache service using Hive for offline persistence.
/// Server is ALWAYS source of truth — this is convenience only.
class LocalCacheService {
  static const String _walletBoxName = 'walletCache';
  static const String _transactionsBoxName = 'transactionsCache';
  static const String _userProfileBoxName = 'userProfileCache';
  static const String _pendingOpsBoxName = 'pendingOps';
  static const String _syncMetaBoxName = 'syncMeta';

  static const String _walletKey = 'current_wallet';
  static const String _transactionsKey = 'transactions_list';
  static const String _userProfileKey = 'current_profile';

  final _log = AppLogger('LocalCacheService');

  Box<CachedWallet>? _walletBox;
  Box<List>? _transactionsBox;
  Box<CachedUserProfile>? _userProfileBox;
  Box<PendingOperation>? _pendingOpsBox;
  Box<SyncMeta>? _syncMetaBox;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Initialize Hive and open all boxes.
  /// Gracefully handles errors — app works even if Hive fails.
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      await Hive.initFlutter();

      // Register adapters (safe to call multiple times — Hive ignores dupes)
      _registerAdapters();

      // Open boxes
      _walletBox = await Hive.openBox<CachedWallet>(_walletBoxName);
      _transactionsBox = await Hive.openBox<List>(_transactionsBoxName);
      _userProfileBox = await Hive.openBox<CachedUserProfile>(_userProfileBoxName);
      _pendingOpsBox = await Hive.openBox<PendingOperation>(_pendingOpsBoxName);
      _syncMetaBox = await Hive.openBox<SyncMeta>(_syncMetaBoxName);

      _initialized = true;
      _log.debug('Hive initialized successfully');
      return true;
    } catch (e, st) {
      _log.error('Hive initialization failed', e, st);
      // Try to clean up corrupted boxes
      try {
        await Hive.deleteFromDisk();
        _log.debug('Deleted corrupted Hive data, will retry next launch');
      } catch (_) {}
      return false;
    }
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CachedWalletAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CachedTransactionAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(CachedUserProfileAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(PendingOperationAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(SyncMetaAdapter());
  }

  // ── Wallet Cache ──

  Future<void> cacheWalletState({
    required String walletId,
    String? address,
    required double usdcBalance,
    required double usdBalance,
    required double pendingBalance,
    required String blockchain,
  }) async {
    if (!_initialized || _walletBox == null) return;
    try {
      final cached = CachedWallet(
        walletId: walletId,
        address: address,
        usdcBalance: usdcBalance,
        usdBalance: usdBalance,
        pendingBalance: pendingBalance,
        blockchain: blockchain,
        cachedAt: DateTime.now(),
      );
      await _walletBox!.put(_walletKey, cached);
      await _updateSyncMeta('wallet');
    } catch (e) {
      _log.error('Failed to cache wallet state', e);
    }
  }

  CachedWallet? getCachedWallet() {
    if (!_initialized || _walletBox == null) return null;
    try {
      return _walletBox!.get(_walletKey);
    } catch (e) {
      _log.error('Failed to read cached wallet', e);
      return null;
    }
  }

  // ── Transactions Cache ──

  Future<void> cacheTransactions(List<CachedTransaction> transactions) async {
    if (!_initialized || _transactionsBox == null) return;
    try {
      await _transactionsBox!.put(_transactionsKey, transactions);
      await _updateSyncMeta('transactions');
    } catch (e) {
      _log.error('Failed to cache transactions', e);
    }
  }

  List<CachedTransaction> getCachedTransactions() {
    if (!_initialized || _transactionsBox == null) return [];
    try {
      final raw = _transactionsBox!.get(_transactionsKey);
      if (raw == null) return [];
      return raw.cast<CachedTransaction>();
    } catch (e) {
      _log.error('Failed to read cached transactions', e);
      return [];
    }
  }

  // ── User Profile Cache ──

  Future<void> cacheUserProfile({
    required String userId,
    String? phone,
    String? firstName,
    String? lastName,
    String? email,
    bool emailVerified = false,
    String? avatarUrl,
    required String countryCode,
    required String kycStatus,
  }) async {
    if (!_initialized || _userProfileBox == null) return;
    try {
      final cached = CachedUserProfile(
        userId: userId,
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        email: email,
        emailVerified: emailVerified,
        avatarUrl: avatarUrl,
        countryCode: countryCode,
        kycStatus: kycStatus,
        cachedAt: DateTime.now(),
      );
      await _userProfileBox!.put(_userProfileKey, cached);
      await _updateSyncMeta('userProfile');
    } catch (e) {
      _log.error('Failed to cache user profile', e);
    }
  }

  CachedUserProfile? getCachedUserProfile() {
    if (!_initialized || _userProfileBox == null) return null;
    try {
      return _userProfileBox!.get(_userProfileKey);
    } catch (e) {
      _log.error('Failed to read cached user profile', e);
      return null;
    }
  }

  // ── Pending Operations Queue ──

  Future<void> queuePendingOp(PendingOperation op) async {
    if (!_initialized || _pendingOpsBox == null) return;
    try {
      // Dedup by ID
      if (_pendingOpsBox!.containsKey(op.id)) {
        _log.debug('Pending op ${op.id} already exists, skipping');
        return;
      }
      await _pendingOpsBox!.put(op.id, op);
    } catch (e) {
      _log.error('Failed to queue pending op', e);
    }
  }

  List<PendingOperation> getPendingOps() {
    if (!_initialized || _pendingOpsBox == null) return [];
    try {
      return _pendingOpsBox!.values.toList();
    } catch (e) {
      _log.error('Failed to read pending ops', e);
      return [];
    }
  }

  List<PendingOperation> getProcessableOps() {
    return getPendingOps()
        .where((op) => op.status == 'queued' || op.status == 'failed' && op.retryCount < 3)
        .toList();
  }

  Future<void> updatePendingOp(PendingOperation op) async {
    if (!_initialized || _pendingOpsBox == null) return;
    try {
      await _pendingOpsBox!.put(op.id, op);
    } catch (e) {
      _log.error('Failed to update pending op', e);
    }
  }

  Future<void> removePendingOp(String id) async {
    if (!_initialized || _pendingOpsBox == null) return;
    try {
      await _pendingOpsBox!.delete(id);
    } catch (e) {
      _log.error('Failed to remove pending op', e);
    }
  }

  int get pendingOpsCount {
    if (!_initialized || _pendingOpsBox == null) return 0;
    return _pendingOpsBox!.length;
  }

  // ── Sync Meta ──

  Future<void> _updateSyncMeta(String entityType) async {
    if (!_initialized || _syncMetaBox == null) return;
    try {
      final meta = SyncMeta(
        entityType: entityType,
        lastSyncAt: DateTime.now(),
      );
      await _syncMetaBox!.put(entityType, meta);
    } catch (e) {
      _log.error('Failed to update sync meta', e);
    }
  }

  SyncMeta? getSyncMeta(String entityType) {
    if (!_initialized || _syncMetaBox == null) return null;
    try {
      return _syncMetaBox!.get(entityType);
    } catch (e) {
      return null;
    }
  }

  DateTime? getLastSyncAt(String entityType) {
    return getSyncMeta(entityType)?.lastSyncAt;
  }

  /// Check if cached data for an entity type is stale
  bool isStale(String entityType, Duration maxAge) {
    final meta = getSyncMeta(entityType);
    if (meta == null) return true;
    return DateTime.now().difference(meta.lastSyncAt) > maxAge;
  }

  // ── Cleanup ──

  /// Clear all cached data (e.g., on logout)
  Future<void> clearAll() async {
    if (!_initialized) return;
    try {
      await _walletBox?.clear();
      await _transactionsBox?.clear();
      await _userProfileBox?.clear();
      await _pendingOpsBox?.clear();
      await _syncMetaBox?.clear();
      _log.debug('All caches cleared');
    } catch (e) {
      _log.error('Failed to clear caches', e);
    }
  }

  /// Close all boxes
  Future<void> dispose() async {
    try {
      await _walletBox?.close();
      await _transactionsBox?.close();
      await _userProfileBox?.close();
      await _pendingOpsBox?.close();
      await _syncMetaBox?.close();
    } catch (e) {
      _log.error('Failed to close Hive boxes', e);
    }
  }
}

/// Singleton provider for LocalCacheService
final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  return LocalCacheService();
});
