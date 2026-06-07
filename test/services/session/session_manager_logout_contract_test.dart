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

      // Contract: the backend session must be revoked via logout() first;
      // clearLocalSession() is only the fallback when backend logout fails,
      // so the user is never left locally authenticated.
      _expectBackendRevokeBeforeLocalCleanup(warningLogoutBody);
      _expectBackendRevokeBeforeLocalCleanup(expireSessionBody);
    },
  );
}

void _expectBackendRevokeBeforeLocalCleanup(String body) {
  expect(body, contains('.logout()'));
  final logoutIndex = body.indexOf('.logout()');
  final clearIndex = body.indexOf('.clearLocalSession()');
  if (clearIndex >= 0) {
    expect(
      logoutIndex,
      lessThan(clearIndex),
      reason: 'backend logout must be attempted before local cleanup',
    );
    expect(
      body,
      contains('if (!didClearSession)'),
      reason: 'local cleanup must only run when backend logout failed',
    );
  }
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
