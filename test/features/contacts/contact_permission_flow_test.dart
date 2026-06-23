import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Contacts permission flow', () {
    test(
      'contacts screen open shows inline permission, manual sync can recover',
      () {
        final source = File(
          'lib/features/contacts/views/contacts_list_screen.dart',
        ).readAsStringSync();
        final providerSource = File(
          'lib/features/contacts/providers/contacts_provider.dart',
        ).readAsStringSync();
        final initBody = RegExp(
          r'void initState\(\) \{([\s\S]*?)\n  @override',
        ).firstMatch(source)!.group(1)!;
        final loadBody = RegExp(
          r'Future<void> _loadContacts\(\) async \{([\s\S]*?)\n  Future<void> _requestPermissionAndSync',
        ).firstMatch(source)!.group(1)!;
        final manualSyncBody = RegExp(
          r'Future<void> _manualSync\(\) async \{([\s\S]*?)\n  Future<void> _loadContacts',
        ).firstMatch(source)!.group(1)!;
        final requestAndSyncBody = RegExp(
          r'Future<void> _requestPermissionAndSync\(\{([\s\S]*?)\n  @override',
        ).firstMatch(source)!.group(1)!;

        expect(
          initBody,
          contains('WidgetsBinding.instance.addPostFrameCallback'),
        );
        expect(initBody, contains('_loadContacts()'));
        expect(source, contains('with WidgetsBindingObserver'));
        expect(source, contains('WidgetsBinding.instance.addObserver(this)'));
        expect(
          source,
          contains('WidgetsBinding.instance.removeObserver(this)'),
        );
        expect(source, contains('didChangeAppLifecycleState'));
        expect(source, contains('AppLifecycleState.resumed'));
        expect(source, contains('contactsState.permissionRequired'));
        expect(source, contains('contactsState.permissionRequiresSettings'));
        expect(loadBody, contains('syncContacts()'));
        expect(
          initBody,
          isNot(
            contains('_requestPermissionAndSync(showSettingsDialog: false)'),
          ),
        );
        expect(source, isNot(contains("context.go('/contacts/permission')")));
        expect(source, isNot(contains('_routeToPermissionPromptIfNeeded')));
        expect(
          manualSyncBody,
          contains('_requestPermissionAndSync(showSettingsDialog: true)'),
        );
        expect(requestAndSyncBody, contains('notifier.requestPermission()'));
        expect(
          requestAndSyncBody,
          isNot(contains('Permission.contacts.status')),
        );
        expect(
          requestAndSyncBody,
          contains('state.permissionRequiresSettings'),
        );
        expect(requestAndSyncBody, contains('_showContactsSettingsDialog'));
        expect(providerSource, contains('permissionRequiresSettings'));
        expect(
          providerSource,
          contains('contactsPermissionRequiresSettings()'),
        );
        expect(source, contains('requiresSettings'));
        expect(source, contains('l10n.action_open_settings'));
      },
    );

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
      expect(searchBody, contains('_lookupFailed = false'));
      expect(lookupBody, contains('lookupKoridoUsers(query)'));
      expect(lookupBody, contains('localPhones'));
      expect(lookupBody, contains('localUserIds'));
      expect(lookupBody, contains('_lookupFailed = true'));
      expect(source, contains('!_isLookupLoading'));
      expect(
        source,
        isNot(
          contains(
            'if (!state.permissionRequired)\n                    Padding',
          ),
        ),
      );
    });
  });
}
