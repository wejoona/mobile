/// Alert Preferences Provider
/// Riverpod state management for user alert preferences
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../services/api/api_client.dart';
import '../models/index.dart';

/// Alert preferences state
class AlertPreferencesState {
  final AlertPreferences? preferences;
  final List<AlertTypeInfo> availableTypes;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const AlertPreferencesState({
    this.preferences,
    this.availableTypes = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  AlertPreferencesState copyWith({
    AlertPreferences? preferences,
    List<AlertTypeInfo>? availableTypes,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return AlertPreferencesState(
      preferences: preferences ?? this.preferences,
      availableTypes: availableTypes ?? this.availableTypes,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

/// Alert preferences notifier
class AlertPreferencesNotifier extends Notifier<AlertPreferencesState> {
  @override
  AlertPreferencesState build() {
    return const AlertPreferencesState();
  }

  Dio get _dio => ref.read(dioProvider);

  /// Load preferences
  Future<void> loadPreferences() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _dio.get('/alerts/preferences');
      final preferences = AlertPreferences.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        preferences: preferences,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Load available alert types
  Future<void> loadAvailableTypes() async {
    try {
      final response = await _dio.get('/alerts/preferences/alert-types');
      final types = (response.data as List)
          .map((t) => AlertTypeInfo.fromJson(t as Map<String, dynamic>))
          .toList();

      state = state.copyWith(availableTypes: types);
    } catch (e) {
      // Silently fail for types
    }
  }

  /// Update preferences
  Future<bool> updatePreferences(AlertPreferences updates) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await _dio.put('/alerts/preferences', data: updates.toJson());
      final preferences = AlertPreferences.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        preferences: preferences,
        isSaving: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Toggle email alerts
  Future<bool> toggleEmailAlerts(bool enabled) async {
    if (state.preferences == null) return false;
    return updatePreferences(state.preferences!.copyWith(emailAlerts: enabled));
  }

  /// Toggle push alerts
  Future<bool> togglePushAlerts(bool enabled) async {
    if (state.preferences == null) return false;
    return updatePreferences(state.preferences!.copyWith(pushAlerts: enabled));
  }

  /// Toggle SMS alerts
  Future<bool> toggleSmsAlerts(bool enabled) async {
    if (state.preferences == null) return false;
    return updatePreferences(state.preferences!.copyWith(smsAlerts: enabled));
  }

  /// Set large transaction threshold
  Future<bool> setLargeTransactionThreshold(double value) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await _dio.put(
        '/alerts/preferences/threshold/large-transaction',
        data: {'value': value},
      );
      final preferences = AlertPreferences.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        preferences: preferences,
        isSaving: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Set low balance threshold
  Future<bool> setBalanceLowThreshold(double value) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await _dio.put(
        '/alerts/preferences/threshold/balance-low',
        data: {'value': value},
      );
      final preferences = AlertPreferences.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        preferences: preferences,
        isSaving: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Toggle alert type
  Future<bool> toggleAlertType(AlertType type, bool enabled) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await _dio.put(
        '/alerts/preferences/alert-type',
        data: {
          'alertType': type.value,
          'enabled': enabled,
        },
      );
      final preferences = AlertPreferences.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        preferences: preferences,
        isSaving: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Toggle notification channel
  Future<bool> toggleChannel(String channel, bool enabled) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await _dio.put(
        '/alerts/preferences/channel/$channel',
        data: {'enabled': enabled},
      );
      final preferences = AlertPreferences.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        preferences: preferences,
        isSaving: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Set quiet hours
  Future<bool> setQuietHours({
    required bool enabled,
    String? startTime,
    String? endTime,
    String? timezone,
  }) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await _dio.put(
        '/alerts/preferences/quiet-hours',
        data: {
          'enabled': enabled,
          if (startTime != null) 'startTime': startTime,
          if (endTime != null) 'endTime': endTime,
          if (timezone != null) 'timezone': timezone,
        },
      );
      final preferences = AlertPreferences.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        preferences: preferences,
        isSaving: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Reset preferences to default
  Future<bool> resetToDefault() async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await _dio.post('/alerts/preferences/reset');
      final preferences = AlertPreferences.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = state.copyWith(
        preferences: preferences,
        isSaving: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      return error.response?.data?['message']?.toString() ??
          'An error occurred';
    }
    return 'An unexpected error occurred';
  }
}

/// Alert preferences provider
final alertPreferencesProvider =
    NotifierProvider<AlertPreferencesNotifier, AlertPreferencesState>(
  AlertPreferencesNotifier.new,
);

/// Is alert type enabled provider
final isAlertTypeEnabledProvider = Provider.family<bool, AlertType>((ref, type) {
  final prefs = ref.watch(alertPreferencesProvider).preferences;
  return prefs?.isAlertTypeEnabled(type) ?? false;
});
