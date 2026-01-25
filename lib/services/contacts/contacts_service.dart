import 'package:dio/dio.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../api/api_client.dart';
import '../../domain/entities/contact.dart' as domain;

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

  ContactsService(this._storage);

  /// Request permission and get device contacts
  Future<List<Contact>> getDeviceContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      return [];
    }
    return FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    );
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
    recents.insert(
      0,
      contact.copyWith(lastTransfer: DateTime.now()),
    );

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
      id: contact.id,
      name: contact.displayName,
      phone: phone,
      hasApp: false,
    );
  }

  String _normalizePhone(String phone) {
    // Remove spaces, dashes, etc.
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }
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

/// JoonaPay Contacts Service - syncs with backend
class JoonaPayContactsService {
  final Dio _dio;

  JoonaPayContactsService(this._dio);

  /// Get all saved contacts from backend
  Future<List<domain.Contact>> getContacts() async {
    final response = await _dio.get('/contacts');
    final data = response.data as Map<String, dynamic>;
    final contacts = data['contacts'] as List;
    return contacts
        .map((c) => domain.Contact.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  /// Get favorite contacts
  Future<List<domain.Contact>> getFavorites() async {
    final response = await _dio.get('/contacts/favorites');
    final data = response.data as Map<String, dynamic>;
    final contacts = data['contacts'] as List;
    return contacts
        .map((c) => domain.Contact.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  /// Get recent contacts (last transactions)
  Future<List<domain.Contact>> getRecents() async {
    final response = await _dio.get('/contacts/recents');
    final data = response.data as Map<String, dynamic>;
    final contacts = data['contacts'] as List;
    return contacts
        .map((c) => domain.Contact.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  /// Search contacts by name or username
  Future<List<domain.Contact>> searchContacts(String query) async {
    final response = await _dio.get('/contacts/search', queryParameters: {
      'query': query,
    });
    final data = response.data as Map<String, dynamic>;
    final contacts = data['contacts'] as List;
    return contacts
        .map((c) => domain.Contact.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  /// Create a new contact
  Future<domain.Contact> createContact({
    required String name,
    String? phone,
    String? walletAddress,
    String? username,
  }) async {
    final response = await _dio.post('/contacts', data: {
      'name': name,
      if (phone != null) 'phone': phone,
      if (walletAddress != null) 'walletAddress': walletAddress,
      if (username != null) 'username': username,
    });
    return domain.Contact.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update contact
  Future<domain.Contact> updateContact({
    required String contactId,
    String? name,
    bool? isFavorite,
  }) async {
    final response = await _dio.put('/contacts/$contactId', data: {
      if (name != null) 'name': name,
      if (isFavorite != null) 'isFavorite': isFavorite,
    });
    return domain.Contact.fromJson(response.data as Map<String, dynamic>);
  }

  /// Toggle favorite status
  Future<domain.Contact> toggleFavorite(String contactId) async {
    final response = await _dio.put('/contacts/$contactId/favorite');
    return domain.Contact.fromJson(response.data as Map<String, dynamic>);
  }

  /// Delete contact
  Future<void> deleteContact(String contactId) async {
    await _dio.delete('/contacts/$contactId');
  }
}

/// JoonaPay Contacts Service Provider
final joonaPayContactsServiceProvider = Provider<JoonaPayContactsService>((ref) {
  return JoonaPayContactsService(ref.watch(dioProvider));
});

/// All JoonaPay Contacts Provider
final joonaPayContactsProvider =
    FutureProvider.autoDispose<List<domain.Contact>>((ref) async {
  final service = ref.watch(joonaPayContactsServiceProvider);
  return service.getContacts();
});

/// Favorite Contacts Provider
final favoriteContactsProvider =
    FutureProvider.autoDispose<List<domain.Contact>>((ref) async {
  final service = ref.watch(joonaPayContactsServiceProvider);
  return service.getFavorites();
});

/// Recent JoonaPay Contacts Provider
final recentJoonaPayContactsProvider =
    FutureProvider.autoDispose<List<domain.Contact>>((ref) async {
  final service = ref.watch(joonaPayContactsServiceProvider);
  return service.getRecents();
});
