import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/synced_contact.dart';
import '../models/contact_sync_result.dart';
import '../../../services/contacts/contacts_service.dart';
import '../../../services/api/api_client.dart';

/// Contact permission state
enum PermissionState {
  unknown,
  granted,
  denied,
  permanentlyDenied,
}

/// Contacts State
class ContactsState {
  final List<SyncedContact> contacts;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final PermissionState permissionState;
  final ContactSyncResult? lastSyncResult;
  final DateTime? lastSyncTime;

  const ContactsState({
    this.contacts = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.permissionState = PermissionState.unknown,
    this.lastSyncResult,
    this.lastSyncTime,
  });

  ContactsState copyWith({
    List<SyncedContact>? contacts,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    PermissionState? permissionState,
    ContactSyncResult? lastSyncResult,
    DateTime? lastSyncTime,
  }) {
    return ContactsState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
      permissionState: permissionState ?? this.permissionState,
      lastSyncResult: lastSyncResult ?? this.lastSyncResult,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  /// Get only JoonaPay users
  List<SyncedContact> get joonaPayUsers =>
      contacts.where((c) => c.isJoonaPayUser).toList();

  /// Get non-JoonaPay users
  List<SyncedContact> get nonJoonaPayUsers =>
      contacts.where((c) => !c.isJoonaPayUser).toList();

  /// Search contacts
  List<SyncedContact> searchContacts(String query) {
    if (query.isEmpty) return contacts;

    final lowerQuery = query.toLowerCase();
    return contacts
        .where((c) =>
            c.name.toLowerCase().contains(lowerQuery) ||
            c.phone.contains(lowerQuery))
        .toList();
  }
}

/// Contacts Notifier
class ContactsNotifier extends Notifier<ContactsState> {
  @override
  ContactsState build() => const ContactsState();

  /// Check permission status
  Future<void> checkPermission() async {
    final service = ref.read(contactsServiceProvider);
    final hasPermission = await service.hasContactsPermission();

    state = state.copyWith(
      permissionState:
          hasPermission ? PermissionState.granted : PermissionState.denied,
    );
  }

  /// Request contacts permission
  Future<bool> requestPermission() async {
    final service = ref.read(contactsServiceProvider);
    final granted = await service.requestContactsPermission();

    state = state.copyWith(
      permissionState:
          granted ? PermissionState.granted : PermissionState.denied,
    );

    if (granted) {
      await loadAndSyncContacts();
    }

    return granted;
  }

  /// Load device contacts and sync with JoonaPay
  Future<void> loadAndSyncContacts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(contactsServiceProvider);
      final dio = ref.read(dioProvider);

      // Get device contacts
      final deviceContacts = await service.getDeviceContacts();
      final syncedContacts =
          service.deviceContactsToSyncedContacts(deviceContacts);

      // Get JoonaPay matches
      final matchedContacts =
          await service.getJoonaPayContacts(dio, syncedContacts);

      // Count JoonaPay users
      final joonaPayCount =
          matchedContacts.where((c) => c.isJoonaPayUser).length;

      final result = ContactSyncResult(
        totalContacts: matchedContacts.length,
        joonaPayUsersFound: joonaPayCount,
        syncedAt: DateTime.now(),
      );

      state = state.copyWith(
        contacts: matchedContacts,
        isLoading: false,
        lastSyncResult: result,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sync contacts (refresh JoonaPay status)
  Future<void> syncContacts() async {
    if (state.contacts.isEmpty) {
      await loadAndSyncContacts();
      return;
    }

    state = state.copyWith(isSyncing: true, error: null);

    try {
      final service = ref.read(contactsServiceProvider);
      final dio = ref.read(dioProvider);

      // Get updated JoonaPay matches
      final matchedContacts =
          await service.getJoonaPayContacts(dio, state.contacts);

      // Count JoonaPay users
      final joonaPayCount =
          matchedContacts.where((c) => c.isJoonaPayUser).length;

      final result = ContactSyncResult(
        totalContacts: matchedContacts.length,
        joonaPayUsersFound: joonaPayCount,
        syncedAt: DateTime.now(),
      );

      state = state.copyWith(
        contacts: matchedContacts,
        isSyncing: false,
        lastSyncResult: result,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
      );
    }
  }
}

/// Contacts Provider
final contactsProvider = NotifierProvider<ContactsNotifier, ContactsState>(
  ContactsNotifier.new,
);
