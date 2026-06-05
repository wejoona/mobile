import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Empty state for deposit methods when none are available.
class DepositEmptyState extends StatelessWidget {
  const DepositEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return EmptyState(
      icon: Icons.account_balance_wallet_outlined,
      title: l10n.deposit_noProvidersAvailable,
      description: l10n.deposit_noProvidersAvailableDesc,
    );
  }
}
