import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/contact.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';

// =============================================================================
// SAVED RECIPIENT PROVIDERS
// =============================================================================

/// All saved recipients with TTL-based caching.
/// Cache duration: 30 seconds
final savedRecipientsProvider = FutureProvider.autoDispose<List<Contact>>((
  ref,
) async {
  final service = ref.watch(joonaPayContactsServiceProvider);
  final link = ref.keepAlive();

  final timer = Timer(const Duration(seconds: 30), link.close);
  ref.onDispose(timer.cancel);

  return service.getContacts();
});

/// Favorite saved recipients with TTL-based caching.
/// Cache duration: 30 seconds
final favoriteRecipientsProvider = FutureProvider.autoDispose<List<Contact>>((
  ref,
) async {
  final service = ref.watch(joonaPayContactsServiceProvider);
  final link = ref.keepAlive();

  final timer = Timer(const Duration(seconds: 30), link.close);
  ref.onDispose(timer.cancel);

  return service.getFavorites();
});

/// Recent saved recipients with TTL-based caching.
/// Cache duration: 30 seconds
final recentRecipientsProvider = FutureProvider.autoDispose<List<Contact>>((
  ref,
) async {
  final service = ref.watch(joonaPayContactsServiceProvider);
  final link = ref.keepAlive();

  final timer = Timer(const Duration(seconds: 30), link.close);
  ref.onDispose(timer.cancel);

  return service.getRecents();
});

/// Search saved recipients. Search results should be fresh.
final searchSavedRecipientsProvider = FutureProvider.autoDispose
    .family<List<Contact>, String>((ref, query) async {
      if (query.isEmpty) {
        return [];
      }

      final service = ref.watch(joonaPayContactsServiceProvider);
      return service.searchContacts(query);
    });

// =============================================================================
// CONTACT MUTATION STATE
// =============================================================================

/// Saved recipient mutation state.
class SavedRecipientState {
  final bool isLoading;
  final Contact? contact;
  final String? error;

  const SavedRecipientState({this.isLoading = false, this.contact, this.error});

  SavedRecipientState copyWith({
    bool? isLoading,
    Contact? contact,
    String? error,
  }) {
    return SavedRecipientState(
      isLoading: isLoading ?? this.isLoading,
      contact: contact ?? this.contact,
      error: error,
    );
  }
}

/// Saved recipient notifier for managing create, update, and delete mutations.
class SavedRecipientNotifier extends Notifier<SavedRecipientState> {
  @override
  SavedRecipientState build() {
    return const SavedRecipientState();
  }

  KoridoContactsService get _service =>
      ref.read(joonaPayContactsServiceProvider);

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

      ref.invalidate(savedRecipientsProvider);
      ref.invalidate(recentRecipientsProvider);

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

      ref.invalidate(savedRecipientsProvider);
      ref.invalidate(favoriteRecipientsProvider);
      ref.invalidate(recentRecipientsProvider);

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

      ref.invalidate(savedRecipientsProvider);
      ref.invalidate(favoriteRecipientsProvider);

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

      state = const SavedRecipientState();

      ref.invalidate(savedRecipientsProvider);
      ref.invalidate(favoriteRecipientsProvider);
      ref.invalidate(recentRecipientsProvider);

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  void reset() {
    state = const SavedRecipientState();
  }
}

final savedRecipientMutationProvider =
    NotifierProvider.autoDispose<SavedRecipientNotifier, SavedRecipientState>(
      SavedRecipientNotifier.new,
    );
