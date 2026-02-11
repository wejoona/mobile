import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';
import 'package:usdc_wallet/features/deposit/widgets/deposit_method_tile.dart';
import 'package:usdc_wallet/utils/input_formatters.dart';
import 'package:usdc_wallet/utils/form_validators.dart';
import 'package:usdc_wallet/design/components/primitives/step_indicator.dart';

/// Deposit flow screen (select method -> enter amount -> confirm).
class DepositView extends ConsumerStatefulWidget {
  const DepositView({super.key});

  @override
  ConsumerState<DepositView> createState() => _DepositViewState();
}

class _DepositViewState extends ConsumerState<DepositView> {
  final _amountController = TextEditingController();
  int _step = 0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(depositProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: StepIndicator(totalSteps: 3, currentStep: _step),
          ),
          Expanded(
            child: _step == 0
                ? _buildMethodSelection(state)
                : _step == 1
                    ? _buildAmountEntry(state, theme)
                    : _buildConfirmation(state, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSelection(DepositState state) {
    return ListView(
      padding: const EdgeInsets.only(top: 16),
      children: DepositMethod.values.map((method) {
        return DepositMethodTile(
          method: method,
          isSelected: state.selectedMethod == method,
          onTap: () {
            ref.read(depositProvider.notifier).selectMethod(method);
            setState(() => _step = 1);
          },
        );
      }).toList(),
    );
  }

  Widget _buildAmountEntry(DepositState state, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('How much do you want to deposit?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [AmountInputFormatter()],
            style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              prefixText: '\$ ',
              hintText: '0.00',
              border: InputBorder.none,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  ref.read(depositProvider.notifier).setAmount(amount);
                  setState(() => _step = 2);
                }
              },
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation(DepositState state, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row('Method', state.selectedMethod?.label ?? ''),
                  _row('Amount', '\$${state.amount?.toStringAsFixed(2) ?? '0.00'}'),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isLoading ? null : () => ref.read(depositProvider.notifier).initiate(),
              child: state.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Confirm Deposit'),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(state.error!, style: TextStyle(color: theme.colorScheme.error)),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))],
      ),
    );
  }
}
