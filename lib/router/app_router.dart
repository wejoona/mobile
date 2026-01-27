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
import '../features/settings/views/language_view.dart';
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
import '../features/merchant_pay/views/scan_qr_view.dart';
import '../features/merchant_pay/views/payment_receipt_view.dart';
import '../features/merchant_pay/views/merchant_dashboard_view.dart';
import '../features/merchant_pay/views/merchant_qr_view.dart';
import '../features/merchant_pay/views/create_payment_request_view.dart';
import '../features/merchant_pay/views/merchant_transactions_view.dart';
import '../features/merchant_pay/services/merchant_service.dart';
import '../features/bill_payments/views/bill_payments_view.dart';
import '../features/bill_payments/views/bill_payment_form_view.dart';
import '../features/bill_payments/views/bill_payment_success_view.dart';
import '../features/bill_payments/views/bill_payment_history_view.dart';
import '../features/alerts/views/alerts_list_view.dart';
import '../features/alerts/views/alert_detail_view.dart';
import '../features/alerts/views/alert_preferences_view.dart';
import '../features/services/views/services_view.dart';
import '../domain/entities/index.dart';
import '../services/wallet/wallet_service.dart';
import '../services/feature_flags/feature_flags_service.dart';
import '../state/index.dart';
import 'page_transitions.dart';

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
      // Splash Screen (no transition)
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => AppPageTransitions.none(
          state: state,
          child: const SplashView(),
        ),
      ),

      // Onboarding Route (fade)
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const OnboardingView(),
        ),
      ),

      // Auth Routes (fade for smooth transitions)
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const LoginView(),
        ),
      ),
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const OtpView(),
        ),
      ),

      // Main App Routes (with bottom nav - horizontal slide for tab switching)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
              state: state,
              child: const HomeView(),
            ),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
              state: state,
              child: const TransactionsView(),
            ),
          ),
          GoRoute(
            path: '/referrals',
            pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
              state: state,
              child: const ReferralsView(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
              state: state,
              child: const SettingsView(),
            ),
          ),
        ],
      ),

      // Full-screen routes (no bottom nav - vertical slide for modals)
      GoRoute(
        path: '/deposit',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const DepositView(),
        ),
      ),
      GoRoute(
        path: '/send',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const SendView(),
        ),
      ),
      GoRoute(
        path: '/withdraw',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const WithdrawView(),
        ),
      ),
      GoRoute(
        path: '/scan',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const ScanView(),
        ),
      ),
      GoRoute(
        path: '/receive',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const ReceiveView(),
        ),
      ),
      GoRoute(
        path: '/transfer/success',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          Widget child;
          if (extra != null) {
            child = TransferSuccessView(
              amount: extra['amount'] as double,
              recipient: extra['recipient'] as String,
              transactionId: extra['transactionId'] as String,
              note: extra['note'] as String?,
            );
          } else {
            // Fallback - go home
            child = const TransferSuccessView(
              amount: 0,
              recipient: 'Unknown',
              transactionId: 'N/A',
            );
          }
          // Scale and fade for success screens
          return createSuccessTransition(state: state, child: child);
        },
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const NotificationsView(),
        ),
      ),
      GoRoute(
        path: '/transactions/:id',
        pageBuilder: (context, state) {
          final transaction = state.extra as Transaction?;
          Widget child;
          if (transaction != null) {
            child = TransactionDetailView(transaction: transaction);
          } else {
            // If no transaction passed, go back to transactions list
            child = const _PlaceholderPage(title: 'Transaction Not Found');
          }
          return AppPageTransitions.verticalSlide(state: state, child: child);
        },
      ),
      GoRoute(
        path: '/deposit/instructions',
        pageBuilder: (context, state) {
          final response = state.extra as DepositResponse?;
          Widget child;
          if (response != null) {
            child = DepositInstructionsView(response: response);
          } else {
            child = const _PlaceholderPage(title: 'No Deposit Info');
          }
          return AppPageTransitions.verticalSlide(state: state, child: child);
        },
      ),
      GoRoute(
        path: '/settings/profile',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const ProfileView(),
        ),
      ),
      GoRoute(
        path: '/settings/pin',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const ChangePinView(),
        ),
      ),
      GoRoute(
        path: '/settings/kyc',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const KycView(),
        ),
      ),
      GoRoute(
        path: '/settings/notifications',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const NotificationSettingsView(),
        ),
      ),
      GoRoute(
        path: '/settings/security',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const SecurityView(),
        ),
      ),
      GoRoute(
        path: '/settings/limits',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const LimitsView(),
        ),
      ),
      GoRoute(
        path: '/settings/help',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const HelpView(),
        ),
      ),
      GoRoute(
        path: '/settings/language',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const LanguageView(),
        ),
      ),

      // Services Page - centralized view of all features (fade)
      GoRoute(
        path: '/services',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const ServicesView(),
        ),
      ),

      // Feature routes
      GoRoute(
        path: '/request',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const RequestMoneyView(),
        ),
      ),
      GoRoute(
        path: '/scheduled',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const ScheduledTransfersView(),
        ),
      ),
      GoRoute(
        path: '/analytics',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const AnalyticsView(),
        ),
      ),
      GoRoute(
        path: '/recipients',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const SavedRecipientsView(),
        ),
      ),
      GoRoute(
        path: '/converter',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const CurrencyConverterView(),
        ),
      ),
      GoRoute(
        path: '/transactions/export',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const ExportTransactionsView(),
        ),
      ),
      GoRoute(
        path: '/bills',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const BillPayView(),
        ),
      ),
      GoRoute(
        path: '/airtime',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const BuyAirtimeView(),
        ),
      ),
      GoRoute(
        path: '/savings',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const SavingsGoalsView(),
        ),
      ),
      GoRoute(
        path: '/card',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const VirtualCardView(),
        ),
      ),
      GoRoute(
        path: '/split',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const SplitBillView(),
        ),
      ),
      GoRoute(
        path: '/budget',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const BudgetView(),
        ),
      ),

      // Merchant Pay Routes
      GoRoute(
        path: '/scan-to-pay',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const ScanQrView(),
        ),
      ),
      GoRoute(
        path: '/payment-receipt',
        pageBuilder: (context, state) {
          final response = state.extra as PaymentResponse?;
          Widget child;
          if (response != null) {
            child = PaymentReceiptView(payment: response);
          } else {
            child = const _PlaceholderPage(title: 'Payment Not Found');
          }
          return createSuccessTransition(state: state, child: child);
        },
      ),
      GoRoute(
        path: '/merchant-dashboard',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const MerchantDashboardView(),
        ),
      ),
      GoRoute(
        path: '/merchant-qr',
        pageBuilder: (context, state) {
          final merchant = state.extra as MerchantResponse?;
          Widget child;
          if (merchant != null) {
            child = MerchantQrView(merchant: merchant);
          } else {
            child = const _PlaceholderPage(title: 'Merchant Not Found');
          }
          return AppPageTransitions.verticalSlide(state: state, child: child);
        },
      ),
      GoRoute(
        path: '/create-payment-request',
        pageBuilder: (context, state) {
          final merchant = state.extra as MerchantResponse?;
          Widget child;
          if (merchant != null) {
            child = CreatePaymentRequestView(merchant: merchant);
          } else {
            child = const _PlaceholderPage(title: 'Merchant Not Found');
          }
          return AppPageTransitions.verticalSlide(state: state, child: child);
        },
      ),
      GoRoute(
        path: '/merchant-transactions',
        pageBuilder: (context, state) {
          final merchantId = state.extra as String?;
          Widget child;
          if (merchantId != null) {
            child = MerchantTransactionsView(merchantId: merchantId);
          } else {
            child = const _PlaceholderPage(title: 'Merchant Not Found');
          }
          return AppPageTransitions.fade(state: state, child: child);
        },
      ),

      // Bill Payments Routes
      GoRoute(
        path: '/bill-payments',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const BillPaymentsView(),
        ),
      ),
      GoRoute(
        path: '/bill-payments/form/:providerId',
        pageBuilder: (context, state) {
          final providerId = state.pathParameters['providerId'];
          Widget child;
          if (providerId != null) {
            child = BillPaymentFormView(providerId: providerId);
          } else {
            child = const _PlaceholderPage(title: 'Provider Not Found');
          }
          return AppPageTransitions.verticalSlide(state: state, child: child);
        },
      ),
      GoRoute(
        path: '/bill-payments/success/:paymentId',
        pageBuilder: (context, state) {
          final paymentId = state.pathParameters['paymentId'];
          Widget child;
          if (paymentId != null) {
            child = BillPaymentSuccessView(paymentId: paymentId);
          } else {
            child = const _PlaceholderPage(title: 'Payment Not Found');
          }
          return createSuccessTransition(state: state, child: child);
        },
      ),
      GoRoute(
        path: '/bill-payments/history',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const BillPaymentHistoryView(),
        ),
      ),

      // Alerts Routes (Transaction Monitoring)
      GoRoute(
        path: '/alerts',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const AlertsListView(),
        ),
      ),
      GoRoute(
        path: '/alerts/preferences',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const AlertPreferencesView(),
        ),
      ),
      GoRoute(
        path: '/alerts/:id',
        pageBuilder: (context, state) {
          final alertId = state.pathParameters['id'];
          Widget child;
          if (alertId != null) {
            child = AlertDetailView(alertId: alertId);
          } else {
            child = const _PlaceholderPage(title: 'Alert Not Found');
          }
          return AppPageTransitions.verticalSlide(state: state, child: child);
        },
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
