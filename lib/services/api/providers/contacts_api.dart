/// Contacts API — sync, list
library;

import 'package:dio/dio.dart';

class ContactsApi {
  ContactsApi(this._dio);
  final Dio _dio;

  /// GET /contacts
  Future<Response> list() => _dio.get('/contacts');

  /// POST /contacts/sync — sync hashed phone numbers.
  Future<List<Response>> sync(List<String> phoneHashes) async {
    final hashes = phoneHashes
        .map((hash) => hash.trim().toLowerCase())
        .where((hash) => hash.isNotEmpty)
        .toSet()
        .toList();
    final responses = <Response>[];

    for (var start = 0; start < hashes.length; start += 500) {
      final end = (start + 500).clamp(0, hashes.length);
      responses.add(
        await _dio.post(
          '/contacts/sync',
          data: {'phoneHashes': hashes.sublist(start, end)},
        ),
      );
    }

    return responses;
  }

  /// POST /contacts/check — check which phone numbers are registered
  Future<Response> checkContacts(List<String> phoneNumbers) =>
      _dio.post('/contacts/check', data: {'phoneNumbers': phoneNumbers});
}
