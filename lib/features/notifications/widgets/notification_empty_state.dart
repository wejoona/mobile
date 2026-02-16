import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/states/empty_state.dart';

/// Empty state for notifications.
class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.notifications_none_outlined,
      title: 'Aucune notification',
      description: 'Vous êtes à jour ! Les nouvelles notifications apparaîtront ici.',
    );
  }
}
