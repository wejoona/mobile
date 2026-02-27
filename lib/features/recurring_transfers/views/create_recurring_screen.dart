import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/recurring_transfer.dart';
import 'package:usdc_wallet/features/recurring_transfers/providers/create_recurring_provider.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Create recurring transfer screen.
class CreateRecurringScreen extends ConsumerStatefulWidget {
  const CreateRecurringScreen({super.key});

  @override
  ConsumerState<CreateRecurringScreen> createState() => _CreateRecurringScreenState();
}

class _CreateRecurringScreenState extends ConsumerState<CreateRecurringScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createRecurringProvider);
    final notifier = ref.read(createRecurringProvider.notifier);

    ref.listen<CreateRecurringState>(createRecurringProvider, (_, next) {
      if (next.isComplete) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.recurringTransfers_created)));
        Navigator.pop(context, true);
        notifier.reset();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.recurringTransfers_title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: AppStrings.recipient,
                hintText: '+225 07 XX XX XX XX',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (v) => notifier.setRecipient(v),
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
            const SizedBox(height: AppSpacing.lg),

            Text(AppLocalizations.of(context)!.recurringTransfers_frequency, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: RecurringFrequency.values.map((f) => ChoiceChip(
                label: Text(_frequencyLabel(f)),
                selected: state.frequency == f,
                onSelected: (_) => notifier.setFrequency(f),
              )).toList(),
            ),

            const SizedBox(height: AppSpacing.lg),

            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text('${AppLocalizations.of(context)!.recurringTransfers_startDate}: ${_formatDate(state.startDate)}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: state.startDate ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (date != null) notifier.setStartDate(date);
              },
            ),

            const SizedBox(height: AppSpacing.md),

            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optionnel)',
                prefixIcon: Icon(Icons.note_outlined),
              ),
              onChanged: notifier.setNote,
            ),

            const SizedBox(height: AppSpacing.xl),

            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),

            AppButton(
              label: AppLocalizations.of(context)!.recurringTransfers_createTransfer,
              isLoading: state.isLoading,
              onPressed: state.recipientPhone != null && state.amount != null && !state.isLoading
                  ? () => notifier.create()
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _frequencyLabel(RecurringFrequency f) {
    switch (f) {
      case RecurringFrequency.daily: return 'Quotidien';
      case RecurringFrequency.weekly: return 'Hebdomadaire';
      case RecurringFrequency.biweekly: return 'Bimensuel';
      case RecurringFrequency.monthly: return 'Mensuel';
      case RecurringFrequency.quarterly: return 'Trimestriel';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Demain';
    return '${date.day}/${date.month}/${date.year}';
  }
}
