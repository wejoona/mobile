import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

/// Robot for settings and configuration
class SettingsRobot {
  final WidgetTester tester;

  SettingsRobot(this.tester);

  // Navigation to settings screens
  Future<void> openProfile() async {
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
  }

  Future<void> openSecurity() async {
    await tester.tap(find.text('Security'));
    await tester.pumpAndSettle();
  }

  Future<void> openNotifications() async {
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
  }

  Future<void> openLanguage() async {
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
  }

  Future<void> openHelp() async {
    await tester.tap(find.text('Help'));
    await tester.pumpAndSettle();
  }

  Future<void> openKyc() async {
    await tester.tap(find.text('KYC'));
    await tester.pumpAndSettle();
  }

  // PIN change
  Future<void> changePin(String oldPin, String newPin) async {
    await openSecurity();

    await tester.tap(find.text('Change PIN'));
    await tester.pumpAndSettle();

    // Enter old PIN
    await TestHelpers.enterPin(tester, oldPin);

    // Enter new PIN
    await TestHelpers.waitForWidget(tester, find.text('Enter new PIN'));
    await TestHelpers.enterPin(tester, newPin);

    // Confirm new PIN
    await TestHelpers.waitForWidget(tester, find.text('Confirm new PIN'));
    await TestHelpers.enterPin(tester, newPin);

    await TestHelpers.waitForLoadingToComplete(tester);
  }

  // Biometric settings
  Future<void> toggleBiometric() async {
    await openSecurity();

    final biometricSwitch = find.byType(Switch).first;
    await tester.tap(biometricSwitch);
    await tester.pumpAndSettle();
  }

  Future<void> enableBiometric(String pin) async {
    await toggleBiometric();

    // Confirm with PIN
    await TestHelpers.waitForWidget(tester, find.text('Enter PIN'));
    await TestHelpers.enterPin(tester, pin);
  }

  // Profile edit
  Future<void> editProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    await openProfile();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    if (firstName != null) {
      final firstNameField = find.widgetWithText(TextField, 'First Name');
      await tester.enterText(firstNameField, firstName);
    }

    if (lastName != null) {
      final lastNameField = find.widgetWithText(TextField, 'Last Name');
      await tester.enterText(lastNameField, lastName);
    }

    if (email != null) {
      final emailField = find.widgetWithText(TextField, 'Email');
      await tester.enterText(emailField, email);
    }

    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  // Language change
  Future<void> changeLanguage(String language) async {
    await openLanguage();

    await tester.tap(find.text(language));
    await tester.pumpAndSettle();
  }

  // Notification preferences
  Future<void> toggleNotification(String notificationType) async {
    await openNotifications();

    await TestHelpers.scrollUntilVisible(tester, find.text(notificationType));

    final notificationSwitch = find.ancestor(
      of: find.text(notificationType),
      matching: find.byType(Switch),
    );

    await tester.tap(notificationSwitch);
    await tester.pumpAndSettle();
  }

  // Device management
  Future<void> viewDevices() async {
    await openSecurity();

    await tester.tap(find.text('Devices'));
    await tester.pumpAndSettle();
  }

  Future<void> removeDevice(String deviceName) async {
    await viewDevices();

    await TestHelpers.scrollUntilVisible(tester, find.text(deviceName));

    // Find remove button for device
    final removeButton = find.ancestor(
      of: find.text(deviceName),
      matching: find.byIcon(Icons.delete),
    );

    await tester.tap(removeButton);
    await tester.pumpAndSettle();

    // Confirm removal
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
  }

  // Session management
  Future<void> viewSessions() async {
    await openSecurity();

    await tester.tap(find.text('Sessions'));
    await tester.pumpAndSettle();
  }

  Future<void> logoutAllSessions() async {
    await viewSessions();

    await tester.tap(find.text('Logout All'));
    await tester.pumpAndSettle();

    // Confirm
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
  }

  // Help and support
  Future<void> searchHelp(String query) async {
    await openHelp();

    await tester.enterText(find.byType(TextField), query);
    await tester.pumpAndSettle();
  }

  Future<void> openHelpArticle(String title) async {
    await openHelp();

    await TestHelpers.scrollUntilVisible(tester, find.text(title));
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }

  Future<void> contactSupport() async {
    await openHelp();

    await tester.tap(find.text('Contact Support'));
    await tester.pumpAndSettle();
  }

  // Theme
  Future<void> toggleTheme() async {
    await TestHelpers.scrollUntilVisible(tester, find.text('Theme'));

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();

    // Toggle to next theme
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
  }

  // Verification helpers
  void verifyOnSettingsScreen() {
    expect(find.text('Settings'), findsOneWidget);
  }

  void verifyPinChanged() {
    expect(find.text('PIN changed successfully'), findsOneWidget);
  }

  void verifyBiometricEnabled() {
    expect(find.text('Biometric enabled'), findsOneWidget);
  }

  void verifyProfileUpdated() {
    expect(find.text('Profile updated'), findsOneWidget);
  }

  void verifyLanguageChanged(String language) {
    // Check if UI is in new language
    // This would need actual translation verification
  }
}
