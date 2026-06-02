import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/features/recurring_transfers/views/create_recurring_transfer_view.dart';
import 'package:usdc_wallet/features/recurring_transfers/views/recurring_transfer_detail_view.dart';
import 'package:usdc_wallet/features/recurring_transfers/views/recurring_transfers_list_view.dart';
import 'package:usdc_wallet/features/savings_pots/views/create_pot_view.dart';
import 'package:usdc_wallet/features/savings_pots/views/edit_pot_view.dart';
import 'package:usdc_wallet/features/savings_pots/views/pot_detail_view.dart';
import 'package:usdc_wallet/features/savings_pots/views/pots_list_view.dart';
import 'package:usdc_wallet/router/page_transitions.dart';

List<RouteBase> savingsRecurringRoutes() => [
  // Savings Pots Routes
  GoRoute(
    path: '/savings-pots',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const PotsListView()),
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
];
