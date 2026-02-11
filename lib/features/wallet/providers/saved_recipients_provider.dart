import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/domain/entities/contact.dart';

/// Run 349: Saved recipients provider for quick-send feature
class SavedRecipientsState {
  final List<Contact> recipients;
  final List<Contact> recentRecipients;
  final bool isLoading;
  final String? error;

  const SavedRecipientsState({
    this.recipients = const [],
    this.recentRecipients = const [],
    this.isLoading = false,
    this.error,
  });

  SavedRecipientsState copyWith({
    List<Contact>? recipients,
    List<Contact>? recentRecipients,
    bool? isLoading,
    String? error,
  }) => SavedRecipientsState(
    recipients: recipients ?? this.recipients,
    recentRecipients: recentRecipients ?? this.recentRecipients,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class SavedRecipientsNotifier extends StateNotifier<SavedRecipientsState> {
  SavedRecipientsNotifier() : super(const SavedRecipientsState());

  Future<void> loadRecipients() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(isLoading: false, recipients: []);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addRecipient(Contact contact) async {
    final updated = [...state.recipients, contact];
    state = state.copyWith(recipients: updated);
  }

  Future<void> removeRecipient(String contactId) async {
    final updated = state.recipients.where((c) => c.id != contactId).toList();
    state = state.copyWith(recipients: updated);
  }

  void addToRecent(Contact contact) {
    final recent = [contact, ...state.recentRecipients.where((c) => c.id != contact.id)];
    state = state.copyWith(
      recentRecipients: recent.take(10).toList(),
    );
  }

  List<Contact> search(String query) {
    if (query.isEmpty) return state.recipients;
    final lower = query.toLowerCase();
    return state.recipients.where((c) {
      return (c.displayName?.toLowerCase().contains(lower) ?? false) ||
          (c.phoneNumber?.toLowerCase().contains(lower) ?? false);
    }).toList();
  }
}

final savedRecipientsProvider =
    StateNotifierProvider<SavedRecipientsNotifier, SavedRecipientsState>((ref) {
  final notifier = SavedRecipientsNotifier();
  notifier.loadRecipients();
  return notifier;
});
