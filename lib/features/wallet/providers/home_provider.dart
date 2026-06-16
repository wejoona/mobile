import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/alerts/providers/alerts_provider.dart';
import 'package:usdc_wallet/features/notifications/providers/notification_count_provider.dart';
import 'package:usdc_wallet/features/savings_pots/providers/savings_pots_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';

/// Home screen aggregated state.
class HomeState {
  const HomeState({
    this.balance,
    this.unreadNotifications = 0,
    this.totalSavings = 0,
    this.visibleAlerts = const [],
    this.isLoading = false,
  });

  final WalletBalance? balance;
  final int unreadNotifications;
  final double totalSavings;
  final List<AppAlert> visibleAlerts;
  final bool isLoading;
}

/// Home screen composite provider — aggregates multiple data sources.
final homeProvider = Provider<HomeState>((ref) {
  final wallet = ref.watch(walletStateMachineProvider);
  final balance = wallet.hasBalanceData
      ? WalletBalance(
          available: wallet.availableBalance,
          pending: wallet.pendingBalance,
          total: wallet.availableBalance + wallet.pendingBalance,
          updatedAt: wallet.lastUpdated ?? DateTime.now(),
        )
      : null;
  final unread = ref.watch(unreadNotificationCountProvider);
  final savings = ref.watch(totalSavingsProvider);
  final alerts = ref.watch(visibleAlertsProvider);

  return HomeState(
    balance: balance,
    unreadNotifications: unread,
    totalSavings: savings,
    visibleAlerts: alerts,
    isLoading: wallet.isLoading,
  );
});
