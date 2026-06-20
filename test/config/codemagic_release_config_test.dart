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

    test('iOS build declares export compliance for TestFlight submission', () {
      final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();

      expect(infoPlist, contains('<key>ITSAppUsesNonExemptEncryption</key>'));
      expect(
        RegExp(
          r'<key>ITSAppUsesNonExemptEncryption</key>\s*<false/>',
        ).hasMatch(infoPlist),
        isTrue,
      );
    });

    test('iOS bootstrap keeps the iOS 27 Flutter VSync launch guard', () {
      final workaround = File(
        'ios/Runner/FlutterViewController+KoridoIOS27VSyncWorkaround.m',
      ).readAsStringSync();
      final project = File(
        'ios/Runner.xcodeproj/project.pbxproj',
      ).readAsStringSync();

      expect(
        workaround,
        contains('KoridoShouldDisableIOS27FlutterTouchRateCorrection'),
      );
      expect(
        workaround,
        contains('createTouchRateCorrectionVSyncClientIfNeeded'),
        reason:
            'Flutter 3.44.2 crashes before Dart starts on iOS 27 beta when this touch-rate VSync hook runs.',
      );
      expect(workaround, contains('korido_disableIOS27TouchRateCorrection'));
      expect(workaround, contains('method_exchangeImplementations'));
      expect(
        project,
        contains(
          'FlutterViewController+KoridoIOS27VSyncWorkaround.m in Sources',
        ),
      );
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
        contains('API_URL=https://staging-korido-api.joonapay.com/api/v1'),
      );
      expect(
        codemagic,
        contains(
          'SENTRY_DSN=https://e940855066e902eafd3bf67348d625e7@sentry.wejoona.com/7',
        ),
      );
    });

    test('production dart define file selects live production mode', () {
      expect(prodEnv, contains('"ENV": "production"'));
      expect(
        prodEnv,
        contains('"API_URL": "https://korido-api.joonapay.com/api/v1"'),
      );
      expect(prodEnv, isNot(contains('127.0.0.1')));
      expect(prodEnv, isNot(contains('USE_MOCKS')));
    });

    test('staging dart define file follows staging DNS prefix convention', () {
      expect(stagingEnv, contains('"ENV": "staging"'));
      expect(
        stagingEnv,
        contains('"API_URL": "https://staging-korido-api.joonapay.com/api/v1"'),
      );
      expect(stagingEnv, contains('"SENTRY_DSN": "https://'));
      expect(stagingEnv, isNot(contains('api-staging')));
      expect(stagingEnv, isNot(contains('staging-api')));
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

    test('Android build uses the Flutter app version name from pubspec', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final version = RegExp(
        r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+\d+',
        multiLine: true,
      ).firstMatch(pubspec)?.group(1);

      expect(version, isNotNull);
      expect(version!.startsWith('1.'), isFalse);
      expect(codemagic, contains('APP_VERSION_NAME='));
      expect(codemagic, contains('flutter.versionName=%s'));
      expect(codemagic, isNot(contains('flutter.versionName=1.0.0')));
    });
  });
}
