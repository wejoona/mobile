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

  /// POST /contacts/check — privacy-preserving registered-user check.
  Future<Response> checkPhoneHashes(
    List<String> phoneHashes, {
    String permissionStatus = 'granted',
  }) {
    final hashes = _canonicalPhoneHashes(phoneHashes);
    return _dio.post(
      '/contacts/check',
      data: {'permissionStatus': permissionStatus, 'phoneHashes': hashes},
    );
  }

  @Deprecated(
    'Raw phone contacts must not be sent by mobile. Hash normalized E.164 '
    'numbers with ContactsService.hashPhone and call checkPhoneHashes.',
  )
  Future<Response> checkContacts(List<String> phoneNumbers) {
    throw UnsupportedError(
      'ContactsApi.checkContacts no longer sends raw phone numbers. '
      'Use checkPhoneHashes with SHA-256 E.164 hashes.',
    );
  }

  List<String> _canonicalPhoneHashes(List<String> phoneHashes) {
    return phoneHashes
        .map((hash) => hash.trim().toLowerCase())
        .where((hash) => RegExp(r'^[a-f0-9]{64}$').hasMatch(hash))
        .toSet()
        .toList();
  }
}
