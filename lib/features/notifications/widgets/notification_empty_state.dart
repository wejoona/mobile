import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Empty state for notifications.
class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return EmptyState(
      icon: Icons.notifications_none_outlined,
      title: l10n.notifications_emptyTitle,
      description: l10n.notifications_emptyMessage,
    );
  }
}
