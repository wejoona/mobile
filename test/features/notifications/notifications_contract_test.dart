import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/domain/entities/notification.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/notifications/notification_handler.dart';
import 'package:usdc_wallet/services/notifications/notifications_service.dart';
import 'package:usdc_wallet/services/notifications/rich_notification_helper.dart';

import '../../helpers/test_utils.dart';

void main() {
  test('notificationsProvider parses backend data envelope', () async {
    final dio = MockDio()
      ..queueResponse({
        'success': true,
        'data': [
          {
            'id': 'notif-1',
            'category': 'security',
            'title': 'New login',
            'body': 'Your account was accessed from a new device.',
            'data': {'deviceId': 'device-1'},
            'readAt': null,
            'createdAt': DateTime.utc(2026, 6, 2).toIso8601String(),
          },
        ],
        'meta': {'total': 1, 'page': 1, 'limit': 20},
      });
    final container = ProviderContainer(
      overrides: [dioProvider.overrideWithValue(dio)],
    );
    addTearDown(container.dispose);

    final notifications = await container.read(notificationsProvider.future);

    final request = dio.requestHistory.singleWhere(
      (entry) => entry.path == '/notifications',
    );
    expect(request.path, '/notifications');
    expect(request.queryParameters['limit'], 100);
    expect(request.queryParameters['offset'], 0);
    expect(request.queryParameters.containsKey('page'), isFalse);
    expect(notifications, hasLength(1));
    expect(notifications.single.type, NotificationType.security);
    expect(notifications.single.isRead, isFalse);
    expect(notifications.single.data?['deviceId'], 'device-1');
  });

  test(
    'notification providers preserve last-known backend feed on failure',
    () async {
      final dio = MockDio()
        ..queueResponse({
          'notifications': [
            {
              'id': 'notif-cached',
              'type': 'security_alert',
              'title': 'Security alert',
              'body': 'A new device signed in.',
              'readAt': null,
              'createdAt': DateTime.utc(2026, 6, 16).toIso8601String(),
            },
          ],
        })
        ..queueResponse({
          'data': {'count': 1},
        })
        ..queueErrorResponse(statusCode: 503, message: 'unavailable')
        ..queueErrorResponse(statusCode: 503, message: 'unavailable');
      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      final notifications = await container.read(notificationsProvider.future);
      final unreadCount = await container.read(
        unreadNotificationCountProvider.future,
      );

      expect(notifications.single.id, 'notif-cached');
      expect(unreadCount, 1);
      expect(container.read(lastKnownNotificationsProvider), hasLength(1));
      expect(container.read(lastKnownUnreadNotificationCountProvider), 1);

      final notificationsSub = container.listen(
        notificationsProvider,
        (_, _) {},
        fireImmediately: true,
      );
      final unreadSub = container.listen(
        unreadNotificationCountProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(notificationsSub.close);
      addTearDown(unreadSub.close);

      container
        ..invalidate(notificationsProvider)
        ..invalidate(unreadNotificationCountProvider);

      await Future<void>.delayed(Duration.zero);

      expect(
        dio.requestHistory
            .where((entry) => entry.path == '/notifications')
            .length,
        greaterThanOrEqualTo(2),
      );
      expect(
        dio.requestHistory
            .where((entry) => entry.path == '/notifications/unread-count')
            .length,
        greaterThanOrEqualTo(2),
      );

      expect(container.read(lastKnownNotificationsProvider), hasLength(1));
      expect(
        container.read(lastKnownNotificationsProvider).single.id,
        'notif-cached',
      );
      expect(container.read(lastKnownUnreadNotificationCountProvider), 1);
    },
  );

  test('notification action payload resolves mobile navigation targets', () {
    final transactionNotification = AppNotification.fromJson({
      'id': 'notif-transaction',
      'type': 'transfer_received',
      'action': 'open_transaction',
      'title': 'Payment received',
      'body': 'You received 50 USDC.',
      'data': {'transactionId': 'txn_123'},
      'referenceType': 'transaction',
      'referenceId': 'txn_123',
      'createdAt': DateTime.utc(2026, 6, 4).toIso8601String(),
      'isUnread': true,
    });
    final securityNotification = AppNotification.fromJson({
      'id': 'notif-security',
      'type': 'security_alert',
      'action': 'open_security',
      'title': 'New device',
      'body': 'A new device signed in.',
      'createdAt': DateTime.utc(2026, 6, 4).toIso8601String(),
      'isUnread': true,
    });
    final safeDeepLink = AppNotification.fromJson({
      'id': 'notif-link',
      'type': 'system',
      'action': 'none',
      'title': 'Review transaction',
      'body': 'Tap to review.',
      'actionUrl': '/transactions/txn_safe',
      'createdAt': DateTime.utc(2026, 6, 4).toIso8601String(),
      'isUnread': true,
    });
    final externalLink = AppNotification.fromJson({
      'id': 'notif-external',
      'type': 'system',
      'action': 'none',
      'title': 'External',
      'body': 'Do not open external links from notification payloads.',
      'actionUrl': 'https://example.com/phishing',
      'createdAt': DateTime.utc(2026, 6, 4).toIso8601String(),
      'isUnread': true,
    });
    final sensitiveInternalLink = AppNotification.fromJson({
      'id': 'notif-sensitive',
      'type': 'system',
      'action': 'none',
      'title': 'Sensitive',
      'body': 'Do not open sensitive recovery routes from notification data.',
      'actionUrl': '/pin/reset',
      'createdAt': DateTime.utc(2026, 6, 4).toIso8601String(),
      'isUnread': true,
    });

    expect(transactionNotification.action, 'open_transaction');
    expect(transactionNotification.navigationRoute, '/transactions/txn_123');
    expect(securityNotification.navigationRoute, '/settings/security');
    expect(safeDeepLink.navigationRoute, '/transactions/txn_safe');
    expect(externalLink.navigationRoute, isNull);
    expect(sensitiveInternalLink.navigationRoute, isNull);
  });

  test('push notification tap routes point to live app screens', () {
    expect(
      routeForNotificationData({
        'type': 'transaction',
        'transactionId': 'txn_123',
      }),
      '/transactions/txn_123',
    );
    expect(
      routeForNotificationData({
        'type': 'security',
        'action': 'new_device_login',
      }),
      '/settings/devices',
    );
    expect(
      routeForNotificationData({'type': 'kyc', 'action': 'approved'}),
      '/kyc',
    );
    expect(routeForNotificationData({'type': 'balance'}), '/home');
    expect(
      routeForNotificationData({'type': 'security', 'route': '/pin/reset'}),
      '/settings/security',
    );
    expect(
      routeForNotificationData({'type': 'system', 'actionUrl': '/pin/reset'}),
      '/notifications',
    );
  });

  test('rich notification quick actions avoid unwired routes', () {
    final rich = RichNotificationHelper.format(
      AppNotification(
        id: 'notif-address',
        title: 'Address approved',
        body: 'Your address was added.',
        type: NotificationType.addressWhitelisted,
        createdAt: DateTime.utc(2026, 6, 11),
      ),
    );

    expect(rich.actions.single.route, '/settings/security');
  });

  test('notification actions use live PUT routes', () async {
    final dio = MockDio()
      ..queueResponse(null, statusCode: 204)
      ..queueResponse(null, statusCode: 204);
    final container = ProviderContainer(
      overrides: [dioProvider.overrideWithValue(dio)],
    );
    addTearDown(container.dispose);
    final actions = container.read(notificationActionsProvider);

    await actions.markAsRead('notif-1');
    await actions.markAllAsRead();

    expect(dio.requestHistory[0].method, 'PUT');
    expect(dio.requestHistory[0].path, '/notifications/notif-1/read');
    expect(dio.requestHistory[1].method, 'PUT');
    expect(dio.requestHistory[1].path, '/notifications/read-all');
  });

  test('notifications feed parses live backend route envelope', () async {
    final dio = MockDio()
      ..queueResponse({
        'notifications': [
          {
            'id': 'notif-live-1',
            'type': 'transfer_received',
            'presentationType': 'transfer',
            'severity': 'success',
            'action': 'open_transaction',
            'status': 'delivered',
            'title': 'Payment received',
            'body': 'You received 25 USDC.',
            'data': {'transactionId': 'txn_live_1'},
            'referenceType': 'transaction',
            'referenceId': 'txn_live_1',
            'sentAt': DateTime.utc(2026, 6, 12).toIso8601String(),
            'deliveredAt': DateTime.utc(2026, 6, 12).toIso8601String(),
            'readAt': null,
            'createdAt': DateTime.utc(2026, 6, 12).toIso8601String(),
            'isUnread': true,
          },
        ],
        'meta': {'total': 1, 'page': 1, 'limit': 50},
      });
    final service = NotificationsService(dio);

    final notifications = await service.getNotifications();

    expect(dio.requestHistory.single.path, '/notifications');
    expect(dio.requestHistory.single.queryParameters, {
      'limit': 50,
      'offset': 0,
    });
    expect(notifications, hasLength(1));
    expect(notifications.single.navigationRoute, '/transactions/txn_live_1');
  });

  test('notifications feed paginates with backend offset contract', () async {
    final dio = MockDio()..queueResponse({'notifications': [], 'total': 0});
    final service = NotificationsService(dio);

    await service.getNotifications(page: 2, pageSize: 25);

    expect(dio.requestHistory.single.path, '/notifications');
    expect(dio.requestHistory.single.queryParameters, {
      'limit': 25,
      'offset': 25,
    });
    expect(
      dio.requestHistory.single.queryParameters.containsKey('page'),
      isFalse,
    );
  });

  test('FCM token removal uses the live device-token route', () async {
    final dio = MockDio()..queueResponse(null, statusCode: 204);
    final service = NotificationsService(dio);

    await service.removeFcmToken('abc/def:ghi');

    expect(dio.requestHistory.single.method, 'DELETE');
    expect(
      dio.requestHistory.single.path,
      '/notifications/device-token/abc%2Fdef%3Aghi',
    );
  });

  test('bulk push token cleanup is not exposed by the live API', () async {
    final dio = MockDio();
    final service = NotificationsService(dio);

    await expectLater(
      service.removeAllFcmTokens(),
      throwsA(isA<UnsupportedError>()),
    );

    expect(dio.requestHistory, isEmpty);
  });

  test('OS notification permission is requested only from consent screen', () {
    final root = Directory.current.path;
    final permissionProvider = File(
      '$root/lib/features/notifications/providers/notification_permission_provider.dart',
    ).readAsStringSync();
    final handler = File(
      '$root/lib/services/notifications/notification_handler.dart',
    ).readAsStringSync();
    final pushService = File(
      '$root/lib/services/notifications/push_notification_service.dart',
    ).readAsStringSync();

    expect(permissionProvider, contains('initialize(requestPermission: true)'));
    expect(handler, isNot(contains('requestPermission: true')));
    expect(
      pushService,
      contains('Future<void> initialize({bool requestPermission = false})'),
    );
  });
}
