import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// Contacts mock service.
class ContactsMock {
  static void register(MockInterceptor interceptor) {
    // GET /contacts
    interceptor.register(
      method: 'GET',
      path: '/contacts',
      handler: (uri, headers, data) async {
        return MockResponse(200, {
          'data': [
            {'id': 'ct_001', 'name': 'Amadou Diallo', 'phone': '+22507080910', 'identifier': '+22507080910', 'identifierType': 'phone', 'isKoridoUser': true, 'avatarUrl': null, 'isFavorite': true, 'createdAt': '2026-01-10T08:00:00Z'},
            {'id': 'ct_002', 'name': 'Fatou Koné', 'phone': '+22505060708', 'identifier': '+22505060708', 'identifierType': 'phone', 'isKoridoUser': true, 'avatarUrl': null, 'isFavorite': true, 'createdAt': '2026-01-12T10:30:00Z'},
            {'id': 'ct_003', 'name': 'Ibrahim Touré', 'phone': '+22501020304', 'identifier': '+22501020304', 'identifierType': 'phone', 'isKoridoUser': false, 'avatarUrl': null, 'isFavorite': false, 'createdAt': '2026-01-15T14:00:00Z'},
            {'id': 'ct_004', 'name': 'Mariam Bamba', 'phone': '+22507112233', 'identifier': '+22507112233', 'identifierType': 'phone', 'isKoridoUser': true, 'avatarUrl': null, 'isFavorite': false, 'createdAt': '2026-01-20T09:00:00Z'},
            {'id': 'ct_005', 'name': 'Youssouf Cissé', 'phone': '+22505443322', 'identifier': '+22505443322', 'identifierType': 'phone', 'isKoridoUser': false, 'avatarUrl': null, 'isFavorite': false, 'createdAt': '2026-02-01T16:00:00Z'},
          ],
          'meta': {'total': 5, 'page': 1, 'limit': 20},
        });
      },
    );

    // POST /contacts/sync
    interceptor.register(
      method: 'POST',
      path: '/contacts/sync',
      handler: (uri, headers, data) async {
        return MockResponse(200, {'synced': 5, 'newKoridoUsers': 2, 'message': 'Contacts synced'});
      },
    );

    // POST /contacts/invite
    interceptor.register(
      method: 'POST',
      path: '/contacts/invite',
      handler: (uri, headers, data) async {
        return MockResponse(200, {'success': true, 'message': 'Invitation sent'});
      },
    );
  }
}
