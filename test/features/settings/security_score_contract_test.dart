import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('security score only suggests actionable current protections', () {
    final source = File(
      'lib/features/settings/views/security_view.dart',
    ).readAsStringSync();

    final tipBody = RegExp(
      r'String _getScoreTip\(.*?\) \{([\s\S]*?)\n  \}',
      multiLine: true,
    ).firstMatch(source)?.group(1);

    expect(tipBody, isNotNull);
    expect(tipBody, contains('security_tipEnableBiometrics'));
    expect(tipBody, contains('security_tipEnableNotifications'));
    expect(tipBody, contains('security_twoFactorComingSoonSubtitle'));
    expect(source, isNot(contains('security_tipEnable2FA')));
  });
}
