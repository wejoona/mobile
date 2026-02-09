# USDC Wallet - Screen Inventory & BDD Definitions

**Generated:** 2025-02-02
**Last Updated:** 2025-02-03
**Total Screens:** 177
**Status:** Phase 1 - COMPLETE ✅

## Quick Stats
| Category | Count |
|----------|-------|
| Active Screens | 143 |
| Feature-Flagged | 23 |
| Dead Code | 5 |
| Demo/Debug | 6 |
| **Total** | **177** |

## Legend
- **ACTIVE**: Used in production flow, routed
- **DEAD_CODE**: Not reachable via router
- **DEMO**: Only for demos/presentations
- **DISABLED**: Feature-flagged off
- **PENDING_FEATURE**: Awaiting implementation

---

## 1. Splash/SplashView
**File:** `lib/features/splash/views/splash_view.dart`
**Status:** ACTIVE
**Route:** `/` (initial route)

### BDD Scenarios
```gherkin
Feature: Splash Screen

  Scenario: App launch animation
    Given the user opens the app
    When the splash screen loads
    Then the JoonaPay logo with animation is displayed
    And the app navigates based on auth state after 2 seconds

  Scenario: Navigate to onboarding for new user
    Given the user has not completed onboarding
    When the splash animation completes
    Then the user is redirected to /onboarding

  Scenario: Navigate to login for returning user
    Given the user has completed onboarding
    And the user is not authenticated
    When the splash animation completes
    Then the user is redirected to /login

  Scenario: Navigate to home for authenticated user
    Given the user is authenticated
    When the splash animation completes
    Then the user is redirected to /home
```

### Testable Actions
- [x] Logo animation plays
- [x] Correct navigation based on auth state
- [x] SharedPreferences onboarding check

### Backend Dependencies
- None (local state only)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 2. Onboarding/OnboardingView
**File:** `lib/features/onboarding/views/onboarding_view.dart`
**Status:** ACTIVE
**Route:** `/onboarding`

### BDD Scenarios
```gherkin
Feature: Onboarding

  Scenario: View onboarding pages
    Given the user is on the onboarding screen
    When the user swipes left
    Then the next onboarding page is displayed
    And the page indicator updates

  Scenario: Skip onboarding
    Given the user is on any onboarding page
    When the user taps "Skip"
    Then onboarding is marked complete
    And the user is redirected to /login

  Scenario: Complete onboarding
    Given the user is on the last onboarding page
    When the user taps "Get Started"
    Then onboarding is marked complete
    And the user is redirected to /login

  Scenario: Page indicators
    Given there are 4 onboarding pages
    When the user is on page 2
    Then indicator 2 is highlighted
    And indicators 1, 3, 4 are dimmed
```

### Testable Actions
- [x] Page swiping
- [x] Skip button
- [x] Get Started button
- [x] Page indicator updates

### Backend Dependencies
- None (SharedPreferences only)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 3. Auth/LoginView
**File:** `lib/features/auth/views/login_view.dart`
**Status:** ACTIVE
**Route:** `/login`

### BDD Scenarios
```gherkin
Feature: Login

  Scenario: Enter phone number
    Given the user is on the login screen
    When the user enters a valid 10-digit phone number
    Then the Continue button becomes enabled
    And a green checkmark appears

  Scenario: Select country
    Given the user is on the login screen
    When the user taps the country selector
    Then a country picker bottom sheet appears
    And the user can search and select a country

  Scenario: Submit login
    Given the user has entered a valid phone number
    When the user taps Continue
    Then an OTP is sent to the phone number
    And the user is redirected to /otp

  Scenario: Toggle registration mode
    Given the user is on the login screen
    When the user taps "Sign Up"
    Then the form switches to registration mode
    And the button label changes to "Create Account"

  Scenario: Invalid phone number
    Given the user enters fewer than 10 digits
    Then the Continue button is disabled
    And a red X indicator appears
```

### Testable Actions
- [x] Phone number input validation
- [x] Country selector
- [x] Submit login/register
- [x] Toggle login/register mode
- [x] Terms/Privacy links

### Backend Dependencies
- POST `/auth/login` - Send OTP
- POST `/auth/register` - Create account

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 4. Auth/OtpView
**File:** `lib/features/auth/views/otp_view.dart`
**Status:** ACTIVE
**Route:** `/otp`

### BDD Scenarios
```gherkin
Feature: OTP Verification

  Scenario: Enter OTP code
    Given the user is on the OTP screen
    When the user enters 6 digits
    Then the OTP is automatically submitted

  Scenario: Successful OTP verification
    Given the user enters a valid OTP
    When the OTP is verified
    Then the user is redirected to /home

  Scenario: Invalid OTP
    Given the user enters an incorrect OTP
    When verification fails
    Then an error message is displayed
    And the PIN dots show error state

  Scenario: Resend OTP
    Given the resend timer has expired (30s)
    When the user taps "Resend Code"
    Then a new OTP is sent
    And the timer resets

  Scenario: SMS Autofill
    Given SMS autofill is supported
    When an OTP SMS arrives
    Then the code is automatically filled
```

### Testable Actions
- [x] OTP digit entry
- [x] Auto-submit on 6 digits
- [x] Resend code with timer
- [x] SMS autofill
- [x] Biometric authentication fallback

### Backend Dependencies
- POST `/auth/verify-otp`
- POST `/auth/login` (resend)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 5. Auth/LoginOtpView
**File:** `lib/features/auth/views/login_otp_view.dart`
**Status:** ACTIVE
**Route:** `/login/otp`

### BDD Scenarios
```gherkin
Feature: Login OTP Verification

  Scenario: Enter OTP for returning user
    Given the user is on the login OTP screen
    When the user enters 6 digits
    Then the OTP is submitted automatically

  Scenario: Navigate to PIN entry
    Given the OTP is verified successfully
    When verification completes
    Then the user is redirected to /login/pin

  Scenario: Handle verification error
    Given the user enters an incorrect OTP
    When verification fails
    Then error state is shown
    And the OTP input is cleared
```

### Testable Actions
- [x] OTP digit entry
- [x] Auto-submit
- [x] Error handling
- [x] Navigation to PIN

### Backend Dependencies
- POST `/auth/verify-otp`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 6. Auth/LoginPinView
**File:** `lib/features/auth/views/login_pin_view.dart`
**Status:** ACTIVE
**Route:** `/login/pin`

### BDD Scenarios
```gherkin
Feature: Login PIN Entry

  Scenario: Enter PIN
    Given the user is on the PIN entry screen
    When the user enters 6 digits
    Then the PIN is verified

  Scenario: Successful PIN verification
    Given the user enters the correct PIN
    When verification succeeds
    Then the user is redirected to /home

  Scenario: Incorrect PIN
    Given the user enters an incorrect PIN
    When verification fails
    Then an error is shown
    And remaining attempts are displayed

  Scenario: Account locked
    Given the user has exhausted all PIN attempts
    When the account is locked
    Then a locked screen is displayed
    And the user must contact support

  Scenario: Biometric authentication
    Given biometric is enabled and supported
    When the user authenticates with biometric
    Then they are redirected to /home
```

### Testable Actions
- [x] PIN digit entry
- [x] Backspace
- [x] Biometric fallback
- [x] Forgot PIN link
- [x] Account lock handling

### Backend Dependencies
- POST `/auth/verify-pin`
- Biometric local authentication

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 7. Wallet/WalletHomeScreen
**File:** `lib/features/wallet/views/wallet_home_screen.dart`
**Status:** ACTIVE
**Route:** `/home` (main tab)

### BDD Scenarios
```gherkin
Feature: Wallet Home

  Scenario: Display balance
    Given the user is authenticated
    And has a wallet
    When the home screen loads
    Then the USDC balance is displayed with animation
    And reference currency conversion is shown (if enabled)

  Scenario: Hide/Show balance
    Given the balance is visible
    When the user taps the visibility toggle
    Then the balance is hidden with asterisks
    And the preference is saved

  Scenario: Quick actions
    Given the user is on the home screen
    When the user taps "Send"
    Then they are navigated to /send
    
  Scenario: KYC banner
    Given the user has not completed KYC
    When the home screen loads
    Then a KYC verification banner is displayed
    
  Scenario: Recent transactions
    Given the user has transaction history
    When the home screen loads
    Then the 5 most recent transactions are displayed

  Scenario: Create wallet for new user
    Given the user has no wallet
    When the home screen loads
    Then an "Activate Wallet" card is shown
    
  Scenario: Pull to refresh
    Given the user is on the home screen
    When the user pulls down to refresh
    Then the balance and transactions are refreshed
```

### Testable Actions
- [x] Balance display/animation
- [x] Balance hide/show toggle
- [x] Quick action buttons (Send, Receive, Deposit, History)
- [x] KYC banner tap
- [x] Recent transactions tap
- [x] Create wallet
- [x] Pull to refresh

### Backend Dependencies
- GET `/wallet` - Fetch wallet info
- GET `/transactions?limit=5` - Recent transactions
- POST `/wallet/create` - Create wallet

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 8. Send/RecipientScreen
**File:** `lib/features/send/views/recipient_screen.dart`
**Status:** ACTIVE
**Route:** `/send`

### BDD Scenarios
```gherkin
Feature: Select Recipient

  Scenario: Enter phone number
    Given the user is on the recipient screen
    When the user enters a 10-digit phone number
    Then the Continue button becomes enabled

  Scenario: Select from contacts
    Given contacts permission is granted
    When the user taps "From Contacts"
    Then a contact picker is shown
    And selecting a contact fills the phone field

  Scenario: Select from beneficiaries
    Given the user has saved beneficiaries
    When the user taps "From Beneficiaries"
    Then a beneficiary picker is shown

  Scenario: Select recent recipient
    Given the user has recent recipients
    When the user taps a recent recipient
    Then their phone number is filled
```

### Testable Actions
- [x] Phone number input
- [x] Contact picker
- [x] Beneficiary picker
- [x] Recent recipients list
- [x] Continue to amount screen

### Backend Dependencies
- GET `/beneficiaries` - List beneficiaries
- GET `/transactions/recipients/recent` - Recent recipients

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 9. Send/AmountScreen
**File:** `lib/features/send/views/amount_screen.dart`
**Status:** ACTIVE
**Route:** `/send/amount`

### BDD Scenarios
```gherkin
Feature: Enter Send Amount

  Scenario: Enter amount
    Given the user has selected a recipient
    When the user enters an amount
    Then the equivalent in reference currency is shown

  Scenario: Quick amount buttons
    Given the user is on the amount screen
    When the user taps a quick amount ($10, $50, etc.)
    Then that amount is filled in the input

  Scenario: Insufficient balance
    Given the user's balance is $50
    When the user enters $100
    Then an error message is displayed
    And the Continue button is disabled

  Scenario: Add note
    Given the user has entered a valid amount
    When the user adds a note
    Then the note is stored for the transaction
```

### Testable Actions
- [x] Amount input
- [x] Quick amount buttons
- [x] Balance validation
- [x] Note input
- [x] Continue to confirm screen

### Backend Dependencies
- Wallet balance (from provider state)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 10. Send/ConfirmScreen
**File:** `lib/features/send/views/confirm_screen.dart`
**Status:** ACTIVE
**Route:** `/send/confirm`

### BDD Scenarios
```gherkin
Feature: Confirm Send

  Scenario: Review transfer details
    Given the user has entered amount and recipient
    When the confirm screen loads
    Then recipient name/phone, amount, and fee are displayed

  Scenario: Confirm and proceed to PIN
    Given the user reviews the details
    When the user taps "Confirm"
    Then they are navigated to PIN verification
```

### Testable Actions
- [x] Display transfer details
- [x] Fee calculation
- [x] Confirm button
- [x] Back navigation

### Backend Dependencies
- Fee calculation (may be local or API)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 11. Send/PinVerificationScreen
**File:** `lib/features/send/views/pin_verification_screen.dart`
**Status:** ACTIVE
**Route:** `/send/pin`

### BDD Scenarios
```gherkin
Feature: PIN Verification for Send

  Scenario: Enter PIN to authorize
    Given the user is on the PIN verification screen
    When the user enters their 6-digit PIN
    Then the transfer is submitted

  Scenario: Successful transfer
    Given the PIN is correct
    When the transfer succeeds
    Then the user is navigated to the result screen

  Scenario: Failed transfer
    Given the PIN is incorrect
    When verification fails
    Then an error is shown
    And remaining attempts are displayed
```

### Testable Actions
- [x] PIN entry
- [x] Submit transfer
- [x] Error handling
- [x] Navigate to result

### Backend Dependencies
- POST `/transfers/internal` - Execute transfer

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 12. Send/ResultScreen
**File:** `lib/features/send/views/result_screen.dart`
**Status:** ACTIVE
**Route:** `/send/result`

### BDD Scenarios
```gherkin
Feature: Transfer Result

  Scenario: Success result
    Given the transfer completed successfully
    When the result screen loads
    Then a success animation is shown
    And transfer details are displayed

  Scenario: Share receipt
    Given the transfer was successful
    When the user taps "Share Receipt"
    Then a share sheet is opened

  Scenario: Return home
    Given the result is displayed
    When the user taps "Done"
    Then they are navigated to /home
```

### Testable Actions
- [x] Success/failure display
- [x] Share receipt
- [x] Done button
- [x] View transaction details

### Backend Dependencies
- None (uses passed state)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 13. Deposit/DepositAmountScreen
**File:** `lib/features/deposit/views/deposit_amount_screen.dart`
**Status:** ACTIVE
**Route:** `/deposit/amount`

### BDD Scenarios
```gherkin
Feature: Deposit Amount

  Scenario: Enter amount in XOF
    Given XOF is selected
    When the user enters an amount
    Then the USD equivalent is displayed

  Scenario: Enter amount in USD
    Given USD is selected
    When the user enters an amount
    Then the XOF equivalent is displayed

  Scenario: Quick amount buttons
    Given the user is on deposit amount screen
    When the user taps 10K (XOF)
    Then 10000 is filled in the amount field

  Scenario: Validate limits
    Given the minimum is 500 XOF and max is 5M XOF
    When the user enters 100 XOF
    Then an error "Minimum 500 XOF" is displayed

  Scenario: Refresh exchange rate
    Given an exchange rate is displayed
    When the user taps refresh
    Then a new rate is fetched from the API
```

### Testable Actions
- [x] Amount input
- [x] Currency toggle (XOF/USD)
- [x] Quick amount buttons
- [x] Exchange rate display
- [x] Rate refresh
- [x] Limit validation

### Backend Dependencies
- GET `/exchange-rates/XOF` - Exchange rate

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 14. Deposit/ProviderSelectionScreen
**File:** `lib/features/deposit/views/provider_selection_screen.dart`
**Status:** ACTIVE
**Route:** `/deposit/provider`

### BDD Scenarios
```gherkin
Feature: Select Payment Provider

  Scenario: Display available providers
    Given the user has entered a deposit amount
    When the provider screen loads
    Then available mobile money providers are displayed

  Scenario: Select provider
    Given providers are displayed
    When the user taps "Orange Money"
    Then that provider is selected
    And they proceed to payment instructions
```

### Testable Actions
- [x] Provider list display
- [x] Provider selection
- [x] Continue to instructions

### Backend Dependencies
- GET `/deposit/providers` - Available providers

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 15. KYC/KycStatusView
**File:** `lib/features/kyc/views/kyc_status_view.dart`
**Status:** ACTIVE
**Route:** `/kyc`

### BDD Scenarios
```gherkin
Feature: KYC Status

  Scenario: Not started
    Given the user has not started KYC
    When the KYC screen loads
    Then a "Start Verification" button is shown
    And info cards explain the process

  Scenario: Submitted/pending review
    Given the user has submitted KYC
    When the screen loads
    Then a pending status icon is shown
    And "Under Review" message is displayed

  Scenario: Verified
    Given KYC is approved
    When the screen loads
    Then a success icon is shown
    And verified badge is displayed

  Scenario: Rejected
    Given KYC was rejected
    When the screen loads
    Then rejection reason is displayed
    And "Try Again" button is shown
```

### Testable Actions
- [x] Status icon display
- [x] Start verification button
- [x] Rejection reason display
- [x] Continue to home (if pending)

### Backend Dependencies
- GET `/kyc/status` - KYC status

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 16. KYC/DocumentTypeView
**File:** `lib/features/kyc/views/document_type_view.dart`
**Status:** ACTIVE
**Route:** `/kyc/document-type`

### BDD Scenarios
```gherkin
Feature: Select Document Type

  Scenario: Display document options
    Given the user is starting KYC
    When the document type screen loads
    Then available document types are shown (Passport, ID Card, etc.)

  Scenario: Select document type
    Given document types are displayed
    When the user selects "National ID"
    Then they proceed to document capture
```

### Testable Actions
- [x] Document type list
- [x] Type selection
- [x] Navigation to capture

### Backend Dependencies
- None (local config)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 17. Transactions/TransactionsView
**File:** `lib/features/transactions/views/transactions_view.dart`
**Status:** ACTIVE
**Route:** `/transactions` (main tab)

### BDD Scenarios
```gherkin
Feature: Transaction History

  Scenario: Display transactions
    Given the user has transaction history
    When the transactions screen loads
    Then transactions are grouped by date
    And each shows type, amount, status

  Scenario: Search transactions
    Given there are many transactions
    When the user searches "deposit"
    Then only matching transactions are shown

  Scenario: Filter transactions
    Given transactions are displayed
    When the user applies type filter "Deposits"
    Then only deposit transactions are shown

  Scenario: Infinite scroll
    Given there are more than 20 transactions
    When the user scrolls to the bottom
    Then more transactions are loaded

  Scenario: Empty state
    Given the user has no transactions
    When the screen loads
    Then an empty state with "Make your first deposit" is shown
```

### Testable Actions
- [x] Transaction list display
- [x] Date grouping
- [x] Search
- [x] Filters (type, status, date, amount)
- [x] Infinite scroll pagination
- [x] Pull to refresh
- [x] Tap transaction for detail

### Backend Dependencies
- GET `/transactions` - Paginated list with filters

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 18. Settings/SettingsScreen
**File:** `lib/features/settings/views/settings_screen.dart`
**Status:** ACTIVE
**Route:** `/settings` (main tab)

### BDD Scenarios
```gherkin
Feature: Settings

  Scenario: Display profile card
    Given the user is authenticated
    When settings screen loads
    Then user avatar, name, and phone are shown

  Scenario: Navigate to profile
    Given the settings screen is displayed
    When the user taps the profile card
    Then they navigate to /settings/profile

  Scenario: Toggle biometric
    Given biometric is supported
    When the user toggles biometric switch
    Then biometric login is enabled/disabled

  Scenario: Change theme
    Given the user taps theme setting
    When they select "Dark"
    Then the app theme changes to dark mode

  Scenario: Logout
    Given the user taps Logout
    When they confirm in the dialog
    Then they are logged out and redirected to /login
```

### Testable Actions
- [x] Profile card display
- [x] Navigate to all settings screens
- [x] Biometric toggle
- [x] Theme selection
- [x] Language selection
- [x] Currency display setting
- [x] Logout with confirmation
- [x] Debug menu (7 taps on version)

### Backend Dependencies
- User state (from provider)
- POST `/auth/logout`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 19. Alerts/AlertsListView
**File:** `lib/features/alerts/views/alerts_list_view.dart`
**Status:** ACTIVE
**Route:** `/alerts`

### BDD Scenarios
```gherkin
Feature: Alerts List

  Scenario: Display alerts
    Given the user has alerts
    When the alerts screen loads
    Then alerts are displayed with severity indicators

  Scenario: Filter by severity
    Given alerts are displayed
    When the user selects "Critical" filter
    Then only critical alerts are shown

  Scenario: Mark all as read
    Given there are unread alerts
    When the user taps "Mark all read"
    Then all alerts are marked as read

  Scenario: View alert detail
    Given alerts are displayed
    When the user taps an alert
    Then they navigate to alert detail
    And the alert is marked as read
```

### Testable Actions
- [x] Alert list display
- [x] Severity filter chips
- [x] Mark all as read
- [x] Statistics summary
- [x] Navigate to alert detail
- [x] Navigate to preferences

### Backend Dependencies
- GET `/alerts` - Alert list
- POST `/alerts/mark-read`
- GET `/alerts/statistics`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 20. Alerts/AlertDetailView
**File:** `lib/features/alerts/views/alert_detail_view.dart`
**Status:** ACTIVE
**Route:** `/alerts/:id`

### BDD Scenarios
```gherkin
Feature: Alert Detail

  Scenario: Display alert details
    Given the user taps an alert
    When the detail screen loads
    Then alert title, message, type, and severity are shown

  Scenario: Take action on alert
    Given an alert requires action
    When the user taps "Verify Identity"
    Then the action is processed
    And the alert is updated

  Scenario: View related transaction
    Given the alert has a related transaction
    When the user taps "View Transaction"
    Then they navigate to transaction detail
```

### Testable Actions
- [x] Alert detail display
- [x] Action buttons (dismiss, verify, block, etc.)
- [x] Related transaction link
- [x] Action confirmation dialog

### Backend Dependencies
- GET `/alerts/:id` - Alert detail
- POST `/alerts/:id/action` - Take action

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 21. Alerts/AlertPreferencesView
**File:** `lib/features/alerts/views/alert_preferences_view.dart`
**Status:** ACTIVE
**Route:** `/alerts/preferences`

### BDD Scenarios
```gherkin
Feature: Alert Preferences

  Scenario: Configure notification channels
    Given the user is on alert preferences
    When they toggle "Push Notifications" off
    Then push alerts are disabled
    And the preference is saved

  Scenario: Set transaction threshold
    Given the user adjusts the large transaction slider
    When they set it to $500
    Then alerts trigger for transactions over $500

  Scenario: Configure quiet hours
    Given the user enables quiet hours
    When they set 10 PM - 7 AM
    Then non-critical alerts are muted during those hours

  Scenario: Reset to defaults
    Given custom preferences are set
    When the user taps "Reset"
    Then all preferences return to default values
```

### Testable Actions
- [x] Toggle push/email/SMS notifications
- [x] Set large transaction threshold slider
- [x] Set low balance threshold
- [x] Toggle alert types
- [x] Configure quiet hours
- [x] Set digest frequency
- [x] Reset to defaults

### Backend Dependencies
- GET `/alerts/preferences`
- PUT `/alerts/preferences`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 22. Cards/CardsListView
**File:** `lib/features/cards/views/cards_list_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/cards` (main tab)

### BDD Scenarios
```gherkin
Feature: Virtual Cards List

  Scenario: Display cards
    Given the user has virtual cards
    When the cards tab loads
    Then cards are displayed in a horizontal scroll

  Scenario: Feature disabled
    Given virtual cards feature flag is off
    When the user navigates to cards
    Then a "Feature disabled" message is shown

  Scenario: Request new card
    Given the user can request more cards
    When they tap the FAB
    Then they navigate to card request flow

  Scenario: Empty state
    Given the user has no cards
    When the screen loads
    Then an empty state with "Get your first card" is shown
```

### Testable Actions
- [x] Card list display
- [x] Feature flag check
- [x] Request new card
- [x] Navigate to card detail
- [x] Pull to refresh

### Backend Dependencies
- GET `/cards` - List user cards
- Feature flag: `virtualCards`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 23. Beneficiaries/BeneficiariesScreen
**File:** `lib/features/beneficiaries/views/beneficiaries_screen.dart`
**Status:** ACTIVE
**Route:** `/beneficiaries`

### BDD Scenarios
```gherkin
Feature: Beneficiaries Management

  Scenario: View all beneficiaries
    Given the user has saved beneficiaries
    When the beneficiaries screen loads
    Then beneficiaries are displayed with avatar and name

  Scenario: Filter by tab
    Given beneficiaries are displayed
    When the user taps "Favorites" tab
    Then only favorite beneficiaries are shown

  Scenario: Search beneficiaries
    Given there are many beneficiaries
    When the user searches "John"
    Then only matching beneficiaries are shown

  Scenario: Add beneficiary
    Given the user is on beneficiaries screen
    When they tap the add button
    Then they navigate to add beneficiary flow
```

### Testable Actions
- [x] Beneficiary list display
- [x] Tab filtering (All, Favorites, Recent)
- [x] Search
- [x] Add beneficiary
- [x] Edit beneficiary
- [x] Delete beneficiary

### Backend Dependencies
- GET `/beneficiaries`
- DELETE `/beneficiaries/:id`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 24. BillPayments/BillPaymentsView
**File:** `lib/features/bill_payments/views/bill_payments_view.dart`
**Status:** ACTIVE
**Route:** `/bill-payments`

### BDD Scenarios
```gherkin
Feature: Bill Payments

  Scenario: Display categories
    Given the user opens bill payments
    When the screen loads
    Then categories (Utilities, Internet, TV, etc.) are displayed

  Scenario: Select category
    Given categories are displayed
    When the user taps "Utilities"
    Then providers for utilities are shown

  Scenario: Search providers
    Given providers are displayed
    When the user searches "Orange"
    Then matching providers are filtered

  Scenario: View payment history
    Given the user is on bill payments
    When they tap the history icon
    Then they navigate to payment history
```

### Testable Actions
- [x] Category display
- [x] Category selection
- [x] Provider list
- [x] Search providers
- [x] Navigate to payment form
- [x] Navigate to history

### Backend Dependencies
- GET `/bill-payments/categories`
- GET `/bill-payments/providers`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 25. SavingsPots/PotsListView
**File:** `lib/features/savings_pots/views/pots_list_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/savings-pots`

### BDD Scenarios
```gherkin
Feature: Savings Pots

  Scenario: Display savings pots
    Given the user has savings pots
    When the screen loads
    Then pots are displayed with progress bars

  Scenario: Create new pot
    Given the user is on pots list
    When they tap the FAB
    Then they navigate to create pot flow

  Scenario: Empty state
    Given the user has no pots
    When the screen loads
    Then an empty state with goal emoji is shown

  Scenario: View pot detail
    Given pots are displayed
    When the user taps a pot
    Then they navigate to pot detail
```

### Testable Actions
- [x] Pots list display
- [x] Progress visualization
- [x] Create new pot
- [x] Navigate to pot detail
- [x] Pull to refresh

### Backend Dependencies
- GET `/savings-pots`
- Feature flag: `savingsPots`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 26. RecurringTransfers/RecurringTransfersListView
**File:** `lib/features/recurring_transfers/views/recurring_transfers_list_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/recurring-transfers`

### BDD Scenarios
```gherkin
Feature: Recurring Transfers

  Scenario: Display recurring transfers
    Given the user has recurring transfers
    When the screen loads
    Then transfers are displayed with frequency info

  Scenario: View upcoming transfers
    Given there are scheduled transfers
    When the screen loads
    Then upcoming transfers section shows next dates

  Scenario: Create recurring transfer
    Given the user is on the list
    When they tap the FAB
    Then they navigate to create flow

  Scenario: Pause transfer
    Given a recurring transfer is active
    When the user pauses it
    Then the transfer status changes to paused
```

### Testable Actions
- [x] Transfer list display
- [x] Upcoming transfers section
- [x] Create new transfer
- [x] Navigate to detail
- [x] Pause/resume transfer

### Backend Dependencies
- GET `/recurring-transfers`
- GET `/recurring-transfers/upcoming`
- Feature flag: `recurringTransfers`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 27. MerchantPay/ScanQrView
**File:** `lib/features/merchant_pay/views/scan_qr_view.dart`
**Status:** ACTIVE
**Route:** `/scan-to-pay`

### BDD Scenarios
```gherkin
Feature: Scan to Pay

  Scenario: Scan merchant QR
    Given the user opens scan to pay
    When they scan a valid merchant QR
    Then payment confirmation sheet appears

  Scenario: Invalid QR
    Given the user scans an invalid QR
    When decoding fails
    Then an error message is shown
    And the scanner resets

  Scenario: Complete payment
    Given the user confirms payment
    When PIN is verified
    Then payment is processed
    And receipt is shown
```

### Testable Actions
- [x] QR scanner display
- [x] QR code decoding
- [x] Payment confirmation
- [x] Error handling
- [x] Navigate to receipt

### Backend Dependencies
- POST `/merchant/decode-qr`
- POST `/merchant/pay`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 28. Insights/InsightsView
**File:** `lib/features/insights/views/insights_view.dart`
**Status:** ACTIVE
**Route:** `/insights`

### BDD Scenarios
```gherkin
Feature: Spending Insights

  Scenario: Display spending summary
    Given the user has transaction history
    When insights screen loads
    Then total spent and received are displayed

  Scenario: Change period
    Given insights are displayed
    When the user selects "This Month"
    Then insights update for the selected period

  Scenario: View by category
    Given spending data exists
    When category section loads
    Then spending by category pie chart is shown

  Scenario: Export report
    Given insights are displayed
    When the user taps share
    Then an export report is generated
```

### Testable Actions
- [x] Spending summary card
- [x] Period selector (Week, Month, Year)
- [x] Spending by category chart
- [x] Spending trend chart
- [x] Top recipients section
- [x] Daily spending chart
- [x] Export/share report

### Backend Dependencies
- GET `/insights/summary`
- GET `/insights/categories`
- GET `/insights/trends`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 29. PaymentLinks/PaymentLinksListView
**File:** `lib/features/payment_links/views/payment_links_list_view.dart`
**Status:** ACTIVE
**Route:** `/payment-links`

### BDD Scenarios
```gherkin
Feature: Payment Links

  Scenario: Display payment links
    Given the user has created payment links
    When the screen loads
    Then links are displayed with status and amount

  Scenario: Create new link
    Given the user is on payment links
    When they tap create
    Then they navigate to create link flow

  Scenario: Share link
    Given a payment link exists
    When the user taps share
    Then the link URL is shared

  Scenario: View link detail
    Given links are displayed
    When the user taps a link
    Then they see link details and payments
```

### Testable Actions
- [x] Links list display
- [x] Create new link
- [x] Share link
- [x] View link detail
- [x] Pull to refresh

### Backend Dependencies
- GET `/payment-links`
- POST `/payment-links`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 30. FSM/AuthLockedView
**File:** `lib/features/fsm_states/views/auth_locked_view.dart`
**Status:** ACTIVE
**Route:** `/auth-locked`

### BDD Scenarios
```gherkin
Feature: Auth Locked State

  Scenario: Display lock countdown
    Given the user exceeded PIN attempts
    When the locked screen appears
    Then remaining time is displayed
    And it counts down

  Scenario: Lock expires
    Given the lock timer reaches 0
    When countdown completes
    Then the user can attempt login again

  Scenario: Contact support
    Given the account is locked
    When the user taps "Contact Support"
    Then support contact info is shown
```

### Testable Actions
- [x] Lock reason display
- [x] Countdown timer
- [x] Contact support link
- [x] Auto-redirect when unlocked

### Backend Dependencies
- None (FSM-driven state)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 31. FSM/WalletFrozenView
**File:** `lib/features/fsm_states/views/wallet_frozen_view.dart`
**Status:** ACTIVE
**Route:** `/wallet-frozen`

### BDD Scenarios
```gherkin
Feature: Wallet Frozen State

  Scenario: Display freeze reason
    Given the wallet is frozen by compliance
    When the frozen screen appears
    Then the reason is displayed
    And frozen until date (if temporary)

  Scenario: Contact support
    Given the wallet is frozen
    When the user taps "Contact Support"
    Then support options are shown

  Scenario: Temporary freeze
    Given the freeze is temporary
    When the freeze expires
    Then the user regains access
```

### Testable Actions
- [x] Freeze reason display
- [x] Freeze duration (if temporary)
- [x] Contact support
- [x] Learn more link

### Backend Dependencies
- None (FSM-driven state)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 32. Notifications/NotificationsView
**File:** `lib/features/notifications/views/notifications_view.dart`
**Status:** ACTIVE
**Route:** `/notifications`

### BDD Scenarios
```gherkin
Feature: Notifications

  Scenario: Display notifications
    Given the user has notifications
    When the notifications screen loads
    Then notifications are grouped by date

  Scenario: Mark as read
    Given there are unread notifications
    When the user views a notification
    Then it is marked as read

  Scenario: Navigate from notification
    Given a transaction notification exists
    When the user taps it
    Then they navigate to transaction detail

  Scenario: Mark all as read
    Given there are unread notifications
    When the user taps "Mark all read"
    Then all notifications are marked as read
```

### Testable Actions
- [x] Notification list display
- [x] Date grouping
- [x] Mark as read
- [x] Mark all as read
- [x] Navigate to action route
- [x] Pull to refresh

### Backend Dependencies
- GET `/notifications`
- POST `/notifications/mark-read`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 33. Referrals/ReferralsView
**File:** `lib/features/referrals/views/referrals_view.dart`
**Status:** ACTIVE
**Route:** `/referrals`

### BDD Scenarios
```gherkin
Feature: Referrals

  Scenario: Display referral code
    Given the user is on referrals screen
    When the screen loads
    Then their unique referral code is displayed

  Scenario: Copy code
    Given the referral code is displayed
    When the user taps "Copy"
    Then the code is copied to clipboard
    And a confirmation is shown

  Scenario: Share referral
    Given the referral screen is displayed
    When the user taps "Share"
    Then a share sheet opens with referral link

  Scenario: View earnings
    Given the user has referred friends
    When they check earnings
    Then total earned and pending are displayed
```

### Testable Actions
- [x] Referral code display
- [x] Copy code
- [x] Share referral link
- [x] How it works explanation
- [x] View referral history

### Backend Dependencies
- GET `/referrals/code`
- GET `/referrals/stats`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 34. KYC/DocumentCaptureView
**File:** `lib/features/kyc/views/document_capture_view.dart`
**Status:** ACTIVE
**Route:** `/kyc/document-capture`

### BDD Scenarios
```gherkin
Feature: Document Capture

  Scenario: Capture document front
    Given the user selected ID card
    When they position the document
    And tap capture
    Then the front image is captured

  Scenario: Capture document back
    Given the front was captured
    When they capture the back
    Then both images are stored

  Scenario: Retake photo
    Given a photo was captured
    When the user taps "Retake"
    Then the camera reopens

  Scenario: Image quality check
    Given an image is captured
    When quality is too low
    Then a warning is shown to retake
```

### Testable Actions
- [x] Camera preview
- [x] Capture button
- [x] Front/back toggle
- [x] Retake option
- [x] Quality validation
- [x] Navigate to next step

### Backend Dependencies
- Image quality check (local)
- Document storage (provider state)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 35. KYC/SelfieView
**File:** `lib/features/kyc/views/selfie_view.dart`
**Status:** ACTIVE
**Route:** `/kyc/selfie`

### BDD Scenarios
```gherkin
Feature: Selfie Capture

  Scenario: Capture selfie
    Given the user is on selfie step
    When they position their face
    And tap capture
    Then the selfie is captured

  Scenario: Face detection
    Given the camera is active
    When no face is detected
    Then a prompt to position face is shown

  Scenario: Liveness check
    Given a selfie is captured
    When liveness check runs
    Then the check passes or fails with feedback
```

### Testable Actions
- [x] Front camera preview
- [x] Face detection feedback
- [x] Capture button
- [x] Retake option
- [x] Navigate to next step

### Backend Dependencies
- Face detection (local ML)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 36. KYC/ReviewView
**File:** `lib/features/kyc/views/review_view.dart`
**Status:** ACTIVE
**Route:** `/kyc/review`

### BDD Scenarios
```gherkin
Feature: KYC Review

  Scenario: Review captured data
    Given all KYC steps are complete
    When the review screen loads
    Then document images and personal info are shown

  Scenario: Edit information
    Given the review is displayed
    When the user taps "Edit" on personal info
    Then they navigate back to edit

  Scenario: Submit KYC
    Given the user reviews all data
    When they tap "Submit"
    Then KYC is submitted for review
    And they see the submitted screen
```

### Testable Actions
- [x] Display captured images
- [x] Display personal info
- [x] Edit navigation
- [x] Submit button
- [x] Loading state

### Backend Dependencies
- POST `/kyc/submit`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 37. Transactions/TransactionDetailView
**File:** `lib/features/transactions/views/transaction_detail_view.dart`
**Status:** ACTIVE
**Route:** `/transactions/:id`

### BDD Scenarios
```gherkin
Feature: Transaction Detail

  Scenario: Display transaction details
    Given the user taps a transaction
    When the detail screen loads
    Then amount, type, date, status are displayed

  Scenario: Share receipt
    Given the transaction detail is shown
    When the user taps "Share"
    Then a receipt is generated and shared

  Scenario: View on explorer
    Given it's an on-chain transaction
    When the user taps "View on Explorer"
    Then the blockchain explorer opens

  Scenario: Dispute transaction
    Given the transaction allows disputes
    When the user taps "Report Issue"
    Then a support ticket is opened
```

### Testable Actions
- [x] Transaction details display
- [x] Share receipt
- [x] View on explorer (for external)
- [x] Report issue
- [x] Related alerts

### Backend Dependencies
- GET `/transactions/:id` (or passed via extra)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 38. Deposit/DepositStatusScreen
**File:** `lib/features/deposit/views/deposit_status_screen.dart`
**Status:** ACTIVE
**Route:** `/deposit/status`

### BDD Scenarios
```gherkin
Feature: Deposit Status

  Scenario: Pending deposit
    Given a deposit is initiated
    When the status screen loads
    Then "Pending" status is shown
    And progress indicator is active

  Scenario: Completed deposit
    Given the deposit completes
    When status updates
    Then success animation plays
    And final balance is shown

  Scenario: Failed deposit
    Given the deposit fails
    When status updates
    Then error message is displayed
    And retry option is shown
```

### Testable Actions
- [x] Status display (pending, completed, failed)
- [x] Progress indicator
- [x] Auto-refresh
- [x] Success/failure animations
- [x] Navigate home

### Backend Dependencies
- GET `/deposits/:id/status`
- WebSocket updates (if available)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 39. Settings/ProfileView
**File:** `lib/features/settings/views/profile_view.dart`
**Status:** ACTIVE
**Route:** `/settings/profile`

### BDD Scenarios
```gherkin
Feature: Profile View

  Scenario: Display profile info
    Given the user navigates to profile
    When the screen loads
    Then name, phone, email are displayed

  Scenario: Edit profile
    Given profile is displayed
    When the user taps "Edit"
    Then they navigate to edit screen

  Scenario: View KYC status
    Given profile is displayed
    When they view KYC section
    Then current tier and status are shown
```

### Testable Actions
- [x] Profile info display
- [x] Avatar display
- [x] Edit navigation
- [x] KYC status section

### Backend Dependencies
- User state (from provider)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 40. Settings/SecurityView
**File:** `lib/features/settings/views/security_view.dart`
**Status:** ACTIVE
**Route:** `/settings/security`

### BDD Scenarios
```gherkin
Feature: Security Settings

  Scenario: View security options
    Given the user navigates to security
    When the screen loads
    Then PIN, biometric, and 2FA options are shown

  Scenario: Enable 2FA
    Given 2FA is disabled
    When the user enables it
    Then they set up authenticator app

  Scenario: View login history
    Given security screen is displayed
    When the user taps login history
    Then recent login attempts are shown
```

### Testable Actions
- [x] Security options display
- [x] Change PIN navigation
- [x] Biometric toggle
- [x] 2FA setup
- [x] Login history

### Backend Dependencies
- GET `/security/settings`
- PUT `/security/2fa`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## Progress Summary

### Screens Documented: 40 / 175+

### By Status:
- **ACTIVE:** 38
- **ACTIVE (Feature-flagged):** 2 (Cards, Savings Pots)
- **DEAD_CODE:** 0 (none identified yet)
- **DEMO:** 0
- **DISABLED:** 0
- **PENDING_FEATURE:** 0

---

## 41. SendExternal/AddressInputScreen
**File:** `lib/features/send_external/views/address_input_screen.dart`
**Status:** ACTIVE
**Route:** `/send-external`

### BDD Scenarios
```gherkin
Feature: External Address Input

  Scenario: Enter wallet address
    Given the user wants to send externally
    When they enter a valid USDC address
    Then the Continue button becomes enabled

  Scenario: Scan QR code
    Given the user is on address input
    When they tap "Scan QR"
    Then QR scanner opens

  Scenario: Paste from clipboard
    Given an address is in clipboard
    When the user taps paste
    Then the address is filled

  Scenario: Invalid address
    Given the user enters an invalid address
    When validation runs
    Then an error message is shown
```

### Testable Actions
- [x] Address input
- [x] Address validation
- [x] QR scan navigation
- [x] Paste from clipboard
- [x] Continue to amount

### Backend Dependencies
- Address validation (may be local or API)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 42. BankLinking/LinkedAccountsView
**File:** `lib/features/bank_linking/views/linked_accounts_view.dart`
**Status:** ACTIVE
**Route:** `/bank-linking`

### BDD Scenarios
```gherkin
Feature: Linked Bank Accounts

  Scenario: Display linked accounts
    Given the user has linked bank accounts
    When the screen loads
    Then accounts are displayed with status

  Scenario: Link new account
    Given the user is on linked accounts
    When they tap "Link Account"
    Then they navigate to bank selection

  Scenario: Remove account
    Given an account is linked
    When the user taps remove
    Then confirmation is shown
    And account is removed on confirm
```

### Testable Actions
- [x] Accounts list display
- [x] Link new account
- [x] Remove account
- [x] Account status display
- [x] Pull to refresh

### Backend Dependencies
- GET `/bank-accounts`
- DELETE `/bank-accounts/:id`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 43. BulkPayments/BulkPaymentsView
**File:** `lib/features/bulk_payments/views/bulk_payments_view.dart`
**Status:** ACTIVE
**Route:** `/bulk-payments`

### BDD Scenarios
```gherkin
Feature: Bulk Payments

  Scenario: Display batches
    Given the user has bulk payment batches
    When the screen loads
    Then batches are displayed with status

  Scenario: Upload CSV
    Given the user is on bulk payments
    When they tap "Upload CSV"
    Then they navigate to upload screen

  Scenario: View batch status
    Given a batch exists
    When the user taps it
    Then they see batch details and status
```

### Testable Actions
- [x] Batches list display
- [x] Upload CSV navigation
- [x] Batch status cards
- [x] Navigate to batch detail

### Backend Dependencies
- GET `/bulk-payments/batches`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 44. Expenses/ExpensesView
**File:** `lib/features/expenses/views/expenses_view.dart`
**Status:** ACTIVE
**Route:** `/expenses`

### BDD Scenarios
```gherkin
Feature: Expenses Tracking

  Scenario: Display expenses
    Given the user has tracked expenses
    When the screen loads
    Then expenses are listed with categories

  Scenario: View summary
    Given expenses exist
    When the screen loads
    Then a summary card shows total/categories

  Scenario: Add expense
    Given the user is on expenses
    When they tap add
    Then they navigate to add expense

  Scenario: View reports
    Given the user taps reports icon
    Then they navigate to expense reports
```

### Testable Actions
- [x] Expenses list display
- [x] Summary card
- [x] Add expense navigation
- [x] Reports navigation
- [x] Pull to refresh

### Backend Dependencies
- GET `/expenses`
- GET `/expenses/summary`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 45. SubBusiness/SubBusinessesView
**File:** `lib/features/sub_business/views/sub_businesses_view.dart`
**Status:** ACTIVE
**Route:** `/sub-businesses`

### BDD Scenarios
```gherkin
Feature: Sub-Business Management

  Scenario: Display sub-businesses
    Given the user is a business account
    When the screen loads
    Then sub-businesses are displayed

  Scenario: Create sub-business
    Given the user is on sub-businesses
    When they tap create
    Then they navigate to create flow

  Scenario: View sub-business detail
    Given a sub-business exists
    When the user taps it
    Then they see detail screen
```

### Testable Actions
- [x] Sub-businesses list
- [x] Create sub-business
- [x] View detail
- [x] Pull to refresh

### Backend Dependencies
- GET `/sub-businesses`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 46. QRPayment/ReceiveQrScreen
**File:** `lib/features/qr_payment/views/receive_qr_screen.dart`
**Status:** ACTIVE
**Route:** Part of `/receive` flow

### BDD Scenarios
```gherkin
Feature: Receive via QR

  Scenario: Display QR code
    Given the user wants to receive
    When the screen loads
    Then their wallet QR code is displayed

  Scenario: Set amount
    Given the QR is displayed
    When the user enters an amount
    Then the QR updates with amount encoded

  Scenario: Share QR
    Given the QR is displayed
    When the user taps share
    Then the QR image is shared

  Scenario: Save to gallery
    Given the QR is displayed
    When the user taps save
    Then the QR is saved to photos
```

### Testable Actions
- [x] QR code display
- [x] Amount input
- [x] Share QR
- [x] Save to gallery
- [x] Copy address
- [x] Brightness increase for scanning

### Backend Dependencies
- Wallet address (from provider)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 47. Offline/PendingTransfersScreen
**File:** `lib/features/offline/views/pending_transfers_screen.dart`
**Status:** ACTIVE
**Route:** Internal (from home)

### BDD Scenarios
```gherkin
Feature: Pending Offline Transfers

  Scenario: Display pending transfers
    Given there are offline queued transfers
    When the screen loads
    Then pending transfers are listed with status

  Scenario: Manual sync
    Given internet is available
    When the user pulls to refresh
    Then pending transfers sync

  Scenario: Clear all
    Given there are pending transfers
    When the user taps "Clear All"
    Then confirmation shows
    And all are cleared on confirm

  Scenario: Retry single
    Given a transfer failed
    When the user taps retry
    Then that transfer is retried
```

### Testable Actions
- [x] Pending list display
- [x] Status indicators
- [x] Pull to sync
- [x] Clear all
- [x] Retry single
- [x] Cancel single

### Backend Dependencies
- Offline queue (local storage)
- POST `/transfers` on sync

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 48. Contacts/ContactsListScreen
**File:** `lib/features/contacts/views/contacts_list_screen.dart`
**Status:** ACTIVE
**Route:** Internal (from send)

### BDD Scenarios
```gherkin
Feature: Contacts List

  Scenario: Display contacts
    Given contacts permission is granted
    When the screen loads
    Then device contacts are displayed

  Scenario: Show JoonaPay users
    Given contacts are synced
    When they are displayed
    Then JoonaPay users are highlighted

  Scenario: Invite non-users
    Given a contact is not on JoonaPay
    When the user taps "Invite"
    Then an invite message is sent

  Scenario: Search contacts
    Given contacts are displayed
    When the user searches
    Then matching contacts are shown
```

### Testable Actions
- [x] Contacts display
- [x] JoonaPay user detection
- [x] Invite functionality
- [x] Search
- [x] Select contact

### Backend Dependencies
- POST `/contacts/sync` - Check JoonaPay users
- Device contacts permission

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 49. Limits/LimitsView
**File:** `lib/features/limits/views/limits_view.dart`
**Status:** ACTIVE
**Route:** `/settings/limits`

### BDD Scenarios
```gherkin
Feature: Transaction Limits

  Scenario: Display limits
    Given the user navigates to limits
    When the screen loads
    Then daily and monthly limits are shown

  Scenario: Show usage
    Given limits are displayed
    When usage exists
    Then progress bars show usage vs limit

  Scenario: Upgrade prompt
    Given the user is on lower tier
    When limits are displayed
    Then an upgrade prompt is shown
```

### Testable Actions
- [x] Limit cards display
- [x] Usage progress bars
- [x] Upgrade prompt
- [x] Refresh limits
- [x] Navigate to KYC upgrade

### Backend Dependencies
- GET `/limits`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 50. Wallet/DepositView
**File:** `lib/features/wallet/views/deposit_view.dart`
**Status:** ACTIVE
**Route:** `/deposit`

### BDD Scenarios
```gherkin
Feature: Deposit Overview

  Scenario: Display deposit options
    Given the user taps deposit
    When the screen loads
    Then deposit options are shown (Mobile Money, Bank)

  Scenario: Select mobile money
    Given options are displayed
    When the user selects Mobile Money
    Then they navigate to deposit amount
```

### Testable Actions
- [x] Deposit options display
- [x] Option selection
- [x] Navigate to flows

### Backend Dependencies
- None (navigation screen)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 51. Wallet/WithdrawView
**File:** `lib/features/wallet/views/withdraw_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/withdraw`

### BDD Scenarios
```gherkin
Feature: Withdraw

  Scenario: Enter withdrawal amount
    Given the user wants to withdraw
    When they enter an amount
    Then fees and final amount are shown

  Scenario: Select withdrawal method
    Given amount is entered
    When methods are displayed
    Then Mobile Money options are shown
```

### Testable Actions
- [x] Amount input
- [x] Method selection
- [x] Fee display
- [x] Continue to confirmation

### Backend Dependencies
- GET `/withdraw/methods`
- Feature flag: `withdraw`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 52. Wallet/ReceiveView
**File:** `lib/features/wallet/views/receive_view.dart`
**Status:** ACTIVE
**Route:** `/receive`

### BDD Scenarios
```gherkin
Feature: Receive Money

  Scenario: Display receive options
    Given the user taps receive
    When the screen loads
    Then QR code and address are shown

  Scenario: Request specific amount
    Given QR is displayed
    When the user sets an amount
    Then QR updates with amount

  Scenario: Share address
    Given address is displayed
    When the user taps share
    Then address is shared
```

### Testable Actions
- [x] QR code display
- [x] Amount input
- [x] Copy address
- [x] Share functionality

### Backend Dependencies
- Wallet address (from provider)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 53. FSM/SessionLockedView
**File:** `lib/features/fsm_states/views/session_locked_view.dart`
**Status:** ACTIVE
**Route:** `/session-locked`

### BDD Scenarios
```gherkin
Feature: Session Locked

  Scenario: Display locked reason
    Given the session is locked
    When the screen appears
    Then the lock reason is displayed

  Scenario: Unlock with PIN
    Given session is locked
    When the user enters PIN
    Then session is unlocked
```

### Testable Actions
- [x] Lock reason display
- [x] PIN entry
- [x] Unlock action

### Backend Dependencies
- None (FSM-driven)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 54. FSM/BiometricPromptView
**File:** `lib/features/fsm_states/views/biometric_prompt_view.dart`
**Status:** ACTIVE
**Route:** `/biometric-prompt`

### BDD Scenarios
```gherkin
Feature: Biometric Prompt

  Scenario: Request biometric
    Given biometric is required
    When the screen appears
    Then biometric prompt shows

  Scenario: Fallback to PIN
    Given biometric fails
    When the user taps "Use PIN"
    Then PIN entry is shown
```

### Testable Actions
- [x] Biometric prompt
- [x] PIN fallback
- [x] Cancel option

### Backend Dependencies
- Local biometric

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 55. FSM/OtpExpiredView
**File:** `lib/features/fsm_states/views/otp_expired_view.dart`
**Status:** ACTIVE
**Route:** `/otp-expired`

### BDD Scenarios
```gherkin
Feature: OTP Expired

  Scenario: Display expired message
    Given the OTP has expired
    When the screen appears
    Then expired message is shown

  Scenario: Request new OTP
    Given OTP is expired
    When the user taps "Get New OTP"
    Then they return to login
```

### Testable Actions
- [x] Expired message display
- [x] Get new OTP action
- [x] Contact support option

### Backend Dependencies
- None (FSM-driven)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 56. Settings/DevicesScreen
**File:** `lib/features/settings/views/devices_screen.dart`
**Status:** ACTIVE
**Route:** `/settings/devices`

### BDD Scenarios
```gherkin
Feature: Trusted Devices

  Scenario: Display devices
    Given the user has logged in from devices
    When the screen loads
    Then trusted devices are listed

  Scenario: Remove device
    Given devices are listed
    When the user removes a device
    Then that device is logged out
```

### Testable Actions
- [x] Devices list
- [x] Current device indicator
- [x] Remove device
- [x] Device details (last active, location)

### Backend Dependencies
- GET `/devices`
- DELETE `/devices/:id`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 57. Settings/SessionsScreen
**File:** `lib/features/settings/views/sessions_screen.dart`
**Status:** ACTIVE
**Route:** `/settings/sessions`

### BDD Scenarios
```gherkin
Feature: Active Sessions

  Scenario: Display sessions
    Given the user has active sessions
    When the screen loads
    Then sessions are listed with details

  Scenario: End session
    Given sessions are listed
    When the user ends a session
    Then that session is terminated
```

### Testable Actions
- [x] Sessions list
- [x] Current session indicator
- [x] End session
- [x] End all other sessions

### Backend Dependencies
- GET `/sessions`
- DELETE `/sessions/:id`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 58. Settings/LanguageView
**File:** `lib/features/settings/views/language_view.dart`
**Status:** ACTIVE
**Route:** `/settings/language`

### BDD Scenarios
```gherkin
Feature: Language Selection

  Scenario: Display languages
    Given the user navigates to language
    When the screen loads
    Then available languages are listed

  Scenario: Change language
    Given languages are displayed
    When the user selects French
    Then the app language changes
```

### Testable Actions
- [x] Language list
- [x] Current language indicator
- [x] Language selection
- [x] Immediate app update

### Backend Dependencies
- None (local preference)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 59. Settings/CurrencyView
**File:** `lib/features/settings/views/currency_view.dart`
**Status:** ACTIVE
**Route:** `/settings/currency`

### BDD Scenarios
```gherkin
Feature: Currency Display Settings

  Scenario: Display options
    Given the user navigates to currency
    When the screen loads
    Then currency display options are shown

  Scenario: Enable reference currency
    Given USDC only is selected
    When the user enables reference
    Then they select a reference currency
```

### Testable Actions
- [x] Display mode selection
- [x] Reference currency selection
- [x] Preview of display

### Backend Dependencies
- None (local preference)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 60. Settings/ThemeSettingsView
**File:** `lib/features/settings/views/theme_settings_view.dart`
**Status:** ACTIVE
**Route:** `/settings/theme`

### BDD Scenarios
```gherkin
Feature: Theme Settings

  Scenario: Display theme options
    Given the user navigates to theme
    When the screen loads
    Then Light, Dark, System options are shown

  Scenario: Change theme
    Given themes are displayed
    When the user selects Dark
    Then the app theme changes immediately
```

### Testable Actions
- [x] Theme options display
- [x] Current theme indicator
- [x] Theme selection
- [x] Immediate theme change

### Backend Dependencies
- None (local preference)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## Progress Summary

### Screens Documented: 60 / 175+

### By Status:
- **ACTIVE:** 56
- **ACTIVE (Feature-flagged):** 4 (Cards, Savings Pots, Recurring, Withdraw)
- **DEAD_CODE:** 0 (none identified yet)
- **DEMO:** 0
- **DISABLED:** 0
- **PENDING_FEATURE:** 0

### Remaining Categories to Document:
- KYC flow screens (8 more)
- Send flow screens (2 more)
- Deposit flow screens (2 more)
- Bill payment screens (3 more)
- Card screens (4 more)
- Merchant screens (4 more)
- Onboarding screens (6 more)
- Help/Support screens
- Debug screens
- Additional FSM screens
- Widget Catalog (dev tool)

---

## Unrouted Screens Analysis

The following 43 screens are NOT directly imported in the router. Their status:

### FSM State Screens (Imported via index.dart, ACTIVE)
| Screen | Route | Status |
|--------|-------|--------|
| auth_locked_view | `/auth-locked` | ACTIVE |
| auth_suspended_view | `/auth-suspended` | ACTIVE |
| biometric_prompt_view | `/biometric-prompt` | ACTIVE |
| device_verification_view | `/device-verification` | ACTIVE |
| kyc_expired_view | `/kyc-expired` | ACTIVE |
| loading_view | `/loading` | ACTIVE |
| otp_expired_view | `/otp-expired` | ACTIVE |
| session_conflict_view | `/session-conflict` | ACTIVE |
| session_locked_view | `/session-locked` | ACTIVE |
| wallet_frozen_view | `/wallet-frozen` | ACTIVE |
| wallet_under_review_view | `/wallet-under-review` | ACTIVE |

### PIN Flow Screens (Used internally, ACTIVE)
| Screen | Status | Notes |
|--------|--------|-------|
| confirm_pin_view | ACTIVE | Used in PIN setup flow |
| enter_pin_view | ACTIVE | Used for PIN entry |
| pin_locked_view | ACTIVE | Shown when PIN locked |
| reset_pin_view | ACTIVE | PIN reset flow |
| set_pin_view | ACTIVE | Initial PIN setup |

### Onboarding/Help Guide Screens (ACTIVE)
| Screen | Status | Notes |
|--------|--------|-------|
| deposits_guide_view | ACTIVE | Help guide |
| fees_transparency_view | ACTIVE | Help guide |
| usdc_explainer_view | ACTIVE | Help guide |
| enhanced_onboarding_view | ACTIVE | Alternative onboarding |
| kyc_prompt_view | ACTIVE | KYC nudge |
| onboarding_pin_view | ACTIVE | PIN during onboarding |
| onboarding_success_view | ACTIVE | Onboarding complete |
| phone_input_view | ACTIVE | Phone entry in onboarding |
| profile_setup_view | ACTIVE | Profile during onboarding |
| otp_verification_view | ACTIVE | OTP in onboarding |
| welcome_post_login_view | ACTIVE | Post-login welcome |
| welcome_view | ACTIVE | Initial welcome |

### Internal/Dialog Screens (ACTIVE - used via showSheet/showDialog)
| Screen | Status | Notes |
|--------|--------|-------|
| contacts_list_screen | ACTIVE | Contact picker |
| contacts_permission_screen | ACTIVE | Permission request |
| offline_queue_dialog | ACTIVE | Offline queue dialog |
| payment_confirm_view | ACTIVE | Merchant payment confirm sheet |
| share_receipt_sheet | ACTIVE | Receipt sharing sheet |
| receive_qr_screen | ACTIVE | QR code display |
| scan_qr_screen | ACTIVE | QR scanner |

### DEAD_CODE / Deprecated Screens
| Screen | Status | Notes |
|--------|--------|-------|
| home_view | DEAD_CODE | Older version, replaced by wallet_home_screen |
| send_view | DEAD_CODE | Older version, replaced by send/recipient_screen |
| pending_transfers_view | DEAD_CODE | Duplicate of pending_transfers_screen |
| login_phone_view | DEAD_CODE | Older login, replaced by login_view |

### DEMO / Debug Screens
| Screen | Status | Notes |
|--------|--------|-------|
| wallet_home_accessibility_example | DEMO | Accessibility example code |
| performance_monitor_view | DEBUG | Performance monitoring (dev only) |

---

## Summary Statistics

| Category | Count |
|----------|-------|
| **Total View Files** | 177 |
| **Routed in app_router.dart** | 132 |
| **FSM State Screens** | 11 |
| **Internal/Dialog Screens** | 7 |
| **PIN Flow Screens** | 5 |
| **Onboarding/Help Screens** | 12 |
| **DEAD_CODE Screens** | 4 |
| **DEMO/Debug Screens** | 2 |
| **Documented in Inventory** | 60 (Phase 1) |

### Feature Flag Protected Screens
- `/cards/*` - `virtualCards` flag
- `/savings-pots/*` - `savingsPots` flag
- `/recurring-transfers/*` - `recurringTransfers` flag
- `/withdraw` - `withdraw` flag
- `/airtime` - `airtime` flag
- `/bills` - `bills` flag
- `/savings` - `savings` flag
- `/split` - `splitBills` flag
- `/budget` - `budget` flag
- `/analytics` - `analytics` flag
- `/converter` - `currencyConverter` flag
- `/request` - `requestMoney` flag
- `/recipients` - `savedRecipients` flag

---

## Notes

### Routing Pattern
All routes are defined in `lib/router/app_router.dart` using GoRouter. Most screens follow the pattern:
- Feature flags guard access to non-MVP features
- FSM (Finite State Machine) controls navigation for auth/KYC flows
- ShellRoute wraps main tabs (Home, Cards, Transactions, Settings)

### Backend Dependencies
The app uses Riverpod providers to manage state. Backend calls are made via Dio client configured in `lib/services/api/api_client.dart`.

### Testing Strategy
1. **Golden Tests:** Visual regression tests for each screen
2. **Widget Tests:** Interaction tests for UI components
3. **Integration Tests:** End-to-end flow tests
4. **Backend Tests:** Real API calls where possible, mocks for unavailable endpoints

### Dead Code Recommendations
The following screens should be reviewed for removal:
1. `lib/features/wallet/views/home_view.dart` - Replace with wallet_home_screen
2. `lib/features/wallet/views/send_view.dart` - Replace with send/recipient_screen
3. `lib/features/wallet/views/pending_transfers_view.dart` - Consolidate with offline/pending_transfers_screen
4. `lib/features/auth/views/login_phone_view.dart` - Remove if login_view is the canonical version

---

## 61. Settings/HelpView
**File:** `lib/features/settings/views/help_view.dart`
**Status:** ACTIVE
**Route:** `/settings/help`

### BDD Scenarios
```gherkin
Feature: Help & FAQ

  Scenario: Display FAQ categories
    Given the user navigates to help
    When the screen loads
    Then FAQs are displayed with expandable items

  Scenario: Search FAQs
    Given FAQs are displayed
    When the user searches "deposit"
    Then matching FAQs are filtered

  Scenario: Expand FAQ item
    Given a FAQ item is visible
    When the user taps the question
    Then the answer expands below

  Scenario: Contact support
    Given the user needs more help
    When they tap "Contact Support"
    Then support options (email, chat, phone) are shown
```

### Testable Actions
- [x] FAQ list display
- [x] Category filtering
- [x] Search functionality
- [x] Expand/collapse answers
- [x] Contact support buttons
- [x] Launch email/phone/chat

### Backend Dependencies
- None (static FAQs, local)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 62. Settings/NotificationSettingsView
**File:** `lib/features/settings/views/notification_settings_view.dart`
**Status:** ACTIVE
**Route:** `/settings/notifications`

### BDD Scenarios
```gherkin
Feature: Notification Settings

  Scenario: Display notification preferences
    Given the user navigates to notification settings
    When the screen loads
    Then notification toggles are displayed by category

  Scenario: Toggle push notifications
    Given notifications are displayed
    When the user toggles "Push Notifications"
    Then the preference is saved

  Scenario: Configure transaction alerts
    Given settings are displayed
    When the user enables transaction alerts
    Then they receive notifications for transactions

  Scenario: Save changes
    Given changes are made
    When the user navigates back
    Then changes are saved automatically
```

### Testable Actions
- [x] Preferences loading
- [x] Toggle switches for each category
- [x] Auto-save on change
- [x] Unsaved changes warning
- [x] Reset to defaults

### Backend Dependencies
- GET `/notifications/preferences`
- PUT `/notifications/preferences`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 63. Settings/ChangePinView
**File:** `lib/features/settings/views/change_pin_view.dart`
**Status:** ACTIVE
**Route:** `/settings/pin`

### BDD Scenarios
```gherkin
Feature: Change PIN

  Scenario: Enter current PIN
    Given the user wants to change PIN
    When they enter current 6-digit PIN
    Then they proceed to new PIN entry

  Scenario: Set new PIN
    Given current PIN is verified
    When the user enters new 6-digit PIN
    Then they proceed to confirmation

  Scenario: Confirm new PIN
    Given new PIN is entered
    When the user confirms with matching PIN
    Then PIN is updated successfully

  Scenario: PIN mismatch
    Given new PIN is entered
    When confirmation doesn't match
    Then an error is shown
    And user returns to new PIN step

  Scenario: Incorrect current PIN
    Given the user enters wrong current PIN
    When verification fails
    Then remaining attempts are shown
```

### Testable Actions
- [x] Current PIN entry
- [x] New PIN entry
- [x] Confirmation entry
- [x] PIN validation
- [x] Step navigation
- [x] Error handling
- [x] Success feedback

### Backend Dependencies
- POST `/auth/verify-pin` (current)
- PUT `/auth/pin` (update)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 64. Settings/CookiePolicyView
**File:** `lib/features/settings/views/cookie_policy_view.dart`
**Status:** ACTIVE
**Route:** `/settings/legal/cookies`

### BDD Scenarios
```gherkin
Feature: Cookie Policy

  Scenario: Display policy
    Given the user navigates to cookie policy
    When the screen loads
    Then the cookie policy text is displayed

  Scenario: Scroll through content
    Given the policy is displayed
    When the user scrolls
    Then more content becomes visible
```

### Testable Actions
- [x] Policy text display
- [x] Scrollable content
- [x] Back navigation

### Backend Dependencies
- None (static content)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 65. Deposit/PaymentInstructionsScreen
**File:** `lib/features/deposit/views/payment_instructions_screen.dart`
**Status:** ACTIVE
**Route:** `/deposit/instructions`

### BDD Scenarios
```gherkin
Feature: Deposit Payment Instructions

  Scenario: Display USSD code
    Given the user selected Orange Money
    When instructions load
    Then the USSD code is displayed
    And a countdown timer shows remaining time

  Scenario: Copy USSD code
    Given the USSD code is displayed
    When the user taps copy
    Then the code is copied to clipboard

  Scenario: Open dialer
    Given the USSD code is displayed
    When the user taps "Dial"
    Then the phone dialer opens with the code

  Scenario: Status polling
    Given instructions are displayed
    When the deposit completes
    Then user is navigated to status screen

  Scenario: Expiry countdown
    Given timer is active
    When it reaches zero
    Then deposit expires
    And user is prompted to retry
```

### Testable Actions
- [x] USSD code display
- [x] Copy to clipboard
- [x] Open dialer
- [x] Countdown timer
- [x] Status polling
- [x] Expiry handling
- [x] Navigate to status

### Backend Dependencies
- GET `/deposits/:id/status` (polling)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 66. KYC/KycPersonalInfoView
**File:** `lib/features/kyc/views/kyc_personal_info_view.dart`
**Status:** ACTIVE
**Route:** `/kyc/personal-info`

### BDD Scenarios
```gherkin
Feature: KYC Personal Information

  Scenario: Enter personal details
    Given the user is on personal info step
    When they fill first name, last name, DOB
    Then the Continue button becomes enabled

  Scenario: Select date of birth
    Given the DOB field is tapped
    When a date picker appears
    Then the user can select their birth date

  Scenario: Age validation
    Given the user selects a date
    When the user is under 18
    Then an error message is shown

  Scenario: Proceed to next step
    Given all fields are valid
    When the user taps Continue
    Then they proceed to document capture
```

### Testable Actions
- [x] First name input
- [x] Last name input
- [x] Date of birth picker
- [x] Age validation (18+)
- [x] Form validation
- [x] Continue navigation

### Backend Dependencies
- None (stored in KYC provider state)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 67. KYC/KycLivenessView
**File:** `lib/features/kyc/views/kyc_liveness_view.dart`
**Status:** ACTIVE
**Route:** `/kyc/liveness`

### BDD Scenarios
```gherkin
Feature: KYC Liveness Check

  Scenario: Display liveness instructions
    Given the user is on liveness step
    When the screen loads
    Then instructions to move head are shown

  Scenario: Complete liveness check
    Given the camera is active
    When the user follows head movement prompts
    Then liveness is verified

  Scenario: Liveness failed
    Given the check fails
    When verification completes
    Then an error is shown
    And the user can retry
```

### Testable Actions
- [x] Camera preview
- [x] Head movement prompts
- [x] Progress indicators
- [x] Success/failure feedback
- [x] Retry option
- [x] Navigate to next step

### Backend Dependencies
- Liveness detection (local ML or API)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 68. KYC/KycUpgradeView
**File:** `lib/features/kyc/views/kyc_upgrade_view.dart`
**Status:** ACTIVE
**Route:** `/kyc/upgrade`

### BDD Scenarios
```gherkin
Feature: KYC Tier Upgrade

  Scenario: Display upgrade options
    Given the user wants higher limits
    When the upgrade screen loads
    Then available tiers and benefits are shown

  Scenario: Select upgrade tier
    Given tiers are displayed
    When the user selects Premium
    Then they proceed to additional requirements

  Scenario: Show current tier
    Given the user is on upgrade screen
    When they view current status
    Then their current tier and limits are displayed
```

### Testable Actions
- [x] Tier comparison display
- [x] Benefits list
- [x] Current tier indicator
- [x] Upgrade button
- [x] Navigate to additional docs

### Backend Dependencies
- GET `/kyc/tiers`
- GET `/kyc/status`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 69. KYC/KycVideoView
**File:** `lib/features/kyc/views/kyc_video_view.dart`
**Status:** ACTIVE
**Route:** `/kyc/video`

### BDD Scenarios
```gherkin
Feature: KYC Video Verification

  Scenario: Record verification video
    Given the user is on video step
    When they record themselves holding ID
    Then the video is captured

  Scenario: Play back video
    Given a video is recorded
    When the user taps play
    Then the video plays for review

  Scenario: Retake video
    Given the video is recorded
    When the user taps retake
    Then the camera reopens
```

### Testable Actions
- [x] Video recording
- [x] Playback preview
- [x] Retake option
- [x] Submit video
- [x] Progress indicator

### Backend Dependencies
- Video upload (KYC submission)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 70. KYC/KycAddressView
**File:** `lib/features/kyc/views/kyc_address_view.dart`
**Status:** ACTIVE
**Route:** `/kyc/address`

### BDD Scenarios
```gherkin
Feature: KYC Address Verification

  Scenario: Enter address
    Given the user is on address step
    When they enter street, city, postal code
    Then the form validates the input

  Scenario: Upload proof of address
    Given address is entered
    When the user uploads a document
    Then the document is stored for review
```

### Testable Actions
- [x] Address form fields
- [x] Country selection
- [x] Document upload
- [x] Form validation
- [x] Continue navigation

### Backend Dependencies
- None (stored in KYC provider)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 71. KYC/KycAdditionalDocsView
**File:** `lib/features/kyc/views/kyc_additional_docs_view.dart`
**Status:** ACTIVE
**Route:** `/kyc/additional-docs`

### BDD Scenarios
```gherkin
Feature: KYC Additional Documents

  Scenario: Display required documents
    Given the user needs additional docs
    When the screen loads
    Then required document types are listed

  Scenario: Upload document
    Given a document type is selected
    When the user captures/uploads
    Then the document is added to the list

  Scenario: Remove document
    Given a document is uploaded
    When the user taps remove
    Then the document is removed
```

### Testable Actions
- [x] Document list display
- [x] Document type selection
- [x] Camera capture
- [x] Gallery upload
- [x] Remove document
- [x] Submit all documents

### Backend Dependencies
- Document upload to S3/storage

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 72. KYC/SubmittedView
**File:** `lib/features/kyc/views/submitted_view.dart`
**Status:** ACTIVE
**Route:** `/kyc/submitted`

### BDD Scenarios
```gherkin
Feature: KYC Submitted

  Scenario: Display submission confirmation
    Given KYC documents are submitted
    When the screen loads
    Then a success animation plays
    And estimated review time is shown

  Scenario: Return to home
    Given submission is confirmed
    When the user taps "Go to Home"
    Then they navigate to the home screen
```

### Testable Actions
- [x] Success animation
- [x] Confirmation message
- [x] Estimated review time
- [x] Go to Home button

### Backend Dependencies
- None (confirmation screen)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 73. BillPayments/BillPaymentFormView
**File:** `lib/features/bill_payments/views/bill_payment_form_view.dart`
**Status:** ACTIVE
**Route:** Internal (from provider selection)

### BDD Scenarios
```gherkin
Feature: Bill Payment Form

  Scenario: Enter account number
    Given the user selected a provider
    When they enter account/meter number
    Then the account is validated

  Scenario: Account validation success
    Given a valid account is entered
    When validation completes
    Then account holder name is displayed

  Scenario: Enter payment amount
    Given account is validated
    When the user enters amount
    Then they can proceed to confirm

  Scenario: Validation failure
    Given an invalid account is entered
    When validation fails
    Then an error message is shown
```

### Testable Actions
- [x] Account number input
- [x] Account validation
- [x] Account holder display
- [x] Amount input
- [x] Balance check
- [x] Proceed to confirmation

### Backend Dependencies
- POST `/bill-payments/validate-account`
- GET `/wallet` (balance check)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 74. BillPayments/BillPaymentHistoryView
**File:** `lib/features/bill_payments/views/bill_payment_history_view.dart`
**Status:** ACTIVE
**Route:** Internal (from bill payments)

### BDD Scenarios
```gherkin
Feature: Bill Payment History

  Scenario: Display payment history
    Given the user has paid bills
    When the history screen loads
    Then past payments are listed by date

  Scenario: Filter by provider
    Given history is displayed
    When the user filters by "Orange"
    Then only Orange payments are shown

  Scenario: Repeat payment
    Given a past payment is visible
    When the user taps "Pay Again"
    Then the form is pre-filled
```

### Testable Actions
- [x] History list display
- [x] Date grouping
- [x] Provider filtering
- [x] Repeat payment
- [x] View receipt
- [x] Pull to refresh

### Backend Dependencies
- GET `/bill-payments/history`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 75. BillPayments/BillPaymentSuccessView
**File:** `lib/features/bill_payments/views/bill_payment_success_view.dart`
**Status:** ACTIVE
**Route:** Internal (from form)

### BDD Scenarios
```gherkin
Feature: Bill Payment Success

  Scenario: Display success
    Given the bill payment completed
    When the success screen loads
    Then success animation plays
    And payment details are shown

  Scenario: Share receipt
    Given success is displayed
    When the user taps "Share Receipt"
    Then a share sheet opens

  Scenario: Return to bills
    Given success is displayed
    When the user taps "Done"
    Then they return to bill payments home
```

### Testable Actions
- [x] Success animation
- [x] Payment details display
- [x] Share receipt
- [x] Done button
- [x] Make another payment

### Backend Dependencies
- None (uses passed state)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 76. Cards/CardDetailView
**File:** `lib/features/cards/views/card_detail_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/cards/detail/:id`

### BDD Scenarios
```gherkin
Feature: Card Details

  Scenario: Display card details
    Given the user taps a card
    When the detail screen loads
    Then card number, expiry, CVV are shown

  Scenario: Reveal CVV
    Given CVV is hidden
    When the user taps "Show CVV"
    Then CVV is revealed for 30 seconds

  Scenario: Copy card number
    Given card number is displayed
    When the user taps copy
    Then the number is copied to clipboard

  Scenario: Navigate to settings
    Given the detail is displayed
    When the user taps settings icon
    Then they navigate to card settings
```

### Testable Actions
- [x] Card visualization
- [x] CVV reveal/hide with timer
- [x] Copy card number
- [x] Copy expiry
- [x] Copy CVV
- [x] Navigate to settings
- [x] View transactions

### Backend Dependencies
- GET `/cards/:id`
- Feature flag: `virtualCards`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 77. Cards/CardSettingsView
**File:** `lib/features/cards/views/card_settings_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/cards/settings/:id`

### BDD Scenarios
```gherkin
Feature: Card Settings

  Scenario: Freeze/unfreeze card
    Given the card settings are displayed
    When the user toggles "Freeze Card"
    Then the card is frozen/unfrozen

  Scenario: Set spending limit
    Given settings are displayed
    When the user sets a daily limit
    Then the limit is applied

  Scenario: Cancel card
    Given the user taps "Cancel Card"
    When they confirm in the dialog
    Then the card is cancelled permanently
```

### Testable Actions
- [x] Freeze toggle
- [x] Spending limit slider
- [x] Transaction notifications toggle
- [x] Cancel card with confirmation
- [x] Rename card

### Backend Dependencies
- PUT `/cards/:id/settings`
- DELETE `/cards/:id`
- Feature flag: `virtualCards`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 78. Cards/CardTransactionsView
**File:** `lib/features/cards/views/card_transactions_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/cards/transactions/:id`

### BDD Scenarios
```gherkin
Feature: Card Transactions

  Scenario: Display card transactions
    Given the user views card transactions
    When the screen loads
    Then transactions for that card are listed

  Scenario: Filter transactions
    Given transactions are displayed
    When the user applies date filter
    Then only matching transactions show

  Scenario: Dispute transaction
    Given a transaction is displayed
    When the user taps "Dispute"
    Then a dispute form opens
```

### Testable Actions
- [x] Transaction list
- [x] Date filtering
- [x] Search
- [x] Transaction detail navigation
- [x] Dispute option
- [x] Export transactions

### Backend Dependencies
- GET `/cards/:id/transactions`
- Feature flag: `virtualCards`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 79. Cards/RequestCardView
**File:** `lib/features/cards/views/request_card_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/cards/request`

### BDD Scenarios
```gherkin
Feature: Request Virtual Card

  Scenario: View card options
    Given the user requests a new card
    When the screen loads
    Then available card types are shown

  Scenario: Select card design
    Given card types are shown
    When the user selects a design
    Then they proceed to confirmation

  Scenario: Confirm card creation
    Given a design is selected
    When the user confirms
    Then the card is created
    And they see the new card
```

### Testable Actions
- [x] Card type selection
- [x] Design preview
- [x] Terms acceptance
- [x] Create card button
- [x] Success navigation

### Backend Dependencies
- POST `/cards`
- GET `/cards/types`
- Feature flag: `virtualCards`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 80. MerchantPay/MerchantDashboardView
**File:** `lib/features/merchant_pay/views/merchant_dashboard_view.dart`
**Status:** ACTIVE
**Route:** `/merchant-dashboard`

### BDD Scenarios
```gherkin
Feature: Merchant Dashboard

  Scenario: Display dashboard stats
    Given the user is a merchant
    When the dashboard loads
    Then sales summary, charts are displayed

  Scenario: Change period
    Given dashboard is displayed
    When the user selects "This Week"
    Then stats update for that period

  Scenario: Navigate to transactions
    Given dashboard is displayed
    When the user taps "View All Transactions"
    Then they navigate to merchant transactions

  Scenario: Not a merchant
    Given the user is not a merchant
    When they access the dashboard
    Then a "Become a Merchant" prompt is shown
```

### Testable Actions
- [x] Stats cards display
- [x] Period selector
- [x] Sales chart
- [x] Recent transactions preview
- [x] Navigate to transactions
- [x] Navigate to QR code
- [x] Merchant setup prompt

### Backend Dependencies
- GET `/merchant/profile`
- GET `/merchant/stats`
- GET `/merchant/transactions`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## Progress Report: 80 / 175+ screens documented

---

## 81. MerchantPay/MerchantQRView
**File:** `lib/features/merchant_pay/views/merchant_qr_view.dart`
**Status:** ACTIVE
**Route:** Internal (from dashboard)

### BDD Scenarios
```gherkin
Feature: Merchant QR Code

  Scenario: Display merchant QR
    Given the user is a merchant
    When the QR screen loads
    Then their payment QR code is displayed

  Scenario: Set amount
    Given the QR is displayed
    When the merchant enters an amount
    Then the QR updates with the amount

  Scenario: Share QR
    Given the QR is displayed
    When the merchant taps share
    Then the QR image is shared

  Scenario: Print QR
    Given the QR is displayed
    When the merchant taps print
    Then print dialog opens
```

### Testable Actions
- [x] QR code display
- [x] Amount input
- [x] QR regeneration
- [x] Share functionality
- [x] Save to gallery
- [x] Print option

### Backend Dependencies
- Merchant ID (from profile)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 82. MerchantPay/CreatePaymentRequestView
**File:** `lib/features/merchant_pay/views/create_payment_request_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Create Payment Request

  Scenario: Enter payment details
    Given the merchant wants to request payment
    When they enter amount and description
    Then a payment request is created

  Scenario: Generate payment link
    Given details are entered
    When the merchant confirms
    Then a payment link is generated
    And a QR code is shown
```

### Testable Actions
- [x] Amount input
- [x] Description input
- [x] Customer reference field
- [x] Generate request
- [x] Share link/QR

### Backend Dependencies
- POST `/merchant/payment-requests`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 83. MerchantPay/PaymentReceiptView
**File:** `lib/features/merchant_pay/views/payment_receipt_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Merchant Payment Receipt

  Scenario: Display receipt
    Given a payment was received
    When the receipt screen loads
    Then payment details are shown

  Scenario: Share receipt
    Given the receipt is displayed
    When the merchant taps share
    Then the receipt is shared

  Scenario: Print receipt
    Given the receipt is displayed
    When the merchant taps print
    Then print dialog opens
```

### Testable Actions
- [x] Receipt details display
- [x] Amount, date, customer info
- [x] Share receipt
- [x] Print receipt
- [x] Return to dashboard

### Backend Dependencies
- None (uses passed transaction)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 84. MerchantPay/MerchantTransactionsView
**File:** `lib/features/merchant_pay/views/merchant_transactions_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Merchant Transactions

  Scenario: Display merchant transactions
    Given the merchant has received payments
    When the screen loads
    Then transactions are listed

  Scenario: Filter by date
    Given transactions are displayed
    When the merchant filters by date range
    Then matching transactions are shown

  Scenario: Export transactions
    Given transactions are displayed
    When the merchant taps export
    Then a CSV/PDF is generated
```

### Testable Actions
- [x] Transaction list
- [x] Date range filter
- [x] Search
- [x] Export CSV/PDF
- [x] View transaction detail
- [x] Pull to refresh

### Backend Dependencies
- GET `/merchant/transactions`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 85. MerchantPay/PaymentConfirmView
**File:** `lib/features/merchant_pay/views/payment_confirm_view.dart`
**Status:** ACTIVE
**Route:** Internal (sheet from scan)

### BDD Scenarios
```gherkin
Feature: Merchant Payment Confirmation

  Scenario: Confirm payment details
    Given a merchant QR was scanned
    When the confirm sheet appears
    Then merchant name and amount are shown

  Scenario: Proceed to PIN
    Given details are confirmed
    When the user taps "Pay"
    Then they proceed to PIN verification

  Scenario: Cancel payment
    Given the confirm sheet is shown
    When the user taps cancel
    Then the sheet closes
```

### Testable Actions
- [x] Merchant info display
- [x] Amount display
- [x] Pay button
- [x] Cancel button
- [x] Edit amount (if allowed)

### Backend Dependencies
- POST `/merchant/decode-qr`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 86. BankLinking/BankSelectionView
**File:** `lib/features/bank_linking/views/bank_selection_view.dart`
**Status:** ACTIVE
**Route:** Internal (from linked accounts)

### BDD Scenarios
```gherkin
Feature: Bank Selection

  Scenario: Display available banks
    Given the user wants to link a bank
    When the selection screen loads
    Then available banks are listed

  Scenario: Search banks
    Given banks are displayed
    When the user searches "Ecobank"
    Then matching banks are filtered

  Scenario: Select bank
    Given a bank is visible
    When the user taps it
    Then they proceed to verification
```

### Testable Actions
- [x] Bank list display
- [x] Bank logos
- [x] Search functionality
- [x] Bank selection
- [x] Popular banks section

### Backend Dependencies
- GET `/bank-linking/banks`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 87. BankLinking/BankVerificationView
**File:** `lib/features/bank_linking/views/bank_verification_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Bank Account Verification

  Scenario: Enter account details
    Given a bank is selected
    When the user enters account number
    Then the account is verified

  Scenario: Verification success
    Given details are correct
    When verification completes
    Then account holder name is shown
    And the account is linked

  Scenario: Verification failure
    Given details are incorrect
    When verification fails
    Then an error message is shown
```

### Testable Actions
- [x] Account number input
- [x] Verification loading
- [x] Success confirmation
- [x] Error handling
- [x] Retry option

### Backend Dependencies
- POST `/bank-linking/verify`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 88. BankLinking/BankTransferView
**File:** `lib/features/bank_linking/views/bank_transfer_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Bank Transfer

  Scenario: Enter transfer amount
    Given the user has a linked bank
    When they enter an amount
    Then fees are calculated

  Scenario: Confirm transfer
    Given amount and bank are set
    When the user confirms
    Then they proceed to PIN verification

  Scenario: Transfer success
    Given PIN is verified
    When transfer completes
    Then success screen is shown
```

### Testable Actions
- [x] Amount input
- [x] Bank account selection
- [x] Fee calculation
- [x] Confirm transfer
- [x] PIN verification
- [x] Success/failure handling

### Backend Dependencies
- POST `/bank-linking/transfer`
- GET `/bank-linking/fees`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 89. BankLinking/LinkBankView
**File:** `lib/features/bank_linking/views/link_bank_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Link Bank Account

  Scenario: Start linking flow
    Given the user wants to link a bank
    When the screen loads
    Then instructions are displayed

  Scenario: Complete linking
    Given instructions are shown
    When the user provides bank details
    Then the account is linked
```

### Testable Actions
- [x] Instructions display
- [x] Start linking button
- [x] Progress indicator
- [x] Success confirmation

### Backend Dependencies
- Bank linking flow

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 90. PaymentLinks/CreateLinkView
**File:** `lib/features/payment_links/views/create_link_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Create Payment Link

  Scenario: Enter link details
    Given the user wants to create a link
    When they enter amount and description
    Then the form validates

  Scenario: Set expiry
    Given details are entered
    When the user selects expiry (24h, 7d, etc.)
    Then expiry is set

  Scenario: Create link
    Given all details are valid
    When the user taps create
    Then the link is generated
    And they see the created link screen
```

### Testable Actions
- [x] Amount input
- [x] Description input
- [x] Expiry selection
- [x] Create button
- [x] Form validation
- [x] Navigate to link created

### Backend Dependencies
- POST `/payment-links`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

---

## 91. PaymentLinks/LinkDetailView
**File:** `lib/features/payment_links/views/link_detail_view.dart`
**Status:** ACTIVE
**Route:** Internal (from list)

### BDD Scenarios
```gherkin
Feature: Payment Link Details

  Scenario: Display link details
    Given the user created a payment link
    When they tap on the link
    Then link details and QR code are shown

  Scenario: View payments received
    Given the link has received payments
    When the detail loads
    Then payments are listed below

  Scenario: Deactivate link
    Given the link is active
    When the user taps "Deactivate"
    Then the link is deactivated
```

### Testable Actions
- [x] Link details display
- [x] QR code display
- [x] Share link
- [x] Copy link URL
- [x] View payments
- [x] Deactivate link
- [x] Refresh status

### Backend Dependencies
- GET `/payment-links/:id`
- PUT `/payment-links/:id/deactivate`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 92. PaymentLinks/LinkCreatedView
**File:** `lib/features/payment_links/views/link_created_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Link Created Confirmation

  Scenario: Display created link
    Given a payment link was created
    When the success screen loads
    Then link URL and QR code are displayed

  Scenario: Share link
    Given the link is displayed
    When the user taps share
    Then share options appear

  Scenario: Copy link
    Given the link is displayed
    When the user taps copy
    Then the URL is copied to clipboard
```

### Testable Actions
- [x] Success animation
- [x] Link URL display
- [x] QR code display
- [x] Share button
- [x] Copy button
- [x] Done button

### Backend Dependencies
- None (uses passed link data)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 93. PaymentLinks/PayLinkView
**File:** `lib/features/payment_links/views/pay_link_view.dart`
**Status:** ACTIVE
**Route:** Deep link handler

### BDD Scenarios
```gherkin
Feature: Pay via Payment Link

  Scenario: Open payment link
    Given the user opens a payment link
    When the screen loads
    Then merchant/requester info and amount are shown

  Scenario: Complete payment
    Given the payment details are shown
    When the user taps "Pay"
    Then they proceed to PIN verification

  Scenario: Expired link
    Given the link has expired
    When the screen loads
    Then an expired message is shown
```

### Testable Actions
- [x] Link details display
- [x] Amount display
- [x] Pay button
- [x] Expired state handling
- [x] Cancel option

### Backend Dependencies
- GET `/payment-links/public/:code`
- POST `/payment-links/:id/pay`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 94. BulkPayments/BulkUploadView
**File:** `lib/features/bulk_payments/views/bulk_upload_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Bulk Payment CSV Upload

  Scenario: Display upload instructions
    Given the user opens bulk upload
    When the screen loads
    Then CSV format instructions are shown

  Scenario: Upload CSV file
    Given instructions are displayed
    When the user taps "Upload"
    Then file picker opens

  Scenario: Parse CSV
    Given a CSV is selected
    When parsing completes
    Then preview shows recipients and amounts

  Scenario: Download template
    Given instructions are displayed
    When the user taps "Download Template"
    Then a sample CSV is downloaded
```

### Testable Actions
- [x] Instructions display
- [x] Upload button
- [x] File picker
- [x] CSV parsing
- [x] Error handling
- [x] Download template
- [x] Navigate to preview

### Backend Dependencies
- POST `/bulk-payments/parse`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 95. BulkPayments/BulkPreviewView
**File:** `lib/features/bulk_payments/views/bulk_preview_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Bulk Payment Preview

  Scenario: Display recipients
    Given CSV was parsed
    When the preview loads
    Then all recipients and amounts are listed

  Scenario: Edit recipient
    Given recipients are listed
    When the user taps a recipient
    Then they can edit the amount

  Scenario: Remove recipient
    Given recipients are listed
    When the user removes one
    Then it's removed from the batch

  Scenario: Confirm batch
    Given all recipients are valid
    When the user taps "Confirm"
    Then they proceed to PIN verification
```

### Testable Actions
- [x] Recipients list display
- [x] Total amount display
- [x] Edit recipient
- [x] Remove recipient
- [x] Validate all
- [x] Confirm batch
- [x] Cancel batch

### Backend Dependencies
- POST `/bulk-payments/validate`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 96. BulkPayments/BulkStatusView
**File:** `lib/features/bulk_payments/views/bulk_status_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Bulk Payment Status

  Scenario: Display batch status
    Given a batch is processing
    When the status screen loads
    Then progress and individual statuses are shown

  Scenario: Completed batch
    Given all payments complete
    When status updates
    Then success summary is displayed

  Scenario: Partial failure
    Given some payments failed
    When status updates
    Then failed payments are highlighted
    And retry option is shown
```

### Testable Actions
- [x] Batch progress display
- [x] Individual payment status
- [x] Auto-refresh
- [x] Retry failed payments
- [x] Download report
- [x] Return to list

### Backend Dependencies
- GET `/bulk-payments/:batchId/status`
- POST `/bulk-payments/:batchId/retry`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 97. FSM/SessionConflictView
**File:** `lib/features/fsm_states/views/session_conflict_view.dart`
**Status:** ACTIVE
**Route:** `/session-conflict`

### BDD Scenarios
```gherkin
Feature: Session Conflict

  Scenario: Display conflict warning
    Given the user is logged in on another device
    When this screen appears
    Then conflict message and device info are shown

  Scenario: Continue here
    Given conflict is displayed
    When the user taps "Continue Here"
    Then other sessions are logged out

  Scenario: Logout
    Given conflict is displayed
    When the user taps "Logout"
    Then they are logged out
```

### Testable Actions
- [x] Conflict message display
- [x] Device info display
- [x] Continue here button
- [x] Logout button
- [x] Loading state

### Backend Dependencies
- POST `/auth/resolve-conflict`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 98. FSM/DeviceVerificationView
**File:** `lib/features/fsm_states/views/device_verification_view.dart`
**Status:** ACTIVE
**Route:** `/device-verification`

### BDD Scenarios
```gherkin
Feature: Device Verification

  Scenario: Display verification request
    Given a new device needs verification
    When the screen appears
    Then verification code entry is shown

  Scenario: Enter verification code
    Given the code was sent to email/phone
    When the user enters the code
    Then the device is verified

  Scenario: Resend code
    Given the timer expired
    When the user taps resend
    Then a new code is sent
```

### Testable Actions
- [x] Verification code input
- [x] Auto-submit on complete
- [x] Resend code with timer
- [x] Device info display
- [x] Cancel option

### Backend Dependencies
- POST `/auth/verify-device`
- POST `/auth/resend-device-code`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 99. FSM/WalletUnderReviewView
**File:** `lib/features/fsm_states/views/wallet_under_review_view.dart`
**Status:** ACTIVE
**Route:** `/wallet-under-review`

### BDD Scenarios
```gherkin
Feature: Wallet Under Review

  Scenario: Display review status
    Given the wallet is under compliance review
    When the screen appears
    Then review message and timeline are shown

  Scenario: Contact support
    Given the wallet is under review
    When the user taps support
    Then support options are shown
```

### Testable Actions
- [x] Review message display
- [x] Timeline/estimated wait
- [x] Contact support button
- [x] Refresh status

### Backend Dependencies
- None (FSM state driven)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 100. FSM/AuthSuspendedView
**File:** `lib/features/fsm_states/views/auth_suspended_view.dart`
**Status:** ACTIVE
**Route:** `/auth-suspended`

### BDD Scenarios
```gherkin
Feature: Auth Suspended

  Scenario: Display suspension message
    Given the account is suspended
    When the screen appears
    Then suspension reason is displayed

  Scenario: Appeal suspension
    Given suspension is shown
    When the user taps "Appeal"
    Then support ticket form opens
```

### Testable Actions
- [x] Suspension message display
- [x] Reason display
- [x] Appeal button
- [x] Contact support
- [x] Logout option

### Backend Dependencies
- None (FSM state driven)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 101. FSM/KycExpiredView
**File:** `lib/features/fsm_states/views/kyc_expired_view.dart`
**Status:** ACTIVE
**Route:** `/kyc-expired`

### BDD Scenarios
```gherkin
Feature: KYC Expired

  Scenario: Display expiry message
    Given KYC documents have expired
    When the screen appears
    Then expiry message and renewal prompt are shown

  Scenario: Renew KYC
    Given the expiry is shown
    When the user taps "Renew"
    Then they start the KYC flow
```

### Testable Actions
- [x] Expiry message display
- [x] Renewal button
- [x] Continue with limits option
- [x] Contact support

### Backend Dependencies
- None (FSM state driven)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 102. FSM/LoadingView
**File:** `lib/features/fsm_states/views/loading_view.dart`
**Status:** ACTIVE
**Route:** `/loading`

### BDD Scenarios
```gherkin
Feature: App Loading State

  Scenario: Display loading indicator
    Given the app is initializing
    When the loading screen appears
    Then a loading animation is displayed

  Scenario: Transition to next state
    Given loading completes
    When the FSM transitions
    Then the appropriate screen is shown
```

### Testable Actions
- [x] Loading animation display
- [x] Logo display
- [x] Progress indicator

### Backend Dependencies
- None (transition screen)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 103. Onboarding/PhoneInputView
**File:** `lib/features/onboarding/views/phone_input_view.dart`
**Status:** ACTIVE
**Route:** Part of onboarding flow

### BDD Scenarios
```gherkin
Feature: Onboarding Phone Input

  Scenario: Enter phone number
    Given the user is registering
    When they enter their phone number
    Then validation runs

  Scenario: Select country code
    Given the phone input is displayed
    When the user taps the country selector
    Then a country picker appears

  Scenario: Accept terms
    Given phone is entered
    When the user accepts terms
    Then they can proceed

  Scenario: Proceed to OTP
    Given phone and terms are valid
    When the user taps Continue
    Then an OTP is sent
```

### Testable Actions
- [x] Phone number input
- [x] Country code selector
- [x] Terms checkbox
- [x] Terms/Privacy links
- [x] Continue button
- [x] Progress indicator

### Backend Dependencies
- POST `/auth/register`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 104. Onboarding/OtpVerificationView
**File:** `lib/features/onboarding/views/otp_verification_view.dart`
**Status:** ACTIVE
**Route:** Part of onboarding flow

### BDD Scenarios
```gherkin
Feature: Onboarding OTP Verification

  Scenario: Enter OTP
    Given OTP was sent
    When the user enters 6 digits
    Then the OTP is verified

  Scenario: Resend OTP
    Given timer has expired
    When the user taps resend
    Then a new OTP is sent

  Scenario: Proceed to PIN setup
    Given OTP is verified
    When verification completes
    Then user proceeds to PIN setup
```

### Testable Actions
- [x] OTP input
- [x] Auto-submit on complete
- [x] Resend with timer
- [x] Error handling
- [x] Progress indicator

### Backend Dependencies
- POST `/auth/verify-otp`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 105. Onboarding/OnboardingPinView
**File:** `lib/features/onboarding/views/onboarding_pin_view.dart`
**Status:** ACTIVE
**Route:** Part of onboarding flow

### BDD Scenarios
```gherkin
Feature: Onboarding PIN Setup

  Scenario: Set PIN
    Given OTP is verified
    When the user enters 6-digit PIN
    Then they proceed to confirmation

  Scenario: Confirm PIN
    Given PIN is entered
    When they confirm with matching PIN
    Then PIN is saved

  Scenario: PIN mismatch
    Given PIN is entered
    When confirmation doesn't match
    Then error is shown
```

### Testable Actions
- [x] PIN entry
- [x] Confirmation entry
- [x] Mismatch handling
- [x] Back navigation
- [x] Progress indicator

### Backend Dependencies
- POST `/auth/set-pin`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 106. Onboarding/ProfileSetupView
**File:** `lib/features/onboarding/views/profile_setup_view.dart`
**Status:** ACTIVE
**Route:** Part of onboarding flow

### BDD Scenarios
```gherkin
Feature: Onboarding Profile Setup

  Scenario: Enter name
    Given PIN is set
    When the user enters first and last name
    Then they can continue

  Scenario: Skip profile
    Given profile setup is shown
    When the user taps "Skip"
    Then they proceed without profile

  Scenario: Complete profile
    Given name is entered
    When the user taps Continue
    Then profile is saved
```

### Testable Actions
- [x] First name input
- [x] Last name input
- [x] Skip option
- [x] Continue button
- [x] Progress indicator

### Backend Dependencies
- PUT `/users/profile`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 107. Onboarding/WelcomeView
**File:** `lib/features/onboarding/views/welcome_view.dart`
**Status:** ACTIVE
**Route:** Part of onboarding flow

### BDD Scenarios
```gherkin
Feature: Welcome Screen

  Scenario: Display welcome
    Given the app is opened for the first time
    When the welcome screen loads
    Then JoonaPay branding and tagline are shown

  Scenario: Start registration
    Given the welcome is displayed
    When the user taps "Get Started"
    Then they proceed to phone input

  Scenario: Login option
    Given welcome is displayed
    When the user taps "Login"
    Then they go to login screen
```

### Testable Actions
- [x] Branding display
- [x] Get Started button
- [x] Login link
- [x] Animation/illustration

### Backend Dependencies
- None

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 108. Onboarding/OnboardingSuccessView
**File:** `lib/features/onboarding/views/onboarding_success_view.dart`
**Status:** ACTIVE
**Route:** Part of onboarding flow

### BDD Scenarios
```gherkin
Feature: Onboarding Success

  Scenario: Display success
    Given registration is complete
    When the success screen loads
    Then celebration animation plays

  Scenario: Go to home
    Given success is displayed
    When the user taps "Get Started"
    Then they navigate to home
```

### Testable Actions
- [x] Success animation
- [x] Personalized message
- [x] Get Started button

### Backend Dependencies
- None

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 109. Onboarding/WelcomePostLoginView
**File:** `lib/features/onboarding/views/welcome_post_login_view.dart`
**Status:** ACTIVE
**Route:** Shown after first login

### BDD Scenarios
```gherkin
Feature: Welcome After Login

  Scenario: Display tips
    Given the user logs in for the first time
    When the welcome screen appears
    Then tips and feature highlights are shown

  Scenario: Enable biometric
    Given welcome is displayed
    When the user enables biometric
    Then biometric is set up

  Scenario: Skip tips
    Given welcome is displayed
    When the user taps "Skip"
    Then they go to home
```

### Testable Actions
- [x] Tips display
- [x] Feature highlights
- [x] Biometric prompt
- [x] Skip button
- [x] Continue button

### Backend Dependencies
- None (local preference)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 110. Onboarding/KycPromptView
**File:** `lib/features/onboarding/views/kyc_prompt_view.dart`
**Status:** ACTIVE
**Route:** Part of onboarding flow

### BDD Scenarios
```gherkin
Feature: KYC Prompt

  Scenario: Display KYC benefits
    Given onboarding is near complete
    When the KYC prompt appears
    Then benefits of verification are shown

  Scenario: Start KYC
    Given benefits are displayed
    When the user taps "Verify Now"
    Then they start KYC flow

  Scenario: Skip KYC
    Given prompt is displayed
    When the user taps "Later"
    Then they proceed to home
```

### Testable Actions
- [x] Benefits list display
- [x] Tier limits comparison
- [x] Verify Now button
- [x] Later button

### Backend Dependencies
- None

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 111. Onboarding/EnhancedOnboardingView
**File:** `lib/features/onboarding/views/enhanced_onboarding_view.dart`
**Status:** ACTIVE
**Route:** `/onboarding` (alternate)

### BDD Scenarios
```gherkin
Feature: Enhanced Onboarding

  Scenario: Interactive tutorial
    Given the user starts enhanced onboarding
    When each step loads
    Then interactive demos are shown

  Scenario: Complete tutorial
    Given all steps are viewed
    When the user finishes
    Then they proceed to registration
```

### Testable Actions
- [x] Step navigation
- [x] Interactive elements
- [x] Skip option
- [x] Progress indicator
- [x] Animations

### Backend Dependencies
- None

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 112. OnboardingHelp/DepositsGuideView
**File:** `lib/features/onboarding/views/help/deposits_guide_view.dart`
**Status:** ACTIVE
**Route:** Internal (from help)

### BDD Scenarios
```gherkin
Feature: Deposits Guide

  Scenario: Display deposit methods
    Given the user opens deposit guide
    When the screen loads
    Then available deposit methods are explained

  Scenario: Navigate steps
    Given the guide is displayed
    When the user swipes
    Then next step is shown
```

### Testable Actions
- [x] Step-by-step guide
- [x] Illustrations
- [x] Navigation between steps
- [x] Done button

### Backend Dependencies
- None (static content)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 113. OnboardingHelp/FeesTransparencyView
**File:** `lib/features/onboarding/views/help/fees_transparency_view.dart`
**Status:** ACTIVE
**Route:** Internal (from help)

### BDD Scenarios
```gherkin
Feature: Fees Transparency

  Scenario: Display fee structure
    Given the user opens fees guide
    When the screen loads
    Then all fees are listed clearly

  Scenario: Compare to competitors
    Given fees are displayed
    When comparison section loads
    Then JoonaPay fees vs others are shown
```

### Testable Actions
- [x] Fee table display
- [x] Examples with calculations
- [x] Comparison section
- [x] Done button

### Backend Dependencies
- None (static content)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 114. OnboardingHelp/UsdcExplainerView
**File:** `lib/features/onboarding/views/help/usdc_explainer_view.dart`
**Status:** ACTIVE
**Route:** Internal (from help)

### BDD Scenarios
```gherkin
Feature: USDC Explainer

  Scenario: Explain USDC
    Given the user opens USDC guide
    When the screen loads
    Then USDC benefits are explained

  Scenario: Compare to local currency
    Given explanation is shown
    When stability section loads
    Then USDC vs XOF comparison is shown
```

### Testable Actions
- [x] USDC benefits list
- [x] Stability explanation
- [x] Visual comparisons
- [x] Done button

### Backend Dependencies
- None (static content)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 115. Expenses/AddExpenseView
**File:** `lib/features/expenses/views/add_expense_view.dart`
**Status:** ACTIVE
**Route:** Internal (from expenses)

### BDD Scenarios
```gherkin
Feature: Add Expense

  Scenario: Enter expense details
    Given the user wants to add an expense
    When they fill amount, category, vendor
    Then the expense can be saved

  Scenario: Select category
    Given expense form is displayed
    When the user taps category
    Then category options appear

  Scenario: Select date
    Given expense form is displayed
    When the user taps date
    Then date picker appears

  Scenario: Save expense
    Given all fields are filled
    When the user taps Save
    Then the expense is saved
```

### Testable Actions
- [x] Amount input
- [x] Category selection
- [x] Vendor input
- [x] Date picker
- [x] Description input
- [x] Save button
- [x] Form validation

### Backend Dependencies
- POST `/expenses`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 116. Expenses/ExpenseDetailView
**File:** `lib/features/expenses/views/expense_detail_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Expense Detail

  Scenario: Display expense
    Given the user taps an expense
    When the detail screen loads
    Then all expense details are shown

  Scenario: Edit expense
    Given the detail is displayed
    When the user taps edit
    Then they can modify the expense

  Scenario: Delete expense
    Given the detail is displayed
    When the user deletes
    Then the expense is removed
```

### Testable Actions
- [x] Expense details display
- [x] Receipt image display
- [x] Edit button
- [x] Delete with confirmation
- [x] Back navigation

### Backend Dependencies
- GET `/expenses/:id`
- DELETE `/expenses/:id`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 117. Expenses/ExpenseReportsView
**File:** `lib/features/expenses/views/expense_reports_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Expense Reports

  Scenario: Display reports
    Given the user opens expense reports
    When the screen loads
    Then spending summaries by period are shown

  Scenario: Select period
    Given reports are displayed
    When the user selects a period
    Then data updates

  Scenario: Export report
    Given a report is displayed
    When the user taps export
    Then PDF/CSV is generated
```

### Testable Actions
- [x] Summary cards
- [x] Period selector
- [x] Category breakdown chart
- [x] Export PDF/CSV
- [x] Pull to refresh

### Backend Dependencies
- GET `/expenses/reports`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 118. Expenses/CaptureReceiptView
**File:** `lib/features/expenses/views/capture_receipt_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Capture Receipt

  Scenario: Open camera
    Given the user wants to add receipt
    When the capture screen opens
    Then camera preview is shown

  Scenario: Capture receipt
    Given camera is active
    When the user takes a photo
    Then the receipt is captured

  Scenario: OCR extraction
    Given a receipt is captured
    When processing completes
    Then amount and vendor are extracted
```

### Testable Actions
- [x] Camera preview
- [x] Capture button
- [x] Retake option
- [x] OCR processing
- [x] Manual override
- [x] Save receipt

### Backend Dependencies
- POST `/expenses/ocr` (optional)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 119. Biometric/BiometricEnrollmentView
**File:** `lib/features/biometric/views/biometric_enrollment_view.dart`
**Status:** ACTIVE
**Route:** `/settings/biometric/enrollment`

### BDD Scenarios
```gherkin
Feature: Biometric Enrollment

  Scenario: Display benefits
    Given the user opens biometric enrollment
    When the screen loads
    Then benefits of biometric are shown

  Scenario: Enroll biometric
    Given benefits are displayed
    When the user taps "Enable"
    Then biometric prompt appears

  Scenario: Enrollment success
    Given biometric was scanned
    When enrollment completes
    Then success message is shown

  Scenario: Skip enrollment
    Given enrollment is optional
    When the user taps "Skip"
    Then they return to previous screen
```

### Testable Actions
- [x] Benefits display
- [x] Enable button
- [x] Biometric prompt
- [x] Success animation
- [x] Skip option
- [x] Continue button

### Backend Dependencies
- Local biometric service

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 120. Biometric/BiometricSettingsView
**File:** `lib/features/biometric/views/biometric_settings_view.dart`
**Status:** ACTIVE
**Route:** `/settings/biometric`

### BDD Scenarios
```gherkin
Feature: Biometric Settings

  Scenario: Display biometric status
    Given the user navigates to biometric settings
    When the screen loads
    Then current biometric status is shown

  Scenario: Enable biometric
    Given biometric is disabled
    When the user toggles on
    Then they are prompted to enroll

  Scenario: Disable biometric
    Given biometric is enabled
    When the user toggles off
    Then PIN verification is required
```

### Testable Actions
- [x] Status display
- [x] Toggle switch
- [x] Enroll navigation
- [x] PIN verification for disable
- [x] Device capability check

### Backend Dependencies
- Local biometric service

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

---

## 121. SubBusiness/SubBusinessesView
**File:** `lib/features/sub_business/views/sub_businesses_view.dart`
**Status:** ACTIVE
**Route:** `/sub-businesses`

### BDD Scenarios
```gherkin
Feature: Sub-Businesses List

  Scenario: Display sub-businesses
    Given the user is a business account
    When the screen loads
    Then sub-businesses are listed with stats

  Scenario: Create sub-business
    Given the list is displayed
    When the user taps add
    Then they navigate to create flow

  Scenario: View sub-business
    Given sub-businesses exist
    When the user taps one
    Then they see detail screen
```

### Testable Actions
- [x] List display
- [x] Stats per sub-business
- [x] Create button
- [x] Navigate to detail
- [x] Pull to refresh

### Backend Dependencies
- GET `/sub-businesses`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 122. SubBusiness/CreateSubBusinessView
**File:** `lib/features/sub_business/views/create_sub_business_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Create Sub-Business

  Scenario: Enter sub-business details
    Given the user wants to create a sub-business
    When they fill name and type
    Then they can create it

  Scenario: Set permissions
    Given details are entered
    When permissions section is shown
    Then the user can configure access

  Scenario: Create sub-business
    Given all fields are valid
    When the user taps Create
    Then the sub-business is created
```

### Testable Actions
- [x] Name input
- [x] Type selection
- [x] Permission toggles
- [x] Create button
- [x] Form validation

### Backend Dependencies
- POST `/sub-businesses`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 123. SubBusiness/SubBusinessDetailView
**File:** `lib/features/sub_business/views/sub_business_detail_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Sub-Business Detail

  Scenario: Display details
    Given the user taps a sub-business
    When the detail screen loads
    Then stats, staff, and settings are shown

  Scenario: View staff
    Given detail is displayed
    When the user taps Staff
    Then staff management screen opens

  Scenario: Edit sub-business
    Given detail is displayed
    When the user taps edit
    Then they can modify settings
```

### Testable Actions
- [x] Stats display
- [x] Staff section
- [x] Transactions preview
- [x] Edit button
- [x] Disable/enable toggle
- [x] Delete option

### Backend Dependencies
- GET `/sub-businesses/:id`
- PUT `/sub-businesses/:id`
- DELETE `/sub-businesses/:id`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 124. SubBusiness/SubBusinessStaffView
**File:** `lib/features/sub_business/views/sub_business_staff_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Sub-Business Staff

  Scenario: Display staff
    Given the sub-business has staff
    When the screen loads
    Then staff members are listed

  Scenario: Add staff
    Given staff list is displayed
    When the user taps add
    Then they can invite a new member

  Scenario: Remove staff
    Given a staff member is shown
    When the user removes them
    Then they lose access
```

### Testable Actions
- [x] Staff list display
- [x] Role indicators
- [x] Add staff
- [x] Remove staff
- [x] Edit permissions

### Backend Dependencies
- GET `/sub-businesses/:id/staff`
- POST `/sub-businesses/:id/staff`
- DELETE `/sub-businesses/:id/staff/:staffId`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 125. Services/ServicesView
**File:** `lib/features/services/views/services_view.dart`
**Status:** ACTIVE
**Route:** `/services`

### BDD Scenarios
```gherkin
Feature: Services Hub

  Scenario: Display service categories
    Given the user opens services
    When the screen loads
    Then services are grouped by category

  Scenario: Navigate to service
    Given services are displayed
    When the user taps a service
    Then they navigate to that service

  Scenario: Feature flag check
    Given some services are flagged
    When displaying services
    Then only enabled services are shown
```

### Testable Actions
- [x] Core services grid
- [x] Financial services grid
- [x] Bill payments grid
- [x] Feature flag filtering
- [x] Service navigation
- [x] Coming soon indicators

### Backend Dependencies
- Feature flags

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 126. Wallet/AnalyticsView
**File:** `lib/features/wallet/views/analytics_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/analytics`

### BDD Scenarios
```gherkin
Feature: Spending Analytics

  Scenario: Display analytics
    Given the user has transactions
    When the analytics screen loads
    Then spending charts and stats are shown

  Scenario: Change period
    Given analytics are displayed
    When the user selects "This Month"
    Then data updates for that period

  Scenario: View by category
    Given analytics are displayed
    When category section shows
    Then spending breakdown by category is shown
```

### Testable Actions
- [x] Period selector
- [x] Total spent/received cards
- [x] Category pie chart
- [x] Spending trend line chart
- [x] Top merchants list
- [x] Export report

### Backend Dependencies
- GET `/analytics/spending`
- Feature flag: `analytics`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 127. Wallet/CurrencyConverterView
**File:** `lib/features/wallet/views/currency_converter_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/converter`

### BDD Scenarios
```gherkin
Feature: Currency Converter

  Scenario: Convert currencies
    Given the user opens converter
    When they enter an amount
    Then the converted value is shown

  Scenario: Swap currencies
    Given conversion is displayed
    When the user taps swap
    Then from/to currencies are swapped

  Scenario: Select currency
    Given the converter is displayed
    When the user taps currency selector
    Then currency list appears
```

### Testable Actions
- [x] Amount input
- [x] From currency selector
- [x] To currency selector
- [x] Swap button
- [x] Live rate display
- [x] Rate refresh

### Backend Dependencies
- GET `/exchange-rates` (or mock rates)
- Feature flag: `currencyConverter`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 128. Wallet/BudgetView
**File:** `lib/features/wallet/views/budget_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/budget`

### BDD Scenarios
```gherkin
Feature: Budget Management

  Scenario: Display budgets
    Given the user has budgets set
    When the screen loads
    Then budget cards with progress are shown

  Scenario: Create budget
    Given budgets are displayed
    When the user taps create
    Then budget creation form opens

  Scenario: View budget detail
    Given a budget exists
    When the user taps it
    Then budget details and spending are shown
```

### Testable Actions
- [x] Budget cards display
- [x] Progress bars
- [x] Create budget
- [x] Edit budget
- [x] Delete budget
- [x] Alert thresholds

### Backend Dependencies
- GET `/budgets`
- POST `/budgets`
- Feature flag: `budget`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 129. Wallet/SplitBillView
**File:** `lib/features/wallet/views/split_bill_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/split`

### BDD Scenarios
```gherkin
Feature: Split Bill

  Scenario: Enter total amount
    Given the user wants to split a bill
    When they enter the total
    Then split options are shown

  Scenario: Add participants
    Given total is entered
    When the user adds contacts
    Then they appear as participants

  Scenario: Calculate splits
    Given participants are added
    When equal split is selected
    Then each person's share is calculated

  Scenario: Send requests
    Given splits are calculated
    When the user confirms
    Then payment requests are sent
```

### Testable Actions
- [x] Total amount input
- [x] Add participants
- [x] Split type (equal, custom)
- [x] Individual amount editing
- [x] Send requests
- [x] Track payments

### Backend Dependencies
- POST `/payment-requests/split`
- Feature flag: `splitBills`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 130. Wallet/RequestMoneyView
**File:** `lib/features/wallet/views/request_money_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/request`

### BDD Scenarios
```gherkin
Feature: Request Money

  Scenario: Create request
    Given the user wants to request money
    When they enter amount and select contact
    Then a request can be sent

  Scenario: Add note
    Given amount is entered
    When the user adds a note
    Then the note is included

  Scenario: Send request
    Given all fields are filled
    When the user taps Send
    Then the request is sent
```

### Testable Actions
- [x] Amount input
- [x] Contact selection
- [x] Note input
- [x] Send button
- [x] QR generation
- [x] Share link

### Backend Dependencies
- POST `/payment-requests`
- Feature flag: `requestMoney`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 131. Wallet/SavedRecipientsView
**File:** `lib/features/wallet/views/saved_recipients_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/recipients`

### BDD Scenarios
```gherkin
Feature: Saved Recipients

  Scenario: Display recipients
    Given the user has saved recipients
    When the screen loads
    Then recipients are listed

  Scenario: Quick send
    Given recipients are displayed
    When the user taps one
    Then send flow starts with recipient pre-filled

  Scenario: Edit recipient
    Given a recipient is displayed
    When the user taps edit
    Then they can modify the nickname
```

### Testable Actions
- [x] Recipients list
- [x] Search
- [x] Quick send
- [x] Edit nickname
- [x] Delete recipient
- [x] Add new

### Backend Dependencies
- GET `/recipients`
- Feature flag: `savedRecipients`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 132. Wallet/ScheduledTransfersView
**File:** `lib/features/wallet/views/scheduled_transfers_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/scheduled`

### BDD Scenarios
```gherkin
Feature: Scheduled Transfers

  Scenario: Display scheduled
    Given the user has scheduled transfers
    When the screen loads
    Then upcoming transfers are listed

  Scenario: Cancel scheduled
    Given a transfer is scheduled
    When the user cancels
    Then it's removed from the list

  Scenario: Edit scheduled
    Given a transfer is scheduled
    When the user edits
    Then they can modify the schedule
```

### Testable Actions
- [x] Scheduled list display
- [x] Next execution date
- [x] Cancel transfer
- [x] Edit transfer
- [x] Create new

### Backend Dependencies
- GET `/scheduled-transfers`
- Feature flag: `scheduledTransfers`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 133. Wallet/BuyAirtimeView
**File:** `lib/features/wallet/views/buy_airtime_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/airtime`

### BDD Scenarios
```gherkin
Feature: Buy Airtime

  Scenario: Select provider
    Given the user opens airtime
    When providers load
    Then mobile network options are shown

  Scenario: Enter phone and amount
    Given a provider is selected
    When the user enters phone and amount
    Then they can proceed

  Scenario: Quick amounts
    Given the form is displayed
    When the user taps a quick amount
    Then that amount is filled
```

### Testable Actions
- [x] Provider selection
- [x] Phone number input
- [x] Amount input
- [x] Quick amounts
- [x] Balance check
- [x] Proceed to confirmation

### Backend Dependencies
- GET `/airtime/providers`
- POST `/airtime/purchase`
- Feature flag: `airtime`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 134. Wallet/SavingsGoalsView
**File:** `lib/features/wallet/views/savings_goals_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/savings`

### BDD Scenarios
```gherkin
Feature: Savings Goals

  Scenario: Display goals
    Given the user has savings goals
    When the screen loads
    Then goals with progress are shown

  Scenario: Create goal
    Given goals are displayed
    When the user taps create
    Then goal creation form opens

  Scenario: Add to goal
    Given a goal exists
    When the user adds funds
    Then the balance increases
```

### Testable Actions
- [x] Goals list display
- [x] Progress visualization
- [x] Create goal
- [x] Add funds
- [x] Withdraw funds
- [x] Edit goal
- [x] Delete goal

### Backend Dependencies
- GET `/savings-goals`
- POST `/savings-goals`
- Feature flag: `savings`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 135. Wallet/VirtualCardView
**File:** `lib/features/wallet/views/virtual_card_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/card`

### BDD Scenarios
```gherkin
Feature: Virtual Card Quick View

  Scenario: Display card
    Given the user has a virtual card
    When the screen loads
    Then the card is displayed

  Scenario: View details
    Given the card is shown
    When the user taps "View Details"
    Then full card details are shown
```

### Testable Actions
- [x] Card display
- [x] Quick actions
- [x] View details navigation
- [x] Request card if none

### Backend Dependencies
- GET `/cards`
- Feature flag: `virtualCards`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 136. Wallet/PendingTransfersView
**File:** `lib/features/wallet/views/pending_transfers_view.dart`
**Status:** DEAD_CODE
**Route:** NOT_ROUTED

### Notes
This screen appears to be a duplicate of `offline/pending_transfers_screen.dart`. Should be removed.

### Recommendation
- Delete this file
- Use `lib/features/offline/views/pending_transfers_screen.dart` instead

---

## 137. Wallet/HomeView
**File:** `lib/features/wallet/views/home_view.dart`
**Status:** DEAD_CODE
**Route:** NOT_ROUTED (replaced by wallet_home_screen.dart)

### Notes
This appears to be an older version of the home screen. The active version is `wallet_home_screen.dart`.

### Recommendation
- Verify no code references this file
- Delete if confirmed unused

---

## 138. Wallet/SendView
**File:** `lib/features/wallet/views/send_view.dart`
**Status:** DEAD_CODE
**Route:** NOT_ROUTED (replaced by send/recipient_screen.dart)

### Notes
Older monolithic send view replaced by the multi-step send flow in `lib/features/send/`.

### Recommendation
- Delete this file
- Use the send feature screens instead

---

## 139. Wallet/TransferSuccessView
**File:** `lib/features/wallet/views/transfer_success_view.dart`
**Status:** ACTIVE
**Route:** `/transfer/success`

### BDD Scenarios
```gherkin
Feature: Transfer Success

  Scenario: Display success
    Given a transfer completed
    When the success screen loads
    Then success animation and details are shown

  Scenario: Share receipt
    Given success is displayed
    When the user taps share
    Then receipt is shared

  Scenario: Return home
    Given success is displayed
    When the user taps Done
    Then they return to home
```

### Testable Actions
- [x] Success animation
- [x] Transfer details
- [x] Share receipt
- [x] Done button
- [x] Make another transfer

### Backend Dependencies
- None (uses passed data)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 140. Wallet/DepositInstructionsView
**File:** `lib/features/wallet/views/deposit_instructions_view.dart`
**Status:** ACTIVE
**Route:** `/deposit/instructions` (alternate)

### BDD Scenarios
```gherkin
Feature: Deposit Instructions

  Scenario: Display instructions
    Given the user wants to deposit
    When the screen loads
    Then step-by-step instructions are shown

  Scenario: Copy details
    Given instructions are displayed
    When the user copies account/USSD
    Then the info is copied
```

### Testable Actions
- [x] Instructions display
- [x] Copy functionality
- [x] Step navigation
- [x] Done button

### Backend Dependencies
- None (static instructions)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 141. Wallet/ScanView
**File:** `lib/features/wallet/views/scan_view.dart`
**Status:** ACTIVE
**Route:** `/scan`

### BDD Scenarios
```gherkin
Feature: QR Scanner

  Scenario: Open scanner
    Given the user taps scan
    When the camera opens
    Then QR scanner is active

  Scenario: Scan valid QR
    Given scanner is active
    When a valid QR is scanned
    Then appropriate action is taken

  Scenario: Invalid QR
    Given scanner is active
    When an invalid QR is scanned
    Then error message is shown
```

### Testable Actions
- [x] Camera preview
- [x] QR detection
- [x] Flash toggle
- [x] QR type handling
- [x] Error feedback

### Backend Dependencies
- POST `/qr/decode`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 142. Wallet/BillPayView
**File:** `lib/features/wallet/views/bill_pay_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/bills`

### BDD Scenarios
```gherkin
Feature: Bill Pay Quick Access

  Scenario: Display bill categories
    Given the user opens bill pay
    When the screen loads
    Then bill categories are shown

  Scenario: Navigate to category
    Given categories are displayed
    When the user selects one
    Then they navigate to providers
```

### Testable Actions
- [x] Categories display
- [x] Recent payments
- [x] Category navigation
- [x] Search providers

### Backend Dependencies
- GET `/bill-payments/categories`
- Feature flag: `bills`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 143. Wallet/WalletHomeAccessibilityExample
**File:** `lib/features/wallet/views/wallet_home_accessibility_example.dart`
**Status:** DEMO
**Route:** NOT_ROUTED

### Notes
This is a demonstration file showing accessibility best practices for the home screen.

### Recommendation
- Keep for reference/documentation
- Not for production use

---

## 144. QRPayment/ScanQrScreen
**File:** `lib/features/qr_payment/views/scan_qr_screen.dart`
**Status:** ACTIVE
**Route:** Internal (from send/scan)

### BDD Scenarios
```gherkin
Feature: Scan QR for Payment

  Scenario: Open scanner
    Given the user wants to pay via QR
    When the scanner opens
    Then camera preview is active

  Scenario: Scan payment QR
    Given scanner is active
    When a payment QR is scanned
    Then payment details are extracted

  Scenario: Proceed to confirm
    Given QR is decoded
    When details are shown
    Then user can proceed to pay
```

### Testable Actions
- [x] Camera preview
- [x] QR scanning
- [x] Flash toggle
- [x] Gallery picker
- [x] Payment details extraction
- [x] Navigate to confirm

### Backend Dependencies
- POST `/qr/decode`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 145. Transactions/ExportTransactionsView
**File:** `lib/features/transactions/views/export_transactions_view.dart`
**Status:** ACTIVE
**Route:** `/transactions/export`

### BDD Scenarios
```gherkin
Feature: Export Transactions

  Scenario: Select format
    Given the user wants to export
    When the export screen opens
    Then format options (CSV, PDF) are shown

  Scenario: Select date range
    Given format is selected
    When the user picks dates
    Then transactions are filtered

  Scenario: Generate export
    Given options are set
    When the user taps Export
    Then the file is generated and shared
```

### Testable Actions
- [x] Format selection
- [x] Date range picker
- [x] Transaction type filter
- [x] Generate export
- [x] Share file
- [x] Save file

### Backend Dependencies
- GET `/transactions/export`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 146. Notifications/NotificationPermissionScreen
**File:** `lib/features/notifications/views/notification_permission_screen.dart`
**Status:** ACTIVE
**Route:** `/notifications/permission`

### BDD Scenarios
```gherkin
Feature: Notification Permission

  Scenario: Request permission
    Given notifications aren't enabled
    When the permission screen shows
    Then benefits are explained

  Scenario: Enable notifications
    Given the screen is displayed
    When the user taps Enable
    Then system permission dialog appears

  Scenario: Skip permission
    Given the screen is displayed
    When the user taps Not Now
    Then they proceed without notifications
```

### Testable Actions
- [x] Benefits display
- [x] Enable button
- [x] Skip option
- [x] System dialog trigger

### Backend Dependencies
- None (system permission)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 147. Notifications/NotificationPreferencesScreen
**File:** `lib/features/notifications/views/notification_preferences_screen.dart`
**Status:** ACTIVE
**Route:** `/notifications/preferences`

### BDD Scenarios
```gherkin
Feature: Notification Preferences

  Scenario: Display preferences
    Given the user opens preferences
    When the screen loads
    Then notification categories are shown

  Scenario: Toggle category
    Given preferences are displayed
    When the user toggles a category
    Then the preference is saved
```

### Testable Actions
- [x] Category toggles
- [x] Save on change
- [x] Reset to defaults

### Backend Dependencies
- GET `/notifications/preferences`
- PUT `/notifications/preferences`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 148. PIN/SetPinView
**File:** `lib/features/pin/views/set_pin_view.dart`
**Status:** ACTIVE
**Route:** Part of onboarding

### BDD Scenarios
```gherkin
Feature: Set PIN (Onboarding)

  Scenario: Enter PIN
    Given the user is setting initial PIN
    When they enter 6 digits
    Then they proceed to confirmation

  Scenario: Weak PIN warning
    Given the user enters a weak PIN (123456)
    When validation runs
    Then a warning is shown
```

### Testable Actions
- [x] PIN entry
- [x] Weak PIN detection
- [x] Navigate to confirm
- [x] Error handling

### Backend Dependencies
- None (local validation)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 149. PIN/ConfirmPinView
**File:** `lib/features/pin/views/confirm_pin_view.dart`
**Status:** ACTIVE
**Route:** Part of onboarding

### BDD Scenarios
```gherkin
Feature: Confirm PIN (Onboarding)

  Scenario: Confirm matching PIN
    Given the user set a PIN
    When they enter the same PIN
    Then the PIN is saved

  Scenario: Mismatch handling
    Given the user set a PIN
    When confirmation doesn't match
    Then error is shown
```

### Testable Actions
- [x] PIN entry
- [x] Match validation
- [x] Error display
- [x] Back to set PIN

### Backend Dependencies
- POST `/auth/set-pin`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 150. PIN/EnterPinView
**File:** `lib/features/pin/views/enter_pin_view.dart`
**Status:** ACTIVE
**Route:** Internal (for verification)

### BDD Scenarios
```gherkin
Feature: Enter PIN

  Scenario: Verify PIN
    Given PIN verification is required
    When the user enters correct PIN
    Then action proceeds

  Scenario: Incorrect PIN
    Given PIN is required
    When wrong PIN is entered
    Then remaining attempts are shown

  Scenario: Biometric fallback
    Given biometric is enabled
    When user opens PIN screen
    Then biometric option is available
```

### Testable Actions
- [x] PIN entry
- [x] Verification
- [x] Attempt counter
- [x] Biometric option
- [x] Forgot PIN link

### Backend Dependencies
- POST `/auth/verify-pin`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

---

## 151. PIN/ResetPinView
**File:** `lib/features/pin/views/reset_pin_view.dart`
**Status:** ACTIVE
**Route:** Internal (from forgot PIN)

### BDD Scenarios
```gherkin
Feature: Reset PIN

  Scenario: Request OTP
    Given the user forgot their PIN
    When they tap "Forgot PIN"
    Then OTP is sent to their phone

  Scenario: Verify OTP
    Given OTP was sent
    When the user enters the OTP
    Then they can set new PIN

  Scenario: Set new PIN
    Given OTP is verified
    When the user enters new PIN
    Then they confirm the new PIN

  Scenario: Complete reset
    Given new PIN is confirmed
    When both PINs match
    Then PIN is reset successfully
```

### Testable Actions
- [x] Request OTP step
- [x] OTP entry
- [x] New PIN entry
- [x] Confirm PIN entry
- [x] Step navigation
- [x] Error handling

### Backend Dependencies
- POST `/auth/forgot-pin`
- POST `/auth/reset-pin`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 152. PIN/PinLockedView
**File:** `lib/features/pin/views/pin_locked_view.dart`
**Status:** ACTIVE
**Route:** Internal (shown when locked)

### BDD Scenarios
```gherkin
Feature: PIN Locked

  Scenario: Display locked status
    Given too many wrong PIN attempts
    When the locked screen appears
    Then remaining lockout time is shown

  Scenario: Countdown timer
    Given account is locked
    When time passes
    Then countdown updates

  Scenario: Unlock
    Given lockout period ends
    When timer reaches 0
    Then user can try again
```

### Testable Actions
- [x] Locked message display
- [x] Countdown timer
- [x] Contact support link
- [x] Auto-unlock on timer end

### Backend Dependencies
- None (local lockout)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 153. PIN/ChangePinView
**File:** `lib/features/pin/views/change_pin_view.dart`
**Status:** ACTIVE
**Route:** Internal

### Notes
This appears to be a simpler change PIN view in the PIN feature, separate from the settings change PIN view.

### Testable Actions
- [x] Current PIN entry
- [x] New PIN entry
- [x] Confirm PIN entry

### Backend Dependencies
- PUT `/auth/pin`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 154. SavingsPots/PotDetailView
**File:** `lib/features/savings_pots/views/pot_detail_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/savings-pots/detail/:id`

### BDD Scenarios
```gherkin
Feature: Savings Pot Detail

  Scenario: Display pot details
    Given the user taps a savings pot
    When the detail screen loads
    Then pot balance, goal, progress are shown

  Scenario: Add to pot
    Given the detail is displayed
    When the user taps "Add"
    Then add funds sheet opens

  Scenario: Withdraw from pot
    Given the detail is displayed
    When the user taps "Withdraw"
    Then withdraw sheet opens

  Scenario: Goal reached
    Given the pot reaches its goal
    When viewing the pot
    Then confetti animation plays
```

### Testable Actions
- [x] Balance display
- [x] Progress visualization
- [x] Add funds
- [x] Withdraw funds
- [x] Transaction history
- [x] Edit pot
- [x] Delete pot
- [x] Goal celebration

### Backend Dependencies
- GET `/savings-pots/:id`
- POST `/savings-pots/:id/deposit`
- POST `/savings-pots/:id/withdraw`
- Feature flag: `savingsPots`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 155. SavingsPots/CreatePotView
**File:** `lib/features/savings_pots/views/create_pot_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** `/savings-pots/create`

### BDD Scenarios
```gherkin
Feature: Create Savings Pot

  Scenario: Enter pot details
    Given the user wants to create a pot
    When they enter name and goal
    Then they can create the pot

  Scenario: Select emoji
    Given the form is displayed
    When the user taps emoji picker
    Then they can choose an icon

  Scenario: Set target date
    Given details are entered
    When the user sets a target date
    Then the date is saved
```

### Testable Actions
- [x] Name input
- [x] Goal amount input
- [x] Emoji/icon picker
- [x] Target date picker
- [x] Create button
- [x] Form validation

### Backend Dependencies
- POST `/savings-pots`
- Feature flag: `savingsPots`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 156. SavingsPots/EditPotView
**File:** `lib/features/savings_pots/views/edit_pot_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Edit Savings Pot

  Scenario: Edit pot details
    Given the user wants to edit a pot
    When they modify name or goal
    Then changes can be saved
```

### Testable Actions
- [x] Pre-filled form
- [x] Edit fields
- [x] Save changes
- [x] Cancel editing

### Backend Dependencies
- PUT `/savings-pots/:id`
- Feature flag: `savingsPots`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 157. RecurringTransfers/RecurringTransferDetailView
**File:** `lib/features/recurring_transfers/views/recurring_transfer_detail_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Recurring Transfer Detail

  Scenario: Display transfer details
    Given the user taps a recurring transfer
    When the detail screen loads
    Then recipient, amount, schedule are shown

  Scenario: View execution history
    Given the detail is displayed
    When scrolling down
    Then past executions are listed

  Scenario: Pause transfer
    Given the transfer is active
    When the user pauses
    Then executions stop temporarily

  Scenario: Cancel transfer
    Given the transfer exists
    When the user cancels
    Then it's permanently stopped
```

### Testable Actions
- [x] Transfer details display
- [x] Next execution date
- [x] Execution history
- [x] Pause/resume toggle
- [x] Cancel transfer
- [x] Edit transfer

### Backend Dependencies
- GET `/recurring-transfers/:id`
- PUT `/recurring-transfers/:id/pause`
- DELETE `/recurring-transfers/:id`
- Feature flag: `recurringTransfers`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 158. RecurringTransfers/CreateRecurringTransferView
**File:** `lib/features/recurring_transfers/views/create_recurring_transfer_view.dart`
**Status:** ACTIVE (Feature-flagged)
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Create Recurring Transfer

  Scenario: Select recipient
    Given the user wants to create recurring transfer
    When they select a recipient
    Then the recipient is set

  Scenario: Set schedule
    Given recipient is selected
    When the user sets frequency
    Then schedule is configured

  Scenario: Set amount
    Given schedule is set
    When the user enters amount
    Then transfer can be created
```

### Testable Actions
- [x] Recipient selection
- [x] Amount input
- [x] Frequency selection
- [x] Start date picker
- [x] End date (optional)
- [x] Create button

### Backend Dependencies
- POST `/recurring-transfers`
- Feature flag: `recurringTransfers`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 159. Business/BusinessSetupView
**File:** `lib/features/business/views/business_setup_view.dart`
**Status:** ACTIVE
**Route:** `/settings/business-setup`

### BDD Scenarios
```gherkin
Feature: Business Account Setup

  Scenario: Enter business details
    Given the user wants business account
    When they fill business name and type
    Then they can proceed

  Scenario: Select business type
    Given the form is displayed
    When the user selects type
    Then appropriate fields are shown

  Scenario: Submit for review
    Given all details are entered
    When the user submits
    Then business account is created
```

### Testable Actions
- [x] Business name input
- [x] Business type selector
- [x] Registration number input
- [x] Tax ID input
- [x] Address input
- [x] Submit button

### Backend Dependencies
- POST `/business/setup`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 160. Business/BusinessProfileView
**File:** `lib/features/business/views/business_profile_view.dart`
**Status:** ACTIVE
**Route:** `/settings/business-profile`

### BDD Scenarios
```gherkin
Feature: Business Profile

  Scenario: Display business info
    Given the user has a business account
    When the profile screen loads
    Then business details are shown

  Scenario: Edit business details
    Given the profile is displayed
    When the user taps edit
    Then they can modify details
```

### Testable Actions
- [x] Business details display
- [x] Edit button
- [x] Status indicator
- [x] Documents section

### Backend Dependencies
- GET `/business/profile`
- PUT `/business/profile`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 161. Auth/LoginPhoneView
**File:** `lib/features/auth/views/login_phone_view.dart`
**Status:** DEAD_CODE
**Route:** NOT_ROUTED (replaced by login_view.dart)

### Notes
This appears to be an older login screen. The active version is `login_view.dart`.

### Recommendation
- Verify no code references this file
- Delete if confirmed unused

---

## 162. Auth/LegalDocumentView
**File:** `lib/features/auth/views/legal_document_view.dart`
**Status:** ACTIVE
**Route:** Internal (from terms/privacy links)

### BDD Scenarios
```gherkin
Feature: Legal Document Viewer

  Scenario: Display terms
    Given the user taps Terms of Service
    When the document loads
    Then terms content is displayed

  Scenario: Display privacy
    Given the user taps Privacy Policy
    When the document loads
    Then privacy content is displayed
```

### Testable Actions
- [x] Document content display
- [x] Scrollable view
- [x] Back navigation

### Backend Dependencies
- GET `/legal/terms` or static content

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 163. Beneficiaries/AddBeneficiaryScreen
**File:** `lib/features/beneficiaries/views/add_beneficiary_screen.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Add Beneficiary

  Scenario: Enter beneficiary details
    Given the user wants to add a beneficiary
    When they enter phone and nickname
    Then the beneficiary can be saved

  Scenario: Validate phone
    Given phone is entered
    When validation runs
    Then the user is checked
```

### Testable Actions
- [x] Phone number input
- [x] Nickname input
- [x] Favorite toggle
- [x] Save button
- [x] Cancel option

### Backend Dependencies
- POST `/beneficiaries`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 164. Beneficiaries/BeneficiaryDetailView
**File:** `lib/features/beneficiaries/views/beneficiary_detail_view.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Beneficiary Detail

  Scenario: Display beneficiary
    Given the user taps a beneficiary
    When the detail screen loads
    Then beneficiary info is shown

  Scenario: Quick send
    Given detail is displayed
    When the user taps Send
    Then send flow starts

  Scenario: Edit beneficiary
    Given detail is displayed
    When the user edits
    Then they can modify nickname
```

### Testable Actions
- [x] Details display
- [x] Quick send button
- [x] Edit nickname
- [x] Toggle favorite
- [x] Delete beneficiary

### Backend Dependencies
- GET `/beneficiaries/:id`
- PUT `/beneficiaries/:id`
- DELETE `/beneficiaries/:id`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 165. Contacts/ContactsPermissionScreen
**File:** `lib/features/contacts/views/contacts_permission_screen.dart`
**Status:** ACTIVE
**Route:** Internal

### BDD Scenarios
```gherkin
Feature: Contacts Permission

  Scenario: Request permission
    Given contacts permission is needed
    When the screen appears
    Then benefits are explained

  Scenario: Grant permission
    Given the screen is displayed
    When the user grants permission
    Then contacts are synced

  Scenario: Deny permission
    Given the screen is displayed
    When the user denies
    Then manual entry is required
```

### Testable Actions
- [x] Benefits display
- [x] Grant button
- [x] Deny/skip option
- [x] System dialog trigger

### Backend Dependencies
- None (system permission)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 166. Settings/HelpScreen
**File:** `lib/features/settings/views/help_screen.dart`
**Status:** ACTIVE
**Route:** `/settings/help-screen`

### Notes
This appears to be a simpler/alternative help screen. May be duplicate of HelpView.

### Testable Actions
- [x] Help content display
- [x] Contact options

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 167. Settings/KycView
**File:** `lib/features/settings/views/kyc_view.dart`
**Status:** ACTIVE
**Route:** `/settings/kyc`

### BDD Scenarios
```gherkin
Feature: KYC Settings View

  Scenario: Display KYC status
    Given the user opens KYC settings
    When the screen loads
    Then current KYC tier and status are shown

  Scenario: Start verification
    Given KYC is not complete
    When the user taps Verify
    Then KYC flow starts
```

### Testable Actions
- [x] Status display
- [x] Tier information
- [x] Start verification
- [x] Upgrade prompt

### Backend Dependencies
- GET `/kyc/status`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 168. Settings/PerformanceMonitorView
**File:** `lib/features/settings/views/performance_monitor_view.dart`
**Status:** DEBUG
**Route:** Internal (dev menu)

### Notes
Developer tool for monitoring app performance. Not for production users.

### Testable Actions
- [x] FPS display
- [x] Memory usage
- [x] Network stats

### Backend Dependencies
- None (local metrics)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 169. Receipts/ShareReceiptSheet
**File:** `lib/features/receipts/views/share_receipt_sheet.dart`
**Status:** ACTIVE
**Route:** Bottom sheet (internal)

### BDD Scenarios
```gherkin
Feature: Share Receipt

  Scenario: Display share options
    Given a transaction is complete
    When share receipt is tapped
    Then share sheet with options appears

  Scenario: Share via system
    Given share sheet is open
    When the user taps share
    Then system share dialog opens
```

### Testable Actions
- [x] Receipt preview
- [x] Share button
- [x] Save to gallery
- [x] Close sheet

### Backend Dependencies
- None (local generation)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 170. SendExternal/ExternalAmountScreen
**File:** `lib/features/send_external/views/external_amount_screen.dart`
**Status:** ACTIVE
**Route:** `/send-external/amount`

### BDD Scenarios
```gherkin
Feature: External Send Amount

  Scenario: Enter amount
    Given the user entered an external address
    When they enter the amount
    Then fees are calculated

  Scenario: Network fee display
    Given amount is entered
    When fees calculate
    Then network fee is displayed
```

### Testable Actions
- [x] Amount input
- [x] Fee calculation
- [x] Balance validation
- [x] Continue to confirm

### Backend Dependencies
- GET `/fees/external`

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 171. SendExternal/ExternalConfirmScreen
**File:** `lib/features/send_external/views/external_confirm_screen.dart`
**Status:** ACTIVE
**Route:** `/send-external/confirm`

### BDD Scenarios
```gherkin
Feature: External Send Confirmation

  Scenario: Display confirmation
    Given amount and address are set
    When the confirm screen loads
    Then all details are displayed

  Scenario: Confirm send
    Given details are displayed
    When the user confirms
    Then they proceed to PIN
```

### Testable Actions
- [x] Address display
- [x] Amount display
- [x] Fee display
- [x] Confirm button
- [x] Back navigation

### Backend Dependencies
- None (uses passed state)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 172. SendExternal/ExternalResultScreen
**File:** `lib/features/send_external/views/external_result_screen.dart`
**Status:** ACTIVE
**Route:** `/send-external/result`

### BDD Scenarios
```gherkin
Feature: External Send Result

  Scenario: Display success
    Given the external send completed
    When the result screen loads
    Then success and transaction hash are shown

  Scenario: View on explorer
    Given success is displayed
    When the user taps explorer link
    Then blockchain explorer opens
```

### Testable Actions
- [x] Success animation
- [x] Transaction hash
- [x] View on explorer
- [x] Share receipt
- [x] Done button

### Backend Dependencies
- None (uses passed result)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 173. SendExternal/ScanAddressQRScreen
**File:** `lib/features/send_external/views/scan_address_qr_screen.dart`
**Status:** ACTIVE
**Route:** `/qr/scan-address`

### BDD Scenarios
```gherkin
Feature: Scan Address QR

  Scenario: Scan wallet QR
    Given the user wants to enter address via QR
    When they scan a wallet QR
    Then the address is extracted

  Scenario: Paste from clipboard
    Given the scanner is open
    When the user taps paste
    Then clipboard address is used
```

### Testable Actions
- [x] QR scanner
- [x] Address extraction
- [x] Paste button
- [x] Flash toggle
- [x] Gallery picker

### Backend Dependencies
- None (local QR processing)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 174. Catalog/WidgetCatalogView
**File:** `lib/catalog/widget_catalog_view.dart`
**Status:** DEMO
**Route:** Internal (dev menu)

### Notes
Design system component showcase. Used for visual testing and documentation during development.

### Testable Actions
- [x] Section navigation
- [x] Component previews
- [x] Theme switching

### Backend Dependencies
- None (demo only)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 175. Core/RTL/RtlDebugScreen
**File:** `lib/core/rtl/examples/rtl_debug_screen.dart`
**Status:** DEMO
**Route:** Internal (dev menu)

### Notes
RTL (Right-to-Left) layout debugging screen for testing Arabic/Hebrew support.

### Testable Actions
- [x] RTL toggle
- [x] Layout inspection

### Backend Dependencies
- None (demo only)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 176. Design/States/StatesDemoView
**File:** `lib/design/components/states/states_demo_view.dart`
**Status:** DEMO
**Route:** Internal (dev menu)

### Notes
Demonstration of loading, error, and empty state components.

### Testable Actions
- [x] Loading states
- [x] Error states
- [x] Empty states

### Backend Dependencies
- None (demo only)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## 177. Send/OfflineQueueDialog
**File:** `lib/features/send/views/offline_queue_dialog.dart`
**Status:** ACTIVE
**Route:** Dialog (internal)

### BDD Scenarios
```gherkin
Feature: Offline Queue Dialog

  Scenario: Display offline message
    Given the user sends while offline
    When the dialog appears
    Then they can queue the transfer

  Scenario: Queue transfer
    Given the dialog is shown
    When the user confirms
    Then transfer is queued for sync
```

### Testable Actions
- [x] Offline message
- [x] Queue button
- [x] Cancel button

### Backend Dependencies
- None (local queue)

### Golden Test Status
- [ ] Golden test exists
- [ ] Golden test passes

---

## Progress Report: 177 screens documented

---

# Summary Statistics

## By Status

| Status | Count | Percentage |
|--------|-------|------------|
| **ACTIVE** | 143 | 80.8% |
| **ACTIVE (Feature-flagged)** | 23 | 13.0% |
| **DEAD_CODE** | 5 | 2.8% |
| **DEMO/DEBUG** | 6 | 3.4% |
| **TOTAL** | 177 | 100% |

## Feature-Flagged Screens

| Feature Flag | Screens |
|--------------|---------|
| `virtualCards` | CardsListView, CardDetailView, CardSettingsView, CardTransactionsView, RequestCardView, VirtualCardView |
| `savingsPots` | PotsListView, PotDetailView, CreatePotView, EditPotView |
| `recurringTransfers` | RecurringTransfersListView, RecurringTransferDetailView, CreateRecurringTransferView |
| `analytics` | AnalyticsView |
| `budget` | BudgetView |
| `splitBills` | SplitBillView |
| `requestMoney` | RequestMoneyView |
| `savedRecipients` | SavedRecipientsView |
| `scheduledTransfers` | ScheduledTransfersView |
| `airtime` | BuyAirtimeView |
| `savings` | SavingsGoalsView |
| `currencyConverter` | CurrencyConverterView |
| `bills` | BillPayView |
| `withdraw` | WithdrawView |

## DEAD_CODE Files to Delete

The following files should be reviewed and deleted:

1. `lib/features/wallet/views/home_view.dart` - Replaced by `wallet_home_screen.dart`
2. `lib/features/wallet/views/send_view.dart` - Replaced by send feature screens
3. `lib/features/wallet/views/pending_transfers_view.dart` - Duplicate of offline version
4. `lib/features/auth/views/login_phone_view.dart` - Replaced by `login_view.dart`

## DEMO/DEBUG Files (Keep for Development)

1. `lib/features/wallet/views/wallet_home_accessibility_example.dart`
2. `lib/features/settings/views/performance_monitor_view.dart`
3. `lib/catalog/widget_catalog_view.dart`
4. `lib/core/rtl/examples/rtl_debug_screen.dart`
5. `lib/design/components/states/states_demo_view.dart`

## Pending Features

Screens that are implemented but disabled via feature flags should be reviewed for:
- Backend API readiness
- QA testing completion
- Product decision to enable

## Next Steps

### Phase 2 TODO
- [ ] Create golden tests for all 177 documented screens
- [ ] Verify backend API endpoints for each screen
- [ ] Remove confirmed dead code files
- [ ] Enable feature-flagged screens as ready
- [ ] Add missing BDD scenarios where needed
