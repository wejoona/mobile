import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/domain/entities/expense.dart';
import 'package:usdc_wallet/features/alerts/views/alert_detail_view.dart';
import 'package:usdc_wallet/features/alerts/views/alert_preferences_view.dart';
import 'package:usdc_wallet/features/alerts/views/alerts_list_view.dart';
import 'package:usdc_wallet/features/bill_payments/views/bill_payment_form_view.dart';
import 'package:usdc_wallet/features/bill_payments/views/bill_payment_history_view.dart';
import 'package:usdc_wallet/features/bill_payments/views/bill_payment_success_view.dart';
import 'package:usdc_wallet/features/bill_payments/views/bill_payments_view.dart';
import 'package:usdc_wallet/features/expenses/views/add_expense_view.dart';
import 'package:usdc_wallet/features/expenses/views/capture_receipt_view.dart';
import 'package:usdc_wallet/features/expenses/views/expense_detail_view.dart';
import 'package:usdc_wallet/features/expenses/views/expense_reports_view.dart';
import 'package:usdc_wallet/features/expenses/views/expenses_view.dart';
import 'package:usdc_wallet/features/merchant_pay/services/merchant_service.dart';
import 'package:usdc_wallet/features/merchant_pay/views/create_payment_request_view.dart';
import 'package:usdc_wallet/features/merchant_pay/views/merchant_dashboard_view.dart';
import 'package:usdc_wallet/features/merchant_pay/views/merchant_qr_view.dart';
import 'package:usdc_wallet/features/merchant_pay/views/merchant_transactions_view.dart';
import 'package:usdc_wallet/features/merchant_pay/views/payment_receipt_view.dart';
import 'package:usdc_wallet/features/merchant_pay/views/scan_qr_view.dart';
import 'package:usdc_wallet/features/payment_links/views/create_link_view.dart';
import 'package:usdc_wallet/features/payment_links/views/link_created_view.dart';
import 'package:usdc_wallet/features/payment_links/views/link_detail_view.dart';
import 'package:usdc_wallet/features/payment_links/views/pay_link_view.dart';
import 'package:usdc_wallet/features/payment_links/views/payment_links_list_view.dart';
import 'package:usdc_wallet/router/page_transitions.dart';
import 'package:usdc_wallet/router/widgets/placeholder_pages.dart';

List<RouteBase> commerceRoutes() => [
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
        child = const RoutePlaceholderPage(title: 'Payment Not Found');
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
        child = const RoutePlaceholderPage(title: 'Merchant Not Found');
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
        child = const RoutePlaceholderPage(title: 'Merchant Not Found');
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
        child = const RoutePlaceholderPage(title: 'Merchant Not Found');
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
        child = const RoutePlaceholderPage(title: 'Provider Not Found');
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
        child = const RoutePlaceholderPage(title: 'Payment Not Found');
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
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const AlertsListView()),
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
        child = const RoutePlaceholderPage(title: 'Alert Not Found');
      }
      return AppPageTransitions.verticalSlide(state: state, child: child);
    },
  ),

  // Expenses Routes
  GoRoute(
    path: '/expenses',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const ExpensesView()),
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
        child = const RoutePlaceholderPage(title: 'Expense Not Found');
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
    path: '/payment-links/detail/:id',
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
        child = const RoutePlaceholderPage(title: 'Link Not Found');
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
        child = const RoutePlaceholderPage(title: 'Invalid Link');
      }
      return AppPageTransitions.verticalSlide(state: state, child: child);
    },
  ),
];
