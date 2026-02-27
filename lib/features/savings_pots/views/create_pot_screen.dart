import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/savings_pots/providers/create_pot_provider.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
        padding: EdgeInsets.all(AppSpacing.md),
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
            SizedBox(height: AppSpacing.md),

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
            SizedBox(height: AppSpacing.md),

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
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),

            AppButton(
              label: l10n.savingsPots_createPot,
              onPressed: !state.isLoading ? () => notifier.create() : null,
              isLoading: state.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
