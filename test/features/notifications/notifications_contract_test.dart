import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

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

    expect(notifications, hasLength(1));
    expect(notifications.single.type, NotificationType.security);
    expect(notifications.single.isRead, isFalse);
    expect(notifications.single.data?['deviceId'], 'device-1');
  });

  test('notification actions use live PUT routes', () async {
    final dio = MockDio();
    dio
      ..queueResponse(null, statusCode: 204)
      ..queueResponse(null, statusCode: 204);
    final actions = NotificationActions(dio);

    await actions.markAsRead('notif-1');
    await actions.markAllAsRead();

    expect(dio.requestHistory[0].method, 'PUT');
    expect(dio.requestHistory[0].path, '/notifications/notif-1/read');
    expect(dio.requestHistory[1].method, 'PUT');
    expect(dio.requestHistory[1].path, '/notifications/read-all');
  });
}
