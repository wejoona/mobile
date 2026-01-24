import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/views/login_view.dart';
import '../features/auth/views/otp_view.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/onboarding/views/onboarding_view.dart';
import '../features/splash/views/splash_view.dart';
import '../features/wallet/views/home_view.dart';
import '../features/wallet/views/deposit_view.dart';
import '../features/wallet/views/deposit_instructions_view.dart';
import '../features/wallet/views/send_view.dart';
import '../features/wallet/views/withdraw_view.dart';
import '../features/wallet/views/receive_view.dart';
import '../features/wallet/views/transfer_success_view.dart';
import '../features/wallet/views/scan_view.dart';
import '../features/transactions/views/transactions_view.dart';
import '../features/transactions/views/transaction_detail_view.dart';
import '../features/referrals/views/referrals_view.dart';
import '../features/settings/views/settings_view.dart';
import '../features/settings/views/profile_view.dart';
import '../features/settings/views/kyc_view.dart';
import '../features/settings/views/change_pin_view.dart';
import '../features/settings/views/notification_settings_view.dart';
import '../features/settings/views/security_view.dart';
import '../features/settings/views/limits_view.dart';
import '../features/settings/views/help_view.dart';
import '../features/notifications/views/notifications_view.dart';
import '../features/wallet/views/request_money_view.dart';
import '../features/wallet/views/scheduled_transfers_view.dart';
import '../features/wallet/views/analytics_view.dart';
import '../features/wallet/views/saved_recipients_view.dart';
import '../features/wallet/views/currency_converter_view.dart';
import '../features/wallet/views/bill_pay_view.dart';
import '../features/wallet/views/buy_airtime_view.dart';
import '../features/wallet/views/savings_goals_view.dart';
import '../features/wallet/views/virtual_card_view.dart';
import '../features/wallet/views/split_bill_view.dart';
import '../features/wallet/views/budget_view.dart';
import '../features/transactions/views/export_transactions_view.dart';
import '../domain/entities/index.dart';
import '../services/wallet/wallet_service.dart';
import '../services/feature_flags/feature_flags_service.dart';
import '../state/index.dart';

/// Navigation shell for bottom navigation - derives state from current route
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  /// Get selected index from the current route location
  int _getSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/referrals')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current location from GoRouter
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _getSelectedIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          // Update state and navigate
          ref.read(navigationProvider.notifier).setTabFromIndex(index);
          final tab = NavTabExt.fromIndex(index);
          context.go(tab.route);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.card_giftcard_outlined),
            selectedIcon: Icon(Icons.card_giftcard),
            label: 'Rewards',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// App Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Read auth state dynamically inside redirect
      final container = ProviderScope.containerOf(context);
      final authState = container.read(authProvider);
      final flags = container.read(featureFlagsProvider);

      final isAuthenticated = authState.isAuthenticated;
      final location = state.matchedLocation;

      // Allow splash, onboarding, and auth routes without auth
      final publicRoutes = ['/', '/onboarding', '/login', '/otp'];
      final isPublicRoute = publicRoutes.contains(location);

      // Auth guards
      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      // Redirect authenticated users away from login/otp (but not splash/onboarding)
      final isAuthRoute = location == '/login' || location == '/otp';
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      // Feature flag guards - redirect to home if feature disabled
      // Phase 1 MVP routes (always enabled, no guard needed)
      // /deposit, /send, /receive, /transactions, /settings/kyc

      // Phase 2 routes
      if (location == '/withdraw' && !flags.canWithdraw) {
        return '/home';
      }

      // Phase 3 routes
      if (location == '/airtime' && !flags.canBuyAirtime) {
        return '/home';
      }
      if (location == '/bills' && !flags.canPayBills) {
        return '/home';
      }

      // Phase 4 routes
      if (location == '/savings' && !flags.canSetSavingsGoals) {
        return '/home';
      }
      if (location == '/card' && !flags.canUseVirtualCards) {
        return '/home';
      }
      if (location == '/split' && !flags.canSplitBills) {
        return '/home';
      }
      if (location == '/budget' && !flags.canUseBudget) {
        return '/home';
      }
      if (location == '/scheduled' && !flags.canScheduleTransfers) {
        return '/home';
      }

      // Other feature routes
      if (location == '/analytics' && !flags.canViewAnalytics) {
        return '/home';
      }
      if (location == '/converter' && !flags.canUseCurrencyConverter) {
        return '/home';
      }
      if (location == '/request' && !flags.canRequestMoney) {
        return '/home';
      }
      if (location == '/recipients' && !flags.canUseSavedRecipients) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashView(),
      ),

      // Onboarding Route
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingView(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpView(),
      ),

      // Main App Routes (with bottom nav)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsView(),
          ),
          GoRoute(
            path: '/referrals',
            builder: (context, state) => const ReferralsView(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsView(),
          ),
        ],
      ),

      // Full-screen routes (no bottom nav)
      GoRoute(
        path: '/deposit',
        builder: (context, state) => const DepositView(),
      ),
      GoRoute(
        path: '/send',
        builder: (context, state) => const SendView(),
      ),
      GoRoute(
        path: '/withdraw',
        builder: (context, state) => const WithdrawView(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const ScanView(),
      ),
      GoRoute(
        path: '/receive',
        builder: (context, state) => const ReceiveView(),
      ),
      GoRoute(
        path: '/transfer/success',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra != null) {
            return TransferSuccessView(
              amount: extra['amount'] as double,
              recipient: extra['recipient'] as String,
              transactionId: extra['transactionId'] as String,
              note: extra['note'] as String?,
            );
          }
          // Fallback - go home
          return const TransferSuccessView(
            amount: 0,
            recipient: 'Unknown',
            transactionId: 'N/A',
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsView(),
      ),
      GoRoute(
        path: '/transactions/:id',
        builder: (context, state) {
          final transaction = state.extra as Transaction?;
          if (transaction != null) {
            return TransactionDetailView(transaction: transaction);
          }
          // If no transaction passed, go back to transactions list
          return const _PlaceholderPage(title: 'Transaction Not Found');
        },
      ),
      GoRoute(
        path: '/deposit/instructions',
        builder: (context, state) {
          final response = state.extra as DepositResponse?;
          if (response != null) {
            return DepositInstructionsView(response: response);
          }
          return const _PlaceholderPage(title: 'No Deposit Info');
        },
      ),
      GoRoute(
        path: '/settings/profile',
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: '/settings/pin',
        builder: (context, state) => const ChangePinView(),
      ),
      GoRoute(
        path: '/settings/kyc',
        builder: (context, state) => const KycView(),
      ),
      GoRoute(
        path: '/settings/notifications',
        builder: (context, state) => const NotificationSettingsView(),
      ),
      GoRoute(
        path: '/settings/security',
        builder: (context, state) => const SecurityView(),
      ),
      GoRoute(
        path: '/settings/limits',
        builder: (context, state) => const LimitsView(),
      ),
      GoRoute(
        path: '/settings/help',
        builder: (context, state) => const HelpView(),
      ),

      // Feature routes
      GoRoute(
        path: '/request',
        builder: (context, state) => const RequestMoneyView(),
      ),
      GoRoute(
        path: '/scheduled',
        builder: (context, state) => const ScheduledTransfersView(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsView(),
      ),
      GoRoute(
        path: '/recipients',
        builder: (context, state) => const SavedRecipientsView(),
      ),
      GoRoute(
        path: '/converter',
        builder: (context, state) => const CurrencyConverterView(),
      ),
      GoRoute(
        path: '/transactions/export',
        builder: (context, state) => const ExportTransactionsView(),
      ),
      GoRoute(
        path: '/bills',
        builder: (context, state) => const BillPayView(),
      ),
      GoRoute(
        path: '/airtime',
        builder: (context, state) => const BuyAirtimeView(),
      ),
      GoRoute(
        path: '/savings',
        builder: (context, state) => const SavingsGoalsView(),
      ),
      GoRoute(
        path: '/card',
        builder: (context, state) => const VirtualCardView(),
      ),
      GoRoute(
        path: '/split',
        builder: (context, state) => const SplitBillView(),
      ),
      GoRoute(
        path: '/budget',
        builder: (context, state) => const BudgetView(),
      ),
    ],
  );
});

/// Placeholder page for routes not yet implemented
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text(
          '$title\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
