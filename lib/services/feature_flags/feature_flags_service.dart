import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Feature flag keys matching the strategic document
class FeatureFlagKeys {
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
  static const String analytics = 'analytics';
  static const String currencyConverter = 'currency_converter';
  static const String requestMoney = 'request_money';
  static const String scheduledTransfers = 'scheduled_transfers';
  static const String savedRecipients = 'saved_recipients';
}

/// Feature flags state
class FeatureFlags {
  // Phase 1 - MVP Core (always on)
  final bool canDeposit;
  final bool canSend;
  final bool canReceive;
  final bool canViewTransactions;
  final bool canCompleteKyc;

  // Phase 2 - Off-ramp
  final bool canWithdraw;

  // Phase 3 - Services
  final bool canBuyAirtime;
  final bool canPayBills;

  // Phase 4 - Financial Tools
  final bool canSetSavingsGoals;
  final bool canUseVirtualCards;
  final bool canSplitBills;
  final bool canSetRecurringTransfers;
  final bool canUseBudget;

  // Phase 5 - Advanced
  final bool hasAgentNetwork;
  final bool hasUssd;

  // Other
  final bool canUseReferrals;
  final bool canViewAnalytics;
  final bool canUseCurrencyConverter;
  final bool canRequestMoney;
  final bool canScheduleTransfers;
  final bool canUseSavedRecipients;

  const FeatureFlags({
    // MVP - always true
    this.canDeposit = true,
    this.canSend = true,
    this.canReceive = true,
    this.canViewTransactions = true,
    this.canCompleteKyc = true,
    // Phase 2+ - off by default
    this.canWithdraw = false,
    this.canBuyAirtime = false,
    this.canPayBills = false,
    this.canSetSavingsGoals = false,
    this.canUseVirtualCards = false,
    this.canSplitBills = false,
    this.canSetRecurringTransfers = false,
    this.canUseBudget = false,
    this.hasAgentNetwork = false,
    this.hasUssd = false,
    // Nice-to-have - can toggle
    this.canUseReferrals = true,
    this.canViewAnalytics = false,
    this.canUseCurrencyConverter = false,
    this.canRequestMoney = true,
    this.canScheduleTransfers = false,
    this.canUseSavedRecipients = true,
  });

  /// MVP-only flags (minimal feature set)
  factory FeatureFlags.mvp() {
    return const FeatureFlags(
      // Core MVP
      canDeposit: true,
      canSend: true,
      canReceive: true,
      canViewTransactions: true,
      canCompleteKyc: true,
      // Everything else off
      canWithdraw: false,
      canBuyAirtime: false,
      canPayBills: false,
      canSetSavingsGoals: false,
      canUseVirtualCards: false,
      canSplitBills: false,
      canSetRecurringTransfers: false,
      canUseBudget: false,
      hasAgentNetwork: false,
      hasUssd: false,
      canUseReferrals: true,
      canViewAnalytics: false,
      canUseCurrencyConverter: false,
      canRequestMoney: true,
      canScheduleTransfers: false,
      canUseSavedRecipients: true,
    );
  }

  /// All features enabled (for development/testing)
  factory FeatureFlags.all() {
    return const FeatureFlags(
      canDeposit: true,
      canSend: true,
      canReceive: true,
      canViewTransactions: true,
      canCompleteKyc: true,
      canWithdraw: true,
      canBuyAirtime: true,
      canPayBills: true,
      canSetSavingsGoals: true,
      canUseVirtualCards: true,
      canSplitBills: true,
      canSetRecurringTransfers: true,
      canUseBudget: true,
      hasAgentNetwork: true,
      hasUssd: true,
      canUseReferrals: true,
      canViewAnalytics: true,
      canUseCurrencyConverter: true,
      canRequestMoney: true,
      canScheduleTransfers: true,
      canUseSavedRecipients: true,
    );
  }

  factory FeatureFlags.fromJson(Map<String, dynamic> json) {
    return FeatureFlags(
      canDeposit: json[FeatureFlagKeys.deposit] as bool? ?? true,
      canSend: json[FeatureFlagKeys.send] as bool? ?? true,
      canReceive: json[FeatureFlagKeys.receive] as bool? ?? true,
      canViewTransactions: json[FeatureFlagKeys.transactions] as bool? ?? true,
      canCompleteKyc: json[FeatureFlagKeys.kyc] as bool? ?? true,
      canWithdraw: json[FeatureFlagKeys.withdraw] as bool? ?? false,
      canBuyAirtime: json[FeatureFlagKeys.airtime] as bool? ?? false,
      canPayBills: json[FeatureFlagKeys.bills] as bool? ?? false,
      canSetSavingsGoals: json[FeatureFlagKeys.savings] as bool? ?? false,
      canUseVirtualCards: json[FeatureFlagKeys.virtualCards] as bool? ?? false,
      canSplitBills: json[FeatureFlagKeys.splitBills] as bool? ?? false,
      canSetRecurringTransfers: json[FeatureFlagKeys.recurringTransfers] as bool? ?? false,
      canUseBudget: json[FeatureFlagKeys.budget] as bool? ?? false,
      hasAgentNetwork: json[FeatureFlagKeys.agentNetwork] as bool? ?? false,
      hasUssd: json[FeatureFlagKeys.ussd] as bool? ?? false,
      canUseReferrals: json[FeatureFlagKeys.referrals] as bool? ?? true,
      canViewAnalytics: json[FeatureFlagKeys.analytics] as bool? ?? false,
      canUseCurrencyConverter: json[FeatureFlagKeys.currencyConverter] as bool? ?? false,
      canRequestMoney: json[FeatureFlagKeys.requestMoney] as bool? ?? true,
      canScheduleTransfers: json[FeatureFlagKeys.scheduledTransfers] as bool? ?? false,
      canUseSavedRecipients: json[FeatureFlagKeys.savedRecipients] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FeatureFlagKeys.deposit: canDeposit,
      FeatureFlagKeys.send: canSend,
      FeatureFlagKeys.receive: canReceive,
      FeatureFlagKeys.transactions: canViewTransactions,
      FeatureFlagKeys.kyc: canCompleteKyc,
      FeatureFlagKeys.withdraw: canWithdraw,
      FeatureFlagKeys.airtime: canBuyAirtime,
      FeatureFlagKeys.bills: canPayBills,
      FeatureFlagKeys.savings: canSetSavingsGoals,
      FeatureFlagKeys.virtualCards: canUseVirtualCards,
      FeatureFlagKeys.splitBills: canSplitBills,
      FeatureFlagKeys.recurringTransfers: canSetRecurringTransfers,
      FeatureFlagKeys.budget: canUseBudget,
      FeatureFlagKeys.agentNetwork: hasAgentNetwork,
      FeatureFlagKeys.ussd: hasUssd,
      FeatureFlagKeys.referrals: canUseReferrals,
      FeatureFlagKeys.analytics: canViewAnalytics,
      FeatureFlagKeys.currencyConverter: canUseCurrencyConverter,
      FeatureFlagKeys.requestMoney: canRequestMoney,
      FeatureFlagKeys.scheduledTransfers: canScheduleTransfers,
      FeatureFlagKeys.savedRecipients: canUseSavedRecipients,
    };
  }

  FeatureFlags copyWith({
    bool? canDeposit,
    bool? canSend,
    bool? canReceive,
    bool? canViewTransactions,
    bool? canCompleteKyc,
    bool? canWithdraw,
    bool? canBuyAirtime,
    bool? canPayBills,
    bool? canSetSavingsGoals,
    bool? canUseVirtualCards,
    bool? canSplitBills,
    bool? canSetRecurringTransfers,
    bool? canUseBudget,
    bool? hasAgentNetwork,
    bool? hasUssd,
    bool? canUseReferrals,
    bool? canViewAnalytics,
    bool? canUseCurrencyConverter,
    bool? canRequestMoney,
    bool? canScheduleTransfers,
    bool? canUseSavedRecipients,
  }) {
    return FeatureFlags(
      canDeposit: canDeposit ?? this.canDeposit,
      canSend: canSend ?? this.canSend,
      canReceive: canReceive ?? this.canReceive,
      canViewTransactions: canViewTransactions ?? this.canViewTransactions,
      canCompleteKyc: canCompleteKyc ?? this.canCompleteKyc,
      canWithdraw: canWithdraw ?? this.canWithdraw,
      canBuyAirtime: canBuyAirtime ?? this.canBuyAirtime,
      canPayBills: canPayBills ?? this.canPayBills,
      canSetSavingsGoals: canSetSavingsGoals ?? this.canSetSavingsGoals,
      canUseVirtualCards: canUseVirtualCards ?? this.canUseVirtualCards,
      canSplitBills: canSplitBills ?? this.canSplitBills,
      canSetRecurringTransfers: canSetRecurringTransfers ?? this.canSetRecurringTransfers,
      canUseBudget: canUseBudget ?? this.canUseBudget,
      hasAgentNetwork: hasAgentNetwork ?? this.hasAgentNetwork,
      hasUssd: hasUssd ?? this.hasUssd,
      canUseReferrals: canUseReferrals ?? this.canUseReferrals,
      canViewAnalytics: canViewAnalytics ?? this.canViewAnalytics,
      canUseCurrencyConverter: canUseCurrencyConverter ?? this.canUseCurrencyConverter,
      canRequestMoney: canRequestMoney ?? this.canRequestMoney,
      canScheduleTransfers: canScheduleTransfers ?? this.canScheduleTransfers,
      canUseSavedRecipients: canUseSavedRecipients ?? this.canUseSavedRecipients,
    );
  }
}

/// Feature flags service - manages feature flag state
class FeatureFlagsService extends Notifier<FeatureFlags> {
  static const _cacheKey = 'feature_flags_cache';
  static const _lastFetchKey = 'feature_flags_last_fetch';
  static const _cacheDuration = Duration(hours: 1);

  @override
  FeatureFlags build() {
    // Load cached flags on init, then fetch fresh ones
    _loadCachedFlags();
    _fetchRemoteFlags();

    // Default to MVP flags in debug, all features in development
    return kDebugMode ? FeatureFlags.all() : FeatureFlags.mvp();
  }

  /// Load flags from local cache
  Future<void> _loadCachedFlags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);

      if (cached != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        state = FeatureFlags.fromJson(json);
        debugPrint('Feature flags loaded from cache');
      }
    } catch (e) {
      debugPrint('Failed to load cached feature flags: $e');
    }
  }

  /// Fetch flags from remote config (backend or Firebase)
  Future<void> _fetchRemoteFlags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetch = prefs.getInt(_lastFetchKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Skip if recently fetched
      if (now - lastFetch < _cacheDuration.inMilliseconds) {
        debugPrint('Feature flags cache still fresh, skipping fetch');
        return;
      }

      // TODO: Fetch from backend API or Firebase Remote Config
      // final response = await dio.get('/config/feature-flags');
      // final remoteFlags = FeatureFlags.fromJson(response.data);

      // For now, use environment-based defaults
      final remoteFlags = kDebugMode ? FeatureFlags.all() : FeatureFlags.mvp();

      // Update state
      state = remoteFlags;

      // Cache the flags
      await prefs.setString(_cacheKey, jsonEncode(remoteFlags.toJson()));
      await prefs.setInt(_lastFetchKey, now);

      debugPrint('Feature flags fetched and cached');
    } catch (e) {
      debugPrint('Failed to fetch remote feature flags: $e');
      // Keep using cached/default flags
    }
  }

  /// Force refresh flags from remote
  Future<void> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastFetchKey); // Clear cache time
    await _fetchRemoteFlags();
  }

  /// Check if a specific feature is enabled
  bool isEnabled(String featureKey) {
    final json = state.toJson();
    return json[featureKey] as bool? ?? false;
  }

  /// Override a flag locally (for testing)
  void setFlag(String key, bool value) {
    final json = state.toJson();
    json[key] = value;
    state = FeatureFlags.fromJson(json);
  }

  /// Reset to MVP defaults
  void resetToMvp() {
    state = FeatureFlags.mvp();
  }

  /// Enable all features (for development)
  void enableAll() {
    state = FeatureFlags.all();
  }
}

/// Feature flags provider
final featureFlagsProvider = NotifierProvider<FeatureFlagsService, FeatureFlags>(
  FeatureFlagsService.new,
);

/// Convenience providers for individual flags
final canDepositProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canDeposit;
});

final canSendProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canSend;
});

final canReceiveProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canReceive;
});

final canWithdrawProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canWithdraw;
});

final canBuyAirtimeProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canBuyAirtime;
});

final canPayBillsProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canPayBills;
});

final canSetSavingsGoalsProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canSetSavingsGoals;
});

final canUseVirtualCardsProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canUseVirtualCards;
});

final canSplitBillsProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canSplitBills;
});

final canUseBudgetProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canUseBudget;
});

final canUseReferralsProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canUseReferrals;
});

final canViewAnalyticsProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canViewAnalytics;
});

final canUseCurrencyConverterProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canUseCurrencyConverter;
});

final canRequestMoneyProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canRequestMoney;
});

final canScheduleTransfersProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canScheduleTransfers;
});

final canUseSavedRecipientsProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider).canUseSavedRecipients;
});
