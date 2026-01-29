import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/views/login_view.dart';
import '../features/auth/views/login_otp_view.dart';
import '../features/auth/views/login_pin_view.dart';
import '../features/auth/views/otp_view.dart';
import '../features/auth/providers/auth_provider.dart';
import '../services/feature_flags/feature_flags_provider.dart';
import '../features/onboarding/views/onboarding_view.dart';
import '../features/splash/views/splash_view.dart';
import '../features/wallet/views/wallet_home_screen.dart';
import '../features/wallet/views/deposit_view.dart';
import '../features/wallet/views/deposit_instructions_view.dart';
import '../features/deposit/views/deposit_amount_screen.dart';
import '../features/deposit/views/provider_selection_screen.dart';
import '../features/deposit/views/payment_instructions_screen.dart';
import '../features/deposit/views/deposit_status_screen.dart';
import '../features/wallet/views/withdraw_view.dart';
import '../features/wallet/views/receive_view.dart';
import '../features/wallet/views/transfer_success_view.dart';
import '../features/wallet/views/scan_view.dart';
import '../features/transactions/views/transactions_view.dart';
import '../features/transactions/views/transaction_detail_view.dart';
import '../features/referrals/views/referrals_view.dart';
import '../features/settings/views/settings_screen.dart';
import '../features/cards/views/cards_screen.dart';
import '../features/cards/views/cards_list_view.dart';
import '../features/cards/views/card_detail_view.dart';
import '../features/cards/views/request_card_view.dart';
import '../features/cards/views/card_settings_view.dart';
import '../features/cards/views/card_transactions_view.dart';
import '../features/settings/views/profile_view.dart';
import '../features/settings/views/kyc_view.dart';
import '../features/kyc/views/kyc_status_view.dart';
import '../features/kyc/views/document_type_view.dart';
import '../features/kyc/views/document_capture_view.dart';
import '../features/kyc/views/selfie_view.dart';
import '../features/kyc/views/review_view.dart';
import '../features/kyc/views/submitted_view.dart';
import '../features/kyc/views/kyc_upgrade_view.dart';
import '../features/kyc/views/kyc_address_view.dart';
import '../features/kyc/views/kyc_video_view.dart';
import '../features/kyc/views/kyc_additional_docs_view.dart';
import '../features/kyc/models/kyc_tier.dart';
import '../features/settings/views/change_pin_view.dart';
import '../features/settings/views/notification_settings_view.dart';
import '../features/settings/views/security_view.dart';
import '../features/biometric/views/biometric_settings_view.dart';
import '../features/biometric/views/biometric_enrollment_view.dart';
import '../features/settings/views/limits_view.dart';
import '../features/settings/views/help_view.dart';
import '../features/settings/views/language_view.dart';
import '../features/settings/views/currency_view.dart';
import '../features/settings/views/devices_screen.dart';
import '../features/settings/views/sessions_screen.dart';
import '../features/settings/views/profile_edit_screen.dart';
import '../features/settings/views/help_screen.dart';
import '../features/settings/views/cookie_policy_view.dart';
import '../features/notifications/views/notifications_view.dart';
import '../features/notifications/views/notification_permission_screen.dart';
import '../features/notifications/views/notification_preferences_screen.dart';
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
import '../features/savings_pots/views/pots_list_view.dart';
import '../features/savings_pots/views/create_pot_view.dart';
import '../features/savings_pots/views/pot_detail_view.dart';
import '../features/savings_pots/views/edit_pot_view.dart';
import '../features/recurring_transfers/views/recurring_transfers_list_view.dart';
import '../features/recurring_transfers/views/create_recurring_transfer_view.dart';
import '../features/recurring_transfers/views/recurring_transfer_detail_view.dart';
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
import '../features/insights/views/insights_view.dart';
import '../features/alerts/views/alert_detail_view.dart';
import '../features/alerts/views/alert_preferences_view.dart';
import '../features/services/views/services_view.dart';
import '../features/beneficiaries/views/beneficiaries_screen.dart';
import '../features/beneficiaries/views/add_beneficiary_screen.dart';
import '../features/beneficiaries/views/beneficiary_detail_view.dart';
import '../features/business/views/business_setup_view.dart';
import '../features/business/views/business_profile_view.dart';
import '../features/expenses/views/expenses_view.dart';
import '../features/expenses/views/add_expense_view.dart';
import '../features/expenses/views/capture_receipt_view.dart';
import '../features/expenses/views/expense_detail_view.dart';
import '../features/expenses/views/expense_reports_view.dart';
import '../features/expenses/models/expense.dart';
import '../features/payment_links/views/payment_links_list_view.dart';
import '../features/payment_links/views/create_link_view.dart';
import '../features/payment_links/views/link_detail_view.dart';
import '../features/payment_links/views/link_created_view.dart';
import '../features/payment_links/views/pay_link_view.dart';
import '../features/bank_linking/views/linked_accounts_view.dart';
import '../features/bank_linking/views/bank_selection_view.dart';
import '../features/bank_linking/views/link_bank_view.dart';
import '../features/bank_linking/views/bank_verification_view.dart';
import '../features/bank_linking/views/bank_transfer_view.dart';
import '../features/send/views/recipient_screen.dart';
import '../features/send/views/amount_screen.dart';
import '../features/send/views/confirm_screen.dart';
import '../features/send/views/pin_verification_screen.dart';
import '../features/send/views/result_screen.dart';
import '../features/send_external/views/address_input_screen.dart';
import '../features/send_external/views/external_amount_screen.dart';
import '../features/send_external/views/external_confirm_screen.dart';
import '../features/send_external/views/external_result_screen.dart';
import '../features/send_external/views/scan_address_qr_screen.dart';
import '../features/bulk_payments/views/bulk_payments_view.dart';
import '../features/bulk_payments/views/bulk_upload_view.dart';
import '../features/bulk_payments/views/bulk_preview_view.dart';
import '../features/bulk_payments/views/bulk_status_view.dart';
import '../features/sub_business/views/sub_businesses_view.dart';
import '../features/sub_business/views/create_sub_business_view.dart';
import '../features/sub_business/views/sub_business_detail_view.dart';
import '../features/sub_business/views/sub_business_staff_view.dart';
import '../domain/entities/index.dart';
import '../services/wallet/wallet_service.dart';
import 'page_transitions.dart';

/// Navigation shell for bottom navigation - derives state from current route
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  /// Get selected index from the current route location
  int _getSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/cards')) return 1;
    if (location.startsWith('/transactions')) return 2;
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
          // Navigate based on index
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/cards');
              break;
            case 2:
              context.go('/transactions');
              break;
            case 3:
              context.go('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history),
            label: 'History',
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
      final publicRoutes = ['/', '/onboarding', '/login', '/login/otp', '/login/pin', '/otp'];
      final isPublicRoute = publicRoutes.any((route) => location.startsWith(route));

      // Auth guards
      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      // Redirect authenticated users away from login/otp (but not splash/onboarding)
      final isAuthRoute = location.startsWith('/login') || location == '/otp';
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      // Feature flag guards - redirect to home if feature disabled
      // Phase 1 MVP routes (always enabled, no guard needed)
      // /deposit, /send, /receive, /transactions, /settings/kyc

      // Phase 2 routes
      if (location == '/withdraw' && !(flags[FeatureFlagKeys.withdraw] ?? false)) {
        return '/home';
      }

      // Phase 3 routes
      if (location == '/airtime' && !(flags[FeatureFlagKeys.airtime] ?? false)) {
        return '/home';
      }
      if (location == '/bills' && !(flags[FeatureFlagKeys.bills] ?? false)) {
        return '/home';
      }

      // Phase 4 routes
      if (location == '/savings' && !(flags[FeatureFlagKeys.savings] ?? false)) {
        return '/home';
      }
      if (location.startsWith('/savings-pots') && !(flags[FeatureFlagKeys.savingsPots] ?? false)) {
        return '/home';
      }
      if ((location == '/card' || location.startsWith('/cards/')) && !(flags[FeatureFlagKeys.virtualCards] ?? false)) {
        return '/home';
      }
      if (location == '/split' && !(flags[FeatureFlagKeys.splitBills] ?? false)) {
        return '/home';
      }
      if (location == '/budget' && !(flags[FeatureFlagKeys.budget] ?? false)) {
        return '/home';
      }
      if (location == '/scheduled' && !(flags[FeatureFlagKeys.recurringTransfers] ?? false)) {
        return '/home';
      }

      // Other feature routes
      if (location == '/analytics' && !(flags[FeatureFlagKeys.analytics] ?? false)) {
        return '/home';
      }
      if (location == '/converter' && !(flags[FeatureFlagKeys.currencyConverter] ?? false)) {
        return '/home';
      }
      if (location == '/request' && !(flags[FeatureFlagKeys.requestMoney] ?? false)) {
        return '/home';
      }
      if (location == '/recipients' && !(flags[FeatureFlagKeys.savedRecipients] ?? false)) {
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
        path: '/login/otp',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const LoginOtpView(),
        ),
      ),
      GoRoute(
        path: '/login/pin',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const LoginPinView(),
        ),
      ),
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const OtpView(),
        ),
      ),

      // Main App Routes (with bottom nav - no animation for tab switching)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const WalletHomeScreen(),
            ),
          ),
          GoRoute(
            path: '/cards',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CardsListView(),
            ),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const TransactionsView(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),

      // Legacy Services route (kept for backward compatibility)
      GoRoute(
        path: '/services',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const ServicesView(),
        ),
      ),

      // Full-screen routes (no bottom nav - vertical slide for modals)
      GoRoute(
        path: '/deposit',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const DepositView(),
        ),
      ),

      // Mobile Money Deposit Flow
      GoRoute(
        path: '/deposit/amount',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const DepositAmountScreen(),
        ),
      ),
      GoRoute(
        path: '/deposit/provider',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const ProviderSelectionScreen(),
        ),
      ),
      GoRoute(
        path: '/deposit/instructions',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const PaymentInstructionsScreen(),
        ),
      ),
      GoRoute(
        path: '/deposit/status',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const DepositStatusScreen(),
        ),
      ),
      GoRoute(
        path: '/send',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const RecipientScreen(),
        ),
      ),
      GoRoute(
        path: '/send/amount',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const AmountScreen(),
        ),
      ),
      GoRoute(
        path: '/send/confirm',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const ConfirmScreen(),
        ),
      ),
      GoRoute(
        path: '/send/pin',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const PinVerificationScreen(),
        ),
      ),
      GoRoute(
        path: '/send/result',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const ResultScreen(),
        ),
      ),
      // External transfer routes
      GoRoute(
        path: '/send-external',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const AddressInputScreen(),
        ),
      ),
      GoRoute(
        path: '/send-external/amount',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const ExternalAmountScreen(),
        ),
      ),
      GoRoute(
        path: '/send-external/confirm',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const ExternalConfirmScreen(),
        ),
      ),
      GoRoute(
        path: '/send-external/result',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const ExternalResultScreen(),
        ),
      ),
      GoRoute(
        path: '/qr/scan-address',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const ScanAddressQrScreen(),
        ),
      ),
      GoRoute(
        path: '/withdraw',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const WithdrawView(),
        ),
      ),

      // Virtual Cards Routes
      GoRoute(
        path: '/cards/request',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const RequestCardView(),
        ),
      ),
      GoRoute(
        path: '/cards/detail/:id',
        pageBuilder: (context, state) {
          final cardId = state.pathParameters['id']!;
          return AppPageTransitions.horizontalSlide(
            state: state,
            child: CardDetailView(cardId: cardId),
          );
        },
      ),
      GoRoute(
        path: '/cards/settings/:id',
        pageBuilder: (context, state) {
          final cardId = state.pathParameters['id']!;
          return AppPageTransitions.horizontalSlide(
            state: state,
            child: CardSettingsView(cardId: cardId),
          );
        },
      ),
      GoRoute(
        path: '/cards/transactions/:id',
        pageBuilder: (context, state) {
          final cardId = state.pathParameters['id']!;
          return AppPageTransitions.horizontalSlide(
            state: state,
            child: CardTransactionsView(cardId: cardId),
          );
        },
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
      // KYC Flow Routes
      GoRoute(
        path: '/kyc',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const KycStatusView(),
        ),
      ),
      GoRoute(
        path: '/kyc/document-type',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const DocumentTypeView(),
        ),
      ),
      GoRoute(
        path: '/kyc/document-capture',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const DocumentCaptureView(),
        ),
      ),
      GoRoute(
        path: '/kyc/selfie',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const SelfieView(),
        ),
      ),
      GoRoute(
        path: '/kyc/review',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const ReviewView(),
        ),
      ),
      GoRoute(
        path: '/kyc/submitted',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const SubmittedView(),
        ),
      ),
      GoRoute(
        path: '/kyc/upgrade',
        pageBuilder: (context, state) {
          final currentTier = state.extra as Map<String, dynamic>?;
          return AppPageTransitions.verticalSlide(
            state: state,
            child: KycUpgradeView(
              currentTier: currentTier?['currentTier'] as KycTier? ?? KycTier.tier0,
              targetTier: currentTier?['targetTier'] as KycTier? ?? KycTier.tier1,
              reason: currentTier?['reason'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/kyc/address',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const KycAddressView(),
        ),
      ),
      GoRoute(
        path: '/kyc/video',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const KycVideoView(),
        ),
      ),
      GoRoute(
        path: '/kyc/additional-docs',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const KycAdditionalDocsView(),
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
        path: '/notifications',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const NotificationsView(),
        ),
      ),
      GoRoute(
        path: '/notifications/permission',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const NotificationPermissionScreen(),
        ),
      ),
      GoRoute(
        path: '/notifications/preferences',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const NotificationPreferencesScreen(),
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
        path: '/settings/biometric',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const BiometricSettingsView(),
        ),
      ),
      GoRoute(
        path: '/settings/biometric/enrollment',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const BiometricEnrollmentView(),
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
      GoRoute(
        path: '/settings/currency',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const CurrencyView(),
        ),
      ),
      GoRoute(
        path: '/settings/devices',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const DevicesScreen(),
        ),
      ),
      GoRoute(
        path: '/settings/sessions',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const SessionsScreen(),
        ),
      ),
      GoRoute(
        path: '/settings/profile/edit',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const ProfileEditScreen(),
        ),
      ),
      GoRoute(
        path: '/settings/help-screen',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const HelpScreen(),
        ),
      ),
      GoRoute(
        path: '/settings/business-setup',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const BusinessSetupView(),
        ),
      ),
      GoRoute(
        path: '/settings/business-profile',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const BusinessProfileView(),
        ),
      ),
      GoRoute(
        path: '/settings/legal/cookies',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const CookiePolicyView(),
        ),
      ),

      // Referrals Page - moved out of bottom nav (fade)
      GoRoute(
        path: '/referrals',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const ReferralsView(),
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
        path: '/insights',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const InsightsView(),
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

      // Savings Pots Routes
      GoRoute(
        path: '/savings-pots',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const PotsListView(),
        ),
      ),
      GoRoute(
        path: '/savings-pots/create',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const CreatePotView(),
        ),
      ),
      GoRoute(
        path: '/savings-pots/detail/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppPageTransitions.fade(
            state: state,
            child: PotDetailView(potId: id),
          );
        },
      ),
      GoRoute(
        path: '/savings-pots/edit/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppPageTransitions.verticalSlide(
            state: state,
            child: EditPotView(potId: id),
          );
        },
      ),

      // Recurring Transfers Routes
      GoRoute(
        path: '/recurring-transfers',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const RecurringTransfersListView(),
        ),
      ),
      GoRoute(
        path: '/recurring-transfers/create',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const CreateRecurringTransferView(),
        ),
      ),
      GoRoute(
        path: '/recurring-transfers/detail/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppPageTransitions.fade(
            state: state,
            child: RecurringTransferDetailView(transferId: id),
          );
        },
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

      // Expenses Routes
      GoRoute(
        path: '/expenses',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const ExpensesView(),
        ),
      ),
      GoRoute(
        path: '/expenses/add',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const AddExpenseView(),
        ),
      ),
      GoRoute(
        path: '/expenses/capture',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const CaptureReceiptView(),
        ),
      ),
      GoRoute(
        path: '/expenses/detail/:id',
        pageBuilder: (context, state) {
          final expense = state.extra as Expense?;
          Widget child;
          if (expense != null) {
            child = ExpenseDetailView(expense: expense);
          } else {
            child = const _PlaceholderPage(title: 'Expense Not Found');
          }
          return AppPageTransitions.horizontalSlide(state: state, child: child);
        },
      ),
      GoRoute(
        path: '/expenses/reports',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const ExpenseReportsView(),
        ),
      ),

      // Payment Links Routes
      GoRoute(
        path: '/payment-links',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const PaymentLinksListView(),
        ),
      ),
      GoRoute(
        path: '/payment-links/create',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const CreateLinkView(),
        ),
      ),
      GoRoute(
        path: '/payment-links/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppPageTransitions.fade(
            state: state,
            child: LinkDetailView(linkId: id),
          );
        },
      ),
      GoRoute(
        path: '/payment-links/created/:id',
        pageBuilder: (context, state) {
          final linkId = state.pathParameters['id'];
          Widget child;
          if (linkId != null) {
            child = LinkCreatedView(linkId: linkId);
          } else {
            child = const _PlaceholderPage(title: 'Link Not Found');
          }
          return AppPageTransitions.fade(state: state, child: child);
        },
      ),
      GoRoute(
        path: '/pay/:code',
        pageBuilder: (context, state) {
          final code = state.pathParameters['code'];
          Widget child;
          if (code != null) {
            child = PayLinkView(linkCode: code);
          } else {
            child = const _PlaceholderPage(title: 'Invalid Link');
          }
          return AppPageTransitions.verticalSlide(state: state, child: child);
        },
      ),

      // Sub-Business Routes
      GoRoute(
        path: '/sub-businesses',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const SubBusinessesView(),
        ),
      ),
      GoRoute(
        path: '/sub-businesses/create',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const CreateSubBusinessView(),
        ),
      ),
      GoRoute(
        path: '/sub-businesses/detail/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'];
          Widget child;
          if (id != null) {
            child = SubBusinessDetailView(subBusinessId: id);
          } else {
            child = const _PlaceholderPage(title: 'Sub-Business Not Found');
          }
          return AppPageTransitions.horizontalSlide(state: state, child: child);
        },
      ),
      GoRoute(
        path: '/sub-businesses/:id/staff',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'];
          Widget child;
          if (id != null) {
            child = SubBusinessStaffView(subBusinessId: id);
          } else {
            child = const _PlaceholderPage(title: 'Sub-Business Not Found');
          }
          return AppPageTransitions.horizontalSlide(state: state, child: child);
        },
      ),
      GoRoute(
        path: '/sub-businesses/transfer/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'];
          // TODO: Implement transfer between sub-businesses screen
          return AppPageTransitions.verticalSlide(
            state: state,
            child: const _PlaceholderPage(title: 'Transfer Between Sub-Businesses'),
          );
        },
      ),

      // Bulk Payments Routes
      GoRoute(
        path: '/bulk-payments',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const BulkPaymentsView(),
        ),
      ),
      GoRoute(
        path: '/bulk-payments/upload',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const BulkUploadView(),
        ),
      ),
      GoRoute(
        path: '/bulk-payments/preview',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const BulkPreviewView(),
        ),
      ),
      GoRoute(
        path: '/bulk-payments/status/:batchId',
        pageBuilder: (context, state) {
          final batchId = state.pathParameters['batchId'];
          Widget child;
          if (batchId != null) {
            child = BulkStatusView(batchId: batchId);
          } else {
            child = const _PlaceholderPage(title: 'Batch Not Found');
          }
          return AppPageTransitions.fade(state: state, child: child);
        },
      ),

      // Beneficiaries Routes
      GoRoute(
        path: '/beneficiaries',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const BeneficiariesScreen(),
        ),
      ),
      GoRoute(
        path: '/beneficiaries/add',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const AddBeneficiaryScreen(),
        ),
      ),
      GoRoute(
        path: '/beneficiaries/detail/:id',
        pageBuilder: (context, state) {
          final beneficiaryId = state.pathParameters['id'];
          Widget child;
          if (beneficiaryId != null) {
            child = BeneficiaryDetailView(beneficiaryId: beneficiaryId);
          } else {
            child = const _PlaceholderPage(title: 'Beneficiary Not Found');
          }
          return AppPageTransitions.horizontalSlide(state: state, child: child);
        },
      ),
      GoRoute(
        path: '/beneficiaries/edit/:id',
        pageBuilder: (context, state) {
          final beneficiaryId = state.pathParameters['id'];
          Widget child;
          if (beneficiaryId != null) {
            child = AddBeneficiaryScreen(beneficiaryId: beneficiaryId);
          } else {
            child = const _PlaceholderPage(title: 'Beneficiary Not Found');
          }
          return AppPageTransitions.verticalSlide(state: state, child: child);
        },
      ),

      // Bank Linking Routes
      GoRoute(
        path: '/bank-linking',
        pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
          state: state,
          child: const LinkedAccountsView(),
        ),
      ),
      GoRoute(
        path: '/bank-linking/select',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const BankSelectionView(),
        ),
      ),
      GoRoute(
        path: '/bank-linking/link',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const LinkBankView(),
        ),
      ),
      GoRoute(
        path: '/bank-linking/verify',
        pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
          state: state,
          child: const BankVerificationView(),
        ),
      ),
      GoRoute(
        path: '/bank-linking/verify/:accountId',
        pageBuilder: (context, state) {
          final accountId = state.pathParameters['accountId'];
          return AppPageTransitions.horizontalSlide(
            state: state,
            child: BankVerificationView(accountId: accountId),
          );
        },
      ),
      GoRoute(
        path: '/bank-linking/transfer/:accountId',
        pageBuilder: (context, state) {
          final accountId = state.pathParameters['accountId'];
          final type = state.extra as String? ?? 'deposit';
          Widget child;
          if (accountId != null) {
            child = BankTransferView(accountId: accountId, type: type);
          } else {
            child = const _PlaceholderPage(title: 'Account Not Found');
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
