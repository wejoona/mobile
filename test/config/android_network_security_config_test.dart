import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android network security config', () {
    test('release config does not allow localhost cleartext', () {
      final xml = File(
        'android/app/src/main/res/xml/network_security_config.xml',
      ).readAsStringSync();

      expect(xml, isNot(contains('cleartextTrafficPermitted="true"')));
      expect(
        xml,
        isNot(contains('<domain includeSubdomains="false">localhost')),
      );
      expect(xml, contains('korido-api.joonapay.com'));
      expect(
        xml,
        isNot(contains('<domain includeSubdomains="true">api.joonapay.com')),
      );
      expect(xml, contains('DcXImxqsw11wXDKaem3Be3mcFibKSosQGkPpNOw9Zuw='));
    });

    test('debug config allows local API hosts only in debug resources', () {
      final xml = File(
        'android/app/src/debug/res/xml/network_security_config.xml',
      ).readAsStringSync();

      expect(xml, contains('cleartextTrafficPermitted="true"'));
      expect(xml, contains('<domain includeSubdomains="false">localhost'));
      expect(xml, contains('<domain includeSubdomains="false">10.0.2.2'));
      expect(xml, contains('<domain includeSubdomains="false">127.0.0.1'));
    });
  });
}
