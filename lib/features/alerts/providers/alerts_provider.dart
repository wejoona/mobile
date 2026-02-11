import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-app alert/banner state.
class AppAlert {
  final String id;
  final String message;
  final AlertType type;
  final String? actionLabel;
  final String? actionRoute;
  final bool isDismissible;

  const AppAlert({
    required this.id,
    required this.message,
    required this.type,
    this.actionLabel,
    this.actionRoute,
    this.isDismissible = true,
  });
}

enum AlertType { info, warning, error, success, promotion }

/// Active alerts notifier.
class AlertsNotifier extends Notifier<List<AppAlert>> {
  @override
  List<AppAlert> build() => [];

  void add(AppAlert alert) {
    if (!state.any((a) => a.id == alert.id)) {
      state = [...state, alert];
    }
  }

  void dismiss(String alertId) {
    state = state.where((a) => a.id != alertId).toList();
  }

  void clear() {
    state = [];
  }

  /// Add KYC reminder if not verified.
  void checkKycReminder(bool isKycVerified) {
    if (!isKycVerified) {
      add(const AppAlert(
        id: 'kyc_reminder',
        message: 'Complete verification to unlock higher limits',
        type: AlertType.warning,
        actionLabel: 'Verify Now',
        actionRoute: '/kyc',
      ));
    }
  }

  /// Add low balance alert.
  void checkLowBalance(double balance, {double threshold = 10.0}) {
    if (balance < threshold && balance > 0) {
      add(AppAlert(
        id: 'low_balance',
        message: 'Your balance is low (\$${balance.toStringAsFixed(2)})',
        type: AlertType.warning,
        actionLabel: 'Deposit',
        actionRoute: '/deposit',
      ));
    } else {
      dismiss('low_balance');
    }
  }
}

final alertsProvider =
    NotifierProvider<AlertsNotifier, List<AppAlert>>(AlertsNotifier.new);

/// First visible alert (for banner display).
final topAlertProvider = Provider<AppAlert?>((ref) {
  final alerts = ref.watch(alertsProvider);
  return alerts.isNotEmpty ? alerts.first : null;
});
