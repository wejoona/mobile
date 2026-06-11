import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/domain/entities/notification.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart';
import 'package:usdc_wallet/features/notifications/repositories/notifications_repository.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/notifications/notifications_service.dart';

import '../../helpers/test_utils.dart';

void main() {
  test('notificationsProvider parses backend data envelope', () async {
    final dio = MockDio();
    dio.queueResponse({
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

    final request = dio.requestHistory.single;
    expect(request.path, '/notifications');
    expect(request.queryParameters['limit'], 100);
    expect(request.queryParameters['offset'], 0);
    expect(notifications, hasLength(1));
    expect(notifications.single.type, NotificationType.security);
    expect(notifications.single.isRead, isFalse);
    expect(notifications.single.data?['deviceId'], 'device-1');
  });

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

    expect(transactionNotification.action, 'open_transaction');
    expect(transactionNotification.navigationRoute, '/transactions/txn_123');
    expect(securityNotification.navigationRoute, '/settings/security');
    expect(safeDeepLink.navigationRoute, '/transactions/txn_safe');
    expect(externalLink.navigationRoute, isNull);
  });

  test('notification actions use live PUT routes', () async {
    final dio = MockDio();
    dio
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

  test('notifications feed surfaces missing backend route', () async {
    final dio = MockDio()
      ..queueErrorResponse(statusCode: 404, message: 'Not found');
    final service = NotificationsService(dio);

    await expectLater(
      service.getNotifications(),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          404,
        ),
      ),
    );
  });

  test('device token removal encodes path segment', () async {
    final dio = MockDio()..queueResponse(null, statusCode: 204);
    final service = NotificationsService(dio);

    await service.removeFcmToken('abc/def:ghi');

    expect(dio.requestHistory.single.method, 'DELETE');
    expect(
      dio.requestHistory.single.path,
      '/notifications/device-token/abc%2Fdef%3Aghi',
    );
  });
}
