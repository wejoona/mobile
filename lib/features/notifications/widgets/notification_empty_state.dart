import 'package:flutter/material.dart';
import '../../../design/components/states/empty_state.dart';

/// Empty state for notifications.
class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.notifications_none_outlined,
      title: 'No notifications',
      description: 'You are all caught up! New notifications will appear here.',
    );
  }
}
