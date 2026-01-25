import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/contact.dart';
import '../../../services/contacts/contacts_service.dart';
import '../../../services/api/api_client.dart';

// =============================================================================
// CONTACTS PROVIDERS
// =============================================================================

/// All Contacts Provider with TTL-based caching
/// Cache duration: 30 seconds
final contactsProvider = FutureProvider.autoDispose<List<Contact>>((ref) async {
  final service = ref.watch(joonaPayContactsServiceProvider);
  final link = ref.keepAlive();

  // Auto-invalidate after 30 seconds
  Timer(const Duration(seconds: 30), () {
    link.close();
  });

  return service.getContacts();
});

/// Favorite Contacts Provider with TTL-based caching
/// Cache duration: 30 seconds
final favoritesProvider = FutureProvider.autoDispose<List<Contact>>((ref) async {
  final service = ref.watch(joonaPayContactsServiceProvider);
  final link = ref.keepAlive();

  // Auto-invalidate after 30 seconds
  Timer(const Duration(seconds: 30), () {
    link.close();
  });

  return service.getFavorites();
});

/// Recent Contacts Provider with TTL-based caching
/// Cache duration: 30 seconds
final recentsProvider = FutureProvider.autoDispose<List<Contact>>((ref) async {
  final service = ref.watch(joonaPayContactsServiceProvider);
  final link = ref.keepAlive();

  // Auto-invalidate after 30 seconds
  Timer(const Duration(seconds: 30), () {
    link.close();
  });

  return service.getRecents();
});

/// Search Contacts Provider
/// No caching - search results should be fresh
final searchContactsProvider =
    FutureProvider.autoDispose.family<List<Contact>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final service = ref.watch(joonaPayContactsServiceProvider);
  return service.searchContacts(query);
});

// =============================================================================
// CONTACT MUTATION STATE
// =============================================================================

/// Contact State for mutations (create, update, delete)
class ContactState {
  final bool isLoading;
  final Contact? contact;
  final String? error;

  const ContactState({
    this.isLoading = false,
    this.contact,
    this.error,
  });

  ContactState copyWith({
    bool? isLoading,
    Contact? contact,
    String? error,
  }) {
    return ContactState(
      isLoading: isLoading ?? this.isLoading,
      contact: contact ?? this.contact,
      error: error,
    );
  }
}

/// Contact Notifier for managing contact mutations
class ContactNotifier extends Notifier<ContactState> {
  @override
  ContactState build() {
    return const ContactState();
  }

  JoonaPayContactsService get _service => ref.read(joonaPayContactsServiceProvider);

  /// Create a new contact
  Future<bool> createContact({
    required String name,
    String? phone,
    String? walletAddress,
    String? username,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final contact = await _service.createContact(
        name: name,
        phone: phone,
        walletAddress: walletAddress,
        username: username,
      );

      state = state.copyWith(isLoading: false, contact: contact);

      // Invalidate contacts list to refresh
      ref.invalidate(contactsProvider);
      ref.invalidate(recentsProvider);

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  /// Update an existing contact
  Future<bool> updateContact({
    required String contactId,
    String? name,
    bool? isFavorite,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final contact = await _service.updateContact(
        contactId: contactId,
        name: name,
        isFavorite: isFavorite,
      );

      state = state.copyWith(isLoading: false, contact: contact);

      // Invalidate contacts list to refresh
      ref.invalidate(contactsProvider);
      ref.invalidate(favoritesProvider);
      ref.invalidate(recentsProvider);

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String contactId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final contact = await _service.toggleFavorite(contactId);

      state = state.copyWith(isLoading: false, contact: contact);

      // Invalidate contacts list to refresh
      ref.invalidate(contactsProvider);
      ref.invalidate(favoritesProvider);

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  /// Delete a contact
  Future<bool> deleteContact(String contactId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _service.deleteContact(contactId);

      state = const ContactState();

      // Invalidate contacts list to refresh
      ref.invalidate(contactsProvider);
      ref.invalidate(favoritesProvider);
      ref.invalidate(recentsProvider);

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  void reset() {
    state = const ContactState();
  }
}

final contactProvider =
    NotifierProvider.autoDispose<ContactNotifier, ContactState>(
  ContactNotifier.new,
);
