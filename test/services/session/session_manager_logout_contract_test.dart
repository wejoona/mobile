import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'session timeout actions revoke the backend session before local cleanup',
    () {
      final source = File(
        'lib/services/session/session_manager.dart',
      ).readAsStringSync();

      final warningLogoutBody = _methodBody(
        source,
        '_logoutFromSessionWarning',
      );
      final expireSessionBody = _methodBody(source, '_expireSession');

      expect(warningLogoutBody, contains('.logout()'));
      expect(warningLogoutBody, isNot(contains('.clearLocalSession()')));

      expect(expireSessionBody, contains('.logout()'));
      expect(expireSessionBody, isNot(contains('.clearLocalSession()')));
    },
  );
}

String _methodBody(String source, String methodName) {
  final signatureIndex = source.indexOf('Future<void> $methodName()');
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
