import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/contact.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';

/// App contacts provider — wired to Dio (mock interceptor handles fallback).
final appContactsProvider = FutureProvider<List<Contact>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () => link.close());
  ref.onDispose(() => timer.cancel());

  final response = await dio.get('/contacts');
  final data = response.data as Map<String, dynamic>;
  final items = (data['contacts'] ?? data['data']) as List? ?? [];
  return items.map((e) => Contact.fromJson(e as Map<String, dynamic>)).toList();
});

/// Favorite contacts.
final favoriteContactsProvider = Provider<List<Contact>>((ref) {
  final contacts = ref.watch(appContactsProvider).value ?? [];
  return contacts.where((c) => c.isFavorite).toList();
});

/// Search contacts.
final contactSearchProvider = Provider.family<List<Contact>, String>((
  ref,
  query,
) {
  final contacts = ref.watch(appContactsProvider).value ?? [];
  if (query.isEmpty) return contacts;
  final lower = query.toLowerCase();
  return contacts.where((c) {
    return c.name.toLowerCase().contains(lower) ||
        (c.phone?.contains(query) ?? false);
  }).toList();
});

/// Contact actions.
class ContactActions {
  final dynamic _dio;
  final ContactsService _contactsService;
  ContactActions(this._dio, this._contactsService);

  Future<void> syncPhoneContacts(List<String> phones) async {
    final hashes = phones.map(_contactsService.hashPhone).toList();
    // ignore: avoid_dynamic_calls
    await _dio.post('/contacts/sync', data: {'phoneHashes': hashes});
  }

  Future<void> invite(String phone) async {
    // ignore: avoid_dynamic_calls
    await _dio.post('/contacts/invite', data: {'phone': phone});
  }

  Future<void> toggleFavorite(String contactId, bool isFavorite) async {
    // ignore: avoid_dynamic_calls
    await _dio.put('/contacts/$contactId', data: {'isFavorite': isFavorite});
  }
}

final contactActionsProvider = Provider<ContactActions>((ref) {
  return ContactActions(
    ref.watch(dioProvider),
    ref.watch(contactsServiceProvider),
  );
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
    return contacts
        .where(
          (c) =>
              c.name.toLowerCase().contains(lower) || c.phone.contains(query),
        )
        .toList();
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
    unawaited(Future.microtask(syncContacts));
    return const ContactsState(isLoading: true);
  }

  Future<void> syncContacts() async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final contactsService = ref.read(contactsServiceProvider);
      final items = MockConfig.useMocks
          ? await _getMockContacts()
          : await _getSyncedDeviceContacts(dio, contactsService);

      final joonaPayCount = items.where((c) => c.isKoridoUser).length;
      _sortContacts(items);

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

  Future<List<SyncedContact>> _getMockContacts() async {
    final dio = ref.read(dioProvider);
    final response = await dio.get('/contacts');
    final rawContacts = _extractContactList(response.data);
    return rawContacts
        .map((contact) => SyncedContact.fromJson(contact))
        .toList();
  }

  Future<List<SyncedContact>> _getSyncedDeviceContacts(
    Dio dio,
    ContactsService contactsService,
  ) async {
    final deviceContacts = await contactsService.getDeviceContacts();
    final items = contactsService.deviceContactsToSyncedContacts(
      deviceContacts,
    );

    return contactsService.getKoridoContacts(dio, items);
  }

  List<Map<String, dynamic>> _extractContactList(Object? data) {
    final raw = switch (data) {
      {'contacts': final List contacts} => contacts,
      {'data': final List contacts} => contacts,
      {'items': final List contacts} => contacts,
      final List contacts => contacts,
      _ => const <Object?>[],
    };

    return raw
        .whereType<Map>()
        .map((contact) => Map<String, dynamic>.from(contact))
        .toList();
  }

  void _sortContacts(List<SyncedContact> items) {
    items.sort((a, b) {
      if (a.isKoridoUser && !b.isKoridoUser) return -1;
      if (!a.isKoridoUser && b.isKoridoUser) return 1;
      return a.name.compareTo(b.name);
    });
  }

  Future<bool> requestPermission() async {
    if (MockConfig.useMocks) {
      await syncContacts();
      return true;
    }

    final contactsService = ref.read(contactsServiceProvider);
    final granted = await contactsService.requestContactsPermission();
    if (granted) {
      await syncContacts();
    }
    return granted;
  }
}

/// Main contacts provider with sync and search support.
final contactsProvider = NotifierProvider<ContactsNotifier, ContactsState>(
  ContactsNotifier.new,
);
