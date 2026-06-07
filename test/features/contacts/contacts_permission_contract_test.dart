import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contacts permission is requested only from explicit user action', () {
    final providerSource = File(
      'lib/features/contacts/providers/contacts_provider.dart',
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
  });
}

String _methodBody(String source, String methodName) {
  final signatureIndex = source.indexOf('Future<void> $methodName()') >= 0
      ? source.indexOf('Future<void> $methodName()')
      : source.indexOf('Future<bool> $methodName()');
  expect(signatureIndex, isNonNegative, reason: '$methodName should exist');

  final bodyStart = source.indexOf('{', signatureIndex);
  expect(bodyStart, isNonNegative, reason: '$methodName should have a body');

  var depth = 0;
  for (var i = bodyStart; i < source.length; i++) {
    final char = source[i];
    if (char == '{') depth++;
    if (char == '}') depth--;
    if (depth == 0) return source.substring(bodyStart, i + 1);
  }

  fail('Could not parse $methodName body');
}
