import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../api/api_client.dart';

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
