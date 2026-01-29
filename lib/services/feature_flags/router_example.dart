/// Example: Feature Flag Integration in Router
///
/// This file demonstrates how to integrate feature flags with GoRouter
/// to guard routes and conditionally show navigation items.
///
/// Copy the relevant patterns to your app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'feature_flags_provider.dart';
import 'feature_flags_extensions.dart';

/// Example Router Configuration with Feature Flag Guards
///
/// Usage in lib/router/app_router.dart:
/// ```dart
/// final routerProvider = Provider<GoRouter>((ref) {
///   final authState = ref.watch(authProvider);
///   final flags = ref.watch(featureFlagsProvider);
///
///   return GoRouter(
///     initialLocation: '/splash',
///     redirect: _createRedirect(authState, flags),
///     routes: _createRoutes(),
///   );
/// });
/// ```
class FeatureFlagRouterExample {
  /// Global redirect logic with feature flag checks
  static String? redirect(
    BuildContext context,
    GoRouterState state,
    bool isAuthenticated,
    Map<String, bool> flags,
  ) {
    final path = state.uri.path;

    // Auth check first
    if (!isAuthenticated && !_isPublicRoute(path)) {
      return '/login';
    }

    // Feature flag guards - redirect to home if feature disabled
    final featureGuards = {
      '/savings-pots': flags.canUseSavingsPots,
      '/recurring-transfers': flags.canScheduleTransfers,
      '/merchant': flags.canUseMerchantQr,
      '/payment-links': flags.canUsePaymentLinks,
      '/referral': flags.canUseReferralProgram,
      '/external-transfer': flags.canUseExternalTransfers,
      '/bill-payments': flags.canUseBillPayments,
    };

    for (final entry in featureGuards.entries) {
      if (path.startsWith(entry.key) && !entry.value) {
        return '/home'; // Redirect to home if feature disabled
      }
    }

    return null; // No redirect
  }

  static bool _isPublicRoute(String path) {
    return path == '/splash' ||
        path.startsWith('/login') ||
        path.startsWith('/onboarding');
  }

  /// Example routes with feature-gated screens
  static List<RouteBase> createRoutes() {
    return [
      // Public routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPhoneView(),
      ),

      // Main app
      GoRoute(
        path: '/home',
        builder: (context, state) => const WalletHomeScreen(),
        routes: [
          // Savings Pots (guarded by feature flag)
          GoRoute(
            path: 'savings-pots',
            builder: (context, state) => const PotsListView(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreatePotView(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PotDetailView(potId: id);
                },
              ),
            ],
          ),

          // Recurring Transfers (guarded by feature flag)
          GoRoute(
            path: 'recurring-transfers',
            builder: (context, state) => const RecurringTransfersListView(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateRecurringTransferView(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return RecurringTransferDetailView(transferId: id);
                },
              ),
            ],
          ),

          // Merchant QR (guarded by feature flag)
          GoRoute(
            path: 'merchant',
            builder: (context, state) => const MerchantDashboardView(),
            routes: [
              GoRoute(
                path: 'scan',
                builder: (context, state) => const ScanQrView(),
              ),
              GoRoute(
                path: 'qr',
                builder: (context, state) => const MerchantQrView(),
              ),
              GoRoute(
                path: 'transactions',
                builder: (context, state) => const MerchantTransactionsView(),
              ),
            ],
          ),

          // Payment Links (guarded by feature flag)
          GoRoute(
            path: 'payment-links',
            builder: (context, state) => const PaymentLinksListView(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateLinkView(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return LinkDetailView(linkId: id);
                },
              ),
            ],
          ),

          // Referral Program (guarded by feature flag)
          GoRoute(
            path: 'referral',
            builder: (context, state) => const ReferralsView(),
          ),

          // External Transfers (guarded by feature flag)
          GoRoute(
            path: 'external-transfer',
            builder: (context, state) => const AddressInputScreen(),
            routes: [
              GoRoute(
                path: 'amount',
                builder: (context, state) => const ExternalAmountScreen(),
              ),
              GoRoute(
                path: 'confirm',
                builder: (context, state) => const ExternalConfirmScreen(),
              ),
            ],
          ),

          // Bill Payments (guarded by feature flag)
          GoRoute(
            path: 'bill-payments',
            builder: (context, state) => const BillPaymentsView(),
            routes: [
              GoRoute(
                path: ':category',
                builder: (context, state) {
                  final category = state.pathParameters['category']!;
                  return BillPaymentFormView(category: category);
                },
              ),
            ],
          ),
        ],
      ),
    ];
  }
}

/// Example: Bottom Navigation with Feature Flags
class BottomNavExample extends ConsumerWidget {
  const BottomNavExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);

    // Build navigation items based on enabled flags
    final navItems = <BottomNavigationBarItem>[
      // Always visible
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.history),
        label: 'Transactions',
      ),

      // Conditionally visible
      if (flags.canUseMerchantQr)
        const BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),

      if (flags.canUseSavingsPots)
        const BottomNavigationBarItem(
          icon: Icon(Icons.savings),
          label: 'Savings',
        ),

      // Always visible
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];

    return BottomNavigationBar(
      items: navItems,
      currentIndex: 0,
      onTap: (index) {
        // Handle navigation based on visible items
        // Note: Indices change based on enabled flags
      },
    );
  }
}

/// Example: App Drawer with Feature Flags
class AppDrawerExample extends ConsumerWidget {
  const AppDrawerExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text('JoonaPay'),
          ),

          // Always visible
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => context.go('/home'),
          ),
          ListTile(
            leading: const Icon(Icons.send),
            title: const Text('Send Money'),
            onTap: () => context.push('/send'),
          ),

          const Divider(),

          // Services section - only show if any service is enabled
          if (flags.canUseBillPayments || flags.canUseMerchantQr)
            const ListTile(
              title: Text('Services'),
              enabled: false,
            ),

          if (flags.canUseBillPayments)
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Bill Payments'),
              onTap: () => context.push('/home/bill-payments'),
            ),

          if (flags.canUseMerchantQr)
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Merchant QR'),
              onTap: () => context.push('/home/merchant'),
            ),

          const Divider(),

          // Features section
          const ListTile(
            title: Text('Features'),
            enabled: false,
          ),

          if (flags.canUseSavingsPots)
            ListTile(
              leading: const Icon(Icons.savings),
              title: const Text('Savings Pots'),
              onTap: () => context.push('/home/savings-pots'),
            ),

          if (flags.canScheduleTransfers)
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Recurring Transfers'),
              onTap: () => context.push('/home/recurring-transfers'),
            ),

          if (flags.canUsePaymentLinks)
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Payment Links'),
              onTap: () => context.push('/home/payment-links'),
            ),

          if (flags.canUseReferralProgram)
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('Refer & Earn'),
              onTap: () => context.push('/home/referral'),
            ),

          const Divider(),

          // Settings - always visible
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

/// Example: Feature Cards Grid
class FeatureCardsExample extends ConsumerWidget {
  const FeatureCardsExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);

    return GridView.count(
      crossAxisCount: 2,
      children: [
        // Always visible
        _FeatureCard(
          icon: Icons.send,
          label: 'Send',
          onTap: () => context.push('/send'),
        ),
        _FeatureCard(
          icon: Icons.call_received,
          label: 'Receive',
          onTap: () => context.push('/receive'),
        ),

        // Feature-gated cards
        if (flags.canUseBillPayments)
          _FeatureCard(
            icon: Icons.receipt,
            label: 'Bills',
            onTap: () => context.push('/home/bill-payments'),
          ),

        if (flags.canUseMerchantQr)
          _FeatureCard(
            icon: Icons.qr_code_scanner,
            label: 'Scan QR',
            onTap: () => context.push('/home/merchant/scan'),
          ),

        if (flags.canUseSavingsPots)
          _FeatureCard(
            icon: Icons.savings,
            label: 'Savings',
            onTap: () => context.push('/home/savings-pots'),
          ),

        if (flags.canUsePaymentLinks)
          _FeatureCard(
            icon: Icons.link,
            label: 'Payment Links',
            onTap: () => context.push('/home/payment-links'),
          ),

        if (flags.canUseReferralProgram)
          _FeatureCard(
            icon: Icons.card_giftcard,
            label: 'Refer',
            onTap: () => context.push('/home/referral'),
          ),

        if (flags.canScheduleTransfers)
          _FeatureCard(
            icon: Icons.repeat,
            label: 'Recurring',
            onTap: () => context.push('/home/recurring-transfers'),
          ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

// Placeholder views for example
class SplashView extends StatelessWidget {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class LoginPhoneView extends StatelessWidget {
  const LoginPhoneView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class WalletHomeScreen extends StatelessWidget {
  const WalletHomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class PotsListView extends StatelessWidget {
  const PotsListView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class CreatePotView extends StatelessWidget {
  const CreatePotView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class PotDetailView extends StatelessWidget {
  final String potId;
  const PotDetailView({super.key, required this.potId});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class RecurringTransfersListView extends StatelessWidget {
  const RecurringTransfersListView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class CreateRecurringTransferView extends StatelessWidget {
  const CreateRecurringTransferView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class RecurringTransferDetailView extends StatelessWidget {
  final String transferId;
  const RecurringTransferDetailView({super.key, required this.transferId});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class MerchantDashboardView extends StatelessWidget {
  const MerchantDashboardView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class ScanQrView extends StatelessWidget {
  const ScanQrView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class MerchantQrView extends StatelessWidget {
  const MerchantQrView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class MerchantTransactionsView extends StatelessWidget {
  const MerchantTransactionsView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class PaymentLinksListView extends StatelessWidget {
  const PaymentLinksListView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class CreateLinkView extends StatelessWidget {
  const CreateLinkView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class LinkDetailView extends StatelessWidget {
  final String linkId;
  const LinkDetailView({super.key, required this.linkId});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class ReferralsView extends StatelessWidget {
  const ReferralsView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class AddressInputScreen extends StatelessWidget {
  const AddressInputScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class ExternalAmountScreen extends StatelessWidget {
  const ExternalAmountScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class ExternalConfirmScreen extends StatelessWidget {
  const ExternalConfirmScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class BillPaymentsView extends StatelessWidget {
  const BillPaymentsView({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class BillPaymentFormView extends StatelessWidget {
  final String category;
  const BillPaymentFormView({super.key, required this.category});
  @override
  Widget build(BuildContext context) => const Scaffold();
}
