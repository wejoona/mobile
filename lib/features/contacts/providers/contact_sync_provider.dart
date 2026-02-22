import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Contact sync provider - syncs device contacts with Korido backend.
enum ContactSyncStatus { idle, requestingPermission, syncing, synced, permissionDenied, error }

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

class ContactSyncNotifier extends Notifier<ContactSyncState> {
  final _logger = AppLogger('ContactSyncNotifier');

  @override
  ContactSyncState build() => const ContactSyncState();

  /// Request contacts permission
  Future<bool> requestPermission() async {
    state = state.copyWith(status: ContactSyncStatus.requestingPermission, error: null);
    try {
      final status = await Permission.contacts.request();
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        state = state.copyWith(
          status: ContactSyncStatus.permissionDenied,
          error: 'Permission permanently denied. Please enable in Settings.',
        );
        return false;
      } else {
        state = state.copyWith(
          status: ContactSyncStatus.permissionDenied,
          error: 'Contacts permission denied',
        );
        return false;
      }
    } catch (e) {
      _logger.error('Permission request failed: $e');
      state = state.copyWith(status: ContactSyncStatus.error, error: e.toString());
      return false;
    }
  }

  /// Sync device contacts with backend
  Future<void> syncContacts() async {
    if (state.status == ContactSyncStatus.syncing) return;

    // Check permission first
    final permissionStatus = await Permission.contacts.status;
    if (!permissionStatus.isGranted) {
      final granted = await requestPermission();
      if (!granted) return;
    }

    state = state.copyWith(status: ContactSyncStatus.syncing, error: null);
    try {
      // Step 1: Read device contacts
      _logger.info('Reading device contacts...');
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      
      // Step 2: Extract phone numbers
      final phoneNumbers = <String>[];
      for (final contact in contacts) {
        for (final phone in contact.phones) {
          final cleaned = phone.number.replaceAll(RegExp(r'[^\d+]'), '');
          if (cleaned.isNotEmpty) {
            phoneNumbers.add(cleaned);
          }
        }
      }

      _logger.info('Found ${phoneNumbers.length} phone numbers from ${contacts.length} contacts');

      if (phoneNumbers.isEmpty) {
        state = state.copyWith(
          status: ContactSyncStatus.synced,
          totalContacts: 0,
          koridoUsers: 0,
          lastSyncAt: DateTime.now(),
        );
        return;
      }

      // Step 3: Send to backend for matching
      final dio = ref.read(dioProvider);
      final response = await dio.post('/contacts/sync', data: {
        'phones': phoneNumbers,
      });

      final data = response.data as Map<String, dynamic>;
      final matchedCount = (data['matched'] as List?)?.length ?? 0;

      state = state.copyWith(
        status: ContactSyncStatus.synced,
        totalContacts: phoneNumbers.length,
        koridoUsers: matchedCount,
        lastSyncAt: DateTime.now(),
      );

      _logger.info('Contact sync complete: $matchedCount Korido users found');
    } catch (e) {
      _logger.error('Contact sync failed: $e');
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

  /// Open app settings for permission
  Future<void> openSettings() async {
    await openAppSettings();
  }
}

final contactSyncProvider =
    NotifierProvider<ContactSyncNotifier, ContactSyncState>(ContactSyncNotifier.new);
