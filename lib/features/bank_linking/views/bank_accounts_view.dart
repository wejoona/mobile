import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/bank_linking/providers/bank_accounts_provider.dart';
import 'package:usdc_wallet/features/bank_linking/widgets/bank_account_card.dart';
import 'package:usdc_wallet/design/components/primitives/empty_state.dart';
import 'package:usdc_wallet/design/components/primitives/confirmation_dialog.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Bank accounts list screen.
class BankAccountsView extends ConsumerWidget {
  const BankAccountsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final accountsAsync = ref.watch(bankAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bankLinking_accounts),
        actions: [IconButton(icon: const Icon(Icons.add_rounded), tooltip: 'Ajouter un compte', onPressed: () {})],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.common_errorFormat(e.toString()))),
        data: (accounts) {
          if (accounts.isEmpty) {
            return const EmptyState(
              icon: Icons.account_balance_rounded,
              title: 'No bank accounts linked',
              subtitle: 'Link a bank account to withdraw funds to your local bank',
              actionLabel: 'Link Account',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(bankAccountsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: accounts.length,
              itemBuilder: (_, i) {
                final account = accounts[i];
                return BankAccountCard(
                  account: account,
                  onRemove: () async {
                    final confirmed = await ConfirmationDialog.show(context,
                      title: 'Remove Account',
                      message: 'Remove ${account.bankName} (${account.maskedAccount})?',
                      confirmLabel: 'Remove',
                      isDestructive: true,
                    );
                    if (confirmed) {
                      final actions = ref.read(bankAccountActionsProvider);
                      await actions.remove(account.id);
                      ref.invalidate(bankAccountsProvider);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
