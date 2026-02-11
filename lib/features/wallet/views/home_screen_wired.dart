import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';
import '../providers/balance_provider.dart';
import '../providers/balance_visibility_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/error/error_handler.dart';
import '../../../design/theme/spacing.dart';

/// Wired home screen with real data from providers.
class HomeScreenWired extends ConsumerWidget {
  const HomeScreenWired({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider);
    final balanceAsync = ref.watch(walletBalanceProvider);
    final isVisible = ref.watch(balanceVisibilityProvider);
    final toggle = ref.watch(toggleBalanceVisibilityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          if (home.unreadNotifications > 0)
            Badge(
              label: Text('${home.unreadNotifications}'),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletBalanceProvider);
          ref.invalidate(notificationsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Balance card
            balanceAsync.when(
              data: (balance) => _BalanceCard(
                balance: balance,
                isVisible: isVisible,
                onToggle: toggle,
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(ErrorHandler.getMessage(e), style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Quick actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _QuickAction(icon: Icons.arrow_upward, label: AppStrings.send, onTap: () => Navigator.pushNamed(context, '/send')),
                _QuickAction(icon: Icons.arrow_downward, label: AppStrings.receive, onTap: () => Navigator.pushNamed(context, '/receive')),
                _QuickAction(icon: Icons.add, label: AppStrings.deposit, onTap: () => Navigator.pushNamed(context, '/deposit')),
                _QuickAction(icon: Icons.qr_code_scanner, label: 'Scan', onTap: () => Navigator.pushNamed(context, '/scan')),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Alerts
            ...home.visibleAlerts.map((alert) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                color: alert.type.name == 'warning' ? Colors.orange.shade50 : Colors.blue.shade50,
                child: ListTile(
                  title: Text(alert.title),
                  subtitle: Text(alert.message),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            )),

            // Recent transactions header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.recentTransactions, style: Theme.of(context).textTheme.titleMedium),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/transactions'),
                    child: Text(AppStrings.seeAll),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final WalletBalance balance;
  final bool isVisible;
  final Future<void> Function() onToggle;

  const _BalanceCard({required this.balance, required this.isVisible, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.balance, style: Theme.of(context).textTheme.bodySmall),
                IconButton(
                  icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, size: 20),
                  onPressed: onToggle,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isVisible ? '\$${balance.available.toStringAsFixed(2)}' : '\$****',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (balance.pending > 0 && isVisible) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('En attente: \$${balance.pending.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
