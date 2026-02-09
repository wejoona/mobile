# JoonaPay Mobile - BDD Screen Inventory

> **Generated:** 2025-01-29
> **Total Screens:** 180 view files across 35 feature modules
> **Status Legend:**
> - `[ACTIVE]` - Live with real API integration
> - `[MOCK]` - Uses mock data, needs backend integration
> - `[PARTIAL]` - Some features mocked
> - `[DEAD_CODE]` - Not in router, unused
> - `[AWAITING_IMPLEMENTATION]` - Placeholder/TODO
> - `[DEMO]` - Demo-only functionality
> - `[DISABLED]` - Feature flagged off

---

## 1. Auth & Authentication

### 1.1 splash_view.dart `[ACTIVE]`
**Path:** `lib/features/splash/views/splash_view.dart`
**Route:** `/`

**Feature:** App Entry Point
```gherkin
Feature: App Launch & Authentication Check
  As a user opening the app
  I want the app to check my authentication status
  So that I'm directed to the appropriate screen

  Scenario: First-time user
    Given the app has never been opened before
    When the splash screen animation completes
    Then I should be navigated to the onboarding flow

  Scenario: Returning user not authenticated
    Given onboarding has been completed
    And the user is not authenticated
    When the splash screen animation completes
    Then I should be navigated to the login screen

  Scenario: Returning authenticated user
    Given the user has valid session tokens
    When the splash screen animation completes
    Then I should be navigated to the home screen
```

**Testable Scenarios:**
- Animation renders correctly (golden test)
- Navigation to `/onboarding` for first-time users
- Navigation to `/login` for unauthenticated users
- Navigation to `/home` for authenticated users
- Loading spinner displays during auth check

---

### 1.2 login_view.dart `[ACTIVE]`
**Path:** `lib/features/auth/views/login_view.dart`
**Route:** `/login`

**Feature:** User Login
```gherkin
Feature: Phone Number Login
  As a returning user
  I want to log in with my phone number
  So that I can access my wallet

  Scenario: Successful login initiation
    Given I am on the login screen
    And I select country "Côte d'Ivoire" (+225)
    When I enter a valid 10-digit phone number
    And I tap "Continue"
    Then I should be navigated to OTP verification

  Scenario: Invalid phone number
    Given I am on the login screen
    When I enter a phone number with less than required digits
    Then the validation indicator should show error
    And the "Continue" button should be disabled

  Scenario: Toggle to registration
    Given I am on the login screen
    When I tap "Don't have an account? Sign Up"
    Then the form should switch to registration mode
    And the button label should change to "Create Account"
```

**Testable Scenarios:**
- Country picker modal opens and displays all supported countries
- Phone validation shows check/error icons
- Loading state on submit
- Error snackbar displays on API error
- Navigation to OTP screen on success
- Registration/Login toggle works
- Terms of Service link opens legal document
- Privacy Policy link opens legal document

---

### 1.3 login_otp_view.dart `[MOCK]`
**Path:** `lib/features/auth/views/login_otp_view.dart`
**Route:** `/login/otp`

**Feature:** OTP Verification during Login
```gherkin
Feature: OTP Verification
  As a user logging in
  I want to verify my identity with an OTP
  So that my account remains secure

  Scenario: Successful OTP entry
    Given I am on the OTP verification screen
    And I received an OTP code
    When I enter the 6-digit OTP correctly
    Then I should be navigated to PIN verification

  Scenario: Invalid OTP
    Given I am on the OTP verification screen
    When I enter an incorrect OTP
    Then the OTP boxes should show error state
    And the input should be cleared

  Scenario: Resend OTP
    Given I am on the OTP verification screen
    And the resend countdown has finished
    When I tap "Resend Code"
    Then a new OTP should be sent
    And the countdown should restart
```

**Testable Scenarios:**
- 6 OTP input boxes render correctly
- Auto-focus moves to next box on digit entry
- Backspace moves to previous box
- Auto-submit when 6 digits entered
- Error state styling
- Resend countdown timer
- Resend button enabled after countdown
- Dev OTP "123456" works in mock mode

---

### 1.4 login_pin_view.dart `[ACTIVE]`
**Path:** `lib/features/auth/views/login_pin_view.dart`
**Route:** `/login/pin`

**Feature:** PIN Verification during Login
```gherkin
Feature: PIN Verification
  As a user
  I want to verify my PIN
  So that I can securely access my wallet

  Scenario: Successful PIN entry
    Given I am on the PIN verification screen
    When I enter my correct 6-digit PIN
    Then I should be navigated to the home screen

  Scenario: Incorrect PIN
    Given I am on the PIN verification screen
    When I enter an incorrect PIN
    Then the PIN dots should show error animation
    And I should see remaining attempts count

  Scenario: Account locked
    Given I have exceeded maximum PIN attempts
    Then I should see the account locked screen
    And I should have the option to go back to login

  Scenario: Biometric login
    Given biometric authentication is enabled
    And the device supports Face ID/Touch ID
    When the PIN screen loads
    Then biometric prompt should appear automatically
```

**Testable Scenarios:**
- PIN pad renders 0-9 digits + backspace
- PIN dots fill as digits entered
- Auto-verify at 6 digits
- Error animation and auto-clear
- Remaining attempts display
- Locked state screen
- Biometric button visibility
- Biometric auto-prompt
- "Forgot PIN" button navigates to reset

---

### 1.5 otp_view.dart `[MOCK]`
**Path:** `lib/features/auth/views/otp_view.dart`
**Route:** `/otp`

**Feature:** Standalone OTP Verification
```gherkin
Feature: Standalone OTP Verification
  As a user
  I want to verify OTP for various operations
  So that I can complete secure actions

  Scenario: OTP verification with biometric option
    Given I am on the OTP verification screen
    And biometric is enabled and available
    When I view the PIN pad
    Then I should see the biometric authentication option
```

**Testable Scenarios:**
- PIN pad with biometric integration
- SMS autofill listener active
- Resend timer with visual countdown
- Navigation to home on success

---

### 1.6 login_phone_view.dart `[DEAD_CODE]`
**Path:** `lib/features/auth/views/login_phone_view.dart`
**Route:** N/A (not in router)

**Feature:** Legacy Phone Input
```gherkin
Feature: Legacy Phone Input (Deprecated)
  Note: This screen is marked as UNUSED in sitemap.
  DO NOT USE - use login_view.dart instead.
```

**Status:** Dead code - simplified duplicate of login_view.dart

---

### 1.7 legal_document_view.dart `[ACTIVE]`
**Path:** `lib/features/auth/views/legal_document_view.dart`
**Route:** Internal (pushed via Navigator)

**Feature:** Legal Document Viewer
```gherkin
Feature: Legal Document Display
  As a user
  I want to view Terms of Service and Privacy Policy
  So that I understand the app's legal terms

  Scenario: View Terms of Service
    Given I tap on "Terms of Service" link
    When the legal document view loads
    Then I should see the current version number
    And I should see the effective date
    And I should see the full document content

  Scenario: View Privacy Policy
    Given I tap on "Privacy Policy" link
    When the legal document view loads
    Then I should see the privacy policy content
```

**Testable Scenarios:**
- Document loads from API/cache
- Version badge displays
- Effective date formats correctly
- HTML content renders properly
- Loading spinner during fetch
- Error state on load failure
- Summary section if available

---

## 2. Onboarding

### 2.1 onboarding_view.dart `[ACTIVE]`
**Path:** `lib/features/onboarding/views/onboarding_view.dart`
**Route:** `/onboarding`

**Feature:** First-Time User Tutorial
```gherkin
Feature: App Onboarding Tutorial
  As a new user
  I want to learn about the app features
  So that I understand how to use JoonaPay

  Scenario: View all onboarding pages
    Given I am on the onboarding screen
    When I swipe through all 4 pages
    Then I should see "Your Money, Your Way"
    And I should see "Send Money Instantly"
    And I should see "Easy Deposits & Withdrawals"
    And I should see "Bank-Level Security"

  Scenario: Skip onboarding
    Given I am on any onboarding page
    When I tap "Skip"
    Then I should be navigated to the login screen
    And onboarding should be marked as completed

  Scenario: Complete onboarding
    Given I am on the last onboarding page
    When I tap "Get Started"
    Then I should be navigated to the login screen
```

**Testable Scenarios:**
- 4 onboarding pages render with icons/text
- Page indicator shows current page
- Skip button visible on all pages
- Next button on pages 1-3
- "Get Started" button on page 4
- SharedPreferences updated on completion

---

### 2.2 welcome_view.dart `[ACTIVE]`
**Path:** `lib/features/onboarding/views/welcome_view.dart`
**Route:** Internal (onboarding flow)

**Feature:** Welcome Screen
```gherkin
Feature: Welcome Screen
  As a new user starting registration
  I want to see a welcoming introduction
  So that I feel confident using the app
```

**Testable Scenarios:**
- Welcome message displays
- Continue button navigates to phone input

---

### 2.3 phone_input_view.dart `[MOCK]`
**Path:** `lib/features/onboarding/views/phone_input_view.dart`
**Route:** Internal (onboarding flow)

**Feature:** Phone Registration
```gherkin
Feature: Phone Number Registration
  As a new user
  I want to register my phone number
  So that I can create an account

  Scenario: Enter valid phone number
    Given I am on the phone input screen
    When I select a country and enter a valid phone number
    And I tap continue
    Then an OTP should be sent to my phone
```

**Testable Scenarios:**
- Country picker with flag display
- Phone validation rules by country
- Continue button state management

---

### 2.4 otp_verification_view.dart `[MOCK]`
**Path:** `lib/features/onboarding/views/otp_verification_view.dart`
**Route:** Internal (onboarding flow)

**Feature:** Registration OTP Verification
```gherkin
Feature: Registration OTP Verification
  As a new user
  I want to verify my phone number with OTP
  So that my account is secured from the start
```

**Testable Scenarios:**
- OTP input fields
- Auto-verify on complete entry
- Resend functionality

---

### 2.5 profile_setup_view.dart `[MOCK]`
**Path:** `lib/features/onboarding/views/profile_setup_view.dart`
**Route:** Internal (onboarding flow)

**Feature:** Profile Name Entry
```gherkin
Feature: Profile Setup
  As a new user
  I want to set up my profile name
  So that my account is personalized

  Scenario: Enter profile name
    Given I am on the profile setup screen
    When I enter my first and last name
    And I tap continue
    Then my profile should be saved
    And I should proceed to PIN setup
```

**Testable Scenarios:**
- First name input
- Last name input
- Validation rules
- Continue button state

---

### 2.6 onboarding_pin_view.dart `[ACTIVE]`
**Path:** `lib/features/onboarding/views/onboarding_pin_view.dart`
**Route:** Internal (onboarding flow)

**Feature:** Initial PIN Creation
```gherkin
Feature: PIN Creation during Onboarding
  As a new user
  I want to create a secure PIN
  So that my wallet is protected
```

**Testable Scenarios:**
- PIN pad renders
- PIN validation rules enforced
- Navigation to confirmation

---

### 2.7 kyc_prompt_view.dart `[ACTIVE]`
**Path:** `lib/features/onboarding/views/kyc_prompt_view.dart`
**Route:** Internal (onboarding flow)

**Feature:** KYC Upsell Prompt
```gherkin
Feature: KYC Verification Prompt
  As a new user
  I want to understand the benefits of KYC verification
  So that I can decide whether to verify my identity

  Scenario: Skip KYC for now
    Given I am on the KYC prompt screen
    When I tap "Skip for now"
    Then I should proceed to the success screen
    And my account should have limited features

  Scenario: Start KYC verification
    Given I am on the KYC prompt screen
    When I tap "Verify my identity"
    Then I should be navigated to the KYC flow
```

**Testable Scenarios:**
- KYC benefits listed
- "Skip for now" button
- "Verify identity" button
- Limit information displayed

---

### 2.8 onboarding_success_view.dart `[ACTIVE]`
**Path:** `lib/features/onboarding/views/onboarding_success_view.dart`
**Route:** Internal (onboarding flow)

**Feature:** Onboarding Completion
```gherkin
Feature: Onboarding Success
  As a new user
  I want to see confirmation that my account is ready
  So that I can start using the app

  Scenario: View success screen
    Given I completed the onboarding flow
    When the success screen loads
    Then I should see a success animation
    And I should see "Account Created Successfully"
    And I should be able to go to home screen
```

**Testable Scenarios:**
- Success animation/icon
- Success message
- "Go to Home" button
- Navigation to home

---

### 2.9 enhanced_onboarding_view.dart `[ACTIVE]`
**Path:** `lib/features/onboarding/views/enhanced_onboarding_view.dart`
**Route:** Enhanced onboarding flow

**Feature:** Enhanced Onboarding Flow
```gherkin
Feature: Enhanced Onboarding Experience
  As a new user
  I want an improved onboarding experience
  So that I can quickly understand and use the app
```

**Testable Scenarios:**
- Enhanced animations
- Interactive elements
- Progress tracking

---

### 2.10 welcome_post_login_view.dart `[ACTIVE]`
**Path:** `lib/features/onboarding/views/welcome_post_login_view.dart`
**Route:** Internal

**Feature:** Post-Login Welcome
```gherkin
Feature: Welcome Back Screen
  As a returning user
  I want to see a personalized welcome
  So that I feel recognized
```

**Testable Scenarios:**
- User name display
- Time-based greeting
- Quick action buttons

---

### 2.11 Help Views (3 files) `[ACTIVE]`
**Path:** `lib/features/onboarding/views/help/`
- `deposits_guide_view.dart`
- `fees_transparency_view.dart`
- `usdc_explainer_view.dart`

**Feature:** Help & Educational Content
```gherkin
Feature: Educational Help Content
  As a user
  I want to learn about USDC, deposits, and fees
  So that I understand how the app works

  Scenario: View USDC explanation
    Given I tap on "What is USDC?"
    When the explainer view loads
    Then I should see clear explanation of USDC stablecoin

  Scenario: View deposit guide
    Given I want to add funds
    When I view the deposit guide
    Then I should see step-by-step instructions

  Scenario: View fee transparency
    Given I want to understand costs
    When I view the fees transparency page
    Then I should see clear breakdown of all fees
```

---

## 3. Wallet & Home

### 3.1 home_view.dart `[PARTIAL]`
**Path:** `lib/features/wallet/views/home_view.dart`
**Route:** `/home`

**Feature:** Wallet Home Screen
```gherkin
Feature: Wallet Dashboard
  As an authenticated user
  I want to see my wallet balance and recent activity
  So that I can manage my finances

  Scenario: View balance
    Given I am on the home screen
    Then I should see my USDC balance
    And I should see optional reference currency conversion

  Scenario: Quick actions
    Given I am on the home screen
    When I view the quick actions section
    Then I should see "Send", "Receive", and "Scan" buttons

  Scenario: View recent transactions
    Given I am on the home screen
    And I have transaction history
    Then I should see the 5 most recent transactions
    And I should be able to tap "View All"

  Scenario: Pull to refresh
    Given I am on the home screen
    When I pull down to refresh
    Then my balance should be updated
    And my transactions should be refreshed
```

**Testable Scenarios:**
- Greeting with time-based message (morning/afternoon/evening/night)
- User avatar with initials
- Balance card with USDC amount
- Reference currency display (if enabled)
- Pending balance indicator
- Quick action buttons (Send, Receive, Scan)
- Services link card
- Transaction list with 5 items max
- Empty transactions state
- Pull-to-refresh functionality
- Tablet/landscape responsive layouts
- Notification bell with unread count
- Settings gear navigation
- Create wallet card (if no wallet exists)
- Error state with retry

---

### 3.2 send_view.dart `[MOCK]`
**Path:** `lib/features/wallet/views/send_view.dart`
**Route:** `/send` (legacy)

**Feature:** Send Money
```gherkin
Feature: Send Money
  As a user with balance
  I want to send money to others
  So that I can transfer funds

  Scenario: Send to phone number
    Given I am on the send screen
    And I have sufficient balance
    When I enter a recipient's phone number
    And I enter an amount
    And I confirm with my PIN
    Then the transfer should be processed

  Scenario: Send to wallet address
    Given I am on the send screen "To Wallet" tab
    When I enter a valid wallet address
    And I enter an amount
    And I confirm with my PIN
    Then the external transfer should be processed

  Scenario: Insufficient balance
    Given I am on the send screen
    When I enter an amount greater than my balance
    Then I should see "Insufficient balance" error
    And the send button should be disabled
```

**Testable Scenarios:**
- Tab switching (To Phone / To Wallet)
- Available balance display from FSM
- Recent contacts horizontal list
- Contact selection from device
- Saved recipients selection
- Phone number input with country code
- Wallet address input with validation
- Amount input with validation
- Quick amount buttons (5, 10, 25, 50, MAX)
- PIN confirmation sheet
- Success snackbar
- Offer to save recipient dialog
- Ethereum address validation
- Phone number validation

---

### 3.3 deposit_view.dart `[MOCK]`
**Path:** `lib/features/wallet/views/deposit_view.dart`
**Route:** `/deposit`

**Feature:** Deposit Funds
```gherkin
Feature: Deposit Funds
  As a user
  I want to add money to my wallet
  So that I can use my balance

  Scenario: Select deposit method
    Given I am on the deposit screen
    When I view payment methods
    Then I should see Mobile Money, Bank Transfer, Card, and Crypto options

  Scenario: Enter deposit amount
    Given I am on the deposit screen
    When I enter an amount within limits
    And I select a payment method
    Then I should be able to continue

  Scenario: Mobile Money deposit
    Given I selected Mobile Money
    And I selected Orange Money
    When I tap continue
    Then I should see USSD instructions
```

**Testable Scenarios:**
- Amount input with currency selector
- Min/max amount validation
- Quick amount buttons (5K, 10K, 25K, 50K)
- Currency picker modal
- Payment method universe sections (expandable)
- Mobile Money providers list
- Bank transfer option
- Card payment option
- Crypto option
- Continue button state
- Navigation to instructions

---

### 3.4 deposit_instructions_view.dart `[MOCK]`
**Path:** `lib/features/wallet/views/deposit_instructions_view.dart`
**Route:** `/deposit/instructions`

**Feature:** Deposit Instructions
```gherkin
Feature: Deposit Payment Instructions
  As a user completing a deposit
  I want clear payment instructions
  So that I can complete my deposit

  Scenario: View USSD instructions
    Given I selected Mobile Money deposit
    When the instructions screen loads
    Then I should see the USSD code to dial
    And I should see step-by-step instructions
```

**Testable Scenarios:**
- USSD code display
- Copy to clipboard functionality
- Step-by-step instructions
- Timer/expiry information

---

### 3.5 withdraw_view.dart `[MOCK]`
**Path:** `lib/features/wallet/views/withdraw_view.dart`
**Route:** `/withdraw`

**Feature:** Withdraw Funds
```gherkin
Feature: Withdraw Funds
  As a user with balance
  I want to withdraw my funds
  So that I can access my money in local currency

  Scenario: Withdraw to Mobile Money
    Given I am on the withdraw screen
    When I select "Mobile Money"
    And I enter my phone number
    And I enter an amount
    And I confirm with PIN
    Then the withdrawal should be initiated

  Scenario: Withdraw to bank
    Given I am on the withdraw screen
    When I select "Bank Transfer"
    And I enter bank details
    And I enter an amount
    And I confirm with PIN
    Then the bank withdrawal should be initiated

  Scenario: Withdraw to crypto wallet
    Given I am on the withdraw screen
    When I select "Crypto Wallet"
    And I enter a valid USDC address
    And I enter an amount
    And I confirm with PIN
    Then the crypto withdrawal should be initiated
```

**Testable Scenarios:**
- Available balance from FSM
- Withdrawal method cards (Mobile Money, Bank, Crypto)
- Method selection state
- Phone number input for Mobile Money
- Bank name and account number for Bank
- Wallet address for Crypto
- Amount input with validation
- Percentage quick buttons (25%, 50%, 75%, MAX)
- PIN confirmation sheet
- Processing info card
- Success/error handling

---

### 3.6 receive_view.dart `[MOCK]`
**Path:** `lib/features/wallet/views/receive_view.dart`
**Route:** `/receive`

**Feature:** Receive Money
```gherkin
Feature: Receive Money
  As a user
  I want to show my receiving details
  So that others can send me money

  Scenario: Display QR code
    Given I am on the receive screen
    Then I should see a QR code with my wallet address
    And I should see my phone number

  Scenario: Share receiving details
    Given I am on the receive screen
    When I tap "Share"
    Then I should be able to share my payment link
```

**Testable Scenarios:**
- QR code generation
- Wallet address display
- Phone number display
- Copy address button
- Share functionality

---

### 3.7 scan_view.dart `[MOCK]`
**Path:** `lib/features/wallet/views/scan_view.dart`
**Route:** `/scan`

**Feature:** QR Scanner
```gherkin
Feature: QR Code Scanner
  As a user
  I want to scan QR codes
  So that I can quickly send money or pay merchants

  Scenario: Scan payment QR
    Given I am on the scan screen
    And the camera is active
    When I scan a valid payment QR code
    Then I should be navigated to payment confirmation
```

**Testable Scenarios:**
- Camera permission request
- Camera preview display
- QR code detection
- Flash toggle button
- Gallery import option

---

### 3.8 transfer_success_view.dart `[MOCK]`
**Path:** `lib/features/wallet/views/transfer_success_view.dart`
**Route:** `/transfer/success`

**Feature:** Transfer Success
```gherkin
Feature: Transfer Success Confirmation
  As a user who completed a transfer
  I want to see confirmation
  So that I know my transfer was successful
```

**Testable Scenarios:**
- Success animation/icon
- Transaction details display
- Share receipt button
- Return to home button

---

### 3.9-3.15 Additional Wallet Views `[MOCK]`
**Paths:**
- `analytics_view.dart` - `/analytics` - Spending analytics
- `bill_pay_view.dart` - `/bills` - Legacy bill payment entry
- `budget_view.dart` - `/budget` - Budget tracking
- `buy_airtime_view.dart` - `/airtime` - Airtime purchase
- `currency_converter_view.dart` - `/converter` - Currency conversion tool
- `pending_transfers_view.dart` - Offline queue display
- `request_money_view.dart` - `/request` - Request money
- `saved_recipients_view.dart` - `/recipients` - Saved recipients list
- `savings_goals_view.dart` - `/savings` - Legacy savings goals
- `scheduled_transfers_view.dart` - `/scheduled` - Legacy scheduled transfers
- `split_bill_view.dart` - `/split` - Bill splitting
- `virtual_card_view.dart` - `/card` - Virtual card (TODO)

---

## 4. PIN Management

### 4.1 set_pin_view.dart `[ACTIVE]`
**Path:** `lib/features/pin/views/set_pin_view.dart`
**Route:** `/pin/set`

**Feature:** Create New PIN
```gherkin
Feature: PIN Creation
  As a user
  I want to create a secure PIN
  So that my wallet is protected

  Scenario: Create valid PIN
    Given I am on the PIN creation screen
    When I enter a 6-digit PIN that meets all requirements
    Then I should proceed to PIN confirmation

  Scenario: Reject sequential PIN
    Given I am on the PIN creation screen
    When I enter "123456" (sequential)
    Then I should see "Sequential numbers not allowed" error
    And the PIN should be cleared

  Scenario: Reject repeated PIN
    Given I am on the PIN creation screen
    When I enter "111111" (repeated)
    Then I should see "Same digit repeated not allowed" error
```

**Testable Scenarios:**
- PIN pad renders correctly
- PIN dots fill on entry
- Validation rules display (6 digits, no sequential, no repeated)
- Rules update as PIN entered
- Error state and auto-clear
- Navigation to confirm on valid PIN

---

### 4.2 confirm_pin_view.dart `[ACTIVE]`
**Path:** `lib/features/pin/views/confirm_pin_view.dart`
**Route:** `/pin/confirm`

**Feature:** Confirm PIN
```gherkin
Feature: PIN Confirmation
  As a user creating a PIN
  I want to confirm my PIN
  So that I don't accidentally set a wrong PIN

  Scenario: Matching PIN
    Given I am on the PIN confirmation screen
    When I enter the same PIN as before
    Then my PIN should be saved
    And I should proceed

  Scenario: Non-matching PIN
    Given I am on the PIN confirmation screen
    When I enter a different PIN
    Then I should see "PINs don't match" error
```

**Testable Scenarios:**
- PIN pad renders
- PIN comparison logic
- Mismatch error state
- Success navigation
- PIN saved to secure storage

---

### 4.3 enter_pin_view.dart `[ACTIVE]`
**Path:** `lib/features/pin/views/enter_pin_view.dart`
**Route:** Internal (used for PIN verification)

**Feature:** Enter PIN for Verification
```gherkin
Feature: PIN Entry
  As a user performing a secure action
  I want to enter my PIN
  So that the action is authorized
```

**Testable Scenarios:**
- PIN entry functionality
- Biometric option if enabled
- Error handling

---

### 4.4 change_pin_view.dart `[ACTIVE]`
**Path:** `lib/features/pin/views/change_pin_view.dart`
**Route:** `/settings/pin`

**Feature:** Change PIN
```gherkin
Feature: Change PIN
  As a user
  I want to change my PIN
  So that I can update my security

  Scenario: Change PIN successfully
    Given I am on the change PIN screen
    When I enter my current PIN correctly
    And I enter a new valid PIN
    And I confirm the new PIN
    Then my PIN should be updated
```

**Testable Scenarios:**
- Current PIN verification
- New PIN entry
- New PIN confirmation
- Success message

---

### 4.5 reset_pin_view.dart `[MOCK]`
**Path:** `lib/features/pin/views/reset_pin_view.dart`
**Route:** `/pin/reset`

**Feature:** Reset Forgotten PIN
```gherkin
Feature: PIN Reset
  As a user who forgot my PIN
  I want to reset it
  So that I can regain access to my wallet

  Scenario: Reset PIN with phone verification
    Given I am on the PIN reset screen
    When I verify my phone number with OTP
    Then I should be able to set a new PIN
```

**Testable Scenarios:**
- OTP verification flow
- New PIN creation
- Security warnings

---

### 4.6 pin_locked_view.dart `[ACTIVE]`
**Path:** `lib/features/pin/views/pin_locked_view.dart`
**Route:** Internal

**Feature:** Account Locked Screen
```gherkin
Feature: Account Locked
  As a user who exceeded PIN attempts
  I want to see the locked status
  So that I know what to do next

  Scenario: View locked screen
    Given I exceeded maximum PIN attempts
    When the locked screen displays
    Then I should see the lock duration
    And I should see contact support option
```

**Testable Scenarios:**
- Lock icon/animation
- Lock duration countdown
- Support contact option
- Return to login button

---

## 5. KYC (Know Your Customer)

### 5.1 kyc_status_view.dart `[PARTIAL]`
**Path:** `lib/features/kyc/views/kyc_status_view.dart`
**Route:** `/kyc`

**Feature:** KYC Status Display
```gherkin
Feature: KYC Verification Status
  As a user
  I want to see my KYC verification status
  So that I know my account capabilities

  Scenario: View pending status
    Given my KYC is not started
    When I view the KYC status screen
    Then I should see "Start Verification" option
    And I should see benefits of verification

  Scenario: View submitted status
    Given I submitted my KYC documents
    When I view the KYC status screen
    Then I should see "Under Review" status
    And I should see estimated review time

  Scenario: View verified status
    Given my KYC is verified
    When I view the KYC status screen
    Then I should see verification checkmark
    And I should see increased limits

  Scenario: View rejected status
    Given my KYC was rejected
    When I view the KYC status screen
    Then I should see rejection reason
    And I should see "Try Again" option
```

**Testable Scenarios:**
- Status icon based on KYC status
- Title and description per status
- Rejection reason display
- Info cards (security, time, documents)
- "Start Verification" button for pending
- "Try Again" button for rejected
- "Continue" button for submitted

---

### 5.2 document_type_view.dart `[ACTIVE]`
**Path:** `lib/features/kyc/views/document_type_view.dart`
**Route:** `/kyc/document-type`

**Feature:** Document Type Selection
```gherkin
Feature: KYC Document Type Selection
  As a user starting KYC
  I want to select my ID document type
  So that I can proceed with verification

  Scenario: Select passport
    Given I am on document type selection
    When I tap "Passport"
    Then I should proceed to document capture

  Scenario: Select national ID
    Given I am on document type selection
    When I tap "National ID Card"
    Then I should proceed to document capture
```

**Testable Scenarios:**
- Document type options display
- Passport option
- National ID option
- Driver's license option
- Selection state
- Continue navigation

---

### 5.3 document_capture_view.dart `[ACTIVE]`
**Path:** `lib/features/kyc/views/document_capture_view.dart`
**Route:** `/kyc/document-capture`

**Feature:** Document Camera Capture
```gherkin
Feature: Document Capture
  As a user doing KYC
  I want to capture photos of my ID
  So that my identity can be verified

  Scenario: Capture front of ID
    Given I am on document capture
    And the camera is active
    When I position my document in the frame
    And I tap capture
    Then the front image should be captured
    And I should be prompted for the back

  Scenario: Retake photo
    Given I captured a document photo
    When I tap "Retake"
    Then the camera should reactivate
    And I can capture again
```

**Testable Scenarios:**
- Camera permission request
- Camera preview display
- Document frame overlay
- Capture button
- Photo preview
- Retake option
- Continue to next step

---

### 5.4 selfie_view.dart `[ACTIVE]`
**Path:** `lib/features/kyc/views/selfie_view.dart`
**Route:** `/kyc/selfie`

**Feature:** Selfie Capture
```gherkin
Feature: Selfie Capture
  As a user doing KYC
  I want to take a selfie
  So that my face can be matched to my ID

  Scenario: Capture selfie
    Given I am on selfie capture screen
    And the front camera is active
    When I position my face in the oval frame
    And I tap capture
    Then my selfie should be captured
```

**Testable Scenarios:**
- Front camera activation
- Face oval overlay
- Lighting guidance
- Capture button
- Preview and retake
- Continue navigation

---

### 5.5 kyc_liveness_view.dart `[ACTIVE]`
**Path:** `lib/features/kyc/views/kyc_liveness_view.dart`
**Route:** Internal

**Feature:** Liveness Check
```gherkin
Feature: Liveness Verification
  As a user doing KYC
  I want to complete a liveness check
  So that the system knows I'm a real person

  Scenario: Complete liveness check
    Given I am on the liveness check screen
    When I follow the on-screen instructions (blink, turn head)
    Then the liveness check should pass
```

**Testable Scenarios:**
- Liveness instructions
- Action prompts (blink, smile, turn)
- Progress indicator
- Success/failure feedback

---

### 5.6 review_view.dart `[ACTIVE]`
**Path:** `lib/features/kyc/views/review_view.dart`
**Route:** `/kyc/review`

**Feature:** KYC Review Before Submit
```gherkin
Feature: KYC Document Review
  As a user who captured documents
  I want to review before submitting
  So that I can ensure quality

  Scenario: Review and submit
    Given I captured all required documents
    When I view the review screen
    Then I should see all captured images
    And I should be able to submit
```

**Testable Scenarios:**
- Document thumbnails display
- Edit/retake options
- Submit button
- Upload progress

---

### 5.7 submitted_view.dart `[ACTIVE]`
**Path:** `lib/features/kyc/views/submitted_view.dart`
**Route:** `/kyc/submitted`

**Feature:** KYC Submission Confirmation
```gherkin
Feature: KYC Submission Confirmation
  As a user who submitted KYC
  I want to see confirmation
  So that I know my documents were received

  Scenario: View submission confirmation
    Given I submitted my KYC documents
    When the confirmation screen loads
    Then I should see success message
    And I should see estimated review time
```

**Testable Scenarios:**
- Success icon/animation
- Confirmation message
- Timeline estimate
- Return to app button

---

### 5.8-5.11 Additional KYC Views
**Paths:**
- `kyc_personal_info_view.dart` - Personal information form
- `kyc_address_view.dart` - Address information
- `kyc_additional_docs_view.dart` - Additional documents
- `kyc_upgrade_view.dart` - KYC tier upgrade
- `kyc_video_view.dart` - Video verification

---

## 6. Transactions

### 6.1 transactions_view.dart `[MOCK]`
**Path:** `lib/features/transactions/views/transactions_view.dart`
**Route:** `/transactions`

**Feature:** Transaction History
```gherkin
Feature: Transaction History
  As a user
  I want to view my transaction history
  So that I can track my spending and income

  Scenario: View all transactions
    Given I am on the transactions screen
    Then I should see transactions grouped by date
    And I should see Today, Yesterday, and older dates

  Scenario: Filter transactions
    Given I am on the transactions screen
    When I tap the filter icon
    Then I should see filter options (type, status, date, amount)

  Scenario: Search transactions
    Given I am on the transactions screen
    When I tap search and enter "Amadou"
    Then I should see only transactions matching "Amadou"

  Scenario: View transaction detail
    Given I am viewing transaction history
    When I tap on a transaction
    Then I should see full transaction details
```

**Testable Scenarios:**
- Transaction list with date grouping
- Loading skeleton state
- Empty state with illustration
- Error state with retry
- Search field with debounce
- Filter bottom sheet
- Active filter chips
- Clear all filters
- Pull-to-refresh
- Infinite scroll pagination
- Transaction row component
- Tablet/landscape grid layout
- Export button navigation

---

### 6.2 transaction_detail_view.dart `[MOCK]`
**Path:** `lib/features/transactions/views/transaction_detail_view.dart`
**Route:** `/transactions/:id`

**Feature:** Transaction Details
```gherkin
Feature: Transaction Details
  As a user
  I want to see full details of a transaction
  So that I have a complete record

  Scenario: View deposit details
    Given I tap on a deposit transaction
    Then I should see amount, date, time
    And I should see deposit source
    And I should see transaction ID

  Scenario: Share receipt
    Given I am viewing transaction details
    When I tap "Share Receipt"
    Then I should be able to share the receipt
```

**Testable Scenarios:**
- Transaction type icon
- Amount display (colored by type)
- Status badge
- Date and time
- Transaction ID
- Recipient/sender info
- Share receipt button
- Loading state

---

### 6.3 export_transactions_view.dart `[MOCK]`
**Path:** `lib/features/transactions/views/export_transactions_view.dart`
**Route:** `/transactions/export`

**Feature:** Export Transactions
```gherkin
Feature: Export Transaction History
  As a user
  I want to export my transactions
  So that I have records for accounting

  Scenario: Export as CSV
    Given I am on the export screen
    When I select date range
    And I select CSV format
    And I tap "Export"
    Then a CSV file should be generated
```

**Testable Scenarios:**
- Date range picker
- Format selection (CSV, PDF)
- Export button
- Download/share functionality

---

## 7. Settings

### 7.1 settings_view.dart `[ACTIVE]`
**Path:** `lib/features/settings/views/settings_view.dart`
**Route:** `/settings`

**Feature:** App Settings
```gherkin
Feature: App Settings
  As a user
  I want to manage my app settings
  So that I can customize my experience

  Scenario: View settings
    Given I am on the settings screen
    Then I should see profile card
    And I should see Security section
    And I should see Preferences section
    And I should see Support section

  Scenario: Logout
    Given I am on the settings screen
    When I tap "Logout"
    And I confirm in the dialog
    Then I should be logged out
    And I should see the login screen
```

**Testable Scenarios:**
- Profile card with avatar, name, phone
- KYC status badge on profile
- Security section (Security, KYC, Limits)
- Account section (Account Type switcher)
- Preferences section (Notifications, Language, Theme, Currency)
- Support section (Help)
- Referral card
- Logout button and confirmation dialog
- Version display
- Responsive layouts (mobile, tablet, landscape)

---

### 7.2-7.16 Settings Sub-views `[PARTIAL/MOCK]`
**Paths:**
- `profile_view.dart` `/settings/profile` - View/edit profile
- `security_view.dart` `/settings/security` - Security settings (biometric, PIN)
- `notification_settings_view.dart` `/settings/notifications` - Notification preferences
- `language_view.dart` `/settings/language` - Language selection (en/fr)
- `theme_settings_view.dart` `/settings/theme` - Theme selection (light/dark/system)
- `currency_view.dart` `/settings/currency` - Reference currency settings
- `limits_view.dart` `/settings/limits` - Transaction limits display
- `kyc_view.dart` `/settings/kyc` - KYC from settings
- `help_view.dart` `/settings/help` - Help center
- `change_pin_view.dart` `/settings/pin` - Change PIN (duplicate)
- `cookie_policy_view.dart` - Cookie policy
- `performance_monitor_view.dart` - Dev performance tools

---

## 8. Notifications

### 8.1 notifications_view.dart `[ACTIVE]`
**Path:** `lib/features/notifications/views/notifications_view.dart`
**Route:** `/notifications`

**Feature:** Notifications List
```gherkin
Feature: Notifications
  As a user
  I want to view my notifications
  So that I stay informed about my account

  Scenario: View notifications
    Given I have notifications
    When I open the notifications screen
    Then I should see notification cards
    And unread notifications should be highlighted

  Scenario: Mark all as read
    Given I have unread notifications
    When I tap "Mark All Read"
    Then all notifications should be marked as read

  Scenario: Dismiss notification
    Given I am viewing notifications
    When I swipe left on a notification
    Then the notification should be dismissed

  Scenario: Tap notification
    Given I tap on a transaction notification
    Then I should be navigated to the transaction
```

**Testable Scenarios:**
- Notification list with unread count
- Notification card with icon, title, message, time
- Unread indicator dot
- Type-specific icons (transaction, security, promo, etc.)
- Swipe to dismiss
- Mark all as read button
- Empty state
- Error state with retry
- Time formatting (just now, minutes ago, hours ago, days ago)
- Navigation on tap based on action route

---

## 9. FSM State Views

### 9.1 loading_view.dart `[ACTIVE]`
**Path:** `lib/features/fsm_states/views/loading_view.dart`
**Route:** FSM state

**Feature:** Loading State
```gherkin
Feature: Loading State Screen
  As a user
  I want to see loading status
  So that I know the app is working

  Scenario: View loading screen
    Given the app is loading wallet data
    Then I should see a loading spinner
    And I should see "Loading your account..." message

  Scenario: Retry after timeout
    Given loading takes too long
    When 10 seconds pass
    Then I should see a "Retry" button
```

**Testable Scenarios:**
- Loading spinner
- Loading message
- Debug info (FSM state, wallet status, KYC status)
- Retry button after timeout
- Retry functionality

---

### 9.2-9.10 FSM State Views `[ACTIVE]`
**Paths:**
- `auth_locked_view.dart` - Account locked state
- `auth_suspended_view.dart` - Account suspended state
- `biometric_prompt_view.dart` - Biometric enrollment prompt
- `device_verification_view.dart` - Device verification required
- `kyc_expired_view.dart` - KYC expired state
- `otp_expired_view.dart` - OTP expired state
- `session_conflict_view.dart` - Multiple session conflict
- `session_locked_view.dart` - Session timeout lock
- `wallet_frozen_view.dart` - Wallet frozen by admin
- `wallet_under_review_view.dart` - Wallet under review

---

## 10. Bill Payments

### 10.1 bill_payments_view.dart `[MOCK]`
**Path:** `lib/features/bill_payments/views/bill_payments_view.dart`
**Route:** `/bill-payments`

**Feature:** Bill Payments Hub
```gherkin
Feature: Bill Payments
  As a user
  I want to pay my bills
  So that I can manage my expenses

  Scenario: View bill payment providers
    Given I am on bill payments screen
    Then I should see categories (Electricity, Water, Internet, TV)
    And I should see available providers

  Scenario: Select provider
    Given I am on bill payments screen
    When I tap on a provider
    Then I should see the payment form
```

**Testable Scenarios:**
- Category tabs/filters
- Provider cards
- Search functionality
- Provider selection navigation

---

### 10.2 bill_payment_form_view.dart `[MOCK]`
**Path:** `lib/features/bill_payments/views/bill_payment_form_view.dart`
**Route:** `/bill-payments/form/:id`

**Feature:** Bill Payment Form
```gherkin
Feature: Bill Payment Form
  As a user paying a bill
  I want to enter payment details
  So that my bill is paid

  Scenario: Pay electricity bill
    Given I selected CIE (electricity)
    When I enter my meter number
    And I enter payment amount
    And I confirm with PIN
    Then my bill should be paid
```

**Testable Scenarios:**
- Dynamic form fields based on provider
- Account/meter number input
- Amount input
- PIN confirmation
- Processing state

---

### 10.3 bill_payment_success_view.dart `[MOCK]`
**Path:** `lib/features/bill_payments/views/bill_payment_success_view.dart`
**Route:** `/bill-payments/success/:id`

**Feature:** Bill Payment Success
```gherkin
Feature: Bill Payment Confirmation
  As a user who paid a bill
  I want confirmation
  So that I know my payment succeeded
```

**Testable Scenarios:**
- Success animation
- Payment details
- Receipt number
- Share receipt button

---

### 10.4 bill_payment_history_view.dart `[MOCK]`
**Path:** `lib/features/bill_payments/views/bill_payment_history_view.dart`
**Route:** `/bill-payments/history`

**Feature:** Bill Payment History
```gherkin
Feature: Bill Payment History
  As a user
  I want to see my bill payment history
  So that I can track payments
```

**Testable Scenarios:**
- Payment list
- Filter by category
- Date range selection

---

## 11. Savings Pots

### 11.1 pots_list_view.dart `[MOCK]`
**Path:** `lib/features/savings_pots/views/pots_list_view.dart`
**Route:** `/savings-pots`

**Feature:** Savings Pots List
```gherkin
Feature: Savings Pots
  As a user
  I want to create savings goals
  So that I can save for specific purposes

  Scenario: View savings pots
    Given I am on savings pots screen
    Then I should see my existing pots
    And I should see total savings amount

  Scenario: Create new pot
    Given I am on savings pots screen
    When I tap "Create Pot"
    Then I should see the pot creation form
```

**Testable Scenarios:**
- Pot cards with progress
- Total savings display
- Create pot FAB
- Empty state

---

### 11.2-11.4 Savings Pot Views `[MOCK]`
**Paths:**
- `create_pot_view.dart` `/savings-pots/create` - Create new pot
- `pot_detail_view.dart` `/savings-pots/detail/:id` - Pot details
- `edit_pot_view.dart` `/savings-pots/edit/:id` - Edit pot

---

## 12. Recurring Transfers

### 12.1 recurring_transfers_list_view.dart `[MOCK]`
**Path:** `lib/features/recurring_transfers/views/recurring_transfers_list_view.dart`
**Route:** `/recurring-transfers`

**Feature:** Recurring Transfers
```gherkin
Feature: Recurring Transfers
  As a user
  I want to set up automatic transfers
  So that I don't forget regular payments

  Scenario: View recurring transfers
    Given I am on recurring transfers screen
    Then I should see my scheduled transfers
    And I should see frequency and next execution date
```

**Testable Scenarios:**
- Transfer cards
- Frequency display
- Next execution date
- Create new button
- Empty state

---

### 12.2-12.3 Recurring Transfer Views `[MOCK]`
**Paths:**
- `create_recurring_transfer_view.dart` - Create scheduled transfer
- `recurring_transfer_detail_view.dart` - Transfer details

---

## 13. Merchant Payments

### 13.1 scan_qr_view.dart `[MOCK]`
**Path:** `lib/features/merchant_pay/views/scan_qr_view.dart`
**Route:** `/scan-to-pay`

**Feature:** Merchant QR Scanner
```gherkin
Feature: Scan to Pay
  As a customer
  I want to scan a merchant's QR code
  So that I can pay them quickly

  Scenario: Scan merchant QR
    Given I am on the scanner screen
    When I scan a merchant's QR code
    Then I should see payment confirmation screen
    With the merchant name and amount
```

**Testable Scenarios:**
- Camera activation
- QR detection
- Payment info extraction
- Navigation to confirmation

---

### 13.2-13.7 Merchant Payment Views `[MOCK]`
**Paths:**
- `payment_confirm_view.dart` - Confirm payment
- `payment_receipt_view.dart` `/payment-receipt` - Payment receipt
- `merchant_dashboard_view.dart` `/merchant-dashboard` - Merchant view
- `merchant_qr_view.dart` `/merchant-qr` - Merchant's QR display
- `create_payment_request_view.dart` `/create-payment-request` - Create request
- `merchant_transactions_view.dart` `/merchant-transactions` - Merchant history

---

## 14. Payment Links

### 14.1 payment_links_list_view.dart `[MOCK]`
**Path:** `lib/features/payment_links/views/payment_links_list_view.dart`
**Route:** `/payment-links`

**Feature:** Payment Links
```gherkin
Feature: Payment Links
  As a user
  I want to create shareable payment links
  So that people can pay me easily

  Scenario: View payment links
    Given I am on payment links screen
    Then I should see my created links
    And I should see link status (active, expired, completed)
```

**Testable Scenarios:**
- Link cards
- Status badges
- Create link button
- Copy/share functionality

---

### 14.2-14.5 Payment Link Views `[MOCK]`
**Paths:**
- `create_link_view.dart` `/payment-links/create` - Create link
- `link_created_view.dart` `/payment-links/created/:id` - Link created success
- `link_detail_view.dart` `/payment-links/detail/:id` - Link details
- `pay_link_view.dart` - Pay a received link

---

## 15. Alerts & Insights

### 15.1 alerts_list_view.dart `[MOCK]`
**Path:** `lib/features/alerts/views/alerts_list_view.dart`
**Route:** `/alerts`

**Feature:** Alerts
```gherkin
Feature: Alerts
  As a user
  I want to receive and manage alerts
  So that I stay informed about important events
```

### 15.2 insights_view.dart `[MOCK]`
**Path:** `lib/features/insights/views/insights_view.dart`
**Route:** `/insights`

**Feature:** Spending Insights
```gherkin
Feature: Spending Insights
  As a user
  I want to see spending analytics
  So that I can understand my financial habits

  Scenario: View spending summary
    Given I am on insights screen
    Then I should see total spending
    And I should see spending by category chart
    And I should see spending trends
```

**Testable Scenarios:**
- Spending summary card
- Pie chart by category
- Line chart for trends
- Top recipients section
- Empty state

---

## 16. Services Hub

### 16.1 services_view.dart `[MOCK]`
**Path:** `lib/features/services/views/services_view.dart`
**Route:** `/services`

**Feature:** Services Hub
```gherkin
Feature: Services Hub
  As a user
  I want to see all available services
  So that I can access features easily

  Scenario: View available services
    Given I am on the services screen
    Then I should see Core Services (Send, Receive, Request, Scan)
    And I should see Financial Services (if enabled)
    And I should see Bills & Payments (if enabled)
    And I should see Tools & Analytics (if enabled)
```

**Testable Scenarios:**
- Section headers
- Service cards grid
- Feature flag filtering
- Navigation to service routes

---

## 17. Referrals

### 17.1 referrals_view.dart `[MOCK]`
**Path:** `lib/features/referrals/views/referrals_view.dart`
**Route:** `/referrals`

**Feature:** Referral Program
```gherkin
Feature: Referral Program
  As a user
  I want to invite friends and earn rewards
  So that I benefit from spreading the app

  Scenario: View referral code
    Given I am on referrals screen
    Then I should see my unique referral code
    And I should see reward amount

  Scenario: Share referral
    Given I am on referrals screen
    When I tap "Share Link"
    Then the share sheet should open
    With my referral link

  Scenario: Copy referral code
    Given I am on referrals screen
    When I tap the copy button
    Then my code should be copied to clipboard
```

**Testable Scenarios:**
- Reward amount display
- Referral code generation
- Copy to clipboard
- Share functionality
- Stats cards (friends invited, total earned)
- How it works steps
- Referral history (empty state)

---

## 18. Beneficiaries

### 18.1 beneficiary_detail_view.dart `[MOCK]`
**Path:** `lib/features/beneficiaries/views/beneficiary_detail_view.dart`
**Route:** `/beneficiaries/detail/:id`

**Feature:** Beneficiary Details
```gherkin
Feature: Beneficiary Management
  As a user
  I want to manage saved recipients
  So that I can quickly send to frequent contacts
```

---

## 19. Cards

### 19.1-19.5 Card Views `[MOCK/TODO]`
**Paths:**
- `cards_list_view.dart` `/cards` - Virtual cards list
- `card_detail_view.dart` - Card details
- `card_settings_view.dart` - Card settings
- `card_transactions_view.dart` - Card transactions
- `request_card_view.dart` - Request new card

---

## 20. Bank Linking

### 20.1-20.5 Bank Linking Views `[MOCK]`
**Paths:**
- `link_bank_view.dart` - Start bank linking
- `bank_selection_view.dart` - Select bank
- `bank_verification_view.dart` - Verify bank account
- `bank_transfer_view.dart` - Bank transfer
- `linked_accounts_view.dart` - View linked accounts

---

## 21. Business Features

### 21.1-21.2 Business Views `[MOCK]`
**Paths:**
- `business_setup_view.dart` - Business account setup
- `business_profile_view.dart` - Business profile

---

## 22. Sub-Business

### 22.1-22.4 Sub-Business Views `[MOCK]`
**Paths:**
- `sub_businesses_view.dart` - Sub-business list
- `create_sub_business_view.dart` - Create sub-business
- `sub_business_detail_view.dart` - Sub-business details
- `sub_business_staff_view.dart` - Staff management

---

## 23. Bulk Payments

### 23.1-23.4 Bulk Payment Views `[MOCK]`
**Paths:**
- `bulk_payments_view.dart` - Bulk payments hub
- `bulk_upload_view.dart` - Upload CSV/Excel
- `bulk_preview_view.dart` - Preview payments
- `bulk_status_view.dart` - Bulk payment status

---

## 24. Expenses

### 24.1-24.5 Expense Views `[MOCK]`
**Paths:**
- `expenses_view.dart` - Expenses list
- `add_expense_view.dart` - Add expense
- `expense_detail_view.dart` - Expense details
- `capture_receipt_view.dart` - Receipt capture
- `expense_reports_view.dart` - Expense reports

---

## 25. Biometric

### 25.1-25.2 Biometric Views `[PARTIAL]`
**Paths:**
- `biometric_enrollment_view.dart` - Enroll biometrics
- `biometric_settings_view.dart` - Biometric settings

---

## 26. Limits

### 26.1 limits_view.dart `[MOCK]`
**Path:** `lib/features/limits/views/limits_view.dart`
**Route:** Internal (duplicate of settings limits)

**Feature:** Transaction Limits
```gherkin
Feature: Transaction Limits
  As a user
  I want to see my transaction limits
  So that I know my capabilities
```

---

## Summary Statistics

| Status | Count |
|--------|-------|
| ACTIVE | ~25 |
| MOCK | ~130 |
| PARTIAL | ~10 |
| DEAD_CODE | ~5 |
| TODO/AWAITING | ~10 |

## Priority for Testing

### Phase 1 - Critical Path (MVP)
1. Auth flow (login, OTP, PIN)
2. Home view with balance
3. Send money flow
4. Receive/QR display
5. Transactions list
6. Basic settings

### Phase 2 - Enhanced Features
1. KYC full flow
2. Deposit/Withdraw flows
3. Notifications
4. Referrals
5. Bill payments

### Phase 3 - Advanced Features
1. Savings pots
2. Recurring transfers
3. Payment links
4. Insights/Analytics
5. Business features

---

*Last Updated: 2025-01-29*
*Total View Files Analyzed: 180*
