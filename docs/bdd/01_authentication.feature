# STATUS: ACTIVE
# Feature: Authentication Flow
# Screens: splash_view, login_view, login_otp_view, login_pin_view, otp_view

@authentication @critical
Feature: User Authentication

  Background:
    Given the USDC Wallet app is installed
    And the backend API is available

  # ============================================
  # SPLASH SCREEN
  # ============================================
  
  @splash
  Scenario: First-time user sees onboarding
    Given the user has never opened the app before
    When the splash screen loads
    Then the user should see the app logo with animation
    And after 2 seconds the user should be redirected to "/onboarding"

  @splash
  Scenario: Returning user without session goes to login
    Given the user has completed onboarding
    And the user does not have a valid session
    When the splash screen loads
    Then the user should be redirected to "/login"

  @splash
  Scenario: Returning user with valid session goes to home
    Given the user has a valid authentication session
    When the splash screen loads
    Then the user should be redirected to "/home"

  @splash
  Scenario: User with expired session goes to login
    Given the user's session token has expired
    When the splash screen loads
    Then the user should be redirected to "/login"

  # ============================================
  # LOGIN - PHONE INPUT
  # ============================================

  @login @phone-input
  Scenario: Enter valid phone number
    Given the user is on the login screen
    When they select country code "+225"
    And they enter phone number "0123456789"
    And they tap the "Continue" button
    Then an OTP request should be sent to the backend
    And the user should be navigated to "/login/otp"

  @login @phone-input
  Scenario: Enter invalid phone number - too short
    Given the user is on the login screen
    When they enter phone number "123"
    And they tap the "Continue" button
    Then an error message "Invalid phone number" should be displayed
    And the user should remain on the login screen

  @login @phone-input
  Scenario: Enter invalid phone number - invalid characters
    Given the user is on the login screen
    When they enter phone number "abc123"
    Then the input should only accept numeric characters
    And the displayed value should be "123"

  @login @phone-input @rate-limiting
  Scenario: Rate limiting on OTP requests
    Given the user has requested OTP 3 times in the last 5 minutes
    When they try to request another OTP
    Then an error message "Too many requests. Please wait X minutes." should be displayed
    And the "Continue" button should be disabled
    And a countdown timer should be shown

  @login @phone-input @network
  Scenario: Network error during OTP request
    Given the user is on the login screen
    And the network is unavailable
    When they tap the "Continue" button
    Then an error message "Network error. Please check your connection." should be displayed
    And a "Retry" option should be available

  # ============================================
  # LOGIN - OTP VERIFICATION
  # ============================================

  @login @otp
  Scenario: Enter correct OTP
    Given the user is on the OTP verification screen
    And they received OTP "123456"
    When they enter "123456"
    Then the OTP should be verified automatically
    And the user should be logged in
    And redirected to "/home" or PIN setup if new user

  @login @otp
  Scenario: Enter incorrect OTP
    Given the user is on the OTP verification screen
    When they enter an incorrect OTP "000000"
    Then an error message "Invalid code. Please try again." should be displayed
    And the remaining attempts should be shown (e.g., "4 attempts remaining")
    And the OTP input should be cleared

  @login @otp
  Scenario: OTP expires after timeout
    Given the user received an OTP 5 minutes ago
    When they try to verify it now
    Then an error message "Code expired. Please request a new one." should be displayed
    And the "Resend Code" button should be highlighted

  @login @otp
  Scenario: Resend OTP
    Given the user is on the OTP verification screen
    And 30 seconds have passed since the last OTP was sent
    When they tap "Resend Code"
    Then a new OTP should be sent
    And a success message "Code sent!" should be displayed
    And the countdown timer should reset to 30 seconds

  @login @otp
  Scenario: Resend OTP before cooldown
    Given the user is on the OTP verification screen
    And only 10 seconds have passed since the last OTP
    When they try to tap "Resend Code"
    Then the button should be disabled
    And show countdown "Resend in 20s"

  @login @otp
  Scenario: Maximum OTP attempts exceeded
    Given the user has entered wrong OTP 5 times
    When they enter another wrong OTP
    Then the account should be temporarily locked
    And the user should see the auth_locked_view
    And a message "Account locked. Try again in 15 minutes." should be displayed

  @login @otp
  Scenario: Navigate back from OTP screen
    Given the user is on the OTP verification screen
    When they tap the back button
    Then they should return to the login screen
    And be able to change the phone number

  # ============================================
  # LOGIN - PIN ENTRY (Returning Users)
  # ============================================

  @login @pin
  Scenario: Enter correct PIN
    Given the user has previously set up a PIN
    And is on the PIN entry screen
    When they enter the correct 6-digit PIN
    Then the PIN should be verified
    And the user should be logged in
    And redirected to "/home"

  @login @pin
  Scenario: Enter incorrect PIN
    Given the user is on the PIN entry screen
    When they enter an incorrect PIN
    Then the PIN dots should shake
    And an error message should be displayed
    And remaining attempts should be shown (e.g., "4 attempts remaining")
    And the PIN input should be cleared

  @login @pin
  Scenario: PIN locked after maximum attempts
    Given the user has entered wrong PIN 5 times
    When they enter another wrong PIN
    Then the user should be navigated to "/auth-locked"
    And see a lockout message with timer
    And option to contact support

  @login @pin
  Scenario: Forgot PIN
    Given the user is on the PIN entry screen
    When they tap "Forgot PIN?"
    Then they should be navigated to PIN reset flow
    And be required to verify identity via OTP

  @login @pin
  Scenario: Biometric authentication available
    Given the user has enabled biometric authentication
    And the device supports Face ID/Touch ID
    When the PIN screen loads
    Then a biometric icon should be visible
    When they tap the biometric icon
    And authenticate successfully
    Then they should be logged in

  @login @pin
  Scenario: Biometric authentication fails
    Given the user has enabled biometric authentication
    When they attempt biometric authentication
    And it fails (e.g., face not recognized)
    Then they should see "Biometric failed. Use PIN instead."
    And be able to enter PIN manually

  # ============================================
  # SESSION MANAGEMENT
  # ============================================

  @session
  Scenario: Session timeout while using app
    Given the user is logged in
    And their session has been idle for 15 minutes
    When they try to perform any action
    Then they should see the session_locked_view
    And be required to re-authenticate with PIN/biometric

  @session
  Scenario: New device login detection
    Given the user logs in from a new device
    Then the device_verification_view should be shown
    And they should verify via OTP
    And optionally add device to trusted devices

  @session
  Scenario: Concurrent session conflict
    Given the user is logged in on Device A
    When they log in on Device B
    Then on Device A, session_conflict_view should appear
    And they should choose to continue on Device A or allow Device B

  @session
  Scenario: Logout
    Given the user is logged in
    When they navigate to Settings
    And tap "Logout"
    And confirm the action
    Then the session should be invalidated
    And they should be redirected to "/login"
    And local data should be cleared appropriately
