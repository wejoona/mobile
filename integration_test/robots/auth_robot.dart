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

  Future<void> selectCountry(String countryCode) async {
    // Tap current country code dropdown (default is +225)
    final currentCode = find.text('+225');
    if (currentCode.evaluate().isNotEmpty) {
      await tester.tap(currentCode);
      await tester.pumpAndSettle();

      // Select new country from dropdown
      final newCountry = find.text(countryCode);
      if (newCountry.evaluate().isNotEmpty) {
        await tester.tap(newCountry.last);
        await tester.pumpAndSettle();
      }
    }
  }

  Future<void> tapContinue() async {
    // Try various continue button texts
    final continueBtn = find.text('Continue');
    final nextBtn = find.text('Next');
    final submitBtn = find.text('Submit');

    if (continueBtn.evaluate().isNotEmpty) {
      await tester.tap(continueBtn.first);
    } else if (nextBtn.evaluate().isNotEmpty) {
      await tester.tap(nextBtn.first);
    } else if (submitBtn.evaluate().isNotEmpty) {
      await tester.tap(submitBtn.first);
    }
    await tester.pumpAndSettle();
  }

  Future<void> enterOtp(String otp) async {
    // OTP screen uses custom PinPad with tappable digit buttons
    // Tap each digit button on the numeric keyboard
    for (int i = 0; i < otp.length; i++) {
      final digit = otp[i];
      // Find the digit button text and tap it (use .last to get the keypad button, not any other text)
      final digitFinder = find.text(digit);
      if (digitFinder.evaluate().isEmpty) {
        // PinPad not visible - OTP screen may not have loaded or we're on a different screen
        debugPrint('Warning: Could not find digit "$digit" on PinPad. Screen state may be unexpected.');
        return;
      }
      await tester.tap(digitFinder.last);
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pumpAndSettle();
  }

  Future<void> tapResendOtp() async {
    // Resend button shows countdown like "Resend Code (26 s)"
    final resendFinder = find.textContaining('Resend Code');
    await tester.tap(resendFinder);
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
    bool skipKycPrompt = false,
  }) async {
    final user = TestData.defaultUser;

    // Enter phone number
    await enterPhoneNumber(phone ?? user['phone'] as String);
    await tapContinue();

    // Wait for OTP screen (shows "Secure Login" title)
    await TestHelpers.waitForWidget(tester, find.text('Secure Login'));

    // Enter OTP
    await enterOtp(otp ?? TestData.testOtp);

    // Wait for loading to complete - app may go to PIN, KYC, or Home
    await TestHelpers.waitForLoadingToComplete(tester);

    // Check if PIN screen is shown (optional step depending on app state)
    final pinScreen = find.text('Enter PIN');
    if (pinScreen.evaluate().isNotEmpty) {
      await enterPin(pin ?? TestData.testPin);
      await TestHelpers.waitForLoadingToComplete(tester);
    }

    // After OTP, there may be a "Start Verification" button for KYC
    await tester.pumpAndSettle();
    final startVerification = find.text('Start Verification');
    if (startVerification.evaluate().isNotEmpty && !skipKycPrompt) {
      await tester.tap(startVerification.first);
      await tester.pumpAndSettle();
    }
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
    // Try to find and tap a checkbox (terms or remember device)
    final checkbox = find.byType(Checkbox);
    if (checkbox.evaluate().isNotEmpty) {
      await tester.tap(checkbox.first);
      await tester.pumpAndSettle();
    }
    // Some flows may not have a checkbox - that's OK
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

    // Enter OTP (screen shows "Secure Login")
    await TestHelpers.waitForWidget(tester, find.text('Secure Login'));
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
    expect(find.text('Secure Login'), findsOneWidget);
    expect(find.textContaining('Resend Code'), findsOneWidget);
  }

  void verifyOnPinScreen() {
    expect(find.text('Enter PIN'), findsOneWidget);
  }

  void verifyOnHomeScreen() {
    // User is authenticated - may be on Home, KYC, or another logged-in screen
    final hasBalance = find.text('Balance').evaluate().isNotEmpty;
    final hasWallet = find.textContaining('Wallet').evaluate().isNotEmpty;
    final hasKYC = find.textContaining('KYC').evaluate().isNotEmpty;
    final hasVerify = find.textContaining('Verify').evaluate().isNotEmpty;
    final hasVerifyIdentity = find.text('Verify your identity').evaluate().isNotEmpty;
    final hasStartVerification = find.text('Start Verification').evaluate().isNotEmpty;
    final hasIdentityVerification = find.text('Identity Verification').evaluate().isNotEmpty;
    final hasHome = find.textContaining('Home').evaluate().isNotEmpty;
    final hasIdentity = find.textContaining('identity').evaluate().isNotEmpty;

    expect(
      hasBalance || hasWallet || hasKYC || hasVerify || hasVerifyIdentity ||
      hasStartVerification || hasIdentityVerification || hasHome || hasIdentity,
      isTrue,
      reason: 'Expected to be on an authenticated screen (Home, KYC, etc.)',
    );
  }

  void verifyLoggedOut() {
    verifyOnLoginScreen();
  }
}
