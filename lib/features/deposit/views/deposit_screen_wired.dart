import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';

/// Fully wired deposit screen.
class DepositScreenWired extends ConsumerStatefulWidget {
  const DepositScreenWired({super.key});

  @override
  ConsumerState<DepositScreenWired> createState() => _DepositScreenWiredState();
}

class _DepositScreenWiredState extends ConsumerState<DepositScreenWired> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(depositProvider);
    final notifier = ref.read(depositProvider.notifier);

    if (state.result != null) {
      return _ResultScreen(
        result: state.result!,
        onDone: () {
          notifier.reset();
          Navigator.pop(context);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.deposit)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.selectProvider,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),

            // Provider selection
            ...DepositMethod.values.map(
              (method) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: Icon(
                    method == DepositMethod.bankTransfer
                        ? Icons.account_balance
                        : Icons.phone_android,
                  ),
                  title: Text(method.label),
                  trailing: state.selectedMethod == method
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  selected: state.selectedMethod == method,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: state.selectedMethod == method
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  onTap: () => notifier.selectMethod(method),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Amount
            if (state.selectedMethod != null) ...[
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: AppStrings.depositAmount,
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'USDC',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) {
                  final amount = double.tryParse(v);
                  if (amount != null) {
                    notifier.setAmount(amount);
                  }
                },
              ),
            ],

            const Spacer(),

            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),

            AppButton(
              label: AppStrings.deposit,
              onPressed:
                  state.selectedMethod != null &&
                      state.amount != null &&
                      !state.isLoading
                  ? notifier.initiate
                  : null,
              isLoading: state.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultScreen extends StatelessWidget {
  const _ResultScreen({
    required DepositResult result,
    required VoidCallback onDone,
  }) : _result = result,
       _onDone = onDone;

  final DepositResult _result;
  final VoidCallback _onDone;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppStrings.deposit)),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Icon(
              _result.status == 'pending'
                  ? Icons.hourglass_top
                  : Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _result.status == 'pending'
                  ? 'Depot en cours de traitement'
                  : AppStrings.success,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_result.reference != null) ...[
              const SizedBox(height: AppSpacing.sm),
              SelectableText(
                'Référence : ${_result.reference}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (_result.instructions != null) ...[
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SelectableText(_result.instructions!),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: AppStrings.done,
              onPressed: _onDone,
              isFullWidth: true,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    ),
  );
}
