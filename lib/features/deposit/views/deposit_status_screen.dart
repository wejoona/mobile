import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';

/// Deposit Status Screen
///
/// Shows completion or failure state after deposit.
class DepositStatusScreen extends ConsumerWidget {
  const DepositStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(depositProvider);
    final isCompleted = state.step == DepositFlowStep.completed;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.error,
                  size: 48,
                  color: isCompleted ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                isCompleted ? 'Deposit Successful!' : 'Deposit Failed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Details
              if (isCompleted && state.response != null) ...[
                Text(
                  '${state.amountXOF.toStringAsFixed(0)} XOF → ${state.amountUSD.toStringAsFixed(2)} USDC',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your USDC balance has been updated',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],

              if (!isCompleted && state.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.error!,
                    style: TextStyle(color: Colors.red[400]),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 48),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(depositProvider.notifier).reset();
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              if (!isCompleted) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    ref.read(depositProvider.notifier).reset();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
