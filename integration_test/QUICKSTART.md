# Integration Tests - Quick Start

Get running with integration tests in 5 minutes.

## Prerequisites

1. Flutter installed (3.10.7+)
2. iOS Simulator or Android Emulator running
3. Xcode (for iOS) or Android Studio (for Android)

## Quick Start

### 1. Install Dependencies

```bash
cd mobile
flutter pub get
```

### 2. Start Device

**iOS:**
```bash
open -a Simulator
```

**Android:**
```bash
emulator -avd <your_avd_name>
```

Or start from Android Studio.

### 3. Run Tests

**Easiest way (all tests):**
```bash
./integration_test.sh
```

**Specific test:**
```bash
flutter test integration_test/flows/auth_flow_test.dart
```

**On specific device:**
```bash
flutter test integration_test/app_test.dart -d "iPhone 15"
```

That's it! Tests will run and report results.

## What Gets Tested

1. **Authentication** (2 min)
   - Registration with phone and OTP
   - Login flow
   - Logout

2. **Send Money** (3 min)
   - Select recipient
   - Enter amount
   - Confirm and verify PIN
   - View receipt

3. **Deposit** (2 min)
   - Select mobile money provider
   - Enter amount
   - Get USSD instructions

4. **Withdraw** (2 min)
   - Enter phone and amount
   - Select provider
   - Confirm with PIN

5. **KYC** (1 min)
   - View status
   - Select document type
   - Navigate capture flow

6. **Settings** (2 min)
   - Change PIN
   - Toggle biometric
   - Edit profile
   - Change language

7. **Beneficiaries** (1 min)
   - Add beneficiary
   - Edit details
   - Mark favorite
   - Delete

**Total runtime: ~15 minutes for all tests**

## Troubleshooting

### Tests fail immediately

**Check device is running:**
```bash
flutter devices
```

You should see your device listed.

### "Widget not found" errors

**Clean and rebuild:**
```bash
flutter clean
flutter pub get
flutter test integration_test/app_test.dart
```

### Tests timeout

**Increase timeout (if needed):**

Edit test file, add at top:
```dart
testWidgets('...', (tester) async {
  // ...
}, timeout: Timeout(Duration(minutes: 5)));
```

### Permission dialogs block tests

**Grant permissions before testing:**

**iOS:**
```bash
xcrun simctl privacy booted grant photos com.joonapay.wallet
xcrun simctl privacy booted grant contacts com.joonapay.wallet
```

**Android:**
```bash
adb shell pm grant com.joonapay.wallet android.permission.CAMERA
adb shell pm grant com.joonapay.wallet android.permission.READ_CONTACTS
```

## Next Steps

1. Read the full [README.md](README.md) for details
2. Explore test files in `flows/` directory
3. Check out `robots/` for reusable test helpers
4. Add new tests for your features

## Tips

### Run Faster

Test single flows during development:
```bash
flutter test integration_test/flows/send_money_flow_test.dart
```

### Debug Tests

Add breakpoints and run in debug mode:
```bash
flutter run integration_test/flows/auth_flow_test.dart --start-paused
```

### Visual Debugging

Add delays to watch tests run:
```dart
await TestHelpers.delay(Duration(seconds: 2)); // Pause to observe
```

### Save Screenshots

Screenshots are automatically saved on test failure to:
```
integration_test/screenshots/
```

## Common Commands

```bash
# Run all tests
flutter test integration_test/app_test.dart

# Run auth tests only
flutter test integration_test/flows/auth_flow_test.dart

# Run with verbose output
flutter test integration_test/app_test.dart --verbose

# Run on specific device
flutter test integration_test/app_test.dart -d "Pixel 7"

# Clean build before tests
flutter clean && flutter pub get && flutter test integration_test/app_test.dart
```

## Need Help?

1. Check [README.md](README.md) for detailed documentation
2. Review test examples in `flows/` directory
3. Look at `helpers/test_helpers.dart` for utilities
4. Check CI workflow: `.github/workflows/mobile-integration-tests.yml`

---

Happy testing! 🚀
