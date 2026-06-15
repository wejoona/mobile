import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('session timeout actions clear local session before remote cleanup', () {
    final source = File(
      'lib/services/session/session_manager.dart',
    ).readAsStringSync();

    final warningLogoutBody = _methodBody(source, '_logoutFromSessionWarning');
    final expireSessionBody = _methodBody(source, '_expireSession');

    // Contract: logout from the warning/expiry path must use AuthNotifier's
    // default local-first logout. Backend revocation and push-token cleanup
    // continue best-effort in the background so the user is never left
    // locally authenticated behind the modal.
    _expectLocalFirstLogout(warningLogoutBody);
    _expectLocalFirstLogout(expireSessionBody);

    expect(source, contains('isResolving: _isResolvingSessionWarning'));
    expect(source, contains('final authState = ref.watch(authProvider)'));
    expect(source, contains('authState.isAuthenticated &&'));
    expect(source, isNot(contains('!_isResolvingSessionWarning &&')));
    expect(source, contains('isLoading: isResolving'));
    expect(source, contains('onPressed: isResolving ? null : onLogout'));
    expect(source, contains('(remainingSeconds / 60).clamp(0.0, 1.0)'));
  });
}

void _expectLocalFirstLogout(String body) {
  expect(body, contains('.logout()'));
  expect(body, isNot(contains('.logout(localFirst: false)')));
  final logoutIndex = body.indexOf('.logout()');
  final clearIndex = body.indexOf('.clearLocalSession()');
  if (clearIndex >= 0) {
    expect(
      logoutIndex,
      lessThan(clearIndex),
      reason: 'local-first logout should be attempted before fallback cleanup',
    );
    expect(
      body,
      contains('if (!didClearSession)'),
      reason: 'fallback cleanup should only run when logout itself failed',
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
