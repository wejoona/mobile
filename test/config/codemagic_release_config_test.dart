import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Codemagic release configuration', () {
    late String codemagic;

    setUpAll(() {
      codemagic = File('codemagic.yaml').readAsStringSync();
    });

    test('builds iOS and Android with production dart defines', () {
      const prodDefine =
          r'--dart-define-from-file="$CM_BUILD_DIR/env.prod.json"';

      expect(codemagic, contains(prodDefine));
      expect(
        RegExp(
          r'flutter build ipa --release[\s\S]*?'
          r'--dart-define-from-file="\$CM_BUILD_DIR/env\.prod\.json"',
        ).hasMatch(codemagic),
        isTrue,
      );
      expect(
        RegExp(
          r'flutter build appbundle --release[\s\S]*?'
          r'--dart-define-from-file="\$CM_BUILD_DIR/env\.prod\.json"',
        ).hasMatch(codemagic),
        isTrue,
      );
    });

    test(
      'uses the configured Android application id for Play build lookup',
      () {
        final gradle = File('android/app/build.gradle.kts').readAsStringSync();
        final applicationId = RegExp(
          'applicationId = "([^"]+)"',
        ).firstMatch(gradle)?.group(1);

        expect(applicationId, isNotNull);
        expect(codemagic, contains('--package-name "$applicationId"'));
      },
    );
  });
}
