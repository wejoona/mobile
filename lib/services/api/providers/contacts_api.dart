/// Contacts API — sync, list
library;

import 'package:dio/dio.dart';

class ContactsApi {
  ContactsApi(this._dio);
  final Dio _dio;

  /// GET /contacts
  Future<Response> list() => _dio.get('/contacts');

  /// POST /contacts/sync — sync hashed phone numbers.
  Future<Response> sync(List<String> phoneHashes) =>
      _dio.post('/contacts/sync', data: {'phoneHashes': phoneHashes});

  /// POST /contacts/check — check which phone numbers are registered
  Future<Response> checkContacts(List<String> phoneNumbers) =>
      _dio.post('/contacts/check', data: {'phoneNumbers': phoneNumbers});
}
