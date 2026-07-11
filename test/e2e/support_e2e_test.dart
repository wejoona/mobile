/// E2E: authenticated Korido support request lifecycle.
library;

import 'package:test/test.dart';

import 'e2e_test_client.dart';

void main() {
  if (!e2eEnabled) {
    skipE2ESuite();
    return;
  }
  if (!runLiveE2E) {
    test('Live E2E disabled', () {}, skip: liveE2ESkipReason);
    return;
  }

  late E2EClient client;
  late String ticketId;

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(uniqueE2EPhone());
  });

  test('support ticket lifecycle is durable and private', () async {
    final create = await client.post('/support/tickets', {
      'subject': 'Korido live support proof',
      'category': 'technical',
      'priority': 'medium',
      'message': 'Actor-visible support request created by the staging proof.',
    });
    expect(create.statusCode, 201);
    final created = create.data?['data'] ?? create.data;
    ticketId = created?['id']?.toString() ?? '';
    expect(ticketId, isNotEmpty);
    expect(created?['status'], 'open');

    final detail = await client.get('/support/tickets/$ticketId');
    detail.expectOk();
    final ticket = detail.data?['data'] ?? detail.data;
    expect(ticket?['subject'], 'Korido live support proof');

    final message = await client.post('/support/tickets/$ticketId/messages', {
      'message': 'Follow-up evidence remains linked to the same request.',
    });
    expect(message.statusCode, 201);

    final list = await client.get('/support/tickets');
    list.expectOk();
    final payload = list.data?['data'] ?? list.data;
    final tickets = payload?['tickets'] as List<dynamic>? ?? const [];
    expect(tickets.any((item) => item['id'] == ticketId), isTrue);

    final anonymous = await E2EClient().get('/support/tickets');
    expect(anonymous.statusCode, 401);

    final close = await client.patch('/support/tickets/$ticketId/close', {});
    close.expectOk();
    final closed = close.data?['data'] ?? close.data;
    expect(closed?['status'], 'closed');
  });
}
