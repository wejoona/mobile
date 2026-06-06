import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Empty state when user has no virtual cards.
class CardEmptyState extends StatelessWidget {
  const CardEmptyState({
    super.key,
    this.onCreateCard,
    this.onNotifyMe,
    this.canCreateCard = true,
    this.reason,
  });

  final VoidCallback? onCreateCard;
  final VoidCallback? onNotifyMe;
  final bool canCreateCard;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unavailable = !canCreateCard;

    return EmptyState(
      icon: Icons.credit_card_outlined,
      title: unavailable ? l10n.cards_comingSoon : l10n.cards_noCards,
      description: unavailable
          ? _unavailableMessage(l10n)
          : l10n.cards_noCardsDescription,
      action: unavailable && onNotifyMe != null
          ? EmptyStateAction(label: l10n.cards_notifyMe, onPressed: onNotifyMe!)
          : onCreateCard != null
          ? EmptyStateAction(
              label: l10n.cards_createCard,
              onPressed: onCreateCard!,
            )
          : null,
    );
  }

  String _unavailableMessage(AppLocalizations l10n) {
    final value = reason;
    if (value == 'provider_or_feature_disabled' ||
        value == 'card_issuing_unavailable') {
      return l10n.cards_notifyDialogMessage;
    }
    return l10n.cards_featureDisabled;
  }
}
