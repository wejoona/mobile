import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:usdc_wallet/domain/entities/contact.dart' as domain;
import 'package:usdc_wallet/features/contacts/models/contact_sync_result.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/utils/phone_normalizer.dart';

/// Simple contact info for contact picker
class ContactInfo {
  final String name;
  final String phoneNumber;

  const ContactInfo({required this.name, required this.phoneNumber});
}

class _ContactSyncMatch {
  const _ContactSyncMatch({
    required this.phoneHash,
    required this.userId,
    this.displayName,
    this.username,
    this.maskedPhone,
    this.avatarUrl,
  });

  final String phoneHash;
  final String userId;
  final String? displayName;
  final String? username;
  final String? maskedPhone;
  final String? avatarUrl;
}

List<Map<String, dynamic>> _extractMapList(Object? payload, List<String> keys) {
  Object? readKey(Object? source, String key) {
    if (source is Map) return source[key];
    return null;
  }

  if (payload is List) {
    return payload.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  for (final key in keys) {
    final direct = readKey(payload, key);
    if (direct is List) {
      return direct.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }
  }

  final nestedData = readKey(payload, 'data');
  if (nestedData is List) {
    return nestedData.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  for (final key in keys) {
    final nested = readKey(nestedData, key);
    if (nested is List) {
      return nested.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }
  }

  return const [];
}

Map<String, dynamic> _asMap(Object? payload) {
  if (payload is Map<String, dynamic>) return payload;
  if (payload is Map) return Map<String, dynamic>.from(payload);
  return const {};
}

String _stringField(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) return value;
  }
  return '';
}

/// Contact with app status
class AppContact {
  final String id;
  final String name;
  final String phone;
  final String? photoUrl;
  final bool hasApp;
  final DateTime? lastTransfer;

  const AppContact({
    required this.id,
    required this.name,
    required this.phone,
    this.photoUrl,
    this.hasApp = false,
    this.lastTransfer,
  });

  factory AppContact.fromJson(Map<String, dynamic> json) {
    return AppContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      photoUrl: json['photoUrl'] as String?,
      hasApp: json['hasApp'] as bool? ?? false,
      lastTransfer: json['lastTransfer'] != null
          ? DateTime.parse(json['lastTransfer'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'photoUrl': photoUrl,
    'hasApp': hasApp,
    'lastTransfer': lastTransfer?.toIso8601String(),
  };

  AppContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? photoUrl,
    bool? hasApp,
    DateTime? lastTransfer,
  }) {
    return AppContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      hasApp: hasApp ?? this.hasApp,
      lastTransfer: lastTransfer ?? this.lastTransfer,
    );
  }
}

/// Contacts Service
class ContactsService {
  final FlutterSecureStorage _storage;
  static const String _contactsKey = 'app_contacts';
  static const String _recentKey = 'recent_contacts';
  static const int _maxContactSyncBatchSize = 500;
  bool _contactsGrantedByFlutterPlugin = false;

  ContactsService(this._storage);

  /// Get device contacts only when permission is already granted.
  ///
  /// Do not request permission here: callers must ask from an explicit user
  /// action so unrelated app startup or background reads cannot trigger the
  /// iOS Contacts system prompt.
  Future<List<Contact>> getDeviceContacts() async {
    final status = await ph.Permission.contacts.status;
    if (!_canReadContacts(status) && !_contactsGrantedByFlutterPlugin) {
      return [];
    }

    try {
      return await FlutterContacts.getAll(
        properties: const {ContactProperty.name, ContactProperty.phone},
      );
    } on Object {
      _contactsGrantedByFlutterPlugin = false;
      return [];
    }
  }

  /// Get contacts as ContactInfo (simplified for picker)
  Future<List<ContactInfo>> getContacts() async {
    final contacts = await getDeviceContacts();
    return contacts
        .where((c) => c.phones.isNotEmpty)
        .map(
          (c) => ContactInfo(
            name: c.displayName ?? '',
            phoneNumber: _normalizePhone(c.phones.first.number),
          ),
        )
        .toList();
  }

  /// Get saved app contacts
  Future<List<AppContact>> getSavedContacts() async {
    final data = await _storage.read(key: _contactsKey);
    if (data == null) return [];

    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => AppContact.fromJson(e)).toList();
  }

  /// Save contact to local storage
  Future<void> saveContact(AppContact contact) async {
    final contacts = await getSavedContacts();
    final index = contacts.indexWhere((c) => c.phone == contact.phone);

    if (index >= 0) {
      contacts[index] = contact;
    } else {
      contacts.add(contact);
    }

    await _storage.write(
      key: _contactsKey,
      value: jsonEncode(contacts.map((c) => c.toJson()).toList()),
    );
  }

  /// Get recent contacts (last 5 transfers)
  Future<List<AppContact>> getRecentContacts() async {
    final data = await _storage.read(key: _recentKey);
    if (data == null) return [];

    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => AppContact.fromJson(e)).toList();
  }

  /// Add to recent contacts
  Future<void> addToRecent(AppContact contact) async {
    final recents = await getRecentContacts();

    // Remove if already exists
    recents.removeWhere((c) => c.phone == contact.phone);

    // Add to front with updated timestamp
    recents.insert(0, contact.copyWith(lastTransfer: DateTime.now()));

    // Keep only last 10
    final trimmed = recents.take(10).toList();

    await _storage.write(
      key: _recentKey,
      value: jsonEncode(trimmed.map((c) => c.toJson()).toList()),
    );
  }

  /// Convert device contact to app contact
  AppContact deviceToAppContact(Contact contact) {
    final phone = contact.phones.isNotEmpty
        ? _normalizePhone(contact.phones.first.number)
        : '';

    return AppContact(
      id: contact.id ?? contact.displayName ?? phone,
      name: contact.displayName ?? phone,
      phone: phone,
      hasApp: false,
    );
  }

  String _normalizePhone(String phone) {
    // Remove spaces, dashes, etc.
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  /// Request contacts permission
  Future<bool> requestContactsPermission() async {
    final current = await ph.Permission.contacts.status;
    if (_canReadContacts(current)) {
      _contactsGrantedByFlutterPlugin = true;
      return true;
    }
    if (current.isPermanentlyDenied) {
      return false;
    }

    final requested = await ph.Permission.contacts.request();
    if (_canReadContacts(requested)) {
      _contactsGrantedByFlutterPlugin = true;
      return true;
    }
    if (requested.isPermanentlyDenied || requested.isRestricted) {
      return false;
    }

    // Some platform/plugin combinations update FlutterContacts before
    // permission_handler observes the new state. Keep this as a narrow fallback
    // for the actual contact reader package.
    final pluginStatus = await FlutterContacts.permissions.request(
      PermissionType.read,
    );
    if (_canReadFlutterContacts(pluginStatus)) {
      _contactsGrantedByFlutterPlugin = true;
      return true;
    }

    final refreshed = _canReadContacts(await ph.Permission.contacts.status);
    _contactsGrantedByFlutterPlugin = refreshed;
    return refreshed;
  }

  /// Check if contacts permission is granted
  Future<bool> hasContactsPermission() async {
    if (_contactsGrantedByFlutterPlugin) {
      return true;
    }
    final status = await ph.Permission.contacts.status;
    final granted = _canReadContacts(status);
    _contactsGrantedByFlutterPlugin = granted;
    return granted;
  }

  Future<bool> contactsPermissionRequiresSettings() async {
    final status = await ph.Permission.contacts.status;
    return status.isPermanentlyDenied || status.isRestricted;
  }

  Future<void> openContactsSettings() async {
    await ph.openAppSettings();
  }

  bool _canReadContacts(ph.PermissionStatus status) =>
      status.isGranted || status.isLimited;

  bool _canReadFlutterContacts(PermissionStatus status) =>
      status == PermissionStatus.granted || status == PermissionStatus.limited;

  /// Normalize phone to E.164 format.
  ///
  /// Local phone book entries often omit the country code. Use the active user
  /// market as the default so US contacts hash as +1... and CI contacts hash as
  /// +225..., matching the backend phone_hash index.
  String normalizePhoneE164(
    String phone, {
    String defaultCountryPrefix = '225',
  }) {
    return PhoneNormalizer.toE164(phone, countryCode: defaultCountryPrefix);
  }

  /// Hash phone number using SHA-256
  String hashPhone(String phone, {String defaultCountryPrefix = '225'}) {
    final normalized = normalizePhoneE164(
      phone,
      defaultCountryPrefix: defaultCountryPrefix,
    );
    final bytes = utf8.encode(normalized);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Convert device contacts to synced contacts
  List<SyncedContact> deviceContactsToSyncedContacts(
    List<Contact> deviceContacts, {
    String defaultCountryPrefix = '225',
  }) {
    final List<SyncedContact> synced = [];

    for (final contact in deviceContacts) {
      if (contact.phones.isNotEmpty) {
        final phones = contact.phones
            .map(
              (phone) => normalizePhoneE164(
                phone.number,
                defaultCountryPrefix: defaultCountryPrefix,
              ),
            )
            .where((phone) => phone.length > 1)
            .toSet()
            .toList();
        if (phones.isEmpty) {
          continue;
        }

        final phone = phones.first;
        final name = contact.displayName ?? phone;

        synced.add(
          SyncedContact(
            id: contact.id ?? phone,
            name: name,
            phone: phone,
            lookupPhones: phones,
          ),
        );
      }
    }

    return synced;
  }

  /// Get Korido users from synced contacts
  ///
  /// Sends hashed phone numbers, receives matches with user info
  Future<List<SyncedContact>> getKoridoContacts(
    Dio dio,
    List<SyncedContact> allContacts, {
    String defaultCountryPrefix = '225',
  }) async {
    final contactHashes = {
      for (final contact in allContacts)
        contact:
            (contact.lookupPhones.isNotEmpty
                    ? contact.lookupPhones
                    : [contact.phone])
                .map(
                  (phone) => hashPhone(
                    phone,
                    defaultCountryPrefix: defaultCountryPrefix,
                  ),
                )
                .toSet(),
    };
    final hashes = contactHashes.values
        .expand((hashes) => hashes)
        .toSet()
        .toList();

    try {
      final matches = <_ContactSyncMatch>[];
      for (final batch in _hashBatches(hashes)) {
        final response = await dio.post(
          '/contacts/sync',
          data: {'phoneHashes': batch},
        );

        matches.addAll(_parseContactSyncMatches(response.data));
      }

      // Create a map of hash -> user info
      final matchMap = {for (final match in matches) match.phoneHash: match};

      // Mark matching contacts
      return allContacts.map((contact) {
        _ContactSyncMatch? match;
        for (final hash in contactHashes[contact] ?? const <String>{}) {
          match = matchMap[hash];
          if (match != null) {
            break;
          }
        }

        if (match != null) {
          return contact.copyWith(
            isKoridoUser: true,
            joonaPayUserId: match.userId,
            name: match.displayName ?? contact.name,
            username: match.username,
            maskedPhone: match.maskedPhone,
            avatarUrl: match.avatarUrl,
          );
        }

        return contact;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Submit already-normalized phone hashes to the backend in API-safe batches.
  Future<int> syncPhoneHashes(Dio dio, Iterable<String> phoneHashes) async {
    final hashes = phoneHashes
        .map((hash) => hash.trim().toLowerCase())
        .where((hash) => hash.isNotEmpty)
        .toSet()
        .toList();

    var matchCount = 0;
    for (final batch in _hashBatches(hashes)) {
      final response = await dio.post(
        '/contacts/sync',
        data: {'phoneHashes': batch},
      );
      matchCount += _contactSyncMatchCount(response.data);
    }

    return matchCount;
  }

  /// Sync contacts with Korido server
  Future<ContactSyncResult> syncContactsWithKorido(
    Dio dio,
    List<SyncedContact> contacts, {
    String defaultCountryPrefix = '225',
  }) async {
    final hashes = contacts
        .expand(
          (contact) => contact.lookupPhones.isNotEmpty
              ? contact.lookupPhones
              : [contact.phone],
        )
        .where((phone) => phone.trim().isNotEmpty)
        .map(
          (phone) =>
              hashPhone(phone, defaultCountryPrefix: defaultCountryPrefix),
        )
        .toSet()
        .toList();

    try {
      final matchCount = await syncPhoneHashes(dio, hashes);

      return ContactSyncResult(
        totalContacts: contacts.length,
        joonaPayUsersFound: matchCount,
        syncedAt: DateTime.now(),
      );
    } catch (e) {
      return ContactSyncResult(
        totalContacts: contacts.length,
        joonaPayUsersFound: 0,
        syncedAt: DateTime.now(),
        success: false,
        error: e.toString(),
      );
    }
  }

  int _contactSyncMatchCount(Object? data) {
    final payload = _asMap(data);
    final dataPayload = _asMap(payload['data']);
    final root = dataPayload.isNotEmpty ? dataPayload : payload;
    final matchesFound = root['matchesFound'] ?? root['matches_found'];
    if (matchesFound is num) return matchesFound.toInt();
    if (matchesFound is String) return int.tryParse(matchesFound) ?? 0;

    return _extractMapList(root, ['matches', 'users', 'contacts']).length;
  }

  Iterable<List<String>> _hashBatches(List<String> hashes) sync* {
    for (
      var start = 0;
      start < hashes.length;
      start += _maxContactSyncBatchSize
    ) {
      final end = (start + _maxContactSyncBatchSize).clamp(0, hashes.length);
      yield hashes.sublist(start, end);
    }
  }

  List<_ContactSyncMatch> _parseContactSyncMatches(Object? data) {
    return _extractMapList(data, ['matches', 'users', 'contacts'])
        .map((match) {
          final splitName = [
            _stringField(match, ['firstName', 'first_name']),
            _stringField(match, ['lastName', 'last_name']),
          ].where((part) => part.trim().isNotEmpty).join(' ');
          final displayName = _stringField(match, ['displayName', 'name'])
              .ifEmpty(splitName)
              .ifEmpty(_stringField(match, ['username', 'handle']));
          final avatarUrl = _stringField(match, [
            'avatarUrl',
            'photoUrl',
            'profilePhotoUrl',
          ]);
          final username = _stringField(match, ['username', 'handle']);
          final maskedPhone = _stringField(match, [
            'maskedPhone',
            'masked_phone',
          ]);

          return _ContactSyncMatch(
            phoneHash: _stringField(match, [
              'phoneHash',
              'hash',
              'phoneNumberHash',
            ]),
            userId: _stringField(match, [
              'userId',
              'koridoUserId',
              'joonaPayUserId',
              'id',
            ]),
            displayName: displayName.isEmpty ? null : displayName,
            username: username.isEmpty ? null : username,
            maskedPhone: maskedPhone.isEmpty ? null : maskedPhone,
            avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
          );
        })
        .where((match) => match.phoneHash.isNotEmpty && match.userId.isNotEmpty)
        .toList();
  }
}

extension _ContactStringFallback on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}

/// Contacts Service Provider
final contactsServiceProvider = Provider<ContactsService>((ref) {
  return ContactsService(ref.watch(secureStorageProvider));
});

/// Device Contacts Provider
final deviceContactsProvider = FutureProvider<List<Contact>>((ref) async {
  final service = ref.watch(contactsServiceProvider);
  return service.getDeviceContacts();
});

/// Saved Contacts Provider
final savedContactsProvider = FutureProvider<List<AppContact>>((ref) async {
  final service = ref.watch(contactsServiceProvider);
  return service.getSavedContacts();
});

/// Recent Contacts Provider
final recentContactsProvider = FutureProvider<List<AppContact>>((ref) async {
  final service = ref.watch(contactsServiceProvider);
  return service.getRecentContacts();
});

// ============================================
// API-BACKED CONTACTS SERVICE
// ============================================

/// Korido Contacts Service - syncs with backend
class KoridoContactsService {
  final Dio _dio;

  KoridoContactsService(this._dio);

  /// Get all saved contacts from backend
  Future<List<domain.Contact>> getContacts() async {
    final response = await _dio.get('/contacts');
    final contacts = _extractMapList(response.data, ['contacts', 'items']);
    return contacts.map(domain.Contact.fromJson).toList();
  }

  /// Get favorite contacts
  Future<List<domain.Contact>> getFavorites() async {
    final response = await _dio.get('/contacts/favorites');
    final contacts = _extractMapList(response.data, ['contacts', 'items']);
    return contacts.map(domain.Contact.fromJson).toList();
  }

  /// Get recent contacts (last transactions)
  Future<List<domain.Contact>> getRecents() async {
    final response = await _dio.get('/contacts/recents');
    final contacts = _extractMapList(response.data, ['contacts', 'items']);
    return contacts.map(domain.Contact.fromJson).toList();
  }

  /// Search contacts by name or username
  Future<List<domain.Contact>> searchContacts(String query) async {
    final response = await _dio.get(
      '/contacts/search',
      queryParameters: {'query': query},
    );
    final contacts = _extractMapList(response.data, ['contacts', 'items']);
    return contacts.map(domain.Contact.fromJson).toList();
  }

  /// Lookup discoverable Korido users for recipient search.
  Future<List<SyncedContact>> lookupKoridoUsers(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return const [];

    final response = await _dio.get(
      '/contacts/lookup',
      queryParameters: {'query': trimmed},
    );
    return _extractMapList(response.data, ['users', 'contacts', 'items'])
        .map((user) {
          final userId = _stringField(user, ['id', 'userId', 'koridoUserId']);
          final username = _stringField(user, ['username', 'handle']);
          final rawPhone = _stringField(user, ['phoneNumber', 'phone']);
          final explicitMaskedPhone = _stringField(user, ['maskedPhone']);
          final maskedPhone = explicitMaskedPhone.isNotEmpty
              ? explicitMaskedPhone
              : _isMaskedPhone(rawPhone)
              ? rawPhone
              : '';
          final safePhone = _isMaskedPhone(rawPhone) ? '' : rawPhone;
          final name = _stringField(user, [
            'name',
            'displayName',
            'username',
            'firstName',
            'phoneNumber',
            'maskedPhone',
            'phone',
          ]);

          return SyncedContact(
            id: userId,
            name: name.isNotEmpty
                ? name
                : maskedPhone.isNotEmpty
                ? maskedPhone
                : 'Korido user',
            phone: safePhone,
            maskedPhone: maskedPhone.isEmpty ? null : maskedPhone,
            isKoridoUser: user['isKoridoUser'] as bool? ?? true,
            joonaPayUserId: userId,
            username: username.isEmpty ? null : username,
            avatarUrl: _stringField(user, ['avatarUrl', 'photoUrl']),
          );
        })
        .where((user) => user.id.isNotEmpty)
        .toList();
  }

  /// Create a new contact
  Future<domain.Contact> createContact({
    required String name,
    String? phone,
    String? walletAddress,
    String? username,
  }) async {
    final response = await _dio.post(
      '/contacts',
      data: {
        'name': name,
        if (phone != null) 'phone': phone,
        if (walletAddress != null) 'walletAddress': walletAddress,
        if (username != null) 'username': username,
      },
    );
    return domain.Contact.fromJson(_responseObject(response.data));
  }

  /// Update contact
  Future<domain.Contact> updateContact({
    required String contactId,
    String? name,
    bool? isFavorite,
  }) async {
    final response = await _dio.put(
      '/contacts/$contactId',
      data: {
        if (name != null) 'name': name,
        if (isFavorite != null) 'isFavorite': isFavorite,
      },
    );
    return domain.Contact.fromJson(_responseObject(response.data));
  }

  /// Toggle favorite status
  Future<domain.Contact> toggleFavorite(String contactId) async {
    final response = await _dio.put('/contacts/$contactId/favorite');
    return domain.Contact.fromJson(_responseObject(response.data));
  }

  /// Delete contact
  Future<void> deleteContact(String contactId) async {
    await _dio.delete('/contacts/$contactId');
  }
}

bool _isMaskedPhone(String value) {
  if (value.isEmpty) return false;
  final normalized = value.toLowerCase();
  return normalized.contains('*') ||
      normalized.contains('•') ||
      normalized.contains('x');
}

Map<String, dynamic> _responseObject(Object? payload) {
  final map = _asMap(payload);
  final data = map['data'];
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return map;
}

/// Korido Contacts Service Provider
final koridoContactsServiceProvider = Provider<KoridoContactsService>((ref) {
  return KoridoContactsService(ref.watch(dioProvider));
});

/// Deprecated alias kept for older screens while the app finishes the rename.
final joonaPayContactsServiceProvider = koridoContactsServiceProvider;

/// All Korido Contacts Provider
final joonaPayContactsProvider =
    FutureProvider.autoDispose<List<domain.Contact>>((ref) async {
      final service = ref.watch(koridoContactsServiceProvider);
      return service.getContacts();
    });

/// Favorite Contacts Provider
final favoriteContactsProvider =
    FutureProvider.autoDispose<List<domain.Contact>>((ref) async {
      final service = ref.watch(koridoContactsServiceProvider);
      return service.getFavorites();
    });

/// Recent Korido Contacts Provider
final recentKoridoContactsProvider =
    FutureProvider.autoDispose<List<domain.Contact>>((ref) async {
      final service = ref.watch(koridoContactsServiceProvider);
      return service.getRecents();
    });
