import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/contact.dart';
import '../../../services/api/api_client.dart';

/// App contacts provider (Korido contacts, not phone contacts).
final appContactsProvider = FutureProvider<List<Contact>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();

  Timer(const Duration(minutes: 5), () => link.close());

  final response = await dio.get('/contacts');
  final data = response.data as Map<String, dynamic>;
  final items = data['data'] as List? ?? [];
  return items
      .map((e) => Contact.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Favorite contacts.
final favoriteContactsProvider = Provider<List<Contact>>((ref) {
  final contacts = ref.watch(appContactsProvider).valueOrNull ?? [];
  return contacts.where((c) => c.isFavorite).toList();
});

/// Search contacts.
final contactSearchProvider =
    Provider.family<List<Contact>, String>((ref, query) {
  final contacts = ref.watch(appContactsProvider).valueOrNull ?? [];
  if (query.isEmpty) return contacts;
  final lower = query.toLowerCase();
  return contacts.where((c) {
    return c.name.toLowerCase().contains(lower) ||
        (c.phone?.contains(query) ?? false);
  }).toList();
});

/// Contact actions.
class ContactActions {
  final Dio _dio;

  ContactActions(this._dio);

  Future<void> syncPhoneContacts(List<String> phones) async {
    await _dio.post('/contacts/sync', data: {'phones': phones});
  }

  Future<void> invite(String phone) async {
    await _dio.post('/contacts/invite', data: {'phone': phone});
  }

  Future<void> toggleFavorite(String contactId, bool isFavorite) async {
    await _dio.patch('/contacts/$contactId', data: {
      'isFavorite': isFavorite,
    });
  }
}

final contactActionsProvider = Provider<ContactActions>((ref) {
  return ContactActions(ref.watch(dioProvider));
});
