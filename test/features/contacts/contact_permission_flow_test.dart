import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Contacts permission flow', () {
    test('initial contact load does not request OS permission', () {
      final source = File(
        'lib/features/contacts/views/contacts_list_screen.dart',
      ).readAsStringSync();
      final loadBody = RegExp(
        r'Future<void> _loadContacts\(\) async \{([\s\S]*?)\n  Future<void> _manualSync',
      ).firstMatch(source)!.group(1)!;
      final manualSyncBody = RegExp(
        r'Future<void> _manualSync\(\) async \{([\s\S]*?)\n  @override',
      ).firstMatch(source)!.group(1)!;

      expect(loadBody, contains('syncContacts()'));
      expect(loadBody, isNot(contains('requestPermission()')));
      expect(manualSyncBody, contains('requestPermission()'));
    });

    test('contacts screen search uses backend Korido lookup', () {
      final source = File(
        'lib/features/contacts/views/contacts_list_screen.dart',
      ).readAsStringSync();
      final searchBody = RegExp(
        r'void _handleSearchChanged\(String value\) \{([\s\S]*?)\n  Future<void> _lookupKoridoUsers',
      ).firstMatch(source)!.group(1)!;
      final lookupBody = RegExp(
        r'Future<void> _lookupKoridoUsers\(String query\) async \{([\s\S]*?)\n  Future<void> _manualSync',
      ).firstMatch(source)!.group(1)!;

      expect(searchBody, contains('_lookupKoridoUsers(trimmed)'));
      expect(lookupBody, contains('lookupKoridoUsers(query)'));
      expect(lookupBody, contains('localPhones'));
      expect(lookupBody, contains('localUserIds'));
    });
  });
}
