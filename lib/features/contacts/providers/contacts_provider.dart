import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/domain/entities/contact.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/utils/user_facing_errors.dart';

/// App contacts provider — wired to Dio (mock interceptor handles fallback).
final appContactsProvider = FutureProvider<List<Contact>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () => link.close());
  ref.onDispose(() => timer.cancel());

  final response = await dio.get('/contacts');
  final items = _extractContactMaps(response.data);
  return items.map(Contact.fromJson).toList();
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
  final Dio _dio;
  final ContactsService _contactsService;
  final String _defaultCountryPrefix;

  ContactActions(
    this._dio,
    this._contactsService, {
    required String defaultCountryPrefix,
  }) : _defaultCountryPrefix = defaultCountryPrefix;

  Future<void> syncPhoneContacts(List<String> phones) async {
    final hashes = phones
        .map(
          (phone) => _contactsService.hashPhone(
            phone,
            defaultCountryPrefix: _defaultCountryPrefix,
          ),
        )
        .toList();
    await _contactsService.syncPhoneHashes(_dio, hashes);
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
  final userCountryCode = ref.watch(userStateMachineProvider).countryCode;
  final selectedCountry = ref.watch(selectedCountryProvider);
  final country =
      SupportedCountries.findByCode(userCountryCode) ?? selectedCountry;
  return ContactActions(
    ref.watch(dioProvider),
    ref.watch(contactsServiceProvider),
    defaultCountryPrefix: country.prefix,
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
  final bool permissionRequired;
  final bool permissionRequiresSettings;
  final String? error;
  final DateTime? lastSyncTime;
  final ContactSyncResult? lastSyncResult;

  const ContactsState({
    this.contacts = const [],
    this.isLoading = false,
    this.permissionRequired = false,
    this.permissionRequiresSettings = false,
    this.error,
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
    bool? permissionRequired,
    bool? permissionRequiresSettings,
    String? error,
    bool clearError = false,
    DateTime? lastSyncTime,
    ContactSyncResult? lastSyncResult,
  }) => ContactsState(
    contacts: contacts ?? this.contacts,
    isLoading: isLoading ?? this.isLoading,
    permissionRequired: permissionRequired ?? this.permissionRequired,
    permissionRequiresSettings:
        permissionRequiresSettings ?? this.permissionRequiresSettings,
    error: clearError ? null : error ?? this.error,
    lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    lastSyncResult: lastSyncResult ?? this.lastSyncResult,
  );
}

/// Contacts notifier — manages synced contacts.
class ContactsNotifier extends Notifier<ContactsState> {
  @override
  ContactsState build() {
    return const ContactsState();
  }

  Future<void> syncContacts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dio = ref.read(dioProvider);
      final contactsService = ref.read(contactsServiceProvider);

      if (!MockConfig.useMocks &&
          !await contactsService.hasContactsPermission()) {
        final requiresSettings = await contactsService
            .contactsPermissionRequiresSettings();
        state = state.copyWith(
          contacts: const [],
          isLoading: false,
          permissionRequired: true,
          permissionRequiresSettings: requiresSettings,
          clearError: true,
        );
        return;
      }

      final items = MockConfig.useMocks
          ? await _getMockContacts()
          : await _getSyncedDeviceContacts(dio, contactsService);

      final joonaPayCount = items.where((c) => c.isKoridoUser).length;
      _sortContacts(items);

      state = state.copyWith(
        contacts: items,
        isLoading: false,
        permissionRequired: false,
        permissionRequiresSettings: false,
        clearError: true,
        lastSyncTime: DateTime.now(),
        lastSyncResult: ContactSyncResult(joonaPayUsersFound: joonaPayCount),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: UserFacingErrors.message(e));
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
    final defaultPrefix = _defaultCountryPrefix();
    final items = contactsService.deviceContactsToSyncedContacts(
      deviceContacts,
      defaultCountryPrefix: defaultPrefix,
    );

    return contactsService.getKoridoContacts(
      dio,
      items,
      defaultCountryPrefix: defaultPrefix,
    );
  }

  String _defaultCountryPrefix() {
    final userCountryCode = ref.read(userStateMachineProvider).countryCode;
    final selectedCountry = ref.read(selectedCountryProvider);
    final country =
        SupportedCountries.findByCode(userCountryCode) ?? selectedCountry;
    return country.prefix;
  }

  List<Map<String, dynamic>> _extractContactList(Object? data) {
    return _extractContactMaps(data);
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

    state = state.copyWith(
      isLoading: true,
      permissionRequired: false,
      permissionRequiresSettings: false,
      clearError: true,
    );

    final contactsService = ref.read(contactsServiceProvider);
    final granted = await contactsService.requestContactsPermission();
    if (granted) {
      await syncContacts();
    } else {
      final requiresSettings = await contactsService
          .contactsPermissionRequiresSettings();
      state = state.copyWith(
        isLoading: false,
        permissionRequired: true,
        permissionRequiresSettings: requiresSettings,
        error: 'contacts_permission_required',
      );
    }
    return granted;
  }
}

/// Main contacts provider with sync and search support.
final contactsProvider = NotifierProvider<ContactsNotifier, ContactsState>(
  ContactsNotifier.new,
);

List<Map<String, dynamic>> _extractContactMaps(Object? data) {
  Object? read(Object? source, String key) {
    if (source is Map) return source[key];
    return null;
  }

  if (data is List) {
    return data.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  for (final key in const ['contacts', 'items', 'results']) {
    final raw = read(data, key);
    if (raw is List) {
      return raw.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }
  }

  final nested = read(data, 'data');
  if (nested is List) {
    return nested.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  for (final key in const ['contacts', 'items', 'results']) {
    final raw = read(nested, key);
    if (raw is List) {
      return raw.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }
  }

  return const [];
}
