# JoonaPay USDC Wallet - Complete Screens BDD Inventory

> **Comprehensive BDD test definitions for ALL 250 screens with status flags**

## Status Flags Legend

| Flag | Meaning | Test Priority |
|------|---------|---------------|
| `ACTIVE` | Production-ready, routed in app | HIGH - Must have golden tests |
| `FEATURE_FLAG` | Gated by feature flag | MEDIUM - Test when flag enabled |
| `AWAITING_BACKEND` | Frontend ready, backend API pending | LOW - Mock for now |
| `DEMO` | Demo/showcase only | SKIP - No tests needed |
| `DEAD_CODE` | Not routed, likely obsolete | SKIP - Consider deletion |
| `DISABLED` | Intentionally disabled for MVP | SKIP - Document why |
| `COMPONENT` | Reusable component, not a route | VARIES - Test as part of flows |

---

# 1. AUTH FLOW

## 1.1 Splash View
- **File:** `lib/features/splash/views/splash_view.dart`
- **Route:** `/`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Splash Screen

Scenario: App Launch
  GIVEN the app is launched
  WHEN the splash screen displays
  THEN the JoonaPay logo should be visible
  AND the app should navigate based on auth state within 2 seconds

Scenario: Authenticated User
  GIVEN user has valid auth tokens
  WHEN splash completes loading
  THEN user should be redirected to /home

Scenario: Unauthenticated User
  GIVEN user has no auth tokens
  WHEN splash completes loading
  THEN user should be redirected to /onboarding or /login
```

---

## 1.2 Onboarding View
- **File:** `lib/features/onboarding/views/onboarding_view.dart`
- **Route:** `/onboarding`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Onboarding

Scenario: First Time User
  GIVEN a new user opens the app
  WHEN the onboarding screen displays
  THEN feature highlight slides should be visible
  AND "Skip" button should be available
  AND "Get Started" button should be available

Scenario: Skip Onboarding
  GIVEN user is on onboarding screen
  WHEN user taps "Skip"
  THEN user should be redirected to /login

Scenario: Complete Onboarding
  GIVEN user is on last onboarding slide
  WHEN user taps "Get Started"
  THEN user should be redirected to /login
```

---

## 1.3 Enhanced Onboarding View
- **File:** `lib/features/onboarding/views/enhanced_onboarding_view.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Superseded by onboarding_view.dart

---

## 1.4 Login View
- **File:** `lib/features/auth/views/login_view.dart`
- **Route:** `/login`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Login Screen

Scenario: Display Login Form
  GIVEN an unauthenticated user
  WHEN the login screen displays
  THEN phone number input should be visible
  AND country code selector should show +225 (Côte d'Ivoire)
  AND "Continue" button should be visible but disabled

Scenario: Enter Valid Phone Number
  GIVEN user is on login screen
  WHEN user enters valid phone number (10 digits)
  THEN "Continue" button should become enabled

Scenario: Submit Phone Number
  GIVEN user entered valid phone number
  WHEN user taps "Continue"
  THEN loading indicator should appear
  AND OTP should be sent to phone
  AND user should be redirected to /otp

Scenario: Invalid Phone Number
  GIVEN user is on login screen
  WHEN user enters invalid phone (too short/long)
  THEN "Continue" button should remain disabled
  AND validation error should be shown
```

---

## 1.5 Login OTP View
- **File:** `lib/features/auth/views/login_otp_view.dart`
- **Route:** `/login/otp`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Login OTP Verification

Scenario: Display OTP Screen
  GIVEN user submitted phone number
  WHEN OTP screen displays
  THEN 6-digit OTP input should be visible
  AND countdown timer should be visible
  AND "Resend Code" should be disabled until timer ends

Scenario: Enter OTP
  GIVEN user is on OTP screen
  WHEN user enters 6-digit OTP
  THEN OTP should auto-submit on 6th digit

Scenario: Valid OTP
  GIVEN user entered correct OTP
  WHEN OTP is verified
  THEN user should be redirected to /home or /kyc

Scenario: Invalid OTP
  GIVEN user entered incorrect OTP
  WHEN OTP verification fails
  THEN error message should be shown
  AND remaining attempts should be displayed

Scenario: Resend OTP
  GIVEN timer has expired
  WHEN user taps "Resend Code"
  THEN new OTP should be sent
  AND timer should reset
```

---

## 1.6 Login PIN View
- **File:** `lib/features/auth/views/login_pin_view.dart`
- **Route:** `/login/pin`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Login PIN Verification

Scenario: Display PIN Screen
  GIVEN returning user needs PIN verification
  WHEN PIN screen displays
  THEN 6-digit PIN entry should be shown
  AND PinPad with digits 0-9 should be visible
  AND "Forgot PIN?" link should be available

Scenario: Enter Correct PIN
  GIVEN user is on PIN screen
  WHEN user enters correct 6-digit PIN
  THEN user should be redirected to /home

Scenario: Incorrect PIN
  GIVEN user is on PIN screen
  WHEN user enters incorrect PIN
  THEN error message should be shown
  AND remaining attempts should be displayed

Scenario: PIN Lockout
  GIVEN user exceeded max PIN attempts
  WHEN lockout is triggered
  THEN user should be redirected to /auth-locked
  AND lockout duration should be shown
```

---

## 1.7 OTP View (Secure Login)
- **File:** `lib/features/auth/views/otp_view.dart`
- **Route:** `/otp`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Secure Login OTP

Scenario: Display Secure Login
  GIVEN user submitted phone number
  WHEN OTP screen displays
  THEN "Secure Login" title should be visible
  AND custom PinPad with digits 0-9 should be visible
  AND dots indicator for 6 digits should be shown
  AND "Resend Code" option should be visible

Scenario: Enter Digits via PinPad
  GIVEN user is on OTP screen
  WHEN user taps digit buttons on PinPad
  THEN corresponding dots should fill in
  AND after 6 digits, auto-submit should trigger

Scenario: Delete Digit
  GIVEN user entered some digits
  WHEN user taps backspace/delete
  THEN last digit should be removed
  AND corresponding dot should unfill
```

---

## 1.8 Login Phone View
- **File:** `lib/features/auth/views/login_phone_view.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Superseded by login_view.dart

---

## 1.9 Legal Document View
- **File:** `lib/features/auth/views/legal_document_view.dart`
- **Route:** None
- **Status:** `DISABLED` - Terms shown inline during registration

---

# 2. ONBOARDING FLOW

## 2.1 Phone Input View
- **File:** `lib/features/onboarding/views/phone_input_view.dart`
- **Route:** None
- **Status:** `COMPONENT` - Used within onboarding flow

---

## 2.2 OTP Verification View (Onboarding)
- **File:** `lib/features/onboarding/views/otp_verification_view.dart`
- **Route:** None
- **Status:** `COMPONENT` - Used within onboarding flow

---

## 2.3 Profile Setup View
- **File:** `lib/features/onboarding/views/profile_setup_view.dart`
- **Route:** None
- **Status:** `COMPONENT` - Used within onboarding flow

---

## 2.4 Onboarding PIN View
- **File:** `lib/features/onboarding/views/onboarding_pin_view.dart`
- **Route:** None
- **Status:** `COMPONENT` - Used within onboarding flow

---

## 2.5 KYC Prompt View
- **File:** `lib/features/onboarding/views/kyc_prompt_view.dart`
- **Route:** None
- **Status:** `COMPONENT` - Prompts user to complete KYC

---

## 2.6 Onboarding Success View
- **File:** `lib/features/onboarding/views/onboarding_success_view.dart`
- **Route:** None
- **Status:** `COMPONENT` - Success state after onboarding

---

## 2.7 Welcome View
- **File:** `lib/features/onboarding/views/welcome_view.dart`
- **Route:** None
- **Status:** `COMPONENT` - Welcome screen component

---

## 2.8 Welcome Post Login View
- **File:** `lib/features/onboarding/views/welcome_post_login_view.dart`
- **Route:** None
- **Status:** `COMPONENT` - Shown after first login

---

## 2.9 USDC Explainer View
- **File:** `lib/features/onboarding/views/help/usdc_explainer_view.dart`
- **Route:** None
- **Status:** `DISABLED` - Help content not in MVP

---

## 2.10 Deposits Guide View
- **File:** `lib/features/onboarding/views/help/deposits_guide_view.dart`
- **Route:** None
- **Status:** `DISABLED` - Help content not in MVP

---

## 2.11 Fees Transparency View
- **File:** `lib/features/onboarding/views/help/fees_transparency_view.dart`
- **Route:** None
- **Status:** `DISABLED` - Help content not in MVP

---

# 3. FSM STATE SCREENS

## 3.1 Loading View
- **File:** `lib/features/fsm_states/views/loading_view.dart`
- **Route:** `/loading`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Loading State

Scenario: Display Loading
  GIVEN the app is fetching wallet/user data
  WHEN the loading state is active
  THEN loading indicator should be visible
  AND "Loading..." message may be shown

Scenario: Loading Complete
  GIVEN data has finished loading
  WHEN loading completes
  THEN user should be redirected to appropriate screen
```

---

## 3.2 OTP Expired View
- **File:** `lib/features/fsm_states/views/otp_expired_view.dart`
- **Route:** `/otp-expired`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: OTP Expired

Scenario: Display Expiry Message
  GIVEN user's OTP has expired
  WHEN the OTP expired screen displays
  THEN expiry message should be visible
  AND "Get New OTP" button should be available

Scenario: Request New OTP
  GIVEN user is on OTP expired screen
  WHEN user taps "Get New OTP"
  THEN user should be redirected to /login
```

---

## 3.3 Auth Locked View
- **File:** `lib/features/fsm_states/views/auth_locked_view.dart`
- **Route:** `/auth-locked`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Auth Locked

Scenario: Display Lock Message
  GIVEN user has too many failed auth attempts
  WHEN the auth locked screen displays
  THEN locked message should be visible
  AND remaining lockout time should be shown
  AND "Contact Support" option should be available

Scenario: Lockout Expires
  GIVEN lockout timer reaches zero
  WHEN timer expires
  THEN "Try Again" button should become enabled
```

---

## 3.4 Auth Suspended View
- **File:** `lib/features/fsm_states/views/auth_suspended_view.dart`
- **Route:** `/auth-suspended`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Auth Suspended

Scenario: Display Suspension Message
  GIVEN user's account is suspended
  WHEN the auth suspended screen displays
  THEN suspension message should be visible
  AND reason for suspension may be shown
  AND "Contact Support" option should be available
```

---

## 3.5 Session Locked View
- **File:** `lib/features/fsm_states/views/session_locked_view.dart`
- **Route:** `/session-locked`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Session Locked

Scenario: Display Lock Screen
  GIVEN user's session has timed out
  WHEN the session locked screen displays
  THEN lock screen with PIN entry should be visible
  AND biometric unlock option should be available (if enabled)

Scenario: Unlock with PIN
  GIVEN user is on session locked screen
  WHEN user enters correct PIN
  THEN session should resume
  AND user should return to previous screen
```

---

## 3.6 Biometric Prompt View
- **File:** `lib/features/fsm_states/views/biometric_prompt_view.dart`
- **Route:** `/biometric-prompt`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Biometric Prompt

Scenario: Display Biometric Prompt
  GIVEN biometric authentication is required
  WHEN the biometric prompt displays
  THEN biometric icon should be visible
  AND "Use PIN instead" option should be available

Scenario: Successful Biometric
  GIVEN biometric scan succeeded
  WHEN verification completes
  THEN user should be authenticated
```

---

## 3.7 Device Verification View
- **File:** `lib/features/fsm_states/views/device_verification_view.dart`
- **Route:** `/device-verification`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Device Verification

Scenario: New Device Detected
  GIVEN user is logging in from a new device
  WHEN device verification is required
  THEN verification message should be visible
  AND OTP verification may be required
  AND "This is my device" option should be available
```

---

## 3.8 Session Conflict View
- **File:** `lib/features/fsm_states/views/session_conflict_view.dart`
- **Route:** `/session-conflict`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Session Conflict

Scenario: Multiple Sessions Detected
  GIVEN user has an active session on another device
  WHEN session conflict is detected
  THEN conflict message should be visible
  AND "Continue here" option should be available
  AND "Cancel" option should be available
```

---

## 3.9 Wallet Frozen View
- **File:** `lib/features/fsm_states/views/wallet_frozen_view.dart`
- **Route:** `/wallet-frozen`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Wallet Frozen

Scenario: Display Frozen State
  GIVEN user's wallet is frozen
  WHEN the wallet frozen screen displays
  THEN frozen message should be visible
  AND reason may be shown
  AND "Contact Support" option should be available
```

---

## 3.10 Wallet Under Review View
- **File:** `lib/features/fsm_states/views/wallet_under_review_view.dart`
- **Route:** `/wallet-under-review`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Wallet Under Review

Scenario: Display Review State
  GIVEN user's wallet is under review
  WHEN the review screen displays
  THEN review message should be visible
  AND expected timeline may be shown
  AND limited functionality notice should be visible
```

---

## 3.11 KYC Expired View
- **File:** `lib/features/fsm_states/views/kyc_expired_view.dart`
- **Route:** `/kyc-expired`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: KYC Expired

Scenario: Display KYC Expiry
  GIVEN user's KYC has expired
  WHEN the KYC expired screen displays
  THEN expiry message should be visible
  AND "Renew KYC" button should be available
```

---

# 4. MAIN NAVIGATION

## 4.1 Wallet Home Screen
- **File:** `lib/features/wallet/views/wallet_home_screen.dart`
- **Route:** `/home`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Home Screen

Scenario: Display Wallet Balance
  GIVEN an authenticated user with verified KYC
  WHEN the home screen displays
  THEN USDC balance should be visible
  AND balance should be formatted correctly

Scenario: Quick Actions
  GIVEN user is on home screen
  WHEN viewing quick actions
  THEN "Send" button should be visible
  AND "Receive" button should be visible
  AND "Deposit" button should be visible

Scenario: Recent Transactions
  GIVEN user has transactions
  WHEN viewing home screen
  THEN recent transactions should be listed
  AND each transaction should show type, amount, date

Scenario: Zero Balance State
  GIVEN user has zero balance
  WHEN viewing home screen
  THEN balance should show "0.00 USDC"
  AND deposit CTA should be prominent

Scenario: Bottom Navigation
  GIVEN user is on home screen
  WHEN viewing navigation bar
  THEN Home tab should be selected
  AND Cards, History, Settings tabs should be visible
```

---

## 4.2 Home View (Legacy)
- **File:** `lib/features/wallet/views/home_view.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Superseded by wallet_home_screen.dart

---

## 4.3 Cards List View
- **File:** `lib/features/cards/views/cards_list_view.dart`
- **Route:** `/cards`
- **Status:** `FEATURE_FLAG` (virtualCards)
- **BDD Tests:**
```gherkin
Feature: Cards Tab

Scenario: Display Cards List
  GIVEN virtualCards feature flag is enabled
  WHEN the Cards tab is selected
  THEN virtual cards list should display
  AND "Request Card" option should be available

Scenario: Empty State
  GIVEN user has no cards
  WHEN viewing cards list
  THEN empty state should be shown
  AND "Get Your First Card" CTA should be visible
```

---

## 4.4 Cards Screen (Legacy)
- **File:** `lib/features/cards/views/cards_screen.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Superseded by cards_list_view.dart

---

## 4.5 Transactions View
- **File:** `lib/features/transactions/views/transactions_view.dart`
- **Route:** `/transactions`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Transactions History

Scenario: Display Transactions List
  GIVEN the History tab is selected
  WHEN the transactions list displays
  THEN all transactions should be listed chronologically
  AND each transaction should show type, amount, date, status

Scenario: Empty State
  GIVEN user has no transactions
  WHEN viewing transactions list
  THEN empty state should be shown
  AND message "No transactions yet" should be visible

Scenario: Filter Transactions
  GIVEN user is on transactions list
  WHEN user taps filter icon
  THEN filter options should appear
  AND type filter (All, Deposits, Sends, Receives) should be available

Scenario: Search Transactions
  GIVEN user is on transactions list
  WHEN user enters search term
  THEN transactions should be filtered by search term
```

---

## 4.6 Settings Screen
- **File:** `lib/features/settings/views/settings_screen.dart`
- **Route:** `/settings`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Settings Screen

Scenario: Display Settings Menu
  GIVEN the Settings tab is selected
  WHEN the settings screen displays
  THEN user profile summary should be visible
  AND Profile option should be visible
  AND Security option should be visible
  AND Help option should be visible
  AND Logout option should be visible

Scenario: Navigate to Sub-setting
  GIVEN user is on settings screen
  WHEN user taps a setting option
  THEN corresponding settings view should open

Scenario: Logout
  GIVEN user is on settings screen
  WHEN user taps Logout
  THEN confirmation dialog should appear
  AND confirming should clear session and redirect to /login
```

---

## 4.7 Settings View (Legacy)
- **File:** `lib/features/settings/views/settings_view.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Superseded by settings_screen.dart

---

# 5. KYC FLOW

## 5.1 KYC Status View
- **File:** `lib/features/kyc/views/kyc_status_view.dart`
- **Route:** `/kyc`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: KYC Status Screen

Scenario: Display Identity Verification
  GIVEN a user needs KYC verification
  WHEN the Identity Verification screen displays
  THEN "Identity Verification" title should be visible
  AND "Start Verification" button should be visible
  AND info cards should be visible:
    - "Your Data is Secure"
    - "Quick Process"
    - "Documents Needed"

Scenario: Start Verification
  GIVEN user is on KYC status screen
  WHEN user taps "Start Verification"
  THEN user should be redirected to /kyc/document-type
```

---

## 5.2 Document Type View
- **File:** `lib/features/kyc/views/document_type_view.dart`
- **Route:** `/kyc/document-type`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Document Type Selection

Scenario: Display Document Options
  GIVEN user tapped "Start Verification"
  WHEN the document type screen displays
  THEN "Select Document Type" title should be visible
  AND National ID Card option should be available
  AND Passport option should be available
  AND Driver's License option should be available
  AND Continue button should be disabled

Scenario: Select Document Type
  GIVEN user is on document type screen
  WHEN user selects "National ID Card"
  THEN checkmark should appear on selected option
  AND Continue button should become enabled

Scenario: Continue to Personal Info
  GIVEN user selected a document type
  WHEN user taps Continue
  THEN user should be redirected to /kyc/personal-info
```

---

## 5.3 KYC Personal Info View
- **File:** `lib/features/kyc/views/kyc_personal_info_view.dart`
- **Route:** `/kyc/personal-info`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Personal Information

Scenario: Display Personal Info Form
  GIVEN user selected a document type
  WHEN the personal info screen displays
  THEN First name input should be visible
  AND Last name input should be visible
  AND Date of birth picker should be visible
  AND info message about matching ID should be visible
  AND Continue button should be disabled

Scenario: Fill Personal Info
  GIVEN user is on personal info screen
  WHEN user fills all required fields
  THEN Continue button should become enabled

Scenario: Continue to Document Capture
  GIVEN user filled personal info
  WHEN user taps Continue
  THEN user should be redirected to /kyc/document-capture
```

---

## 5.4 Document Capture View
- **File:** `lib/features/kyc/views/document_capture_view.dart`
- **Route:** `/kyc/document-capture`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Document Capture

Scenario: Display Capture Instructions
  GIVEN user completed personal info
  WHEN the document capture screen displays
  THEN "Capture National ID Card" title should be visible
  AND tips for good photo should be listed:
    - "Good lighting"
    - "Clear focus"
    - "All corners visible"
  AND "Continue" button should be visible

Scenario: Camera Available
  GIVEN camera permission is granted
  WHEN user taps Continue
  THEN camera viewfinder should open
  AND capture frame overlay should be visible

Scenario: Camera Not Available (Simulator)
  GIVEN camera is not available
  WHEN document capture screen displays
  THEN "Choose from Gallery" option should appear

Scenario: Capture Document
  GIVEN user is on camera screen
  WHEN user captures photo
  THEN preview should be shown
  AND "Retake" and "Use Photo" options should be available
```

---

## 5.5 Selfie View
- **File:** `lib/features/kyc/views/selfie_view.dart`
- **Route:** `/kyc/selfie`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Selfie Capture

Scenario: Display Selfie Instructions
  GIVEN user captured document
  WHEN the selfie screen displays
  THEN selfie capture instructions should be visible
  AND face frame overlay should be visible
  AND tips for good selfie should be shown

Scenario: Capture Selfie
  GIVEN user is on selfie screen
  WHEN user takes selfie
  THEN face should be detected within frame
  AND preview should be shown
```

---

## 5.6 KYC Liveness View
- **File:** `lib/features/kyc/views/kyc_liveness_view.dart`
- **Route:** `/kyc/liveness`
- **Status:** `ACTIVE`
- **Backend Dependency:** `liveness-service` (may need creation)
- **BDD Tests:**
```gherkin
Feature: Liveness Check

Scenario: Display Liveness Instructions
  GIVEN user captured selfie
  WHEN the liveness check screen displays
  THEN liveness instructions should be visible
  AND action prompts should be shown (e.g., "Turn head left")

Scenario: Complete Liveness Check
  GIVEN user is performing liveness check
  WHEN all actions are completed successfully
  THEN liveness should be verified
  AND user should proceed to review
```

---

## 5.7 Review View
- **File:** `lib/features/kyc/views/review_view.dart`
- **Route:** `/kyc/review`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: KYC Review

Scenario: Display Review Screen
  GIVEN user completed all captures
  WHEN the review screen displays
  THEN captured document images should be displayed
  AND selfie should be displayed
  AND personal info summary should be shown
  AND "Submit" button should be available

Scenario: Submit KYC
  GIVEN user is on review screen
  WHEN user taps Submit
  THEN loading indicator should appear
  AND KYC should be submitted to backend
  AND user should be redirected to /kyc/submitted
```

---

## 5.8 Submitted View
- **File:** `lib/features/kyc/views/submitted_view.dart`
- **Route:** `/kyc/submitted`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: KYC Submitted

Scenario: Display Success Message
  GIVEN user submitted KYC
  WHEN the submitted screen displays
  THEN success icon should be visible
  AND "Verification Submitted" message should be shown
  AND estimated review time should be displayed
  AND "Continue" button should be available

Scenario: Continue to Home
  GIVEN user is on submitted screen
  WHEN user taps Continue
  THEN user should be redirected to /home
```

---

## 5.9 KYC Upgrade View
- **File:** `lib/features/kyc/views/kyc_upgrade_view.dart`
- **Route:** `/kyc/upgrade`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: KYC Upgrade

Scenario: Display Upgrade Options
  GIVEN user wants to upgrade KYC tier
  WHEN the upgrade screen displays
  THEN current tier should be shown
  AND target tier benefits should be listed
  AND additional requirements should be shown
  AND "Upgrade Now" button should be available
```

---

## 5.10 KYC Address View
- **File:** `lib/features/kyc/views/kyc_address_view.dart`
- **Route:** `/kyc/address`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: KYC Address

Scenario: Display Address Form
  GIVEN user needs to provide address for Tier 2
  WHEN the address screen displays
  THEN street address input should be visible
  AND city input should be visible
  AND country selector should be visible
  AND proof of address upload should be available
```

---

## 5.11 KYC Video View
- **File:** `lib/features/kyc/views/kyc_video_view.dart`
- **Route:** `/kyc/video`
- **Status:** `ACTIVE`
- **Backend Dependency:** `video-verification-service` (may need creation)
- **BDD Tests:**
```gherkin
Feature: KYC Video Verification

Scenario: Display Video Instructions
  GIVEN user needs video verification for Tier 3
  WHEN the video screen displays
  THEN recording instructions should be visible
  AND script to read should be shown
  AND "Start Recording" button should be available
```

---

## 5.12 KYC Additional Docs View
- **File:** `lib/features/kyc/views/kyc_additional_docs_view.dart`
- **Route:** `/kyc/additional-docs`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: KYC Additional Documents

Scenario: Display Document Upload
  GIVEN user needs to provide additional documents
  WHEN the additional docs screen displays
  THEN required document types should be listed
  AND upload buttons for each should be available
  AND uploaded documents should show preview
```

---

## 5.13 KYC Instruction Screen
- **File:** `lib/features/kyc/widgets/kyc_instruction_screen.dart`
- **Route:** None
- **Status:** `COMPONENT` - Reusable instruction widget

---

# 6. DEPOSIT FLOW

## 6.1 Deposit View
- **File:** `lib/features/wallet/views/deposit_view.dart`
- **Route:** `/deposit`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Deposit Entry Point

Scenario: Display Deposit Options
  GIVEN an authenticated user with verified KYC
  WHEN the Deposit button is tapped
  THEN deposit methods should be displayed
  AND Mobile Money options should be shown:
    - Orange Money
    - MTN MoMo
    - Wave
```

---

## 6.2 Deposit Amount Screen
- **File:** `lib/features/deposit/views/deposit_amount_screen.dart`
- **Route:** `/deposit/amount`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Deposit Amount

Scenario: Display Amount Input
  GIVEN user selected a deposit method
  WHEN the amount screen displays
  THEN amount input field should be visible
  AND currency should show XOF
  AND exchange rate to USDC should be displayed
  AND fee breakdown should be visible
  AND "Continue" button should be disabled

Scenario: Enter Valid Amount
  GIVEN user is on amount screen
  WHEN user enters valid amount (within limits)
  THEN USDC equivalent should be calculated
  AND fee should be displayed
  AND "Continue" button should become enabled

Scenario: Amount Below Minimum
  GIVEN user is on amount screen
  WHEN user enters amount below minimum
  THEN error message should be shown
  AND minimum amount should be displayed
```

---

## 6.3 Provider Selection Screen
- **File:** `lib/features/deposit/views/provider_selection_screen.dart`
- **Route:** `/deposit/provider`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Payment Provider Selection

Scenario: Display Providers
  GIVEN user entered deposit amount
  WHEN the provider selection screen displays
  THEN available payment providers should be listed
  AND each provider should show:
    - Provider logo
    - Fee percentage
    - Processing time

Scenario: Select Provider
  GIVEN user is on provider selection
  WHEN user selects a provider
  THEN provider should be highlighted
  AND "Continue" button should become enabled
```

---

## 6.4 Payment Instructions Screen
- **File:** `lib/features/deposit/views/payment_instructions_screen.dart`
- **Route:** `/deposit/instructions`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Payment Instructions

Scenario: Display USSD Instructions
  GIVEN user selected Orange Money
  WHEN the instructions screen displays
  THEN USSD code should be displayed (e.g., *144#)
  AND step-by-step instructions should be shown
  AND payment reference should be visible
  AND countdown timer may be visible

Scenario: Copy Reference
  GIVEN user is on instructions screen
  WHEN user taps "Copy" on reference
  THEN reference should be copied to clipboard
  AND confirmation toast should appear

Scenario: I've Paid Button
  GIVEN user completed payment on phone
  WHEN user taps "I've Paid"
  THEN status check should be initiated
  AND user should be redirected to /deposit/status
```

---

## 6.5 Deposit Status Screen
- **File:** `lib/features/deposit/views/deposit_status_screen.dart`
- **Route:** `/deposit/status`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Deposit Status

Scenario: Pending Status
  GIVEN deposit is being processed
  WHEN the status screen displays
  THEN pending indicator should be visible
  AND "Waiting for confirmation" message should be shown
  AND polling should occur for status updates

Scenario: Success Status
  GIVEN deposit completed successfully
  WHEN the status screen updates
  THEN success indicator should be visible
  AND amount credited should be shown
  AND "Done" button should be available

Scenario: Failed Status
  GIVEN deposit failed
  WHEN the status screen updates
  THEN failure indicator should be visible
  AND error message should be shown
  AND "Try Again" button should be available
```

---

## 6.6 Deposit Instructions View (Legacy)
- **File:** `lib/features/wallet/views/deposit_instructions_view.dart`
- **Route:** `/deposit/instructions` (with extra param)
- **Status:** `DEAD_CODE` - Superseded by payment_instructions_screen.dart

---

# 7. SEND FLOW (Internal Transfer)

## 7.1 Recipient Screen
- **File:** `lib/features/send/views/recipient_screen.dart`
- **Route:** `/send`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Send - Recipient Selection

Scenario: Display Recipient Screen
  GIVEN an authenticated user
  WHEN the Send button is tapped
  THEN phone number input should be visible
  AND recent recipients may be listed
  AND beneficiaries may be shown

Scenario: Enter Phone Number
  GIVEN user is on recipient screen
  WHEN user enters valid phone number
  THEN recipient should be validated
  AND recipient name may be shown
  AND "Continue" button should become enabled

Scenario: Select Beneficiary
  GIVEN user has saved beneficiaries
  WHEN user taps a beneficiary
  THEN beneficiary details should populate
  AND "Continue" button should become enabled

Scenario: Invalid Recipient
  GIVEN user is on recipient screen
  WHEN user enters non-existent phone number
  THEN error message should be shown
  AND "Invite" option may be available
```

---

## 7.2 Amount Screen
- **File:** `lib/features/send/views/amount_screen.dart`
- **Route:** `/send/amount`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Send - Amount Entry

Scenario: Display Amount Screen
  GIVEN user selected a recipient
  WHEN the amount screen displays
  THEN amount input should be visible
  AND available balance should be shown
  AND currency should be USDC

Scenario: Enter Amount
  GIVEN user is on amount screen
  WHEN user enters amount within balance
  THEN amount should be displayed
  AND fee breakdown may be visible
  AND "Continue" button should become enabled

Scenario: Insufficient Balance
  GIVEN user is on amount screen
  WHEN user enters amount exceeding balance
  THEN error message should be shown
  AND "Continue" button should remain disabled
```

---

## 7.3 Confirm Screen
- **File:** `lib/features/send/views/confirm_screen.dart`
- **Route:** `/send/confirm`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Send - Confirmation

Scenario: Display Confirmation
  GIVEN user entered amount
  WHEN the confirm screen displays
  THEN transaction summary should be visible:
    - Recipient name and phone
    - Amount to send
    - Fee (if any)
    - Total deduction
  AND "Confirm" button should be visible

Scenario: Confirm Transaction
  GIVEN user is on confirm screen
  WHEN user taps "Confirm"
  THEN PIN verification should be triggered
  AND user should be redirected to /send/pin
```

---

## 7.4 PIN Verification Screen
- **File:** `lib/features/send/views/pin_verification_screen.dart`
- **Route:** `/send/pin`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Send - PIN Verification

Scenario: Display PIN Entry
  GIVEN user confirmed transaction
  WHEN PIN verification is required
  THEN 6-digit PIN entry should be shown
  AND PinPad with digits 0-9 should be visible

Scenario: Correct PIN
  GIVEN user is on PIN screen
  WHEN user enters correct PIN
  THEN transfer should be executed
  AND user should be redirected to /send/result

Scenario: Incorrect PIN
  GIVEN user is on PIN screen
  WHEN user enters incorrect PIN
  THEN error message should be shown
  AND remaining attempts should be displayed
```

---

## 7.5 Result Screen
- **File:** `lib/features/send/views/result_screen.dart`
- **Route:** `/send/result`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Send - Result

Scenario: Success
  GIVEN transfer completed successfully
  WHEN the result screen displays
  THEN success indicator should be visible
  AND transaction details should be shown:
    - Amount sent
    - Recipient
    - Reference/ID
  AND "Done" button should be available
  AND "Share Receipt" option may be available

Scenario: Failure
  GIVEN transfer failed
  WHEN the result screen displays
  THEN failure indicator should be visible
  AND error message should be shown
  AND "Try Again" button may be available
```

---

## 7.6 Send View (Legacy)
- **File:** `lib/features/wallet/views/send_view.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Superseded by send/recipient_screen.dart

---

## 7.7 Offline Queue Dialog
- **File:** `lib/features/send/views/offline_queue_dialog.dart`
- **Route:** None (dialog)
- **Status:** `COMPONENT` - Modal for offline transactions

---

# 8. SEND EXTERNAL FLOW (Crypto Transfer)

## 8.1 Address Input Screen
- **File:** `lib/features/send_external/views/address_input_screen.dart`
- **Route:** `/send-external`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: External Transfer - Address Input

Scenario: Display Address Input
  GIVEN an authenticated user
  WHEN the send external flow starts
  THEN wallet address input should be visible
  AND QR scan button should be available
  AND network selector may be visible (Solana, Polygon, etc.)

Scenario: Enter Valid Address
  GIVEN user is on address input
  WHEN user enters valid wallet address
  THEN address should be validated
  AND "Continue" button should become enabled

Scenario: Invalid Address
  GIVEN user is on address input
  WHEN user enters invalid address format
  THEN error message should be shown
```

---

## 8.2 External Amount Screen
- **File:** `lib/features/send_external/views/external_amount_screen.dart`
- **Route:** `/send-external/amount`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: External Transfer - Amount

Scenario: Display Amount Screen
  GIVEN user entered valid address
  WHEN the amount screen displays
  THEN amount input should be visible
  AND available balance should be shown
  AND network fee estimate should be displayed
```

---

## 8.3 External Confirm Screen
- **File:** `lib/features/send_external/views/external_confirm_screen.dart`
- **Route:** `/send-external/confirm`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: External Transfer - Confirmation

Scenario: Display Confirmation
  GIVEN user entered amount
  WHEN the confirm screen displays
  THEN transaction summary should be visible:
    - Destination address (truncated)
    - Amount to send
    - Network fee
    - Network name
  AND warning about irreversibility should be shown
  AND "Confirm" button should be visible
```

---

## 8.4 External Result Screen
- **File:** `lib/features/send_external/views/external_result_screen.dart`
- **Route:** `/send-external/result`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: External Transfer - Result

Scenario: Success
  GIVEN external transfer completed
  WHEN the result screen displays
  THEN success indicator should be visible
  AND transaction hash should be shown
  AND "View on Explorer" link may be available
```

---

## 8.5 Scan Address QR Screen
- **File:** `lib/features/send_external/views/scan_address_qr_screen.dart`
- **Route:** `/qr/scan-address`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Scan Wallet Address QR

Scenario: Display Scanner
  GIVEN user tapped QR scan button
  WHEN the scan screen displays
  THEN camera viewfinder should be visible
  AND QR frame overlay should be shown

Scenario: Scan Valid QR
  GIVEN user is on scan screen
  WHEN valid wallet QR is scanned
  THEN address should be extracted
  AND user should return to address input with address filled
```

---

# 9. WITHDRAW FLOW

## 9.1 Withdraw View
- **File:** `lib/features/wallet/views/withdraw_view.dart`
- **Route:** `/withdraw`
- **Status:** `FEATURE_FLAG` (withdraw)
- **BDD Tests:**
```gherkin
Feature: Withdraw

Scenario: Display Withdraw Options
  GIVEN withdraw feature flag is enabled
  WHEN the withdraw screen displays
  THEN withdrawal methods should be shown:
    - Mobile Money
    - Bank Transfer
  AND current USDC balance should be displayed

Scenario: Select Withdraw Method
  GIVEN user is on withdraw screen
  WHEN user selects a method
  THEN withdrawal form should be shown
  AND destination account input should be visible
```

---

# 10. RECEIVE & SCAN

## 10.1 Receive View
- **File:** `lib/features/wallet/views/receive_view.dart`
- **Route:** `/receive`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Receive Money

Scenario: Display QR Code
  GIVEN an authenticated user
  WHEN the receive screen displays
  THEN QR code should be displayed
  AND wallet address should be shown below QR
  AND "Copy Address" button should be available
  AND "Share" button should be available

Scenario: Request Specific Amount
  GIVEN user is on receive screen
  WHEN user enters a specific amount
  THEN QR code should update with amount encoded
  AND amount should be displayed below QR

Scenario: Copy Address
  GIVEN user is on receive screen
  WHEN user taps "Copy Address"
  THEN address should be copied to clipboard
  AND confirmation toast should appear
```

---

## 10.2 Scan View
- **File:** `lib/features/wallet/views/scan_view.dart`
- **Route:** `/scan`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Scan QR Code

Scenario: Display Scanner
  GIVEN an authenticated user
  WHEN the scan screen displays
  THEN camera viewfinder should be visible
  AND QR frame overlay should be shown
  AND flash toggle may be available

Scenario: Scan JoonaPay QR
  GIVEN user is on scan screen
  WHEN valid JoonaPay QR is scanned
  THEN payment details should be extracted
  AND user should be redirected to send flow

Scenario: Invalid QR
  GIVEN user is on scan screen
  WHEN invalid QR is scanned
  THEN error message should be shown
```

---

## 10.3 Receive QR Screen (Legacy)
- **File:** `lib/features/qr_payment/views/receive_qr_screen.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Superseded by receive_view.dart

---

## 10.4 Scan QR Screen (Legacy)
- **File:** `lib/features/qr_payment/views/scan_qr_screen.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Superseded by scan_view.dart

---

## 10.5 Transfer Success View
- **File:** `lib/features/wallet/views/transfer_success_view.dart`
- **Route:** `/transfer/success`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Transfer Success

Scenario: Display Success
  GIVEN a transfer completed successfully
  WHEN the success view displays
  THEN success animation/icon should be visible
  AND transaction details should be shown
  AND "Done" button should be available
```

---

# 11. CARDS FEATURE

## 11.1 Request Card View
- **File:** `lib/features/cards/views/request_card_view.dart`
- **Route:** `/cards/request`
- **Status:** `FEATURE_FLAG` (virtualCards)
- **BDD Tests:**
```gherkin
Feature: Request Virtual Card

Scenario: Display Request Form
  GIVEN virtualCards feature flag is enabled
  WHEN user taps "Request Card"
  THEN card request form should display
  AND card type options may be shown
  AND terms should be displayed
  AND "Request Card" button should be available

Scenario: Submit Request
  GIVEN user is on request form
  WHEN user taps "Request Card"
  THEN request should be submitted
  AND confirmation should be shown
```

---

## 11.2 Card Detail View
- **File:** `lib/features/cards/views/card_detail_view.dart`
- **Route:** `/cards/detail/:id`
- **Status:** `FEATURE_FLAG` (virtualCards)
- **BDD Tests:**
```gherkin
Feature: Card Details

Scenario: Display Card Details
  GIVEN user has a virtual card
  WHEN user taps the card
  THEN card details should display:
    - Card number (masked: **** **** **** 1234)
    - Expiry date
    - CVV (hidden)
  AND "Show Details" button should be available
  AND card actions should be visible

Scenario: Reveal Card Details
  GIVEN user is on card detail
  WHEN user taps "Show Details" and verifies PIN
  THEN full card number should be revealed
  AND CVV should be revealed
  AND copy buttons should be available
```

---

## 11.3 Card Settings View
- **File:** `lib/features/cards/views/card_settings_view.dart`
- **Route:** `/cards/settings/:id`
- **Status:** `FEATURE_FLAG` (virtualCards)
- **BDD Tests:**
```gherkin
Feature: Card Settings

Scenario: Display Card Settings
  GIVEN user is on card detail
  WHEN user taps Settings
  THEN card settings should display:
    - Freeze/Unfreeze toggle
    - Transaction limits
    - Online payments toggle
    - ATM withdrawals toggle (if physical)
  AND "Delete Card" option should be available
```

---

## 11.4 Card Transactions View
- **File:** `lib/features/cards/views/card_transactions_view.dart`
- **Route:** `/cards/transactions/:id`
- **Status:** `FEATURE_FLAG` (virtualCards)
- **BDD Tests:**
```gherkin
Feature: Card Transactions

Scenario: Display Card Transactions
  GIVEN user is on card detail
  WHEN user taps Transactions
  THEN card-specific transactions should display
  AND each transaction should show:
    - Merchant name
    - Amount
    - Date
    - Status
```

---

# 12. SETTINGS SCREENS

## 12.1 Profile View
- **File:** `lib/features/settings/views/profile_view.dart`
- **Route:** `/settings/profile`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Profile View

Scenario: Display Profile
  GIVEN user is on settings
  WHEN user taps Profile
  THEN profile details should display:
    - Profile photo
    - Full name
    - Phone number
    - Email (if set)
  AND "Edit" button should be available
```

---

## 12.2 Profile Edit Screen
- **File:** `lib/features/settings/views/profile_edit_screen.dart`
- **Route:** `/settings/profile/edit`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Edit Profile

Scenario: Display Edit Form
  GIVEN user tapped Edit on profile
  WHEN the edit screen displays
  THEN editable fields should be shown:
    - First name
    - Last name
    - Email
  AND "Save" button should be available

Scenario: Save Changes
  GIVEN user modified profile
  WHEN user taps Save
  THEN changes should be saved
  AND success message should be shown
```

---

## 12.3 Change PIN View
- **File:** `lib/features/settings/views/change_pin_view.dart`
- **Route:** `/settings/pin`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Change PIN

Scenario: Display Change PIN Flow
  GIVEN user is on security settings
  WHEN user taps Change PIN
  THEN current PIN entry should be requested first

Scenario: Enter Current PIN
  GIVEN user is on change PIN
  WHEN user enters correct current PIN
  THEN new PIN entry should be shown

Scenario: Set New PIN
  GIVEN user entered current PIN
  WHEN user enters new PIN and confirms
  THEN PIN should be updated
  AND success message should be shown
```

---

## 12.4 KYC View (Settings)
- **File:** `lib/features/settings/views/kyc_view.dart`
- **Route:** `/settings/kyc`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: KYC Settings

Scenario: Display KYC Status
  GIVEN user is on settings
  WHEN user taps Identity/KYC
  THEN current KYC status should be shown
  AND current tier should be displayed
  AND "Upgrade" option should be available (if applicable)
```

---

## 12.5 Notification Settings View
- **File:** `lib/features/settings/views/notification_settings_view.dart`
- **Route:** `/settings/notifications`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Notification Settings

Scenario: Display Notification Preferences
  GIVEN user is on settings
  WHEN user taps Notifications
  THEN notification categories should be displayed
  AND toggle switches should be available for:
    - Transaction alerts
    - Marketing
    - Security alerts
    - Price alerts
```

---

## 12.6 Security View
- **File:** `lib/features/settings/views/security_view.dart`
- **Route:** `/settings/security`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Security Settings

Scenario: Display Security Options
  GIVEN user is on settings
  WHEN user taps Security
  THEN security options should be displayed:
    - Change PIN
    - Biometric authentication
    - Active sessions
    - Linked devices
    - 2FA settings (if available)
```

---

## 12.7 Biometric Settings View
- **File:** `lib/features/biometric/views/biometric_settings_view.dart`
- **Route:** `/settings/biometric`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Biometric Settings

Scenario: Display Biometric Options
  GIVEN user is on security settings
  WHEN user taps Biometric
  THEN biometric settings should display
  AND enable/disable toggle should be visible
  AND biometric type should be shown (Face ID/Fingerprint)
```

---

## 12.8 Biometric Enrollment View
- **File:** `lib/features/biometric/views/biometric_enrollment_view.dart`
- **Route:** `/settings/biometric/enrollment`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Biometric Enrollment

Scenario: Enroll Biometric
  GIVEN user is enabling biometric
  WHEN enrollment screen displays
  THEN biometric prompt should appear
  AND on success, biometric should be enrolled
```

---

## 12.9 Limits View
- **File:** `lib/features/settings/views/limits_view.dart`
- **Route:** `/settings/limits`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Transaction Limits

Scenario: Display Limits
  GIVEN user is on settings
  WHEN user taps Limits
  THEN transaction limits should be displayed:
    - Daily send limit
    - Monthly send limit
    - Daily withdraw limit
    - Per-transaction limit
  AND current KYC tier limits should be shown
  AND upgrade CTA may be shown
```

---

## 12.10 Help View
- **File:** `lib/features/settings/views/help_view.dart`
- **Route:** `/settings/help`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Help & Support

Scenario: Display Help Options
  GIVEN user is on settings
  WHEN user taps Help
  THEN help options should be displayed:
    - FAQ
    - Contact Support
    - Live Chat (if available)
    - Terms of Service
    - Privacy Policy
```

---

## 12.11 Help Screen
- **File:** `lib/features/settings/views/help_screen.dart`
- **Route:** `/settings/help-screen`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Help Screen

Scenario: Display Help Content
  GIVEN user tapped a help topic
  WHEN the help screen displays
  THEN help content should be shown
  AND search may be available
```

---

## 12.12 Language View
- **File:** `lib/features/settings/views/language_view.dart`
- **Route:** `/settings/language`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Language Settings

Scenario: Display Language Options
  GIVEN user is on settings
  WHEN user taps Language
  THEN language options should be displayed:
    - Français (French)
    - English
  AND current language should be selected

Scenario: Change Language
  GIVEN user is on language settings
  WHEN user selects a different language
  THEN app should update to selected language
  AND confirmation should be shown
```

---

## 12.13 Theme Settings View
- **File:** `lib/features/settings/views/theme_settings_view.dart`
- **Route:** `/settings/theme`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Theme Settings

Scenario: Display Theme Options
  GIVEN user is on settings
  WHEN user taps Theme/Appearance
  THEN theme options should be displayed:
    - Light
    - Dark
    - System default
  AND current theme should be selected
```

---

## 12.14 Currency View
- **File:** `lib/features/settings/views/currency_view.dart`
- **Route:** `/settings/currency`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Currency Settings

Scenario: Display Currency Options
  GIVEN user is on settings
  WHEN user taps Currency
  THEN display currency options should be shown:
    - USDC
    - XOF
    - USD
    - EUR
  AND current display currency should be selected
```

---

## 12.15 Devices Screen
- **File:** `lib/features/settings/views/devices_screen.dart`
- **Route:** `/settings/devices`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Linked Devices

Scenario: Display Devices
  GIVEN user is on security settings
  WHEN user taps Devices
  THEN linked devices should be listed
  AND each device should show:
    - Device name
    - Last active time
    - Device type
  AND "Remove" option should be available

Scenario: Remove Device
  GIVEN user is on devices screen
  WHEN user removes a device
  THEN confirmation should be requested
  AND device should be unlinked
```

---

## 12.16 Sessions Screen
- **File:** `lib/features/settings/views/sessions_screen.dart`
- **Route:** `/settings/sessions`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Active Sessions

Scenario: Display Sessions
  GIVEN user is on security settings
  WHEN user taps Sessions
  THEN active sessions should be listed
  AND current session should be marked
  AND "End Session" option should be available for others

Scenario: End Other Session
  GIVEN user is on sessions screen
  WHEN user ends another session
  THEN that session should be terminated
  AND confirmation should be shown
```

---

## 12.17 Business Setup View
- **File:** `lib/features/business/views/business_setup_view.dart`
- **Route:** `/settings/business-setup`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Business Setup

Scenario: Display Business Setup
  GIVEN user wants to enable business features
  WHEN business setup screen displays
  THEN business registration form should be shown
  AND business name input should be visible
  AND business type selector should be available
```

---

## 12.18 Business Profile View
- **File:** `lib/features/business/views/business_profile_view.dart`
- **Route:** `/settings/business-profile`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Business Profile

Scenario: Display Business Profile
  GIVEN user has business account
  WHEN business profile screen displays
  THEN business details should be shown
  AND edit option should be available
```

---

## 12.19 Cookie Policy View
- **File:** `lib/features/settings/views/cookie_policy_view.dart`
- **Route:** `/settings/legal/cookies`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Cookie Policy

Scenario: Display Cookie Policy
  GIVEN user is viewing legal documents
  WHEN cookie policy screen displays
  THEN cookie policy content should be shown
```

---

## 12.20 Performance Monitor View
- **File:** `lib/features/settings/views/performance_monitor_view.dart`
- **Route:** None
- **Status:** `DEMO` - Debug tool only

---

## 12.21 Limits View (Features)
- **File:** `lib/features/limits/views/limits_view.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Duplicate of settings/limits_view.dart

---

# 13. NOTIFICATIONS

## 13.1 Notifications View
- **File:** `lib/features/notifications/views/notifications_view.dart`
- **Route:** `/notifications`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Notifications List

Scenario: Display Notifications
  GIVEN an authenticated user
  WHEN the notifications screen displays
  THEN notifications should be listed chronologically
  AND unread notifications should be highlighted
  AND each notification should show:
    - Title
    - Message preview
    - Timestamp

Scenario: Empty State
  GIVEN user has no notifications
  WHEN the notifications screen displays
  THEN empty state should be shown
  AND message "No notifications yet" should be visible
```

---

## 13.2 Notification Permission Screen
- **File:** `lib/features/notifications/views/notification_permission_screen.dart`
- **Route:** `/notifications/permission`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Notification Permission

Scenario: Request Permission
  GIVEN notifications are not enabled
  WHEN permission screen displays
  THEN explanation of benefits should be shown
  AND "Enable Notifications" button should be available
  AND "Skip" option should be available
```

---

## 13.3 Notification Preferences Screen
- **File:** `lib/features/notifications/views/notification_preferences_screen.dart`
- **Route:** `/notifications/preferences`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Notification Preferences

Scenario: Display Preferences
  GIVEN user is managing notifications
  WHEN preferences screen displays
  THEN notification categories should be listed
  AND toggle switches should be available for each
```

---

# 14. TRANSACTIONS

## 14.1 Transaction Detail View
- **File:** `lib/features/transactions/views/transaction_detail_view.dart`
- **Route:** `/transactions/:id`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Transaction Detail

Scenario: Display Transaction Detail
  GIVEN user tapped a transaction
  WHEN the detail screen displays
  THEN full transaction details should be shown:
    - Transaction type
    - Amount
    - Fee
    - Total
    - Date and time
    - Status
    - Reference/ID
  AND "Share Receipt" option should be available
```

---

## 14.2 Export Transactions View
- **File:** `lib/features/transactions/views/export_transactions_view.dart`
- **Route:** `/transactions/export`
- **Status:** `ACTIVE`
- **BDD Tests:**
```gherkin
Feature: Export Transactions

Scenario: Display Export Options
  GIVEN user wants to export transactions
  WHEN the export screen displays
  THEN date range picker should be available
  AND format options should be shown (PDF, CSV)
  AND "Export" button should be available

Scenario: Export Data
  GIVEN user selected date range and format
  WHEN user taps Export
  THEN file should be generated
  AND download/share options should be shown
```

---

# 15. FEATURE FLAG GATED SCREENS

## 15.1 Bill Pay View
- **File:** `lib/features/wallet/views/bill_pay_view.dart`
- **Route:** `/bills`
- **Status:** `FEATURE_FLAG` (bills)

---

## 15.2 Buy Airtime View
- **File:** `lib/features/wallet/views/buy_airtime_view.dart`
- **Route:** `/airtime`
- **Status:** `FEATURE_FLAG` (airtime)

---

## 15.3 Savings Goals View
- **File:** `lib/features/wallet/views/savings_goals_view.dart`
- **Route:** `/savings`
- **Status:** `FEATURE_FLAG` (savings)

---

## 15.4 Virtual Card View
- **File:** `lib/features/wallet/views/virtual_card_view.dart`
- **Route:** `/card`
- **Status:** `FEATURE_FLAG` (virtualCards)

---

## 15.5 Split Bill View
- **File:** `lib/features/wallet/views/split_bill_view.dart`
- **Route:** `/split`
- **Status:** `FEATURE_FLAG` (splitBills)

---

## 15.6 Budget View
- **File:** `lib/features/wallet/views/budget_view.dart`
- **Route:** `/budget`
- **Status:** `FEATURE_FLAG` (budget)

---

## 15.7 Analytics View
- **File:** `lib/features/wallet/views/analytics_view.dart`
- **Route:** `/analytics`
- **Status:** `FEATURE_FLAG` (analytics)

---

## 15.8 Currency Converter View
- **File:** `lib/features/wallet/views/currency_converter_view.dart`
- **Route:** `/converter`
- **Status:** `FEATURE_FLAG` (currencyConverter)

---

## 15.9 Request Money View
- **File:** `lib/features/wallet/views/request_money_view.dart`
- **Route:** `/request`
- **Status:** `FEATURE_FLAG` (requestMoney)

---

## 15.10 Saved Recipients View
- **File:** `lib/features/wallet/views/saved_recipients_view.dart`
- **Route:** `/recipients`
- **Status:** `FEATURE_FLAG` (savedRecipients)

---

## 15.11 Scheduled Transfers View
- **File:** `lib/features/wallet/views/scheduled_transfers_view.dart`
- **Route:** `/scheduled`
- **Status:** `FEATURE_FLAG` (recurringTransfers)

---

## 15.12 Pending Transfers View
- **File:** `lib/features/wallet/views/pending_transfers_view.dart`
- **Route:** None
- **Status:** `DISABLED` - Offline feature not in MVP

---

# 16-30: ADDITIONAL SCREENS

(Continuing with remaining screens from the inventory...)

See individual test files in `integration_test/golden/tests/` for complete BDD definitions for:
- Savings Pots (16)
- Recurring Transfers (17)
- Merchant Pay (18)
- Bill Payments (19)
- Alerts (20)
- Insights (21)
- Expenses (22)
- Payment Links (23)
- Sub-Business (24)
- Bulk Payments (25)
- Beneficiaries (26)
- Bank Linking (27)
- PIN Feature (28)
- Contacts (29)
- Other Screens (30)

---

# SUMMARY

## Screen Counts by Status

| Status | Count | Test Requirement |
|--------|-------|-----------------|
| ACTIVE | ~145 | Golden tests required |
| FEATURE_FLAG | ~25 | Golden tests when enabled |
| COMPONENT | ~20 | Test within flows |
| AWAITING_BACKEND | 5 | Mock and test |
| DEAD_CODE | ~15 | Consider deletion |
| DISABLED | ~10 | Document and skip |
| DEMO | 2 | Skip |

**Total: ~222 screens documented**

---

## Backend Dependencies to Create

The following backend services may need creation (ask user before scaffolding with `ddd`):

1. `liveness-service` - For KYC liveness verification
2. `video-verification-service` - For KYC video verification
3. `identity-verification-service` - For document OCR and verification

---

## Test Execution Order

1. **Auth Flow** (01) - Foundation
2. **KYC Flow** (02) - Onboarding completion
3. **Home & Navigation** (03) - Main app shell
4. **Deposit Flow** (04) - Core feature
5. **Send Flow** (05) - Core feature
6. **Send External** (06) - Core feature
7. **Settings** (07) - User preferences
8. **Transactions** (08) - History
9. **Remaining features** (09-24) - As enabled

---

*Document generated: 2026-02-03*
*Total screens analyzed: 250*
*Golden test files: 24*
