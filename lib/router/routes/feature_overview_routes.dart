import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/features/bill_payments/views/bill_payments_view.dart';
import 'package:usdc_wallet/features/cards/views/cards_list_view.dart';
import 'package:usdc_wallet/features/contacts/views/contacts_list_screen.dart';
import 'package:usdc_wallet/features/insights/views/insights_view.dart';
import 'package:usdc_wallet/features/payment_links/views/create_link_view.dart';
import 'package:usdc_wallet/features/recurring_transfers/views/recurring_transfers_list_view.dart';
import 'package:usdc_wallet/features/savings_pots/views/pots_list_view.dart';
import 'package:usdc_wallet/features/transactions/views/export_transactions_view.dart';
import 'package:usdc_wallet/features/wallet/views/analytics_view.dart';
import 'package:usdc_wallet/features/wallet/views/budget_view.dart';
import 'package:usdc_wallet/features/wallet/views/buy_airtime_view.dart';
import 'package:usdc_wallet/features/wallet/views/currency_converter_view.dart';
import 'package:usdc_wallet/features/wallet/views/saved_recipients_view.dart';
import 'package:usdc_wallet/features/wallet/views/split_bill_view.dart';
import 'package:usdc_wallet/router/page_transitions.dart';

List<RouteBase> featureOverviewRoutes() => [
  // Feature routes
  GoRoute(
    path: '/request',
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const CreateLinkView(),
    ),
  ),
  GoRoute(
    path: '/scheduled',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const RecurringTransfersListView(),
    ),
  ),
  GoRoute(
    path: '/analytics',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const AnalyticsView()),
  ),
  GoRoute(
    path: '/insights',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const InsightsView()),
  ),
  GoRoute(
    path: '/recipients',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const SavedRecipientsView(),
    ),
  ),
  GoRoute(
    path: '/contacts',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const ContactsListScreen(),
    ),
  ),
  GoRoute(
    path: '/contacts/permission',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const ContactsListScreen(),
    ),
  ),
  GoRoute(
    path: '/contacts/list',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const ContactsListScreen(),
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
      child: const BillPaymentsView(),
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
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const PotsListView()),
  ),
  GoRoute(
    path: '/card',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const CardsListView()),
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
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const BudgetView()),
  ),
];
