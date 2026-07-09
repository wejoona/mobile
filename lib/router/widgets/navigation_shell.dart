import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/connectivity/connectivity_provider.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_extensions.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_provider.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Navigation shell for bottom navigation - derives state from current route.
class MainShell extends ConsumerWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  /// Get selected index from the current route location.
  int _getSelectedIndex(String location) {
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/cards')) {
      return 1;
    }
    if (location.startsWith('/transactions')) {
      return 2;
    }
    if (location.startsWith('/settings')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current location from GoRouter.
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _getSelectedIndex(location);
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final flags = ref.watch(featureFlagsProvider);
    final showCardsBadge = flags.canUseVirtualCards;

    return Scaffold(
      body: Column(
        children: [
          const _ConnectivityBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.container,
          border: Border(
            top: BorderSide(color: colors.borderSubtle),
          ),
          boxShadow: colors.isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0x245A431B),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                    spreadRadius: -8,
                  ),
                ],
        ),
        child: NavigationBar(
          backgroundColor: colors.container,
          indicatorColor: colors.gold.withValues(
            alpha: colors.isDark ? 0.14 : 0.18,
          ),
          surfaceTintColor: Colors.transparent,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
          // Navigate based on index.
          switch (index) {
            case 0:
              context.fsmGo('/home');
              break;
            case 1:
              context.fsmGo('/cards');
              break;
            case 2:
              context.fsmGo('/transactions');
              break;
            case 3:
              context.fsmGo('/settings');
              break;
          }
          },
          destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navigation_home,
          ),
          NavigationDestination(
            icon: showCardsBadge
                ? Badge(
                    backgroundColor: colors.warning,
                    smallSize: 8,
                    child: const Icon(Icons.credit_card_outlined),
                  )
                : const Icon(Icons.credit_card_outlined),
            selectedIcon: showCardsBadge
                ? Badge(
                    backgroundColor: colors.warning,
                    smallSize: 8,
                    child: const Icon(Icons.credit_card),
                  )
                : const Icon(Icons.credit_card),
            label: l10n.navigation_cards,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_rounded),
            selectedIcon: const Icon(Icons.history),
            label: l10n.navigation_history,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navigation_settings,
          ),
          ],
        ),
      ),
    );
  }
}

/// Thin connectivity banner shown at top when offline.
class _ConnectivityBanner extends ConsumerWidget {
  const _ConnectivityBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(connectivityProvider);
    if (state.isOnline) {
      return const SizedBox.shrink();
    }
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.errorBg,
        border: Border(
          bottom: BorderSide(
            color: colors.error.withValues(alpha: colors.isDark ? 0.28 : 0.32),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: colors.errorText, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: AppText(
              l10n.offline_noConnection,
              variant: AppTextVariant.labelMedium,
              color: colors.errorText,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Auth-gated shell: wraps MainShell and avoids a home flash during redirects.
class AuthGatedShell extends ConsumerWidget {
  const AuthGatedShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return PopScope(
      canPop: false,
      child: authState.isAuthenticated
          ? MainShell(child: child)
          : Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
    );
  }
}
