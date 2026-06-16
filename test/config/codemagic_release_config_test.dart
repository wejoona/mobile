import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Codemagic release configuration', () {
    late String codemagic;
    late String prodEnv;
    late String stagingEnv;

    setUpAll(() {
      codemagic = File('codemagic.yaml').readAsStringSync();
      prodEnv = File('env.prod.json').readAsStringSync();
      stagingEnv = File('env.staging.json').readAsStringSync();
    });

    test('builds staging iOS and Android with staging dart defines', () {
      const stagingDefine =
          r'--dart-define-from-file="$CM_BUILD_DIR/env.staging.json"';

      expect(codemagic, contains(stagingDefine));
      expect(
        RegExp(
          r'flutter build ipa --release[\s\S]*?'
          r'--dart-define-from-file="\$CM_BUILD_DIR/env\.staging\.json"',
        ).hasMatch(codemagic),
        isTrue,
      );
      expect(
        RegExp(
          r'\./gradlew :app:bundleRelease[\s\S]*?'
          r'-Pdart-defines="\$DART_DEFINES"',
        ).hasMatch(codemagic),
        isTrue,
      );
      expect(codemagic, contains('ENV=staging'));
      expect(
        codemagic,
        contains('API_URL=https://staging-api.joonapay.com/api/v1'),
      );
    });

    test('production dart define file selects live production mode', () {
      expect(prodEnv, contains('"ENV": "production"'));
      expect(prodEnv, contains('"API_URL": "https://api.joonapay.com/api/v1"'));
      expect(prodEnv, isNot(contains('127.0.0.1')));
      expect(prodEnv, isNot(contains('USE_MOCKS')));
    });

    test('staging dart define file follows staging DNS prefix convention', () {
      expect(stagingEnv, contains('"ENV": "staging"'));
      expect(
        stagingEnv,
        contains('"API_URL": "https://staging-api.joonapay.com/api/v1"'),
      );
      expect(stagingEnv, isNot(contains('api-staging')));
      expect(stagingEnv, isNot(contains('127.0.0.1')));
      expect(stagingEnv, isNot(contains('USE_MOCKS')));
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
