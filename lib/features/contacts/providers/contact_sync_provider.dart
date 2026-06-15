import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Contact sync provider - syncs device contacts with Korido backend.
enum ContactSyncStatus {
  idle,
  requestingPermission,
  syncing,
  synced,
  permissionDenied,
  error,
}

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
    state = state.copyWith(
      status: ContactSyncStatus.requestingPermission,
      error: null,
    );
    try {
      final contactsService = ref.read(contactsServiceProvider);
      final granted = await contactsService.requestContactsPermission();
      if (granted) {
        return true;
      }

      if (await contactsService.contactsPermissionRequiresSettings()) {
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
      state = state.copyWith(
        status: ContactSyncStatus.error,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Sync device contacts with backend
  Future<void> syncContacts() async {
    if (state.status == ContactSyncStatus.syncing) return;

    // Passive sync must not trigger the iOS Contacts prompt. Permission should
    // only be requested from an explicit user action.
    final contactsService = ref.read(contactsServiceProvider);
    if (!await contactsService.hasContactsPermission()) {
      state = state.copyWith(status: ContactSyncStatus.permissionDenied);
      return;
    }

    state = state.copyWith(status: ContactSyncStatus.syncing, error: null);
    try {
      // Step 1: Read device contacts
      _logger.info('Reading device contacts...');
      final contacts = await contactsService.getDeviceContacts();

      // Step 2: Hash normalized phone numbers before sending them to the API.
      final phoneHashes = <String>{};
      final defaultPrefix = _defaultCountryPrefix();
      for (final contact in contacts) {
        for (final phone in contact.phones) {
          if (phone.number.trim().isNotEmpty) {
            phoneHashes.add(
              contactsService.hashPhone(
                phone.number,
                defaultCountryPrefix: defaultPrefix,
              ),
            );
          }
        }
      }

      _logger.info(
        'Found ${phoneHashes.length} phone numbers from ${contacts.length} contacts',
      );

      if (phoneHashes.isEmpty) {
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
      final matchedCount = await contactsService.syncPhoneHashes(
        dio,
        phoneHashes,
      );

      state = state.copyWith(
        status: ContactSyncStatus.synced,
        totalContacts: phoneHashes.length,
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

  String _defaultCountryPrefix() {
    final userCountryCode = ref.read(userStateMachineProvider).countryCode;
    final selectedCountry = ref.read(selectedCountryProvider);
    final country =
        SupportedCountries.findByCode(userCountryCode) ?? selectedCountry;
    return country.prefix;
  }

  Future<void> syncIfNeeded() async {
    if (state.needsSync) {
      await syncContacts();
    }
  }

  /// Open app settings for permission
  Future<void> openSettings() async {
    await ref.read(contactsServiceProvider).openContactsSettings();
  }
}

final contactSyncProvider =
    NotifierProvider<ContactSyncNotifier, ContactSyncState>(
      ContactSyncNotifier.new,
    );
