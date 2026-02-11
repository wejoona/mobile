import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/savings_pots/providers/create_pot_provider.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/design/theme/spacing.dart';

/// Create savings pot screen — wired to CreatePotNotifier.
class CreatePotScreen extends ConsumerStatefulWidget {
  const CreatePotScreen({super.key});

  @override
  ConsumerState<CreatePotScreen> createState() => _CreatePotScreenState();
}

class _CreatePotScreenState extends ConsumerState<CreatePotScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPotProvider);
    final notifier = ref.read(createPotProvider.notifier);

    ref.listen<CreatePotState>(createPotProvider, (_, next) {
      if (next.isComplete) {
        Navigator.pop(context, true);
        notifier.reset();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createPot)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppStrings.potName,
                hintText: 'Ex: Vacances, Urgence...',
                prefixIcon: const Icon(Icons.savings_outlined),
              ),
              onChanged: notifier.setName,
            ),
            const SizedBox(height: AppSpacing.md),

            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: '${AppStrings.targetAmount} (optionnel)',
                hintText: '0.00',
                prefixIcon: const Icon(Icons.flag_outlined),
                suffixText: 'USDC',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) {
                final amount = double.tryParse(v);
                if (amount != null) notifier.setTargetAmount(amount);
              },
            ),
            const SizedBox(height: AppSpacing.md),

            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(state.targetDate != null
                  ? 'Date cible: ${state.targetDate!.day}/${state.targetDate!.month}/${state.targetDate!.year}'
                  : 'Date cible (optionnel)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (date != null) notifier.setTargetDate(date);
              },
            ),

            const Spacer(),

            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),

            FilledButton(
              onPressed: !state.isLoading ? () => notifier.create() : null,
              child: state.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Creer la cagnotte'),
            ),
          ],
        ),
      ),
    );
  }
}
