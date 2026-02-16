import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/savings_pots/providers/savings_pots_provider.dart';
import 'package:usdc_wallet/features/savings_pots/widgets/savings_pot_card.dart';
import 'package:usdc_wallet/features/savings_pots/widgets/create_pot_sheet.dart';
import 'package:usdc_wallet/design/components/primitives/empty_state.dart';
import 'package:usdc_wallet/design/components/primitives/shimmer_loading.dart';

/// Savings pots list screen.
class SavingsPotsListView extends ConsumerWidget {
  const SavingsPotsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final potsAsync = ref.watch(savingsPotsProvider);
    final totalSavings = ref.watch(totalSavingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Pots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateSheet(context, ref),
          ),
        ],
      ),
      body: potsAsync.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: ShimmerList(itemCount: 3)),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (pots) {
          if (pots.isEmpty) {
            return EmptyState(
              icon: Icons.savings_rounded,
              title: 'No savings pots yet',
              subtitle: 'Create a pot to start saving toward your goals',
              actionLabel: 'Create Pot',
              onAction: () => _showCreateSheet(context, ref),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(savingsPotsProvider.future),
            child: ListView(
              children: [
                // Total savings header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Total Savings', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text('\$${totalSavings.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ...pots.map((pot) => SavingsPotCard(pot: pot, onTap: () {})),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => CreatePotSheet(
        onCreate: (name, target, date) async {
          final actions = ref.read(savingsPotsActionsProvider);
          await actions.create(name: name, targetAmount: target, targetDate: date);
          ref.invalidate(savingsPotsProvider);
        },
      ),
    );
  }
}
