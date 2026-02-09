# USDC Wallet - Master BDD Specifications

> Generated: 2025-02-04
> Total Screens: 170+
> Coverage: All screens flagged with status

---

## Table of Contents

1. [Screen Status Summary](#screen-status-summary)
2. [Core Screens (MVP)](#core-screens-mvp)
3. [Authentication Screens](#authentication-screens)
4. [Onboarding Screens](#onboarding-screens)
5. [Wallet/Home Screens](#wallethome-screens)
6. [Send Flow Screens](#send-flow-screens)
7. [Send External Flow Screens](#send-external-flow-screens)
8. [Deposit Flow Screens](#deposit-flow-screens)
9. [Transaction Screens](#transaction-screens)
10. [KYC Screens](#kyc-screens)
11. [Cards Screens](#cards-screens)
12. [Settings Screens](#settings-screens)
13. [Notification Screens](#notification-screens)
14. [FSM State Screens](#fsm-state-screens)
15. [Feature-Flagged Screens](#feature-flagged-screens)
16. [Business/Merchant Screens](#businessmerchant-screens)
17. [Debug/Demo Screens](#debugdemo-screens)
18. [Backend Requirements](#backend-requirements)

---

## Screen Status Summary

| Status | Count | Description |
|--------|-------|-------------|
| ACTIVE | 65 | In production, used in MVP |
| FEATURE_FLAGGED | 45 | Behind feature flags |
| AWAITING_IMPLEMENTATION | 20 | Placeholder/partial implementation |
| DEMO_ONLY | 8 | Development/demo purposes |
| DEAD_CODE | 12 | Not referenced in router |
| DISABLED | 5 | Temporarily disabled |

---

## Core Screens (MVP)

### 1. Splash Screen
**File:** `lib/features/splash/views/splash_view.dart`
**Route:** `/`
**STATUS: ACTIVE**

```gherkin
Feature: Application Splash Screen

  Background:
    Given the application is launched

  Scenario: Display splash screen animation
    When the splash screen loads
    Then I should see the JoonaPay logo with fade animation
    And I should see "JoonaPay" title
    And I should see "Your Digital Wallet" tagline
    And I should see a loading indicator

  Scenario: Navigate to onboarding for new user
    Given onboarding has not been completed
    When the splash animation completes after 2 seconds
    Then I should be navigated to "/onboarding"

  Scenario: Navigate to login for returning user without auth
    Given onboarding has been completed
    And user is not authenticated
    When the splash animation completes after 2 seconds
    Then I should be navigated to "/login"

  Scenario: Navigate to home for authenticated user
    Given onboarding has been completed
    And user is authenticated
    When the splash animation completes after 2 seconds
    Then I should be navigated to "/home"
```

**Test Requirements:**
- Animation controller with 1500ms duration
- SharedPreferences check for `onboarding_completed`
- Auth state check via `userStateMachineProvider`
- Navigation via GoRouter

---

## Authentication Screens

### 2. Login View
**File:** `lib/features/auth/views/login_view.dart`
**Route:** `/login`
**STATUS: ACTIVE**

```gherkin
Feature: User Login

  Background:
    Given I am on the login screen

  Scenario: Display login form
    Then I should see the JoonaPay logo
    And I should see "Welcome Back" or "Create Account" text
    And I should see a country selector defaulting to Ivory Coast
    And I should see a phone number input with prefix "+225"
    And I should see a "Continue" button
    And I should see terms and privacy links

  Scenario: Select different country
    When I tap the country selector
    Then I should see a bottom sheet with supported countries
    And each country should show flag, name, and dial code
    When I select "Ghana"
    Then the dial prefix should update to "+233"
    And the phone format should update accordingly

  Scenario: Enter valid phone number
    Given the phone length for Ivory Coast is 10 digits
    When I enter "0123456789"
    Then I should see a green checkmark indicator
    And the "Continue" button should be enabled

  Scenario: Enter invalid phone number
    When I enter "012"
    Then I should see a red X indicator
    And I should see "Enter 10 digits" helper text
    And the "Continue" button should be disabled

  Scenario: Submit login request
    Given I have entered a valid phone number "0123456789"
    When I tap "Continue"
    Then I should see a loading indicator on the button
    And the auth provider should send OTP to "+2250123456789"
    And I should be navigated to "/otp" on success

  Scenario: Handle login error
    Given I have entered a valid phone number
    When I tap "Continue"
    And the server returns an error
    Then I should see an error snackbar with the error message
    And the button should no longer be loading

  Scenario: Toggle between login and register mode
    Given I am in login mode showing "Don't have an account?"
    When I tap "Sign up"
    Then the text should change to "Already have an account?"
    And the submit action should call register instead of login

  Scenario: View legal documents
    When I tap "Terms of Service"
    Then I should be navigated to the legal document view for terms
    When I tap "Privacy Policy"
    Then I should be navigated to the legal document view for privacy
```

**Backend API:**
- `POST /auth/login` - Send OTP for existing user
- `POST /auth/register` - Register new user and send OTP

---

### 3. OTP View
**File:** `lib/features/auth/views/otp_view.dart`
**Route:** `/otp`
**STATUS: ACTIVE**

```gherkin
Feature: OTP Verification

  Background:
    Given I am on the OTP verification screen
    And I have received an OTP to my phone

  Scenario: Display OTP screen
    Then I should see "Verify your number" title
    And I should see the phone number I'm verifying
    And I should see 6 OTP input fields
    And I should see a countdown timer (initially 60 seconds)
    And I should see a disabled "Resend" button

  Scenario: Enter OTP digits
    When I enter "123456"
    Then all 6 input fields should be filled
    And the verify request should be triggered automatically

  Scenario: Successful OTP verification
    Given I have entered the correct OTP "123456"
    Then I should see a loading indicator
    When the server verifies the OTP
    Then I should be navigated to "/home" or "/kyc" based on user status

  Scenario: Failed OTP verification
    Given I have entered incorrect OTP "000000"
    Then I should see an error message "Invalid OTP"
    And the OTP fields should be cleared
    And I should be able to retry

  Scenario: Resend OTP
    Given the countdown timer has reached 0
    Then the "Resend" button should be enabled
    When I tap "Resend"
    Then a new OTP should be sent to my phone
    And the countdown should reset to 60 seconds
```

**Backend API:**
- `POST /auth/verify-otp` - Verify OTP code
- `POST /auth/resend-otp` - Resend OTP

---

### 4. Login OTP View
**File:** `lib/features/auth/views/login_otp_view.dart`
**Route:** `/login/otp`
**STATUS: ACTIVE**

```gherkin
Feature: Login OTP Verification

  Background:
    Given I am on the login OTP screen
    And I have initiated login

  Scenario: Enter OTP for returning user
    When I enter the OTP received via SMS
    Then I should be authenticated
    And I should be navigated to "/home"

  Scenario: OTP expiration
    Given 5 minutes have passed since OTP was sent
    When I enter the OTP
    Then I should see "OTP expired" error
    And I should be able to request a new OTP
```

---

### 5. Login PIN View
**File:** `lib/features/auth/views/login_pin_view.dart`
**Route:** `/login/pin`
**STATUS: ACTIVE**

```gherkin
Feature: PIN Login

  Background:
    Given I have a PIN set up
    And I am on the PIN login screen

  Scenario: Display PIN entry screen
    Then I should see "Enter your PIN" title
    And I should see 4 PIN input dots
    And I should see a numeric keypad

  Scenario: Enter correct PIN
    When I enter my 4-digit PIN correctly
    Then I should be authenticated
    And I should be navigated to "/home"

  Scenario: Enter incorrect PIN
    When I enter an incorrect PIN
    Then I should see "Incorrect PIN" error
    And the PIN dots should reset
    And I should see attempts remaining

  Scenario: Too many failed attempts
    Given I have entered incorrect PIN 5 times
    Then I should see "Too many attempts" message
    And I should be locked out for 30 minutes
    And I should be navigated to "/auth-locked"
```

---

## Onboarding Screens

### 6. Onboarding View
**File:** `lib/features/onboarding/views/onboarding_view.dart`
**Route:** `/onboarding`
**STATUS: ACTIVE**

```gherkin
Feature: App Onboarding

  Background:
    Given I am a new user
    And I am on the onboarding screen

  Scenario: Display onboarding pages
    Then I should see page 1 with wallet icon
    And I should see "Your Money, Your Way" title
    And I should see page indicators showing 4 pages
    And I should see "Next" button
    And I should see "Skip" button

  Scenario: Navigate through pages
    When I swipe left or tap "Next"
    Then I should see page 2 with send icon
    And the page indicator should update
    When I reach page 4
    Then the button text should change to "Get Started"

  Scenario: Skip onboarding
    When I tap "Skip"
    Then onboarding should be marked as completed
    And I should be navigated to "/login"

  Scenario: Complete onboarding
    Given I am on page 4
    When I tap "Get Started"
    Then onboarding should be marked as completed
    And I should be navigated to "/login"
```

---

## Wallet/Home Screens

### 7. Wallet Home Screen
**File:** `lib/features/wallet/views/wallet_home_screen.dart`
**Route:** `/home`
**STATUS: ACTIVE**

```gherkin
Feature: Wallet Home Screen

  Background:
    Given I am authenticated
    And I am on the home screen

  Scenario: Display home screen with balance
    Then I should see a time-based greeting (Good morning/afternoon/evening/night)
    And I should see my profile avatar
    And I should see notification icon
    And I should see settings icon
    And I should see my USDC balance card
    And I should see 4 quick action buttons (Send, Receive, Deposit, History)
    And I should see recent transactions section

  Scenario: Balance animation on load
    When the wallet loads successfully
    Then I should see balance count-up animation from 0 to actual balance
    And the balance should display in USD format

  Scenario: Toggle balance visibility
    Given my balance is visible
    When I tap the visibility toggle icon
    Then my balance should show as "******"
    And the icon should change to show balance
    When I tap the visibility toggle again
    Then my balance should be visible again

  Scenario: Display reference currency
    Given I have reference currency enabled (e.g., XOF)
    When the balance is displayed
    Then I should see "≈ {amount} XOF" below the USD amount

  Scenario: Pending balance indicator
    Given I have pending deposits of $50
    Then I should see "+$50.00 pending" indicator

  Scenario: Quick action navigation
    When I tap "Send"
    Then I should be navigated to "/send"
    When I tap "Receive"
    Then I should be navigated to "/receive"
    When I tap "Deposit"
    Then I should be navigated to "/deposit"
    When I tap "History"
    Then I should be navigated to "/transactions"

  Scenario: KYC banner for unverified user
    Given my KYC status is not verified
    Then I should see KYC verification banner
    When I tap the banner
    Then I should be navigated to "/kyc"

  Scenario: Limits warning banner
    Given I am approaching my daily transaction limit
    Then I should see a limits warning banner
    And it should show remaining limit amount

  Scenario: Recent transactions display
    Given I have transactions
    Then I should see up to 5 recent transactions
    And each transaction should show type, amount, date
    When I tap a transaction
    Then I should be navigated to transaction detail

  Scenario: Empty transactions state
    Given I have no transactions
    Then I should see "No transactions yet" message
    And I should see "Make your first deposit" prompt

  Scenario: Pull to refresh
    When I pull down on the screen
    Then wallet balance should refresh
    And transactions should refresh

  Scenario: No wallet state
    Given I don't have a wallet yet
    Then I should see "Create Wallet" card
    When I tap "Activate Wallet"
    Then I should see loading dialog
    And wallet should be created via API
    And balance should update on success

  Scenario: Error state
    Given wallet loading fails
    Then I should see error card with retry button
    When I tap "Retry"
    Then wallet should attempt to reload

  Scenario: Responsive layout - tablet
    Given I am on a tablet device
    Then I should see two-column layout
    With balance card on left, quick actions on right

  Scenario: Responsive layout - landscape
    Given I am in landscape orientation
    Then I should see horizontal split layout
    With balance and actions on left, transactions on right
```

**Backend API:**
- `GET /wallet` - Get wallet details and balance
- `POST /wallet/create` - Create new wallet
- `GET /transactions?limit=5` - Get recent transactions

---

## Send Flow Screens

### 8. Recipient Screen
**File:** `lib/features/send/views/recipient_screen.dart`
**Route:** `/send`
**STATUS: ACTIVE**

```gherkin
Feature: Select Send Recipient

  Background:
    Given I am authenticated with a wallet
    And I am on the recipient selection screen

  Scenario: Display recipient screen
    Then I should see "Select Recipient" title
    And I should see phone number input with "+225" prefix
    And I should see "From Contacts" button
    And I should see "From Beneficiaries" button
    And I should see recent recipients list
    And I should see "Continue" button

  Scenario: Enter phone number manually
    When I enter "0123456789"
    Then the input should be valid
    And "Continue" button should be enabled

  Scenario: Invalid phone number
    When I enter "123"
    Then I should see "Enter 10 digits" error
    And "Continue" button should be disabled

  Scenario: Select from contacts
    Given I grant contacts permission
    When I tap "From Contacts"
    Then I should see contacts picker bottom sheet
    When I select a contact with phone number
    Then the phone number should populate the input

  Scenario: Select from beneficiaries
    When I tap "From Beneficiaries"
    Then I should see beneficiaries picker bottom sheet
    When I select a beneficiary
    Then the phone number should populate the input

  Scenario: Select recent recipient
    When I tap on a recent recipient card
    Then the phone number should populate the input

  Scenario: Continue to amount screen
    Given I have entered a valid phone number
    When I tap "Continue"
    Then I should be navigated to "/send/amount"
    And the recipient should be set in send provider state
```

**Backend API:**
- `GET /beneficiaries` - List saved beneficiaries
- `GET /transfers/recent` - Recent transfer recipients

---

### 9. Amount Screen
**File:** `lib/features/send/views/amount_screen.dart`
**Route:** `/send/amount`
**STATUS: ACTIVE**

```gherkin
Feature: Enter Send Amount

  Background:
    Given I have selected a recipient
    And I am on the amount screen

  Scenario: Display amount screen
    Then I should see "Enter Amount" title
    And I should see recipient info card
    And I should see available balance
    And I should see amount input with "$" prefix
    And I should see optional note input
    And I should see "Continue" button

  Scenario: No recipient redirects back
    Given no recipient is selected
    Then I should be redirected to "/send"

  Scenario: Enter valid amount
    Given my balance is $100
    When I enter "50"
    Then the input should be valid
    And fee preview should appear
    And total amount should be calculated

  Scenario: Amount exceeds balance
    Given my balance is $100
    When I enter "150"
    Then I should see "Insufficient balance" error
    And "Continue" button should be disabled

  Scenario: Amount exceeds daily limit
    Given my daily limit is $500
    And I have used $450 today
    When I enter "100"
    Then I should see "Daily limit exceeded" error

  Scenario: Set maximum amount
    Given my balance is $100
    When I tap "Max"
    Then the amount should be set to $100

  Scenario: Add optional note
    When I enter a note "Birthday gift"
    Then the note should be saved to send state

  Scenario: Continue to confirmation
    Given I have entered valid amount $50
    When I tap "Continue"
    Then I should be navigated to "/send/confirm"
```

**Backend API:**
- `GET /wallet` - Get available balance
- `GET /limits` - Get transaction limits

---

### 10. Confirm Screen
**File:** `lib/features/send/views/confirm_screen.dart`
**Route:** `/send/confirm`
**STATUS: ACTIVE**

```gherkin
Feature: Confirm Send Transfer

  Background:
    Given I have entered recipient and amount
    And I am on the confirmation screen

  Scenario: Display confirmation details
    Then I should see "Confirm Transfer" title
    And I should see recipient name/phone
    And I should see amount in USDC
    And I should see transaction fee
    And I should see total amount
    And I should see "Confirm & Send" button

  Scenario: Confirm and proceed to PIN
    When I tap "Confirm & Send"
    Then I should be navigated to "/send/pin"
```

---

### 11. PIN Verification Screen
**File:** `lib/features/send/views/pin_verification_screen.dart`
**Route:** `/send/pin`
**STATUS: ACTIVE**

```gherkin
Feature: PIN Verification for Transfer

  Background:
    Given I have confirmed a transfer
    And I am on the PIN verification screen

  Scenario: Display PIN entry
    Then I should see "Enter PIN" title
    And I should see transfer summary
    And I should see 4-digit PIN input

  Scenario: Enter correct PIN and process transfer
    When I enter correct PIN
    Then transfer should be submitted to backend
    And I should see processing indicator
    And on success, I should be navigated to "/send/result"

  Scenario: Enter incorrect PIN
    When I enter incorrect PIN
    Then I should see "Incorrect PIN" error
    And I can retry
```

**Backend API:**
- `POST /transfers/internal` - Execute internal transfer

---

### 12. Result Screen
**File:** `lib/features/send/views/result_screen.dart`
**Route:** `/send/result`
**STATUS: ACTIVE**

```gherkin
Feature: Transfer Result

  Background:
    Given a transfer has been processed
    And I am on the result screen

  Scenario: Display success result
    Given the transfer was successful
    Then I should see success checkmark animation
    And I should see "Transfer Successful" title
    And I should see amount sent
    And I should see recipient name
    And I should see transaction ID
    And I should see "Done" and "Share Receipt" buttons

  Scenario: Display failure result
    Given the transfer failed
    Then I should see error icon
    And I should see "Transfer Failed" title
    And I should see error reason
    And I should see "Try Again" button

  Scenario: Navigate home
    When I tap "Done"
    Then I should be navigated to "/home"

  Scenario: Share receipt
    When I tap "Share Receipt"
    Then native share sheet should open
    With transfer receipt details
```

---

## Send External Flow Screens

### 13. Address Input Screen
**File:** `lib/features/send_external/views/address_input_screen.dart`
**Route:** `/send-external`
**STATUS: FEATURE_FLAGGED**
**Feature Flag:** `external_transfers`

```gherkin
Feature: External Wallet Address Input

  Background:
    Given external transfers feature is enabled
    And I am on the address input screen

  Scenario: Display address input
    Then I should see "Send External" title
    And I should see wallet address input
    And I should see "Scan QR" button
    And I should see network selector (Stellar, etc.)

  Scenario: Enter valid address
    When I enter a valid Stellar address
    Then address should be validated
    And "Continue" button should be enabled

  Scenario: Scan QR code
    When I tap "Scan QR"
    Then I should be navigated to "/qr/scan-address"
    And scanned address should populate input
```

---

### 14-17. External Amount, Confirm, Result Screens
**Routes:** `/send-external/amount`, `/send-external/confirm`, `/send-external/result`
**STATUS: FEATURE_FLAGGED**

Similar to internal send flow but for external blockchain transfers.

---

## Deposit Flow Screens

### 18. Deposit Amount Screen
**File:** `lib/features/deposit/views/deposit_amount_screen.dart`
**Route:** `/deposit/amount`
**STATUS: ACTIVE**

```gherkin
Feature: Deposit Amount Entry

  Background:
    Given I am authenticated
    And I am on the deposit amount screen

  Scenario: Display deposit screen
    Then I should see "Deposit" title
    And I should see exchange rate card (1 USD = X XOF)
    And I should see currency toggle (XOF/USD)
    And I should see amount input
    And I should see quick amount buttons
    And I should see min/max limits info

  Scenario: View exchange rate
    Then I should see current rate "1 USD = {rate} XOF"
    And I should see "Updated X minutes ago"
    When I tap refresh icon
    Then exchange rate should reload

  Scenario: Toggle currency
    Given I am entering in XOF
    When I tap "USD" tab
    Then amount input should switch to USD
    And conversion preview should update

  Scenario: Enter amount in XOF
    When I enter "10000" in XOF
    Then I should see "You will receive: $X.XX"
    And amount should be validated against limits

  Scenario: Quick amount buttons
    When I tap "10K" button
    Then amount should be set to 10000 XOF
    And conversion should update

  Scenario: Validate minimum
    When I enter "100" (below 500 XOF minimum)
    Then I should see "Minimum 500 XOF" error

  Scenario: Validate maximum
    When I enter "10000000" (above 5M XOF maximum)
    Then I should see "Maximum 5,000,000 XOF" error

  Scenario: Continue to provider selection
    Given I have entered valid amount
    When I tap "Continue"
    Then I should be navigated to "/deposit/provider"
```

**Backend API:**
- `GET /exchange-rates?from=XOF&to=USD` - Get current exchange rate

---

### 19. Provider Selection Screen
**File:** `lib/features/deposit/views/provider_selection_screen.dart`
**Route:** `/deposit/provider`
**STATUS: ACTIVE**

```gherkin
Feature: Payment Provider Selection

  Background:
    Given I have entered deposit amount
    And I am on the provider selection screen

  Scenario: Display available providers
    Then I should see "Select Payment Method" title
    And I should see list of mobile money providers
    Each provider should show:
      - Provider logo
      - Provider name
      - Fee information
      - Processing time

  Scenario: Select provider
    When I tap on "Orange Money"
    Then provider should be highlighted
    And "Continue" button should be enabled

  Scenario: Continue to instructions
    Given I have selected a provider
    When I tap "Continue"
    Then I should be navigated to "/deposit/instructions"
```

**Backend API:**
- `GET /deposit/providers` - List available payment providers

---

### 20. Payment Instructions Screen
**File:** `lib/features/deposit/views/payment_instructions_screen.dart`
**Route:** `/deposit/instructions`
**STATUS: ACTIVE**

```gherkin
Feature: Payment Instructions

  Background:
    Given I have selected a provider
    And I am on the payment instructions screen

  Scenario: Display payment instructions
    Then I should see provider-specific instructions
    And I should see payment reference/code
    And I should see amount to pay in XOF
    And I should see "I've Made Payment" button
    And I should see countdown timer if applicable

  Scenario: Copy payment reference
    When I tap copy icon next to reference
    Then reference should be copied to clipboard
    And I should see "Copied" confirmation

  Scenario: Confirm payment
    When I tap "I've Made Payment"
    Then I should be navigated to "/deposit/status"
```

**Backend API:**
- `POST /deposit/initiate` - Create deposit request and get payment details

---

### 21. Deposit Status Screen
**File:** `lib/features/deposit/views/deposit_status_screen.dart`
**Route:** `/deposit/status`
**STATUS: ACTIVE**

```gherkin
Feature: Deposit Status Tracking

  Background:
    Given I have made a deposit payment
    And I am on the status screen

  Scenario: Display pending status
    Then I should see "Processing" status
    And I should see animated loading indicator
    And I should see "This may take a few minutes"
    And status should poll every 10 seconds

  Scenario: Status updates to success
    When backend confirms deposit
    Then I should see success animation
    And I should see "Deposit Successful"
    And I should see credited amount
    And I should see "Done" button

  Scenario: Status updates to failed
    When backend reports failure
    Then I should see error icon
    And I should see "Deposit Failed"
    And I should see failure reason
    And I should see "Try Again" and "Contact Support" buttons

  Scenario: Navigate home on success
    When I tap "Done"
    Then I should be navigated to "/home"
```

**Backend API:**
- `GET /deposit/{id}/status` - Poll deposit status

---

## Transaction Screens

### 22. Transactions View
**File:** `lib/features/transactions/views/transactions_view.dart`
**Route:** `/transactions`
**STATUS: ACTIVE**

```gherkin
Feature: Transaction History

  Background:
    Given I am authenticated
    And I am on the transactions screen

  Scenario: Display transactions list
    Then I should see "Transactions" title
    And I should see search icon
    And I should see filter icon
    And I should see export icon
    And I should see transactions grouped by date

  Scenario: Search transactions
    When I tap search icon
    Then search input should appear
    When I type "deposit"
    Then transactions should filter by search term

  Scenario: Filter transactions
    When I tap filter icon
    Then filter bottom sheet should appear
    With options for:
      - Transaction type
      - Status
      - Date range
      - Amount range

  Scenario: Apply filter
    Given I have selected "Deposits" filter
    When I tap "Apply"
    Then only deposit transactions should display
    And active filter count badge should show

  Scenario: Clear filters
    Given filters are active
    When I tap "Clear All"
    Then all transactions should display
    And filter badge should disappear

  Scenario: Transaction grouping
    Then transactions should be grouped by:
      - "Today" for current date
      - "Yesterday" for previous date
      - Day name for within 7 days
      - "MMM d, yyyy" for older

  Scenario: View transaction detail
    When I tap on a transaction
    Then I should be navigated to "/transactions/{id}"

  Scenario: Pagination
    When I scroll to bottom of list
    Then more transactions should load
    And loading indicator should show

  Scenario: Pull to refresh
    When I pull down on the list
    Then transactions should refresh

  Scenario: Empty state with no filters
    Given I have no transactions
    Then I should see empty state illustration
    And I should see "No transactions yet"
    And I should see "Make your first deposit" button

  Scenario: Empty state with filters
    Given filters return no results
    Then I should see "No results found"
    And I should see "Clear filters" button

  Scenario: Export transactions
    When I tap export icon
    Then I should be navigated to "/transactions/export"

  Scenario: Error state - connection
    Given there is no network connection
    Then I should see connection error illustration
    And I should see "Unable to load transactions"
    And I should see "Retry" button

  Scenario: Responsive - tablet landscape
    Given I am on a tablet in landscape
    Then transactions should display in grid layout
```

**Backend API:**
- `GET /transactions` - List transactions with pagination
- `GET /transactions?type=deposit&status=completed` - Filtered list

---

### 23. Transaction Detail View
**File:** `lib/features/transactions/views/transaction_detail_view.dart`
**Route:** `/transactions/:id`
**STATUS: ACTIVE**

```gherkin
Feature: Transaction Detail

  Background:
    Given I am viewing a transaction

  Scenario: Display transaction detail
    Then I should see transaction type icon
    And I should see amount with +/- indicator
    And I should see status badge
    And I should see date and time
    And I should see transaction ID
    And I should see "From" and "To" information
    And I should see "Share Receipt" button

  Scenario: Copy transaction ID
    When I tap copy icon next to transaction ID
    Then ID should be copied to clipboard

  Scenario: Share receipt
    When I tap "Share Receipt"
    Then receipt generation should start
    And share sheet should open with receipt
```

---

## KYC Screens

### 24. KYC Status View
**File:** `lib/features/kyc/views/kyc_status_view.dart`
**Route:** `/kyc`
**STATUS: ACTIVE**

```gherkin
Feature: KYC Status

  Background:
    Given I am authenticated
    And I am on the KYC status screen

  Scenario: Display pending status
    Given my KYC status is "pending"
    Then I should see verification icon
    And I should see "Identity Verification Required" title
    And I should see info cards about process
    And I should see "Start Verification" button

  Scenario: Display submitted status
    Given my KYC status is "submitted"
    Then I should see hourglass icon
    And I should see "Under Review" title
    And I should see "Continue" button to go home

  Scenario: Display verified status
    Given my KYC status is "verified"
    Then I should see success checkmark
    And I should see "Identity Verified" title

  Scenario: Display rejected status
    Given my KYC status is "rejected"
    And rejection reason is "Document unclear"
    Then I should see error icon
    And I should see "Verification Failed" title
    And I should see rejection reason card
    And I should see "Try Again" button

  Scenario: Start verification
    When I tap "Start Verification"
    Then I should be navigated to "/kyc/document-type"
```

**Backend API:**
- `GET /kyc/status` - Get current KYC status

---

### 25-33. KYC Flow Screens
**Routes:** `/kyc/document-type`, `/kyc/personal-info`, `/kyc/document-capture`, `/kyc/selfie`, `/kyc/liveness`, `/kyc/review`, `/kyc/submitted`
**STATUS: ACTIVE**

```gherkin
Feature: KYC Document Type Selection
  # /kyc/document-type

  Scenario: Select document type
    Then I should see document type options:
      - National ID
      - Passport
      - Driver's License
    When I select "National ID"
    Then I should be navigated to "/kyc/personal-info"

Feature: KYC Personal Info
  # /kyc/personal-info

  Scenario: Enter personal information
    Then I should see form fields:
      - First name
      - Last name
      - Date of birth
      - Address
    When I fill in all required fields
    And tap "Continue"
    Then I should be navigated to "/kyc/document-capture"

Feature: KYC Document Capture
  # /kyc/document-capture

  Scenario: Capture document front
    Then I should see camera viewfinder with document frame
    And I should see "Capture front of document" instruction
    When I capture image
    Then I should see preview with "Retake" and "Continue" options

  Scenario: Capture document back
    Given I have captured front
    Then I should see "Capture back of document"
    When I capture image
    Then I should be navigated to "/kyc/selfie"

Feature: KYC Selfie
  # /kyc/selfie

  Scenario: Capture selfie
    Then I should see front camera viewfinder with face frame
    When I capture selfie
    Then I should see preview
    And option to continue or retake

Feature: KYC Liveness
  # /kyc/liveness

  Scenario: Complete liveness check
    Then I should see instructions to follow prompts
    When I complete liveness actions (turn head, blink)
    Then liveness should be verified
    And I should be navigated to "/kyc/review"

Feature: KYC Review
  # /kyc/review

  Scenario: Review submission
    Then I should see all captured information
    And I should see "Submit" button
    When I tap "Submit"
    Then KYC data should be submitted
    And I should be navigated to "/kyc/submitted"

Feature: KYC Submitted
  # /kyc/submitted

  Scenario: Display submitted confirmation
    Then I should see success animation
    And I should see "Documents Submitted" title
    And I should see "We'll notify you within 24 hours"
    And I should see "Continue" button to go home
```

**Backend API:**
- `POST /kyc/submit` - Submit all KYC documents
- `POST /kyc/documents` - Upload individual documents
- `POST /kyc/liveness` - Submit liveness check

---

## Cards Screens

### 34. Cards List View
**File:** `lib/features/cards/views/cards_list_view.dart`
**Route:** `/cards`
**STATUS: FEATURE_FLAGGED**
**Feature Flag:** `virtual_cards`

```gherkin
Feature: Virtual Cards List

  Background:
    Given virtual cards feature is enabled
    And I am on the cards screen

  Scenario: Feature disabled
    Given virtual cards feature is disabled
    Then I should see "Feature not available" message

  Scenario: Display empty state
    Given I have no virtual cards
    Then I should see empty state illustration
    And I should see "No cards yet" message
    And I should see "Request Card" button

  Scenario: Display cards list
    Given I have virtual cards
    Then I should see list of cards
    Each card showing:
      - Card design/brand
      - Masked card number
      - Card status
    And I should see floating "Request Card" button

  Scenario: View card detail
    When I tap on a card
    Then I should be navigated to "/cards/detail/{id}"

  Scenario: Request new card
    When I tap "Request Card"
    Then I should be navigated to "/cards/request"
```

---

### 35-38. Card Detail, Settings, Transactions, Request Views
**Routes:** `/cards/detail/:id`, `/cards/settings/:id`, `/cards/transactions/:id`, `/cards/request`
**STATUS: FEATURE_FLAGGED**

```gherkin
Feature: Card Detail
  # /cards/detail/:id

  Scenario: Display card detail
    Then I should see full card visualization
    And I should see card number (tap to reveal)
    And I should see CVV (tap to reveal)
    And I should see expiry date
    And I should see "Settings" and "Transactions" buttons

Feature: Card Settings
  # /cards/settings/:id

  Scenario: Manage card settings
    Then I should see:
      - Freeze/Unfreeze toggle
      - Transaction limits
      - Online purchases toggle
      - ATM withdrawals toggle
      - Delete card option

Feature: Request Card
  # /cards/request

  Scenario: Request virtual card
    Then I should see card type options
    And I should see fee information
    When I tap "Request Card"
    Then card should be created
    And I should be navigated to card detail
```

**Backend API:**
- `GET /cards` - List user's cards
- `GET /cards/{id}` - Get card details
- `POST /cards` - Request new card
- `PATCH /cards/{id}/settings` - Update card settings

---

## Settings Screens

### 39. Settings Screen
**File:** `lib/features/settings/views/settings_screen.dart`
**Route:** `/settings`
**STATUS: ACTIVE**

```gherkin
Feature: Settings

  Background:
    Given I am authenticated
    And I am on the settings screen

  Scenario: Display settings sections
    Then I should see profile card with:
      - Avatar with initials
      - Name
      - Phone number
      - Verified badge if KYC complete
    And I should see "PROFILE" section
    And I should see "SECURITY" section
    And I should see "PREFERENCES" section
    And I should see "ABOUT" section
    And I should see referral card
    And I should see "Logout" button
    And I should see app version

  Scenario: Navigate to profile edit
    When I tap profile card or "Edit Profile"
    Then I should be navigated to "/settings/profile/edit"

  Scenario: Navigate to KYC
    When I tap "KYC Verification"
    Then I should be navigated to "/settings/kyc"
    And I should see KYC status in subtitle

  Scenario: Security section
    Then I should see:
      - Change PIN
      - Biometric (if available)
      - Devices
      - Active Sessions
      - Security Settings
      - Transaction Limits

  Scenario: Toggle biometric
    Given device supports Face ID
    When I toggle biometric switch
    Then I should be prompted to authenticate
    And biometric preference should save

  Scenario: Preferences section
    Then I should see:
      - Language (showing current)
      - Currency Display
      - Theme (Light/Dark/System)
      - Notifications

  Scenario: Change theme
    When I tap "Theme"
    Then theme dialog should appear
    When I select "Dark"
    Then theme should change to dark mode

  Scenario: Logout
    When I tap "Logout"
    Then confirmation dialog should appear
    When I confirm
    Then I should be logged out
    And navigated to "/login"

  Scenario: Debug menu
    When I tap version text 7 times
    Then debug menu should appear
    Showing app version, environment, mock status
```

---

### 40-52. Settings Sub-screens
**Various routes under /settings/**
**STATUS: ACTIVE**

```gherkin
Feature: Profile Edit
  # /settings/profile/edit

  Scenario: Edit profile
    Then I should see editable fields:
      - First name
      - Last name
      - Email (optional)
    When I make changes and tap "Save"
    Then profile should update

Feature: Change PIN
  # /settings/pin

  Scenario: Change PIN
    Then I should see "Enter current PIN"
    When I enter current PIN
    Then I should see "Enter new PIN"
    When I enter new PIN twice
    Then PIN should be changed

Feature: Language
  # /settings/language

  Scenario: Change language
    Then I should see supported languages
    When I select "Français"
    Then app should change to French

Feature: Theme
  # /settings/theme

  Scenario: Already covered in settings screen

Feature: Currency
  # /settings/currency

  Scenario: Set reference currency
    Then I should see "Primary: USDC" (non-editable)
    And I should see reference currency options
    When I enable reference currency
    And select "XOF"
    Then home screen should show XOF conversions

Feature: Devices
  # /settings/devices

  Scenario: Manage trusted devices
    Then I should see list of devices
    Each showing device name, last active
    When I tap "Remove" on a device
    Then device should be removed after confirmation

Feature: Sessions
  # /settings/sessions

  Scenario: Manage active sessions
    Then I should see list of sessions
    With ability to end other sessions

Feature: Limits
  # /settings/limits

  Scenario: View transaction limits
    Then I should see:
      - Daily limit and usage
      - Monthly limit and usage
      - Per-transaction limits
    And option to request limit increase

Feature: Help
  # /settings/help

  Scenario: Get help
    Then I should see FAQ sections
    And I should see "Contact Support" option
```

---

## Notification Screens

### 53-55. Notification Screens
**Routes:** `/notifications`, `/notifications/permission`, `/notifications/preferences`
**STATUS: ACTIVE**

```gherkin
Feature: Notifications List
  # /notifications

  Scenario: Display notifications
    Then I should see notifications list
    Grouped by date
    With unread indicator
    When I tap notification
    Then it should mark as read
    And navigate to relevant screen

Feature: Notification Permission
  # /notifications/permission

  Scenario: Request permission
    Then I should see permission explanation
    And "Enable Notifications" button
    When I tap enable
    Then system permission dialog should appear

Feature: Notification Preferences
  # /notifications/preferences

  Scenario: Configure notifications
    Then I should see toggles for:
      - Transaction alerts
      - Security alerts
      - Marketing
      - Price alerts
```

---

## FSM State Screens

### 56-66. FSM State Screens
**Routes:** Various under / (e.g., `/otp-expired`, `/auth-locked`, etc.)
**STATUS: ACTIVE**

These screens handle special application states managed by the Finite State Machine:

```gherkin
Feature: OTP Expired
  # /otp-expired

  Scenario: Display OTP expired
    Then I should see "OTP Expired" message
    And "Get New OTP" button

Feature: Auth Locked
  # /auth-locked

  Scenario: Display locked account
    Then I should see "Account Locked" message
    And unlock countdown
    And "Contact Support" option

Feature: Auth Suspended
  # /auth-suspended

  Scenario: Display suspended account
    Then I should see "Account Suspended" message
    And reason if available
    And "Contact Support" button

Feature: Session Locked
  # /session-locked

  Scenario: Display session locked
    Then I should see "Session Expired" message
    And "Unlock" button to re-authenticate

Feature: Biometric Prompt
  # /biometric-prompt

  Scenario: Prompt for biometric
    Then biometric auth should trigger automatically

Feature: Device Verification
  # /device-verification

  Scenario: Verify new device
    Then I should see "New Device Detected" message
    And OTP verification required

Feature: Session Conflict
  # /session-conflict

  Scenario: Handle session conflict
    Then I should see "Active Session on Another Device"
    And "End Other Session" button

Feature: Wallet Frozen
  # /wallet-frozen

  Scenario: Display frozen wallet
    Then I should see "Wallet Frozen" message
    And reason
    And "Contact Support" button

Feature: Wallet Under Review
  # /wallet-under-review

  Scenario: Display under review
    Then I should see "Wallet Under Review" message
    And expected timeline

Feature: KYC Expired
  # /kyc-expired

  Scenario: Display KYC expired
    Then I should see "Verification Expired" message
    And "Renew KYC" button

Feature: Loading
  # /loading

  Scenario: Display loading state
    Then I should see loading indicator
    While FSM determines next state
```

---

## Feature-Flagged Screens

### 67-100. Feature-Flagged Screens

All screens below are behind feature flags and will show "Feature not available" when disabled:

| Feature | Flag | Route | Status |
|---------|------|-------|--------|
| Savings Pots | `savings_pots` | `/savings-pots/*` | FEATURE_FLAGGED |
| Recurring Transfers | `recurring_transfers` | `/recurring-transfers/*` | FEATURE_FLAGGED |
| Bill Payments | `bill_payments` | `/bill-payments/*` | FEATURE_FLAGGED |
| Payment Links | `payment_links` | `/payment-links/*` | FEATURE_FLAGGED |
| Merchant QR | `merchant_qr` | `/merchant-dashboard/*` | FEATURE_FLAGGED |
| Bank Linking | (TBD) | `/bank-linking/*` | FEATURE_FLAGGED |
| Bulk Payments | (TBD) | `/bulk-payments/*` | FEATURE_FLAGGED |
| Sub-Businesses | (TBD) | `/sub-businesses/*` | FEATURE_FLAGGED |
| Expenses | (TBD) | `/expenses/*` | FEATURE_FLAGGED |
| Alerts | (TBD) | `/alerts/*` | FEATURE_FLAGGED |

---

## Business/Merchant Screens

### 101-110. Business Screens
**STATUS: FEATURE_FLAGGED / AWAITING_IMPLEMENTATION**

```gherkin
Feature: Business Setup
  # /settings/business-setup

  Scenario: Setup business profile
    Then I should see business registration form

Feature: Merchant Dashboard
  # /merchant-dashboard

  Scenario: View merchant stats
    Then I should see:
      - Today's sales
      - Transaction count
      - Recent payments
      - Generate QR button
```

---

## Debug/Demo Screens

### 111-115. Debug Screens
**STATUS: DEMO_ONLY**

```gherkin
Feature: Widget Catalog
  # /catalog

  Scenario: View design system components
    Then I should see all UI components
    For development/testing purposes

Feature: RTL Debug Screen
  # (internal)

  Scenario: Test RTL layout
    Then I should see RTL layout testing tools

Feature: Performance Debug Screen
  # (internal)

  Scenario: View performance metrics
    Then I should see frame rates, memory usage, etc.

Feature: States Demo View
  # (internal)

  Scenario: Preview all state variations
    For each component, show all states
```

---

## Dead Code Screens

### 116-127. Identified Dead Code
**STATUS: DEAD_CODE**

These screens exist but are not referenced in the router:

| File | Reason |
|------|--------|
| `wallet_home_accessibility_example.dart` | Example/reference only |
| `contacts_permission_screen.dart` | Permission handled inline |
| `pending_transfers_screen.dart` | Replaced by offline sync |
| `help_screen.dart` | Duplicate of help_view.dart |
| `cards_screen.dart` | Duplicate of cards_list_view.dart |
| Several `*_view.dart` duplicates | Legacy files |

---

## Backend Requirements

### Required API Endpoints (Current)

| Endpoint | Method | Purpose | Status |
|----------|--------|---------|--------|
| `/auth/login` | POST | Initiate login | ✅ |
| `/auth/register` | POST | Register new user | ✅ |
| `/auth/verify-otp` | POST | Verify OTP | ✅ |
| `/auth/resend-otp` | POST | Resend OTP | ✅ |
| `/wallet` | GET | Get wallet balance | ✅ |
| `/wallet/create` | POST | Create wallet | ✅ |
| `/transactions` | GET | List transactions | ✅ |
| `/transfers/internal` | POST | Internal transfer | ✅ |
| `/transfers/external` | POST | External transfer | ⚠️ Behind flag |
| `/deposit/providers` | GET | List deposit providers | ✅ |
| `/deposit/initiate` | POST | Start deposit | ✅ |
| `/deposit/{id}/status` | GET | Poll deposit status | ✅ |
| `/kyc/status` | GET | Get KYC status | ✅ |
| `/kyc/submit` | POST | Submit KYC | ✅ |
| `/beneficiaries` | GET/POST | Manage beneficiaries | ✅ |
| `/limits` | GET | Get transaction limits | ✅ |
| `/feature-flags/me` | GET | Get feature flags | ✅ |
| `/exchange-rates` | GET | Get exchange rates | ✅ |
| `/cards` | GET/POST | Manage cards | ⚠️ Behind flag |

### Missing/Needed Endpoints

| Endpoint | Purpose | Priority |
|----------|---------|----------|
| `/notifications` | List notifications | High |
| `/notifications/preferences` | Notification settings | Medium |
| `/devices` | Trusted devices | Medium |
| `/sessions` | Active sessions | Medium |
| `/receipts/{id}` | Generate receipt | Low |

---

## Next Steps

1. ✅ **Step 1 Complete:** All screens have BDD definitions with status flags
2. ⏳ **Step 2:** Create golden tests for all screens using real backend
3. ⏳ **Step 3:** Fix any backend issues discovered
4. ⏳ **Step 4:** Design testing after golden tests pass
5. ⏳ **Step 5:** Unit tests after design tests pass

---

*Generated by Claude - USDC Wallet Testing Suite*
