# Integration Tests

End-to-end integration tests for the JoonaPay mobile app.

## Overview

This test suite covers all critical user flows in the app:

- **Authentication**: Login, registration, OTP verification, logout
- **Send Money**: P2P transfers, beneficiary selection, PIN verification
- **Deposit**: Mobile money deposits (Orange Money, MTN, Wave)
- **Withdraw**: Mobile money withdrawals
- **KYC**: Document upload and verification flow
- **Settings**: PIN change, biometric, profile edit, language
- **Beneficiaries**: Add, edit, delete, favorite beneficiaries

## Structure

```
integration_test/
├── app_test.dart                  # Main test entry point
├── flows/                         # Test flows by feature
│   ├── auth_flow_test.dart
│   ├── send_money_flow_test.dart
│   ├── deposit_flow_test.dart
│   ├── withdraw_flow_test.dart
│   ├── kyc_flow_test.dart
│   ├── settings_flow_test.dart
│   └── beneficiary_flow_test.dart
├── robots/                        # Page object models
│   ├── auth_robot.dart
│   ├── wallet_robot.dart
│   ├── send_robot.dart
│   └── settings_robot.dart
├── helpers/                       # Test utilities
│   ├── test_helpers.dart
│   └── test_data.dart
└── test_driver/
    └── integration_test.dart      # Test driver for devices
```

## Running Tests

### Prerequisites

1. Ensure device/emulator is running:
```bash
# List devices
flutter devices

# Start emulator (if needed)
open -a Simulator  # iOS
# or
emulator -avd <avd_name>  # Android
```

2. Install dependencies:
```bash
cd mobile
flutter pub get
```

### Run All Tests

On simulator/emulator (fast):
```bash
flutter test integration_test/app_test.dart
```

On real device (full integration):
```bash
flutter drive \
  --driver=integration_test/test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

### Run Specific Flow

Run only auth tests:
```bash
flutter test integration_test/flows/auth_flow_test.dart
```

Run only send money tests:
```bash
flutter test integration_test/flows/send_money_flow_test.dart
```

### Run on Specific Device

```bash
flutter test integration_test/app_test.dart -d "iPhone 15"
flutter test integration_test/app_test.dart -d "Pixel 7"
```

### Debug Mode

Run with verbose output:
```bash
flutter test integration_test/app_test.dart --verbose
```

Run with screenshots on failure:
```bash
flutter drive \
  --driver=integration_test/test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  --screenshot=integration_test/screenshots/
```

## Test Data

All test data is West African context-aware:

### Test Credentials
- **Phone**: +225 07 12 34 56 78 (Côte d'Ivoire)
- **OTP**: 123456 (dev mode)
- **PIN**: 123456 (dev mode)

### Test Users
- Amadou Diallo (Côte d'Ivoire)
- Fatou Traore (Senegal)
- Ibrahim Keita (Mali)

### Mobile Money Providers
- Orange Money
- MTN Mobile Money
- Wave
- Moov Money

### Test Amounts (XOF)
- Small: 1,000 XOF (~$1.60)
- Medium: 10,000 XOF (~$16)
- Large: 100,000 XOF (~$160)

See `helpers/test_data.dart` for complete test data.

## Robot Pattern

Tests use the Robot (Page Object) pattern for maintainability:

```dart
// Instead of:
await tester.enterText(find.byType(TextField), phone);
await tester.tap(find.text('Continue'));

// Use:
await authRobot.enterPhoneNumber(phone);
await authRobot.tapContinue();
```

Benefits:
- **Reusable**: Share logic across tests
- **Maintainable**: Update in one place
- **Readable**: Self-documenting test code

## Writing New Tests

### 1. Create Test File

```dart
// integration_test/flows/new_feature_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import '../helpers/test_helpers.dart';
import '../robots/auth_robot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('New Feature Tests', () {
    setUp(() async {
      await TestHelpers.clearAppData();
    });

    testWidgets('Test case description', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        // Test logic here

      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'test_error');
        rethrow;
      }
    });
  });
}
```

### 2. Create Robot (if needed)

```dart
// integration_test/robots/new_feature_robot.dart
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

class NewFeatureRobot {
  final WidgetTester tester;

  NewFeatureRobot(this.tester);

  Future<void> doAction() async {
    await tester.tap(find.text('Action'));
    await tester.pumpAndSettle();
  }

  void verifyState() {
    expect(find.text('Expected'), findsOneWidget);
  }
}
```

### 3. Add Test Data (if needed)

```dart
// In helpers/test_data.dart
class TestData {
  static const newFeatureData = {
    'field': 'value',
  };
}
```

## Best Practices

### 1. Always Clean State
```dart
setUp(() async {
  await TestHelpers.clearAppData();
});
```

### 2. Use Screenshots on Failure
```dart
try {
  // test logic
} catch (e) {
  await TestHelpers.takeScreenshot(binding, 'descriptive_name');
  rethrow;
}
```

### 3. Wait for Animations
```dart
await tester.pumpAndSettle(); // Wait for all animations
```

### 4. Use Descriptive Test Names
```dart
testWidgets('Send money with insufficient balance shows error', ...);
// Not: testWidgets('Test send', ...);
```

### 5. Verify Before Acting
```dart
// Verify on correct screen before interacting
authRobot.verifyOnLoginScreen();
await authRobot.enterPhoneNumber(phone);
```

### 6. Handle Flakiness
```dart
// Wait for widget to appear
await TestHelpers.waitForWidget(tester, find.text('Expected'));

// Don't assume immediate availability
// await tester.tap(find.text('Expected')); // Might fail!
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/integration-tests.yml
name: Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.7'

      - name: Install dependencies
        run: |
          cd mobile
          flutter pub get

      - name: Run integration tests
        run: |
          cd mobile
          flutter test integration_test/app_test.dart
```

### Firebase Test Lab (Android)

```bash
# Build APK
flutter build apk --debug

# Build test APK
pushd android
./gradlew app:assembleDebugAndroidTest
./gradlew app:assembleDebug -Ptarget=integration_test/app_test.dart
popd

# Upload to Test Lab
gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --device model=Pixel2,version=30,locale=en,orientation=portrait
```

### AWS Device Farm (iOS)

```bash
# Build for testing
flutter build ios --debug integration_test/app_test.dart

# Create IPA
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -derivedDataPath build \
  -sdk iphoneos build-for-testing

# Upload to Device Farm
# (Use AWS Console or CLI)
```

## Troubleshooting

### Tests Timeout
- Increase timeout in `pubspec.yaml`:
```yaml
dev_dependencies:
  integration_test:
    sdk: flutter

flutter:
  test:
    timeout: 5m
```

### Widget Not Found
- Add waits: `await TestHelpers.waitForWidget(tester, finder)`
- Check if widget is scrolled off-screen: Use `scrollUntilVisible`
- Verify you're on the correct screen first

### Flaky Tests
- Add delays for animations: `await tester.pumpAndSettle()`
- Use `waitForWidget` instead of immediate taps
- Mock network calls to avoid dependency on API

### Permission Dialogs
- Tests might fail if permission dialogs appear
- Grant permissions before running tests:
```bash
# iOS
xcrun simctl privacy <device> grant photos <bundle-id>
xcrun simctl privacy <device> grant contacts <bundle-id>

# Android
adb shell pm grant <package> android.permission.CAMERA
adb shell pm grant <package> android.permission.READ_CONTACTS
```

### Screenshots Not Saving
- Ensure directory exists: `mkdir -p integration_test/screenshots`
- Check write permissions
- Use absolute paths

## Maintenance

### When to Update Tests

1. **UI Changes**: Update robots when widget structure changes
2. **New Features**: Add new flow tests
3. **API Changes**: Update test data
4. **Bugs**: Add regression tests

### Review Checklist

- [ ] All tests pass locally
- [ ] Tests pass on both iOS and Android
- [ ] Screenshots on failure enabled
- [ ] Test data is realistic
- [ ] Robots are reusable
- [ ] Tests are independent (no shared state)
- [ ] Assertions are meaningful
- [ ] Test names are descriptive

## Resources

- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Integration Test Package](https://pub.dev/packages/integration_test)
- [Robot Pattern](https://martinfowler.com/bliki/PageObject.html)

---

Last updated: 2026-01-29
