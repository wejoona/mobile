import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart'
    as notifications;

/// Run 360: Unread notification count provider with auto-refresh
final unreadNotificationCountProvider = Provider<int>(
  (ref) => ref.watch(notifications.lastKnownUnreadNotificationCountProvider),
);

final refreshUnreadNotificationCountProvider = Provider<Future<int> Function()>(
  (ref) =>
      () => _refreshUnreadNotificationCount(ref),
);

Future<int> _refreshUnreadNotificationCount(Ref ref) async {
  try {
    final count = await ref.read(
      notifications.unreadNotificationCountProvider.future,
    );
    _writeUnreadCountAfterBuild(ref, count);
    return count;
  } on Object {
    return ref.read(notifications.lastKnownUnreadNotificationCountProvider);
  }
}

/// Provider that periodically polls for new notifications
final notificationPollingProvider = Provider<void>((ref) {
  void refresh() {
    _runAfterBuild(ref, () {
      ref
        ..invalidate(notifications.notificationsProvider)
        ..invalidate(notifications.unreadNotificationCountProvider);
      unawaited(ref.read(refreshUnreadNotificationCountProvider)());
    });
  }

  final initialRefresh = Timer(const Duration(milliseconds: 250), refresh);
  final timer = Timer.periodic(const Duration(minutes: 2), (_) => refresh());

  ref.onDispose(() {
    initialRefresh.cancel();
    timer.cancel();
  });
});

void _writeUnreadCountAfterBuild(Ref ref, int count) {
  _runAfterBuild(ref, () {
    ref
            .read(
              notifications.lastKnownUnreadNotificationCountProvider.notifier,
            )
            .state =
        count;
  });
}

void _runAfterBuild(Ref ref, void Function() action) {
  void run() {
    if (!ref.mounted) {
      return;
    }
    action();
  }

  final scheduler = SchedulerBinding.instance;
  final phase = scheduler.schedulerPhase;
  if (phase == SchedulerPhase.idle ||
      phase == SchedulerPhase.postFrameCallbacks) {
    scheduleMicrotask(run);
  } else {
    scheduler.addPostFrameCallback((_) => run());
  }
}
