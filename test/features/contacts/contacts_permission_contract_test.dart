import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contacts permission is requested only from explicit user action', () {
    final providerSource = File(
      'lib/features/contacts/providers/contacts_provider.dart',
    ).readAsStringSync();
    final pickerSource = File(
      'lib/features/send/widgets/contact_picker_bottom_sheet.dart',
    ).readAsStringSync();
    final serviceSource = File(
      'lib/services/contacts/contacts_service.dart',
    ).readAsStringSync();
    final recipientSource = File(
      'lib/features/send/views/recipient_screen.dart',
    ).readAsStringSync();
    final entrySource = File(
      'lib/features/contacts/views/contacts_entry_screen.dart',
    ).readAsStringSync();
    final permissionScreenSource = File(
      'lib/features/contacts/views/contacts_permission_screen.dart',
    ).readAsStringSync();
    final listSource = File(
      'lib/features/contacts/views/contacts_list_screen.dart',
    ).readAsStringSync();

    final syncContactsBody = _methodBody(providerSource, 'syncContacts');
    final requestPermissionBody = _methodBody(
      providerSource,
      'requestPermission',
    );

    expect(syncContactsBody, contains('hasContactsPermission'));
    expect(syncContactsBody, contains('permissionRequired: true'));
    expect(syncContactsBody, isNot(contains('requestContactsPermission')));

    expect(requestPermissionBody, contains('requestContactsPermission'));
    expect(requestPermissionBody, contains('await syncContacts()'));

    final pickerPermissionBody = _methodBody(
      pickerSource,
      '_requestContactsPermission',
    );
    final pickerPermissionCard = _methodBody(
      pickerSource,
      '_buildPermissionRequestCard',
    );

    expect(pickerPermissionBody, contains('requestContactsPermission'));
    expect(
      pickerPermissionBody,
      contains('contactsPermissionRequiresSettings'),
    );
    expect(pickerPermissionBody, contains('openContactsSettings'));
    expect(pickerPermissionBody, isNot(contains('Permission.contacts.status')));
    expect(pickerPermissionCard, contains('_requiresSettings'));
    expect(
      pickerPermissionCard,
      isNot(contains('variant: AppButtonVariant.secondary')),
    );
    expect(
      pickerSource,
      contains('canShowLookupWithoutContacts'),
      reason:
          'Korido username/account search should remain available without phone-book permission',
    );
    expect(
      pickerSource,
      contains('_permissionRequired && !canShowLookupWithoutContacts'),
    );
    expect(pickerSource, contains('_buildLookupSection(colors)'));
    expect(pickerSource, contains('_buildPermissionRequestCard(colors)'));
    expect(serviceSource, contains('_contactsGrantedByFlutterPlugin'));
    expect(serviceSource, contains('FlutterContacts.permissions.request'));
    expect(serviceSource, contains('PermissionType.read'));
    expect(pickerSource, contains('contactsService.hasContactsPermission'));
    expect(pickerSource, isNot(contains('permission_handler')));
    expect(pickerSource, contains('_readSyncedDeviceContacts'));
    expect(entrySource, contains('contactsServiceProvider'));
    expect(entrySource, contains('hasContactsPermission'));
    expect(entrySource, isNot(contains('permission_handler')));
    expect(permissionScreenSource, contains('openContactsSettings'));
    expect(permissionScreenSource, isNot(contains('permission_handler')));
    expect(listSource, contains('openContactsSettings'));
    expect(listSource, isNot(contains('permission_handler')));
    expect(listSource, contains('_loadContactsOrRouteToPermission'));
    expect(
      listSource,
      contains('final routed = await _routeToPermissionPromptIfNeeded();'),
      reason:
          'contacts list startup should not sync and show an inline error while also routing first-time users to the permission explainer',
    );
    expect(
      listSource,
      contains('if (!routed && mounted)'),
      reason:
          'background contact sync must only run after the permission route decision is settled',
    );

    final recipientContactBody = _methodBody(
      recipientSource,
      '_selectFromContacts',
    );

    expect(recipientSource, isNot(contains('permission_handler')));
    expect(recipientContactBody, contains('ContactPickerBottomSheet'));
    expect(recipientContactBody, isNot(contains('requestContactsPermission')));
    expect(recipientContactBody, isNot(contains('Permission.contacts')));
  });
}

String _methodBody(String source, String methodName) {
  final signatures = [
    'Future<void> $methodName()',
    'Future<bool> $methodName()',
    'Widget $methodName(',
  ];
  final signatureIndex = signatures
      .map(source.indexOf)
      .where((index) => index >= 0)
      .fold<int>(-1, (current, index) => current == -1 ? index : current);
  expect(signatureIndex, isNonNegative, reason: '$methodName should exist');

  final bodyStart = source.indexOf('{', signatureIndex);
  expect(bodyStart, isNonNegative, reason: '$methodName should have a body');

  var depth = 0;
  for (var i = bodyStart; i < source.length; i++) {
    final char = source[i];
    if (char == '{') {
      depth++;
    }
    if (char == '}') {
      depth--;
    }
    if (depth == 0) {
      return source.substring(bodyStart, i + 1);
    }
  }

  fail('Could not parse $methodName body');
}
