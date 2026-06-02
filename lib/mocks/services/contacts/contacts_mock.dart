import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// Contacts mock service.
class ContactsMock {
  static void register(MockInterceptor interceptor) {
    // GET /contacts/recents
    interceptor.register(
      method: 'GET',
      path: '/contacts/recents',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(
          statusCode: 200,
          data: {
            'contacts': [
              {
                'phone': '+2250711223344',
                'name': 'Mariam Bamba',
                'lastTransferDate': '2026-05-20T09:00:00Z',
                'lastAmount': 25.0,
                'isKoridoUser': true,
                'joonaPayUserId': 'usr_mariam',
              },
              {
                'phone': '+2250708091011',
                'name': 'Amadou Diallo',
                'lastTransferDate': '2026-05-18T13:30:00Z',
                'lastAmount': 10.0,
                'isKoridoUser': true,
                'joonaPayUserId': 'usr_amadou',
              },
            ],
          },
        );
      },
    );

    // GET /contacts
    interceptor.register(
      method: 'GET',
      path: '/contacts',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(
          statusCode: 200,
          data: {
            'data': [
              {
                'id': 'ct_001',
                'name': 'Amadou Diallo',
                'phone': '+2250708091011',
                'identifier': '+2250708091011',
                'identifierType': 'phone',
                'isKoridoUser': true,
                'joonaPayUserId': 'usr_amadou',
                'avatarUrl': null,
                'isFavorite': true,
                'createdAt': '2026-01-10T08:00:00Z',
              },
              {
                'id': 'ct_002',
                'name': 'Fatou Koné',
                'phone': '+2250506070809',
                'identifier': '+2250506070809',
                'identifierType': 'phone',
                'isKoridoUser': true,
                'joonaPayUserId': 'usr_fatou',
                'avatarUrl': null,
                'isFavorite': true,
                'createdAt': '2026-01-12T10:30:00Z',
              },
              {
                'id': 'ct_003',
                'name': 'Ibrahim Touré',
                'phone': '+2250102030405',
                'identifier': '+2250102030405',
                'identifierType': 'phone',
                'isKoridoUser': false,
                'avatarUrl': null,
                'isFavorite': false,
                'createdAt': '2026-01-15T14:00:00Z',
              },
              {
                'id': 'ct_004',
                'name': 'Mariam Bamba',
                'phone': '+2250711223344',
                'identifier': '+2250711223344',
                'identifierType': 'phone',
                'isKoridoUser': true,
                'joonaPayUserId': 'usr_mariam',
                'avatarUrl': null,
                'isFavorite': false,
                'createdAt': '2026-01-20T09:00:00Z',
              },
              {
                'id': 'ct_005',
                'name': 'Youssouf Cissé',
                'phone': '+2250544332211',
                'identifier': '+2250544332211',
                'identifierType': 'phone',
                'isKoridoUser': false,
                'avatarUrl': null,
                'isFavorite': false,
                'createdAt': '2026-02-01T16:00:00Z',
              },
            ],
            'meta': {'total': 5, 'page': 1, 'limit': 20},
          },
        );
      },
    );

    // POST /contacts/invite
    interceptor.register(
      method: 'POST',
      path: '/contacts/invite',
      legacyHandler: (uri, headers, data) async {
        return MockResponse(
          statusCode: 200,
          data: {'success': true, 'message': 'Invitation sent'},
        );
      },
    );
  }
}
