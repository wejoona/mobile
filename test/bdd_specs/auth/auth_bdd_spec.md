# STATUS: ACTIVE
# Authentication Feature - BDD Specifications

## Overview
Authentication flow including login, OTP verification, PIN entry, and registration.

## Screens Covered
- `/login` - Login View
- `/otp` - OTP View  
- `/login/otp` - Login OTP View
- `/login/pin` - Login PIN View

---

## Feature: User Login

### Screen: LoginView
**File:** `lib/features/auth/views/login_view.dart`
**Route:** `/login`

```gherkin
Feature: User Login via Phone Number

  Background:
    Given the app is installed
    And I am not logged in
    And I am on the login screen

  @smoke @auth
  Scenario: Display login form with default country
    Then I should see the JoonaPay logo
    And I should see "Welcome Back" text
    And I should see country selector defaulting to Ivory Coast
    And I should see phone input with "+225" prefix
    And I should see disabled "Continue" button
    And I should see terms and privacy links

  @auth @country
  Scenario Outline: Select different country
    When I tap the country selector
    Then I should see country picker bottom sheet
    When I select "<country>"
    Then the dial prefix should show "<prefix>"
    And phone format hint should update

    Examples:
      | country      | prefix |
      | Ivory Coast  | +225   |
      | Ghana        | +233   |
      | Senegal      | +221   |

  @auth @validation
  Scenario: Validate phone number length
    Given Ivory Coast requires 10 digit phone numbers
    When I enter "012345678" (9 digits)
    Then I should see error indicator
    And "Continue" button should be disabled
    When I enter "0123456789" (10 digits)
    Then I should see success indicator
    And "Continue" button should be enabled

  @auth @submit
  Scenario: Submit login successfully
    Given I have entered valid phone "0123456789"
    When I tap "Continue"
    Then I should see loading indicator
    And API call should be made to POST /auth/login
    And on success, I should navigate to "/otp"

  @auth @error
  Scenario: Handle login error
    Given I have entered valid phone
    When I tap "Continue"
    And the server returns error "User not found"
    Then I should see error snackbar "User not found"
    And I should remain on login screen

  @auth @register
  Scenario: Toggle to registration mode
    Given I am in login mode
    When I tap "Don't have an account? Sign up"
    Then I should see "Already have an account? Sign in"
    And submit should call POST /auth/register

  @auth @legal
  Scenario: View legal documents
    When I tap "Terms of Service"
    Then I should navigate to legal document view
    When I go back and tap "Privacy Policy"
    Then I should navigate to privacy policy view
```

---

## Feature: OTP Verification

### Screen: OtpView
**File:** `lib/features/auth/views/otp_view.dart`
**Route:** `/otp`

```gherkin
Feature: OTP Verification

  Background:
    Given I have initiated login/registration
    And I am on the OTP screen

  @smoke @otp
  Scenario: Display OTP verification screen
    Then I should see "Verify your number" title
    And I should see the phone number being verified
    And I should see 6 OTP input fields
    And I should see countdown timer starting at 60
    And I should see disabled "Resend" button

  @otp @input
  Scenario: Enter OTP automatically triggers verification
    When I enter "123456" in the OTP fields
    Then verification should trigger automatically
    And I should see loading indicator

  @otp @success
  Scenario: Successful OTP verification
    Given I enter correct OTP
    When verification completes successfully
    Then I should navigate to "/home" or next onboarding step

  @otp @failure
  Scenario: Failed OTP verification
    Given I enter incorrect OTP "000000"
    When verification fails
    Then I should see "Invalid OTP" error
    And OTP fields should clear
    And I should be able to retry

  @otp @resend
  Scenario: Resend OTP after countdown
    Given countdown has reached 0
    Then "Resend" button should be enabled
    When I tap "Resend"
    Then new OTP should be sent
    And countdown should reset to 60
    And I should see "OTP sent" confirmation

  @otp @timeout
  Scenario: OTP expiration
    Given 5 minutes have passed
    When I enter the OTP
    Then I should see "OTP expired" error
    And I should tap "Resend" for new OTP
```

---

## Feature: PIN Login

### Screen: LoginPinView
**File:** `lib/features/auth/views/login_pin_view.dart`
**Route:** `/login/pin`

```gherkin
Feature: PIN Authentication

  Background:
    Given I have a PIN set up
    And I am on the PIN login screen

  @smoke @pin
  Scenario: Display PIN entry screen
    Then I should see "Enter your PIN" title
    And I should see 4 empty PIN dots
    And I should see numeric keypad 0-9
    And I should see delete button

  @pin @input
  Scenario: Enter PIN
    When I tap "1", "2", "3", "4"
    Then I should see 4 filled PIN dots
    And authentication should trigger

  @pin @success
  Scenario: Correct PIN
    When I enter my correct PIN
    Then I should be authenticated
    And I should navigate to "/home"

  @pin @failure
  Scenario: Incorrect PIN
    When I enter incorrect PIN
    Then I should see "Incorrect PIN" shake animation
    And I should see "X attempts remaining"
    And PIN dots should reset

  @pin @lockout
  Scenario: Too many failed attempts
    Given I have failed PIN entry 5 times
    Then I should see "Too many attempts"
    And I should see lockout countdown
    And I should navigate to "/auth-locked"

  @pin @biometric
  Scenario: Biometric fallback available
    Given device supports Face ID/Touch ID
    And biometric is enabled
    Then I should see biometric icon
    When I tap biometric icon
    Then biometric auth should trigger
```

---

## Test Data Requirements

### Mock Users
```json
{
  "existingUser": {
    "phone": "+2250123456789",
    "pin": "1234",
    "otp": "123456"
  },
  "newUser": {
    "phone": "+2250987654321"
  }
}
```

### API Mocks Needed
- POST /auth/login
- POST /auth/register  
- POST /auth/verify-otp
- POST /auth/resend-otp

---

## Golden Test Requirements

Each screen needs golden tests for:
1. Initial state (empty)
2. Input state (partial entry)
3. Loading state
4. Success state
5. Error state
6. Dark mode variants

---

*Part of USDC Wallet Complete Testing Suite*
