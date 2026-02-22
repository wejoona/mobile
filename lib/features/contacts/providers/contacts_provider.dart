import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/contact.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// App contacts provider — wired to Dio (mock interceptor handles fallback).
final appContactsProvider = FutureProvider<List<Contact>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () => link.close());
  ref.onDispose(() => timer.cancel());

  final response = await dio.get('/contacts');
  final data = response.data as Map<String, dynamic>;
  final items = data['data'] as List? ?? [];
  return items.map((e) => Contact.fromJson(e as Map<String, dynamic>)).toList();
});

/// Favorite contacts.
final favoriteContactsProvider = Provider<List<Contact>>((ref) {
  final contacts = ref.watch(appContactsProvider).value ?? [];
  return contacts.where((c) => c.isFavorite).toList();
});

/// Search contacts.
final contactSearchProvider = Provider.family<List<Contact>, String>((ref, query) {
  final contacts = ref.watch(appContactsProvider).value ?? [];
  if (query.isEmpty) return contacts;
  final lower = query.toLowerCase();
  return contacts.where((c) {
    return c.name.toLowerCase().contains(lower) || (c.phone?.contains(query) ?? false);
  }).toList();
});

/// Contact actions.
class ContactActions {
  final dynamic _dio;
  ContactActions(this._dio);

  Future<void> syncPhoneContacts(List<String> phones) async {
    // ignore: avoid_dynamic_calls
    await _dio.post('/contacts/sync', data: {'phones': phones});
  }

  Future<void> invite(String phone) async {
    // ignore: avoid_dynamic_calls
    await _dio.post('/contacts/invite', data: {'phone': phone});
  }

  Future<void> toggleFavorite(String contactId, bool isFavorite) async {
    // ignore: avoid_dynamic_calls
    await _dio.patch('/contacts/$contactId', data: {'isFavorite': isFavorite});
  }
}

final contactActionsProvider = Provider<ContactActions>((ref) {
  return ContactActions(ref.watch(dioProvider));
});

/// Contact sync result.
class ContactSyncResult {
  final int joonaPayUsersFound;
  const ContactSyncResult({this.joonaPayUsersFound = 0});
}

/// Contacts state for the contacts feature.
class ContactsState {
  final List<SyncedContact> contacts;
  final bool isLoading;
  final DateTime? lastSyncTime;
  final ContactSyncResult? lastSyncResult;

  const ContactsState({
    this.contacts = const [],
    this.isLoading = false,
    this.lastSyncTime,
    this.lastSyncResult,
  });

  List<SyncedContact> searchContacts(String query) {
    if (query.isEmpty) return contacts;
    final lower = query.toLowerCase();
    return contacts.where((c) =>
      c.name.toLowerCase().contains(lower) || c.phone.contains(query)
    ).toList();
  }

  ContactsState copyWith({
    List<SyncedContact>? contacts,
    bool? isLoading,
    DateTime? lastSyncTime,
    ContactSyncResult? lastSyncResult,
  }) => ContactsState(
    contacts: contacts ?? this.contacts,
    isLoading: isLoading ?? this.isLoading,
    lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    lastSyncResult: lastSyncResult ?? this.lastSyncResult,
  );
}

/// Contacts notifier — manages synced contacts.
class ContactsNotifier extends Notifier<ContactsState> {
  @override
  ContactsState build() {
    Future.microtask(() => syncContacts());
    return const ContactsState(isLoading: true);
  }

  Future<void> syncContacts() async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/contacts/synced');
      final data = response.data as Map<String, dynamic>;
      var items = (data['data'] as List? ?? [])
          .map((e) => SyncedContact.fromJson(e as Map<String, dynamic>))
          .toList();

      // Check which contacts are registered Korido users
      items = await _checkRegisteredContacts(dio, items);

      final joonaPayCount = items.where((c) => c.isKoridoUser).length;
      // Sort: Korido users first
      items.sort((a, b) {
        if (a.isKoridoUser && !b.isKoridoUser) return -1;
        if (!a.isKoridoUser && b.isKoridoUser) return 1;
        return a.name.compareTo(b.name);
      });

      state = state.copyWith(
        contacts: items,
        isLoading: false,
        lastSyncTime: DateTime.now(),
        lastSyncResult: ContactSyncResult(joonaPayUsersFound: joonaPayCount),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Call POST /contacts/check to detect registered Korido users
  Future<List<SyncedContact>> _checkRegisteredContacts(
    dynamic dio,
    List<SyncedContact> contacts,
  ) async {
    if (contacts.isEmpty) return contacts;

    try {
      final phoneNumbers = contacts.map((c) => c.phone).toList();
      // ignore: avoid_dynamic_calls
      final response = await dio.post(
        '/contacts/check',
        data: {'phoneNumbers': phoneNumbers},
      );
      // ignore: avoid_dynamic_calls
      final data = response.data as Map<String, dynamic>;
      final registered = (data['registered'] as List? ?? [])
          .cast<Map<String, dynamic>>();

      // Build a set of registered phones for quick lookup
      final registeredPhones = <String, Map<String, dynamic>>{};
      for (final r in registered) {
        registeredPhones[r['phone'] as String] = r;
      }

      return contacts.map((c) {
        final match = registeredPhones[c.phone];
        if (match != null) {
          return c.copyWith(
            isKoridoUser: true,
            joonaPayUserId: match['userId'] as String?,
          );
        }
        return c;
      }).toList();
    } catch (_) {
      // If check fails, return contacts as-is
      return contacts;
    }
  }

  Future<bool> requestPermission() async {
    // Permission request — returns true if granted
    return true;
  }
}

/// Main contacts provider with sync and search support.
final contactsProvider = NotifierProvider<ContactsNotifier, ContactsState>(ContactsNotifier.new);
