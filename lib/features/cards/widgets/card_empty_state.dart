import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Empty state when user has no virtual cards.
class CardEmptyState extends StatelessWidget {
  const CardEmptyState({super.key, this.onCreateCard});

  final VoidCallback? onCreateCard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return EmptyState(
      icon: Icons.credit_card_outlined,
      title: l10n.cards_noCards,
      description: l10n.cards_noCardsDescription,
      action: onCreateCard != null
          ? EmptyStateAction(
              label: l10n.cards_createCard,
              onPressed: onCreateCard!,
            )
          : null,
    );
  }
}
