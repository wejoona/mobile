import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/services/security/auth/biometric_reenrollment_detector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.joonapay.usdc_wallet/biometrics');
  var nativeState = 'ios:first-state';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    nativeState = 'ios:first-state';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getEnrollmentStateHash') {
            return nativeState;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('stores baseline and reports unchanged biometric enrollment', () async {
    final detector = BiometricReenrollmentDetector();

    expect(await detector.hasEnrollmentChanged(), isFalse);
    expect(await detector.hasEnrollmentChanged(), isFalse);
  });

  test('detects and acknowledges biometric enrollment changes', () async {
    final detector = BiometricReenrollmentDetector();

    expect(await detector.hasEnrollmentChanged(), isFalse);

    nativeState = 'ios:second-state';
    expect(await detector.hasEnrollmentChanged(), isTrue);

    await detector.acknowledgeChange();
    expect(await detector.hasEnrollmentChanged(), isFalse);
  });

  test(
    'does not disrupt development when native biometric state is missing',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);

      final detector = BiometricReenrollmentDetector();

      expect(await detector.hasEnrollmentChanged(), isFalse);
    },
  );
}
