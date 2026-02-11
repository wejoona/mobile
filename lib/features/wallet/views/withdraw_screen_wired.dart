import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/wallet/providers/withdraw_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/design/theme/spacing.dart';

/// Fully wired withdrawal screen.
class WithdrawScreenWired extends ConsumerStatefulWidget {
  const WithdrawScreenWired({super.key});

  @override
  ConsumerState<WithdrawScreenWired> createState() => _WithdrawScreenWiredState();
}

class _WithdrawScreenWiredState extends ConsumerState<WithdrawScreenWired> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(withdrawProvider);
    final notifier = ref.read(withdrawProvider.notifier);
    final balance = ref.watch(availableBalanceProvider);

    if (state.result != null) {
      return _WithdrawResult(result: state.result!, onDone: () {
        notifier.reset();
        Navigator.pop(context);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.withdraw)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Solde: \$${balance.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),

            Text('Methode de retrait', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),

            Wrap(
              spacing: AppSpacing.sm,
              children: WithdrawMethod.values.map((m) => ChoiceChip(
                label: Text(m.label),
                selected: state.method == m,
                onSelected: (_) => notifier.selectMethod(m),
              )).toList(),
            ),

            if (state.method != null) ...[
              const SizedBox(height: AppSpacing.lg),

              if (state.method != WithdrawMethod.bankTransfer)
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Numero ${state.method!.label}',
                    hintText: '${state.method!.prefix} XX XX XX XX',
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: notifier.setPhoneNumber,
                ),

              const SizedBox(height: AppSpacing.md),

              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: AppStrings.amount,
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: 'USDC',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  final amount = double.tryParse(v);
                  if (amount != null) notifier.setAmount(amount);
                },
              ),

              if (state.fee > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.fee, style: Theme.of(context).textTheme.bodySmall),
                    Text('\$${state.fee.toStringAsFixed(4)}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.total, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text('\$${state.total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ],

            const Spacer(),

            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),

            FilledButton(
              onPressed: state.method != null && state.amount != null && !state.isLoading
                  ? () => notifier.submit()
                  : null,
              child: state.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(AppStrings.withdraw),
            ),
          ],
        ),
      ),
    );
  }
}

class _WithdrawResult extends StatelessWidget {
  final WithdrawResult result;
  final VoidCallback onDone;

  const _WithdrawResult({required this.result, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: AppSpacing.md),
            Text('Retrait initie', style: Theme.of(context).textTheme.headlineSmall),
            if (result.reference != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Ref: ${result.reference}'),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(onPressed: onDone, child: Text(AppStrings.done)),
          ],
        ),
      ),
    );
  }
}
