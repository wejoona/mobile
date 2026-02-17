import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/bank_linking/providers/link_bank_provider.dart';
import 'package:usdc_wallet/config/west_african_banks.dart';
import 'package:usdc_wallet/design/theme/spacing.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Link bank account screen.
class LinkBankScreen extends ConsumerStatefulWidget {
  const LinkBankScreen({super.key});

  @override
  ConsumerState<LinkBankScreen> createState() => _LinkBankScreenState();
}

class _LinkBankScreenState extends ConsumerState<LinkBankScreen> {
  final _accountController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(linkBankProvider);
    final notifier = ref.read(linkBankProvider.notifier);

    ref.listen<LinkBankState>(linkBankProvider, (_, next) {
      if (next.isComplete) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bankLinking_linkSuccess)));
        Navigator.pop(context, true);
        notifier.reset();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bankLinking_linkAccount)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.bankLinking_selectBank, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),

            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: WestAfricanBanks.ivoireBanks.length,
                itemBuilder: (context, index) {
                  final bank = WestAfricanBanks.ivoireBanks[index];
                  final selected = state.selectedBank == bank;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () => notifier.selectBank(bank),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                            width: selected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: selected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance, color: selected ? Theme.of(context).colorScheme.primary : Colors.grey),
                            const SizedBox(height: AppSpacing.xs),
                            Text(bank.code, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (state.selectedBank != null) ...[
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _accountController,
                decoration: const InputDecoration(
                  labelText: 'Numero de compte',
                  prefixIcon: Icon(Icons.numbers),
                ),
                onChanged: notifier.setAccountNumber,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du titulaire',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                onChanged: notifier.setAccountName,
              ),
            ],

            const Spacer(),

            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),

            FilledButton(
              onPressed: state.selectedBank != null && state.accountNumber != null && !state.isLoading
                  ? () => notifier.link()
                  : null,
              child: state.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(l10n.bankLinking_linkAccount),
            ),
          ],
        ),
      ),
    );
  }
}
