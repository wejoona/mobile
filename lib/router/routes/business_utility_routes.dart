import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/catalog/widget_catalog_view.dart';
import 'package:usdc_wallet/features/bank_linking/views/bank_selection_view.dart';
import 'package:usdc_wallet/features/bank_linking/views/bank_transfer_view.dart';
import 'package:usdc_wallet/features/bank_linking/views/bank_verification_view.dart';
import 'package:usdc_wallet/features/bank_linking/views/link_bank_view.dart';
import 'package:usdc_wallet/features/bank_linking/views/linked_accounts_view.dart';
import 'package:usdc_wallet/features/beneficiaries/views/add_beneficiary_screen.dart';
import 'package:usdc_wallet/features/beneficiaries/views/beneficiaries_screen.dart';
import 'package:usdc_wallet/features/beneficiaries/views/beneficiary_detail_view.dart';
import 'package:usdc_wallet/features/bulk_payments/views/bulk_payments_view.dart';
import 'package:usdc_wallet/features/bulk_payments/views/bulk_preview_view.dart';
import 'package:usdc_wallet/features/bulk_payments/views/bulk_status_view.dart';
import 'package:usdc_wallet/features/bulk_payments/views/bulk_upload_view.dart';
import 'package:usdc_wallet/features/sub_business/views/create_sub_business_view.dart';
import 'package:usdc_wallet/features/sub_business/views/sub_business_detail_view.dart';
import 'package:usdc_wallet/features/sub_business/views/sub_business_staff_view.dart';
import 'package:usdc_wallet/features/sub_business/views/sub_business_transfer_view.dart';
import 'package:usdc_wallet/features/sub_business/views/sub_businesses_view.dart';
import 'package:usdc_wallet/router/page_transitions.dart';
import 'package:usdc_wallet/router/widgets/placeholder_pages.dart';

List<RouteBase> businessUtilityRoutes({bool includeDevelopmentRoutes = true}) {
  final routes = <RouteBase>[
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
          child = const RoutePlaceholderPage(title: 'Sub-Business Not Found');
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
          child = const RoutePlaceholderPage(title: 'Sub-Business Not Found');
        }
        return AppPageTransitions.horizontalSlide(state: state, child: child);
      },
    ),
    GoRoute(
      path: '/sub-businesses/transfer/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'];
        Widget child;
        if (id != null) {
          child = SubBusinessTransferView(subBusinessId: id);
        } else {
          child = const RoutePlaceholderPage(title: 'Sub-Business Not Found');
        }
        return AppPageTransitions.verticalSlide(state: state, child: child);
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
          child = const RoutePlaceholderPage(title: 'Batch Not Found');
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
          child = const RoutePlaceholderPage(title: 'Beneficiary Not Found');
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
          child = const RoutePlaceholderPage(title: 'Beneficiary Not Found');
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
          child = const RoutePlaceholderPage(title: 'Account Not Found');
        }
        return AppPageTransitions.verticalSlide(state: state, child: child);
      },
    ),
  ];

  if (includeDevelopmentRoutes) {
    routes.add(
      GoRoute(
        path: '/catalog',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const WidgetCatalogView(),
        ),
      ),
    );
  }

  return routes;
}
