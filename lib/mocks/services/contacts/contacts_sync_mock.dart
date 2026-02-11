import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// Mock data for contact sync feature
class ContactsSyncMock {
  static void register(MockInterceptor interceptor) {
    // POST /contacts/sync
    interceptor.register(
      method: 'POST',
      path: '/contacts/sync',
      handler: _handleContactsSync,
    );

    // POST /contacts/invite
    interceptor.register(
      method: 'POST',
      path: '/contacts/invite',
      handler: _handleContactsInvite,
    );
  }

  /// Handle POST /contacts/sync
  static Future<MockResponse> _handleContactsSync(RequestOptions options) async {
    final data = options.data as Map<String, dynamic>;
    final phoneHashes = (data['phoneHashes'] as List).cast<String>();

    // Simulate matching against known JoonaPay users
    final matches = _getMatchingUsers(phoneHashes);

    return MockResponse.success({
      'matches': matches,
      'totalChecked': phoneHashes.length,
      'matchesFound': matches.length,
    });
  }

  /// Handle POST /contacts/invite
  static Future<MockResponse> _handleContactsInvite(RequestOptions options) async {
    return MockResponse.success({
      'success': true,
      'message': 'Invitation sent successfully',
    });
  }

  /// Mock JoonaPay users database
  /// In production, these would be real users in the backend
  static final List<Map<String, dynamic>> _mockJoonaPayUsers = [
    {
      'phone': '+2250701234567',
      'userId': 'user_amadou_123',
      'name': 'Amadou Diallo',
      'avatarUrl': 'https://i.pravatar.cc/150?img=12',
    },
    {
      'phone': '+2250707654321',
      'userId': 'user_fatou_456',
      'name': 'Fatou Traoré',
      'avatarUrl': 'https://i.pravatar.cc/150?img=5',
    },
    {
      'phone': '+2250709876543',
      'userId': 'user_koffi_789',
      'name': 'Koffi Kouassi',
      'avatarUrl': null,
    },
  ];

  /// Hash phone number (matches ContactsService.hashPhone)
  static String _hashPhone(String phone) {
    final bytes = utf8.encode(phone);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get matching users from hashes
  static List<Map<String, dynamic>> _getMatchingUsers(List<String> hashes) {
    final matches = <Map<String, dynamic>>[];

    for (final user in _mockJoonaPayUsers) {
      final userPhone = user['phone'] as String;
      final userHash = _hashPhone(userPhone);

      if (hashes.contains(userHash)) {
        matches.add({
          'phoneHash': userHash,
          'userId': user['userId'],
          'avatarUrl': user['avatarUrl'],
        });
      }
    }

    return matches;
  }
}

/// Mock device contacts for testing
class MockDeviceContacts {
  static final List<Map<String, String>> contacts = [
    // JoonaPay users (will match)
    {'name': 'Amadou Diallo', 'phone': '+225 07 01 23 45 67'},
    {'name': 'Fatou Traoré', 'phone': '+225 07 07 65 43 21'},
    {'name': 'Koffi Kouassi', 'phone': '+225 07 09 87 65 43'},

    // Non-JoonaPay users (won't match)
    {'name': 'Yao N\'Guessan', 'phone': '+225 07 11 11 11 11'},
    {'name': 'Aissata Koné', 'phone': '+225 07 22 22 22 22'},
    {'name': 'Mamadou Coulibaly', 'phone': '+225 07 33 33 33 33'},
    {'name': 'Aya Koné', 'phone': '+225 07 44 44 44 44'},
    {'name': 'Ibrahim Touré', 'phone': '+225 07 55 55 55 55'},
    {'name': 'Mariame Bamba', 'phone': '+225 07 66 66 66 66'},
    {'name': 'Seydou Sanogo', 'phone': '+225 07 77 77 77 77'},
  ];
}
