import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/services/storage/hive_models.dart';
import 'package:usdc_wallet/services/storage/local_cache_service.dart';
import 'package:usdc_wallet/services/storage/pending_ops_processor.dart';
import 'package:usdc_wallet/services/connectivity/connectivity_provider.dart';
import 'package:usdc_wallet/state/app_state.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/state/transaction_state_machine.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Stale data thresholds
class StaleThresholds {
  static const wallet = Duration(minutes: 5);
  static const transactions = Duration(minutes: 15);
  static const userProfile = Duration(minutes: 30);
}

/// SyncService: bridges local cache ↔ Riverpod state ↔ server.
/// Server always wins on conflict.
class SyncService {
  final Ref _ref;
  final _log = AppLogger('SyncService');

  SyncService(this._ref);

  LocalCacheService get _cache => _ref.read(localCacheServiceProvider);

  /// On app start: load cached data into state, then trigger server sync.
  Future<void> onAppStart() async {
    if (!_cache.isInitialized) return;

    _log.debug('Loading cached data into state...');

    // Load cached wallet
    _loadCachedWallet();

    // Load cached transactions
    _loadCachedTransactions();

    // Load cached user profile
    _loadCachedUserProfile();
  }

  /// Called when connectivity is restored
  Future<void> onConnectivityRestored() async {
    if (!_cache.isInitialized) return;

    _log.debug('Connectivity restored — syncing...');

    // Process pending operations first
    final processor = _ref.read(pendingOpsProcessorProvider);
    await processor.processAll();

    // Refresh stale data
    if (_cache.isStale('wallet', StaleThresholds.wallet)) {
      try {
        await _ref.read(walletStateMachineProvider.notifier).refresh();
      } catch (e) {
        _log.error('Failed to refresh wallet on reconnect', e);
      }
    }

    if (_cache.isStale('transactions', StaleThresholds.transactions)) {
      try {
        await _ref.read(transactionStateMachineProvider.notifier).refresh();
      } catch (e) {
        _log.error('Failed to refresh transactions on reconnect', e);
      }
    }
  }

  // ── Cache from API responses ──

  /// Cache wallet state after successful API fetch
  void cacheWalletFromState(WalletState state) {
    if (!_cache.isInitialized) return;
    if (state.walletId.isEmpty) return;

    _cache.cacheWalletState(
      walletId: state.walletId,
      address: state.walletAddress,
      usdcBalance: state.usdcBalance,
      usdBalance: state.usdBalance,
      pendingBalance: state.pendingBalance,
      blockchain: state.blockchain,
    );
  }

  /// Cache transactions after successful API fetch
  void cacheTransactionsFromList(List<Transaction> transactions) {
    if (!_cache.isInitialized) return;

    final now = DateTime.now();
    final cached = transactions.map((tx) => CachedTransaction(
      id: tx.id,
      walletId: tx.walletId,
      type: tx.type.name,
      amount: tx.amount,
      currency: tx.currency,
      status: tx.status.name,
      recipientPhone: tx.recipientPhone,
      recipientAddress: tx.recipientAddress,
      description: tx.description,
      externalReference: tx.externalReference,
      failureReason: tx.failureReason,
      fee: tx.fee,
      createdAt: tx.createdAt,
      completedAt: tx.completedAt,
      cachedAt: now,
      recipientWalletId: tx.recipientWalletId,
    )).toList();

    _cache.cacheTransactions(cached);
  }

  /// Cache user profile after login/refresh
  void cacheUserFromState(UserState state) {
    if (!_cache.isInitialized) return;
    if (state.userId == null) return;

    _cache.cacheUserProfile(
      userId: state.userId!,
      phone: state.phone,
      firstName: state.firstName,
      lastName: state.lastName,
      email: state.email,
      emailVerified: state.emailVerified,
      avatarUrl: state.avatarUrl,
      countryCode: state.countryCode,
      kycStatus: state.kycStatus.name,
    );
  }

  // ── Load cached data into Riverpod state ──

  void _loadCachedWallet() {
    final cached = _cache.getCachedWallet();
    if (cached == null) return;

    // Only load if current state is initial (not yet fetched from server)
    final current = _ref.read(walletStateMachineProvider);
    if (current.status != WalletStatus.initial) return;

    _log.debug('Restoring wallet from cache (${cached.cachedAt})');
    // We don't directly set state on the notifier — instead we note the cache
    // is available. The state machines will use getCachedWallet() on error.
  }

  void _loadCachedTransactions() {
    final cached = _cache.getCachedTransactions();
    if (cached.isEmpty) return;

    final current = _ref.read(transactionStateMachineProvider);
    if (current.status != TransactionListStatus.initial) return;

    _log.debug('Cached transactions available (${cached.length} items)');
  }

  void _loadCachedUserProfile() {
    final cached = _cache.getCachedUserProfile();
    if (cached == null) return;
    _log.debug('Cached user profile available: ${cached.firstName} ${cached.lastName}');
  }

  /// Public accessor for cached user profile (used by UserStateMachine fallback)
  CachedUserProfile? getCachedUserProfile() {
    return _cache.getCachedUserProfile();
  }

  /// Convert cached transactions back to domain Transaction entities
  List<Transaction> cachedTransactionsToDomain() {
    final cached = _cache.getCachedTransactions();
    return cached.map((ct) => Transaction(
      id: ct.id,
      walletId: ct.walletId,
      type: TransactionType.values.firstWhere(
        (e) => e.name == ct.type,
        orElse: () => TransactionType.deposit,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == ct.status,
        orElse: () => TransactionStatus.pending,
      ),
      amount: ct.amount,
      currency: ct.currency,
      fee: ct.fee,
      description: ct.description,
      externalReference: ct.externalReference,
      failureReason: ct.failureReason,
      recipientPhone: ct.recipientPhone,
      recipientAddress: ct.recipientAddress,
      recipientWalletId: ct.recipientWalletId,
      createdAt: ct.createdAt,
      completedAt: ct.completedAt,
    )).toList();
  }

  /// Clear all caches (on logout)
  Future<void> clearOnLogout() async {
    await _cache.clearAll();
  }
}

final localSyncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});
