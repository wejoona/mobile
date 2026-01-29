import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Feature flag keys from backend
class FeatureFlagKeys {
  // Backend-controlled flags
  static const String twoFactorAuth = 'two_factor_auth';
  static const String externalTransfers = 'external_transfers';
  static const String billPayments = 'bill_payments';
  static const String savingsPots = 'savings_pots';
  static const String biometricAuth = 'biometric_auth';
  static const String mobileMoneyWithdrawals = 'mobile_money_withdrawals';

  // Phase 1 - MVP (always enabled)
  static const String deposit = 'deposit';
  static const String send = 'send';
  static const String receive = 'receive';
  static const String transactions = 'transactions';
  static const String kyc = 'kyc';

  // Phase 2
  static const String withdraw = 'withdraw';
  static const String offRamp = 'off_ramp';

  // Phase 3
  static const String airtime = 'airtime';
  static const String bills = 'bills';

  // Phase 4
  static const String savings = 'savings';
  static const String virtualCards = 'virtual_cards';
  static const String splitBills = 'split_bills';
  static const String recurringTransfers = 'recurring_transfers';
  static const String budget = 'budget';

  // Phase 5
  static const String agentNetwork = 'agent_network';
  static const String ussd = 'ussd';

  // Other features
  static const String referrals = 'referrals';
  static const String referralProgram = 'referral_program';
  static const String analytics = 'analytics';
  static const String currencyConverter = 'currency_converter';
  static const String requestMoney = 'request_money';
  static const String scheduledTransfers = 'scheduled_transfers';
  static const String savedRecipients = 'saved_recipients';
  static const String merchantQr = 'merchant_qr';
  static const String paymentLinks = 'payment_links';
}

/// Feature Flags Service
///
/// Fetches and caches feature flags from backend API.
/// Flags are evaluated server-side based on:
/// - User ID
/// - Country
/// - App version
/// - Platform
/// - Rollout percentage
/// - Time windows
class FeatureFlagsService {
  final Dio _dio;
  final SharedPreferences _prefs;

  static const _cacheKey = 'feature_flags_cache';
  static const _lastFetchKey = 'feature_flags_last_fetch';
  static const _refreshInterval = Duration(minutes: 15);

  Map<String, bool> _flags = {};
  DateTime? _lastFetch;

  FeatureFlagsService(this._dio, this._prefs);

  /// Initialize service and load cached flags
  Future<void> init() async {
    await _loadFromCache();
    await fetchFlags();
  }

  /// Fetch flags from backend API
  Future<Map<String, bool>> fetchFlags() async {
    try {
      // Check if we need to refresh
      if (_lastFetch != null &&
          DateTime.now().difference(_lastFetch!) < _refreshInterval) {
        debugPrint('[FeatureFlags] Cache still fresh, skipping fetch');
        return _flags;
      }

      debugPrint('[FeatureFlags] Fetching from API...');
      final response = await _dio.get('/feature-flags/me');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final flags = data['flags'] as Map<String, dynamic>? ?? {};

        // Convert to Map<String, bool>
        _flags = flags.map((key, value) => MapEntry(key, value as bool));

        // Cache the flags
        await _saveToCache();
        _lastFetch = DateTime.now();

        debugPrint('[FeatureFlags] Fetched ${_flags.length} flags');
        return _flags;
      }

      debugPrint('[FeatureFlags] Failed to fetch: ${response.statusCode}');
      return _flags;
    } catch (e) {
      debugPrint('[FeatureFlags] Error fetching flags: $e');
      // Return cached flags on error
      return _flags;
    }
  }

  /// Check if a feature is enabled
  bool isEnabled(String key) {
    return _flags[key] ?? false;
  }

  /// Get all flags
  Map<String, bool> getAll() {
    return Map.unmodifiable(_flags);
  }

  /// Force refresh flags
  Future<void> refresh() async {
    _lastFetch = null;
    await fetchFlags();
  }

  /// Load flags from cache
  Future<void> _loadFromCache() async {
    try {
      final cached = _prefs.getString(_cacheKey);
      if (cached != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        _flags = json.map((key, value) => MapEntry(key, value as bool));

        final lastFetchMs = _prefs.getInt(_lastFetchKey);
        if (lastFetchMs != null) {
          _lastFetch = DateTime.fromMillisecondsSinceEpoch(lastFetchMs);
        }

        debugPrint('[FeatureFlags] Loaded ${_flags.length} flags from cache');
      }
    } catch (e) {
      debugPrint('[FeatureFlags] Failed to load cache: $e');
    }
  }

  /// Save flags to cache
  Future<void> _saveToCache() async {
    try {
      await _prefs.setString(_cacheKey, jsonEncode(_flags));
      if (_lastFetch != null) {
        await _prefs.setInt(_lastFetchKey, _lastFetch!.millisecondsSinceEpoch);
      }
      debugPrint('[FeatureFlags] Saved to cache');
    } catch (e) {
      debugPrint('[FeatureFlags] Failed to save cache: $e');
    }
  }

  /// Clear cache (for testing)
  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
    await _prefs.remove(_lastFetchKey);
    _flags = {};
    _lastFetch = null;
  }
}
