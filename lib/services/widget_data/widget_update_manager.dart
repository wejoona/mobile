import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widget_data_service.dart';
import '../../state/wallet_state_machine.dart';
import '../../state/user_state_machine.dart';

/// Manager for updating home screen widgets
class WidgetUpdateManager {
  final WidgetDataService _dataService;
  static const MethodChannel _channel = MethodChannel('com.joonapay.usdc_wallet/widget');

  WidgetUpdateManager(this._dataService);

  /// Update widget data from current app state
  Future<void> updateFromState({
    required double balance,
    required String currency,
    String? userName,
  }) async {
    try {
      // Update shared data
      await _dataService.updateBalance(
        balance: balance,
        currency: currency,
        userName: userName,
      );

      // Notify native widgets to refresh
      await _requestWidgetUpdate();
    } catch (e) {
      // Silently fail - widget updates are non-critical
      print('Widget update failed: $e');
    }
  }

  /// Update last transaction info
  Future<void> updateLastTransaction({
    required String type,
    required double amount,
    required String currency,
    required String status,
    String? recipientName,
  }) async {
    try {
      await _dataService.updateLastTransaction(
        type: type,
        amount: amount,
        currency: currency,
        status: status,
        recipientName: recipientName,
      );

      await _requestWidgetUpdate();
    } catch (e) {
      print('Widget transaction update failed: $e');
    }
  }

  /// Clear widget data on logout
  Future<void> clearWidgetData() async {
    try {
      await _dataService.clearWidgetData();
      await _requestWidgetUpdate();
    } catch (e) {
      print('Widget clear failed: $e');
    }
  }

  /// Request native widget refresh
  Future<void> _requestWidgetUpdate() async {
    try {
      await _channel.invokeMethod('updateWidget');
    } on PlatformException catch (e) {
      print('Failed to update widget: ${e.message}');
    }
  }
}

/// Provider for widget update manager
final widgetUpdateManagerProvider = Provider<WidgetUpdateManager>((ref) {
  return WidgetUpdateManager(WidgetDataService());
});

/// Auto-update widgets when wallet state changes
class WidgetAutoUpdater extends Notifier<void> {
  @override
  void build() {
    // Watch wallet state
    ref.listen(walletStateMachineProvider, (previous, next) {
      if (next.isLoaded || next.status == WalletStatus.refreshing) {
        _updateWidget(next);
      }
    });

    // Watch user state for name changes
    ref.listen(userStateMachineProvider, (previous, next) {
      if (next.isLoaded) {
        _updateWidgetWithUser(next);
      }
    });
  }

  Future<void> _updateWidget(WalletState walletState) async {
    final manager = ref.read(widgetUpdateManagerProvider);
    final userState = ref.read(userStateMachineProvider);

    await manager.updateFromState(
      balance: walletState.usdcBalance,
      currency: 'USD',
      userName: _getUserDisplayName(userState),
    );
  }

  Future<void> _updateWidgetWithUser(UserState userState) async {
    final manager = ref.read(widgetUpdateManagerProvider);
    final walletState = ref.read(walletStateMachineProvider);

    if (walletState.isLoaded) {
      await manager.updateFromState(
        balance: walletState.usdcBalance,
        currency: 'USD',
        userName: _getUserDisplayName(userState),
      );
    }
  }

  String? _getUserDisplayName(UserState userState) {
    if (userState.profile?.firstName != null && userState.profile?.lastName != null) {
      return '${userState.profile!.firstName} ${userState.profile!.lastName}';
    } else if (userState.profile?.firstName != null) {
      return userState.profile!.firstName;
    }
    return null;
  }
}

/// Provider to initialize auto-updater
final widgetAutoUpdaterProvider = NotifierProvider<WidgetAutoUpdater, void>(
  WidgetAutoUpdater.new,
);
