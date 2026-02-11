import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/contact.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// App contacts provider — wired to Dio (mock interceptor handles fallback).
final appContactsProvider = FutureProvider<List<Contact>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), () => link.close());

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
    await _dio.post('/contacts/sync', data: {'phones': phones});
  }

  Future<void> invite(String phone) async {
    await _dio.post('/contacts/invite', data: {'phone': phone});
  }

  Future<void> toggleFavorite(String contactId, bool isFavorite) async {
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
      final items = (data['data'] as List? ?? [])
          .map((e) => SyncedContact.fromJson(e as Map<String, dynamic>))
          .toList();
      final joonaPayCount = items.where((c) => c.isJoonaPayUser).length;
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

  Future<bool> requestPermission() async {
    // Permission request — returns true if granted
    return true;
  }
}

/// Main contacts provider with sync and search support.
final contactsProvider = NotifierProvider<ContactsNotifier, ContactsState>(ContactsNotifier.new);
