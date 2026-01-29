import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/notifications/notifications_service.dart';

/// Notification Preferences Notifier
class NotificationPreferencesNotifier
    extends AsyncNotifier<NotificationPreferences> {
  @override
  Future<NotificationPreferences> build() async {
    final service = ref.watch(notificationPreferencesServiceProvider);
    return await service.getPreferences();
  }

  /// Update transaction alerts preference
  Future<void> updateTransactionAlerts(bool value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(notificationPreferencesServiceProvider);
      return await service.updatePreference(transactionAlerts: value);
    });
  }

  /// Update security alerts preference
  Future<void> updateSecurityAlerts(bool value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(notificationPreferencesServiceProvider);
      return await service.updatePreference(securityAlerts: value);
    });
  }

  /// Update promotions preference
  Future<void> updatePromotions(bool value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(notificationPreferencesServiceProvider);
      return await service.updatePreference(promotions: value);
    });
  }

  /// Update price alerts preference
  Future<void> updatePriceAlerts(bool value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(notificationPreferencesServiceProvider);
      return await service.updatePreference(priceAlerts: value);
    });
  }

  /// Update weekly summary preference
  Future<void> updateWeeklySummary(bool value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(notificationPreferencesServiceProvider);
      return await service.updatePreference(weeklySummary: value);
    });
  }

  /// Update large transaction threshold
  Future<void> updateLargeTransactionThreshold(double value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(notificationPreferencesServiceProvider);
      return await service.updatePreference(largeTransactionThreshold: value);
    });
  }

  /// Update low balance threshold
  Future<void> updateLowBalanceThreshold(double value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(notificationPreferencesServiceProvider);
      return await service.updatePreference(lowBalanceThreshold: value);
    });
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(notificationPreferencesServiceProvider);
      final defaults = const NotificationPreferences();
      await service.savePreferences(defaults);
      return defaults;
    });
  }
}

/// Notification Preferences Notifier Provider
final notificationPreferencesNotifierProvider = AsyncNotifierProvider<
    NotificationPreferencesNotifier,
    NotificationPreferences>(NotificationPreferencesNotifier.new);
