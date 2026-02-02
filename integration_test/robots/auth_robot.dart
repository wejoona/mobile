import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_data.dart';

/// Enable mocks for integration tests
void enableTestMocks() {
  MockConfig.enableAllMocks();
}

/// Robot for authentication flows
class AuthRobot {
  final WidgetTester tester;

  AuthRobot(this.tester);

  // Login flow
  Future<void> enterPhoneNumber(String phone) async {
    final phoneField = find.byType(TextField).first;
    await tester.enterText(phoneField, phone);
    await tester.pumpAndSettle();
  }

  Future<void> selectCountry(String countryName) async {
    // Tap country picker
    await tester.tap(find.text('CI')); // Default country code displayed
    await tester.pumpAndSettle();

    // Select country from list
    await TestHelpers.scrollUntilVisible(tester, find.text(countryName));
    await tester.tap(find.text(countryName));
    await tester.pumpAndSettle();
  }

  Future<void> tapContinue() async {
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  Future<void> enterOtp(String otp) async {
    // Enter OTP digits
    for (int i = 0; i < otp.length; i++) {
      final digit = otp[i];
      final digitField = find.byType(TextField).at(i);
      await tester.enterText(digitField, digit);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  Future<void> tapResendOtp() async {
    await tester.tap(find.text('Resend code'));
    await tester.pumpAndSettle();
  }

  Future<void> enterPin(String pin) async {
    await TestHelpers.enterPin(tester, pin);
  }

  Future<void> tapLoginTab() async {
    // Try both possible texts
    final loginFinder = find.text('Sign in');
    if (loginFinder.evaluate().isNotEmpty) {
      await tester.tap(loginFinder);
    } else {
      await tester.tap(find.text('Login'));
    }
    await tester.pumpAndSettle();
  }

  Future<void> tapRegisterTab() async {
    // Try both possible texts
    final signUpFinder = find.text('Sign up');
    if (signUpFinder.evaluate().isNotEmpty) {
      await tester.tap(signUpFinder);
    } else {
      await tester.tap(find.text('Register'));
    }
    await tester.pumpAndSettle();
  }

  // Complete login flow
  Future<void> completeLogin({
    String? phone,
    String? otp,
    String? pin,
  }) async {
    final user = TestData.defaultUser;

    // Enter phone number
    await enterPhoneNumber(phone ?? user['phone'] as String);
    await tapContinue();

    // Wait for OTP screen
    await TestHelpers.waitForWidget(tester, find.text('Enter OTP'));

    // Enter OTP
    await enterOtp(otp ?? TestData.testOtp);

    // Wait for PIN screen
    await TestHelpers.waitForWidget(tester, find.text('Enter PIN'));

    // Enter PIN
    await enterPin(pin ?? TestData.testPin);

    // Wait for home screen
    await TestHelpers.waitForLoadingToComplete(tester);
  }

  // Registration flow
  Future<void> enterName(String firstName, String lastName) async {
    await tester.enterText(
      find.widgetWithText(TextField, 'First Name'),
      firstName,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Last Name'),
      lastName,
    );
    await tester.pumpAndSettle();
  }

  Future<void> createPin(String pin) async {
    await enterPin(pin);

    // Confirm PIN
    await TestHelpers.waitForWidget(tester, find.text('Confirm PIN'));
    await enterPin(pin);
  }

  Future<void> acceptTermsAndConditions() async {
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
  }

  Future<void> completeRegistration({
    String? phone,
    String? firstName,
    String? lastName,
    String? otp,
    String? pin,
  }) async {
    final user = TestData.defaultUser;

    // Switch to register tab
    await tapRegisterTab();

    // Enter phone
    await enterPhoneNumber(phone ?? user['phone'] as String);

    // Accept terms
    await acceptTermsAndConditions();
    await tapContinue();

    // Enter OTP
    await TestHelpers.waitForWidget(tester, find.text('Enter OTP'));
    await enterOtp(otp ?? TestData.testOtp);

    // Enter name
    await TestHelpers.waitForWidget(tester, find.text('First Name'));
    await enterName(
      firstName ?? user['firstName'] as String,
      lastName ?? user['lastName'] as String,
    );
    await tapContinue();

    // Create PIN
    await TestHelpers.waitForWidget(tester, find.text('Create PIN'));
    await createPin(pin ?? TestData.testPin);

    // Wait for success/home
    await TestHelpers.waitForLoadingToComplete(tester);
  }

  // Logout
  Future<void> logout() async {
    // Navigate to settings
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Scroll to logout
    await TestHelpers.scrollUntilVisible(tester, find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    // Confirm logout
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
  }

  // Verification helpers
  void verifyOnLoginScreen() {
    // Check for either old or new UI text
    final hasSignIn = find.text('Sign in').evaluate().isNotEmpty;
    final hasLogin = find.text('Login').evaluate().isNotEmpty;
    final hasSignUp = find.text('Sign up').evaluate().isNotEmpty;
    final hasRegister = find.text('Register').evaluate().isNotEmpty;
    final hasWelcome = find.text('Welcome back').evaluate().isNotEmpty;
    final hasCreateWallet = find.text('Create your USDC wallet').evaluate().isNotEmpty;
    final hasContinue = find.text('Continue').evaluate().isNotEmpty;

    // Should have at least one indicator we're on login/auth screen
    expect(
      hasSignIn || hasLogin || hasSignUp || hasRegister || hasWelcome || hasCreateWallet || hasContinue,
      isTrue,
      reason: 'Expected to be on login/auth screen',
    );
  }

  void verifyOnOtpScreen() {
    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.text('Resend code'), findsOneWidget);
  }

  void verifyOnPinScreen() {
    expect(find.text('Enter PIN'), findsOneWidget);
  }

  void verifyOnHomeScreen() {
    expect(find.text('Balance'), findsOneWidget);
  }

  void verifyLoggedOut() {
    verifyOnLoginScreen();
  }
}
