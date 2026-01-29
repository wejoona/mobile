import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction.dart';
import '../../features/beneficiaries/models/beneficiary.dart';

/// Offline Cache Service
/// Caches essential data for offline access using SharedPreferences
class OfflineCacheService {
  static const String _keyBalance = 'offline_cache_balance';
  static const String _keyTransactions = 'offline_cache_transactions';
  static const String _keyBeneficiaries = 'offline_cache_beneficiaries';
  static const String _keyWalletId = 'offline_cache_wallet_id';
  static const String _keyLastSync = 'offline_cache_last_sync';
  static const int _maxTransactions = 50;

  final SharedPreferences _prefs;

  OfflineCacheService(this._prefs);

  // ============================================================
  // Balance Caching
  // ============================================================

  /// Cache wallet balance
  Future<void> cacheBalance(double balance) async {
    await _prefs.setDouble(_keyBalance, balance);
    await _updateLastSync();
  }

  /// Get cached balance
  double? getCachedBalance() {
    return _prefs.getDouble(_keyBalance);
  }

  // ============================================================
  // Transaction Caching
  // ============================================================

  /// Cache transactions (last 50)
  Future<void> cacheTransactions(List<Transaction> transactions) async {
    final limited = transactions.take(_maxTransactions).toList();
    final jsonList = limited.map((tx) => tx.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs.setString(_keyTransactions, jsonString);
    await _updateLastSync();
  }

  /// Get cached transactions
  List<Transaction>? getCachedTransactions() {
    final jsonString = _prefs.getString(_keyTransactions);
    if (jsonString == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // Beneficiary Caching
  // ============================================================

  /// Cache beneficiaries list
  Future<void> cacheBeneficiaries(List<Beneficiary> beneficiaries) async {
    final jsonList = beneficiaries.map((b) => b.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs.setString(_keyBeneficiaries, jsonString);
    await _updateLastSync();
  }

  /// Get cached beneficiaries
  List<Beneficiary>? getCachedBeneficiaries() {
    final jsonString = _prefs.getString(_keyBeneficiaries);
    if (jsonString == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Beneficiary.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // Wallet ID Caching
  // ============================================================

  /// Cache wallet ID
  Future<void> cacheWalletId(String walletId) async {
    await _prefs.setString(_keyWalletId, walletId);
  }

  /// Get cached wallet ID
  String? getCachedWalletId() {
    return _prefs.getString(_keyWalletId);
  }

  // ============================================================
  // Sync Metadata
  // ============================================================

  /// Update last sync timestamp
  Future<void> _updateLastSync() async {
    await _prefs.setString(_keyLastSync, DateTime.now().toIso8601String());
  }

  /// Get last sync timestamp
  DateTime? getLastSync() {
    final isoString = _prefs.getString(_keyLastSync);
    if (isoString == null) return null;
    return DateTime.tryParse(isoString);
  }

  // ============================================================
  // Clear Cache
  // ============================================================

  /// Clear all cached data
  Future<void> clearCache() async {
    await _prefs.remove(_keyBalance);
    await _prefs.remove(_keyTransactions);
    await _prefs.remove(_keyBeneficiaries);
    await _prefs.remove(_keyWalletId);
    await _prefs.remove(_keyLastSync);
  }

  /// Check if cache exists
  bool hasCachedData() {
    return _prefs.containsKey(_keyBalance) ||
        _prefs.containsKey(_keyTransactions);
  }
}

/// Offline Cache Service Provider
final offlineCacheServiceProvider = Provider<OfflineCacheService>((ref) {
  throw UnimplementedError('Must be overridden with SharedPreferences');
});

/// Provider for OfflineCacheService with SharedPreferences
final offlineCacheServiceFutureProvider =
    FutureProvider<OfflineCacheService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return OfflineCacheService(prefs);
});
