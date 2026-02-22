import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/preferences/notification_preferences_service.dart';
import 'package:usdc_wallet/domain/entities/notification_preferences.dart';

/// State for notification preferences
class NotificationPreferencesState {
  final UserNotificationPreferences? preferences;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const NotificationPreferencesState({
    this.preferences,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  NotificationPreferencesState copyWith({
    UserNotificationPreferences? preferences,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return NotificationPreferencesState(
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }

  /// Returns true if preferences have been loaded
  bool get hasData => preferences != null;
}

/// Notifier for managing notification preferences state
class NotificationPreferencesNotifier extends Notifier<NotificationPreferencesState> {
  @override
  NotificationPreferencesState build() {
    // Start loading preferences
    _loadPreferences();
    return const NotificationPreferencesState(isLoading: true);
  }

  NotificationPreferencesApiService get _service =>
      ref.read(notificationPreferencesApiServiceProvider);

  /// Load preferences from the backend
  Future<void> _loadPreferences() async {
    try {
      final prefs = await _service.getPreferences();
      state = NotificationPreferencesState(preferences: prefs);
    } on ApiException catch (e) {
      state = NotificationPreferencesState(error: e.message);
    } catch (e) {
      state = NotificationPreferencesState(
        error: 'Failed to load preferences: $e',
      );
    }
  }

  /// Refresh preferences from the backend
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    await _loadPreferences();
  }

  /// Update all preferences at once
  Future<bool> updatePreferences(
      UserNotificationPreferences newPreferences) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final updated = await _service.updatePreferences(newPreferences);
      state = NotificationPreferencesState(preferences: updated);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to save preferences: $e',
      );
      return false;
    }
  }

  /// Update push notification master toggle
  Future<bool> setPushEnabled(bool enabled) async {
    return _updateSinglePreference(pushEnabled: enabled);
  }

  /// Update push transaction alerts
  Future<bool> setPushTransactions(bool enabled) async {
    return _updateSinglePreference(pushTransactions: enabled);
  }

  /// Update push security alerts
  Future<bool> setPushSecurity(bool enabled) async {
    return _updateSinglePreference(pushSecurity: enabled);
  }

  /// Update push marketing
  Future<bool> setPushMarketing(bool enabled) async {
    return _updateSinglePreference(pushMarketing: enabled);
  }

  /// Update email notification master toggle
  Future<bool> setEmailEnabled(bool enabled) async {
    return _updateSinglePreference(emailEnabled: enabled);
  }

  /// Update email transaction receipts
  Future<bool> setEmailTransactions(bool enabled) async {
    return _updateSinglePreference(emailTransactions: enabled);
  }

  /// Update email monthly statements
  Future<bool> setEmailMonthlyStatement(bool enabled) async {
    return _updateSinglePreference(emailMonthlyStatement: enabled);
  }

  /// Update email marketing
  Future<bool> setEmailMarketing(bool enabled) async {
    return _updateSinglePreference(emailMarketing: enabled);
  }

  /// Update SMS notification master toggle
  Future<bool> setSmsEnabled(bool enabled) async {
    return _updateSinglePreference(smsEnabled: enabled);
  }

  /// Update SMS transaction alerts
  Future<bool> setSmsTransactions(bool enabled) async {
    return _updateSinglePreference(smsTransactions: enabled);
  }

  /// Update large transaction threshold
  Future<bool> setLargeTransactionThreshold(double threshold) async {
    return _updateSinglePreference(largeTransactionThreshold: threshold);
  }

  /// Update low balance threshold
  Future<bool> setLowBalanceThreshold(double threshold) async {
    return _updateSinglePreference(lowBalanceThreshold: threshold);
  }

  /// Internal helper to update a single preference
  Future<bool> _updateSinglePreference({
    bool? pushEnabled,
    bool? pushTransactions,
    bool? pushSecurity,
    bool? pushMarketing,
    bool? emailEnabled,
    bool? emailTransactions,
    bool? emailMonthlyStatement,
    bool? emailMarketing,
    bool? smsEnabled,
    bool? smsTransactions,
    bool? smsSecurity,
    double? largeTransactionThreshold,
    double? lowBalanceThreshold,
  }) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final updated = await _service.updateSinglePreference(
        pushEnabled: pushEnabled,
        pushTransactions: pushTransactions,
        pushSecurity: pushSecurity,
        pushMarketing: pushMarketing,
        emailEnabled: emailEnabled,
        emailTransactions: emailTransactions,
        emailMonthlyStatement: emailMonthlyStatement,
        emailMarketing: emailMarketing,
        smsEnabled: smsEnabled,
        smsTransactions: smsTransactions,
        smsSecurity: smsSecurity,
        largeTransactionThreshold: largeTransactionThreshold,
        lowBalanceThreshold: lowBalanceThreshold,
      );
      state = NotificationPreferencesState(preferences: updated);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to update preference: $e',
      );
      return false;
    }
  }
}

/// Provider for notification preferences
final notificationPreferencesProvider = NotifierProvider<
    NotificationPreferencesNotifier, NotificationPreferencesState>(
  NotificationPreferencesNotifier.new,
);

/// Simple FutureProvider for read-only access to preferences with caching
/// Cache duration: 5 minutes
final notificationPreferencesFutureProvider =
    FutureProvider<UserNotificationPreferences>((ref) async {
  final service = ref.watch(notificationPreferencesApiServiceProvider);
  final link = ref.keepAlive();

  // Auto-invalidate after 5 minutes
  final timer = Timer(const Duration(minutes: 5), () {    link.close();  });
  ref.onDispose(() => timer.cancel());

  return service.getPreferences();
});
