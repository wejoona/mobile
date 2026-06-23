import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/features/cards/views/cards_list_view.dart';
import 'package:usdc_wallet/features/services/views/services_view.dart';
import 'package:usdc_wallet/features/settings/views/settings_screen.dart';
import 'package:usdc_wallet/features/transactions/views/transactions_view.dart';
import 'package:usdc_wallet/features/wallet/views/wallet_home_screen.dart';
import 'package:usdc_wallet/router/page_transitions.dart';
import 'package:usdc_wallet/router/widgets/navigation_shell.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

List<RouteBase> primaryShellRoutes() => [
  // Main App Routes (with bottom nav - no animation for tab switching)
  ShellRoute(
    pageBuilder: (context, state, child) => NoTransitionPage(
      key: state.pageKey,
      child: AuthGatedShell(child: child),
    ),
    routes: [
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const _ProtectedRootTab(child: WalletHomeScreen()),
        ),
      ),
      GoRoute(
        path: '/cards',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const _ProtectedRootTab(child: CardsListView()),
        ),
      ),
      GoRoute(
        path: '/transactions',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const _ProtectedRootTab(child: TransactionsView()),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const _ProtectedRootTab(child: SettingsScreen()),
        ),
      ),
    ],
  ),

  // Legacy Services route (kept for backward compatibility)
  GoRoute(
    path: '/services',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const ServicesView()),
  ),

  // Full-screen routes (no bottom nav - vertical slide for modals)
  GoRoute(
    path: '/deposit',
    redirect: (_, _) => '/deposit/amount',
  ),
];

class _ProtectedRootTab extends StatelessWidget {
  const _ProtectedRootTab({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) {
        context.fsmGo('/home');
      }
    },
    child: child,
  );
}
