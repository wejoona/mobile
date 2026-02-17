import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/bill_payments/providers/bill_payment_provider.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/design/theme/spacing.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Wired bill payment screen.
class BillPaymentScreenWired extends ConsumerStatefulWidget {
  const BillPaymentScreenWired({super.key});

  @override
  ConsumerState<BillPaymentScreenWired> createState() => _BillPaymentScreenWiredState();
}

class _BillPaymentScreenWiredState extends ConsumerState<BillPaymentScreenWired> {
  final _subscriberController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _subscriberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(billPaymentProvider);
    final notifier = ref.read(billPaymentProvider.notifier);

    if (state.result != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: AppSpacing.md),
              Text(AppLocalizations.of(context)!.billPayments_paymentComplete, style: Theme.of(context).textTheme.headlineSmall),
              if (state.result!.reference != null)
                Text('${AppLocalizations.of(context)!.billPayments_reference}: ${state.result!.reference}'),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () { notifier.reset(); Navigator.pop(context); },
                child: Text(AppStrings.done),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.billPayments)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context)!.billPayments_category, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: BillCategory.values.map((c) => ChoiceChip(
                label: Text(c.label),
                selected: state.selectedCategory == c,
                avatar: Icon(_categoryIcon(c), size: 18),
                onSelected: (_) => notifier.selectCategory(c),
              )).toList(),
            ),

            if (state.selectedCategory != null) ...[
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _subscriberController,
                decoration: const InputDecoration(
                  labelText: 'Numero abonne / Reference',
                  prefixIcon: Icon(Icons.tag),
                ),
                onChanged: notifier.setSubscriberNumber,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: AppStrings.amount,
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'USDC',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  final amount = double.tryParse(v);
                  if (amount != null) notifier.setAmount(amount);
                },
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),

            FilledButton(
              onPressed: state.selectedCategory != null && state.amount != null && state.subscriberNumber != null && !state.isLoading
                  ? () => notifier.pay()
                  : null,
              child: state.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(AppStrings.payBill),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(BillCategory c) {
    switch (c) {
      case BillCategory.electricity: return Icons.bolt;
      case BillCategory.water: return Icons.water_drop;
      case BillCategory.internet: return Icons.wifi;
      case BillCategory.television: return Icons.tv;
      case BillCategory.telecom: return Icons.phone_android;
      case BillCategory.insurance: return Icons.shield;
    }
  }
}
