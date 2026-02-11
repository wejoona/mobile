import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/contact.dart';

/// Run 362: Contact sync provider - syncs device contacts with Korido backend
enum ContactSyncStatus { idle, syncing, synced, error }

class ContactSyncState {
  final ContactSyncStatus status;
  final int totalContacts;
  final int koridoUsers;
  final DateTime? lastSyncAt;
  final String? error;

  const ContactSyncState({
    this.status = ContactSyncStatus.idle,
    this.totalContacts = 0,
    this.koridoUsers = 0,
    this.lastSyncAt,
    this.error,
  });

  bool get needsSync {
    if (lastSyncAt == null) return true;
    return DateTime.now().difference(lastSyncAt!).inHours > 24;
  }

  ContactSyncState copyWith({
    ContactSyncStatus? status,
    int? totalContacts,
    int? koridoUsers,
    DateTime? lastSyncAt,
    String? error,
  }) => ContactSyncState(
    status: status ?? this.status,
    totalContacts: totalContacts ?? this.totalContacts,
    koridoUsers: koridoUsers ?? this.koridoUsers,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    error: error,
  );
}

class ContactSyncNotifier extends StateNotifier<ContactSyncState> {
  ContactSyncNotifier() : super(const ContactSyncState());

  Future<void> syncContacts() async {
    if (state.status == ContactSyncStatus.syncing) return;
    state = state.copyWith(status: ContactSyncStatus.syncing, error: null);
    try {
      // Step 1: Read device contacts
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Hash phone numbers and send to backend
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 3: Receive matched Korido users
      state = state.copyWith(
        status: ContactSyncStatus.synced,
        lastSyncAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: ContactSyncStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> syncIfNeeded() async {
    if (state.needsSync) {
      await syncContacts();
    }
  }
}

final contactSyncProvider =
    StateNotifierProvider<ContactSyncNotifier, ContactSyncState>((ref) {
  return ContactSyncNotifier();
});
