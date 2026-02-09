# STATUS: ACTIVE
# Deposit Flow Feature - BDD Specifications

## Overview
Mobile money deposit flow for adding funds to USDC wallet.

## Screens Covered
- `/deposit/amount` - Deposit Amount Screen
- `/deposit/provider` - Provider Selection Screen
- `/deposit/instructions` - Payment Instructions Screen
- `/deposit/status` - Deposit Status Screen

---

## Feature: Deposit Amount Entry

### Screen: DepositAmountScreen
**File:** `lib/features/deposit/views/deposit_amount_screen.dart`
**Route:** `/deposit/amount`

```gherkin
Feature: Enter Deposit Amount

  Background:
    Given I am authenticated
    And I am on the deposit amount screen

  @smoke @deposit @amount
  Scenario: Display deposit screen
    Then I should see "Deposit" title
    And I should see exchange rate card
    And I should see currency toggle (XOF/USD)
    And I should see amount input
    And I should see quick amount buttons
    And I should see min/max limits info
    And I should see disabled "Continue" button

  @deposit @exchange_rate
  Scenario: Display exchange rate
    Given current rate is 1 USD = 600 XOF
    Then exchange rate card should show:
      | Field       | Value                   |
      | Rate        | 1 USD = 600.00 XOF      |
      | Updated     | 5m ago                  |
    And I should see refresh button

  @deposit @exchange_rate @refresh
  Scenario: Refresh exchange rate
    When I tap refresh icon
    Then exchange rate should reload
    And timestamp should update

  @deposit @currency @toggle
  Scenario: Toggle between XOF and USD
    Given I am entering in XOF
    When I tap "USD" tab
    Then input should switch to USD mode
    And conversion preview should update

  @deposit @amount @xof
  Scenario: Enter amount in XOF
    Given rate is 600 XOF = 1 USD
    When I select XOF tab
    And I enter "60000"
    Then I should see "You will receive: $100.00"

  @deposit @amount @usd
  Scenario: Enter amount in USD
    Given rate is 600 XOF = 1 USD
    When I select USD tab
    And I enter "100"
    Then I should see "You will pay: 60,000 XOF"

  @deposit @quick_amounts @xof
  Scenario: Quick amount buttons in XOF
    Given I am in XOF mode
    Then I should see quick buttons: 5K, 10K, 25K, 50K
    When I tap "10K"
    Then amount should be set to 10000

  @deposit @quick_amounts @usd
  Scenario: Quick amount buttons in USD
    Given I am in USD mode
    Then I should see quick buttons: $10, $20, $50, $100
    When I tap "$50"
    Then amount should be set to 50

  @deposit @validation @min
  Scenario: Validate minimum amount
    Given minimum is 500 XOF
    When I enter "100" XOF
    Then I should see "Minimum 500 XOF" error
    And "Continue" button should be disabled

  @deposit @validation @max
  Scenario: Validate maximum amount
    Given maximum is 5,000,000 XOF
    When I enter "10000000" XOF
    Then I should see "Maximum 5,000,000 XOF" error

  @deposit @limits_info
  Scenario: Display limits info
    Then I should see info card with:
      | Field   | Value                                |
      | Min     | 500 XOF                              |
      | Max     | 5,000,000 XOF                        |

  @deposit @continue
  Scenario: Continue to provider selection
    Given I have entered valid amount 10000 XOF
    When I tap "Continue"
    Then amount should be saved to state
    And I should navigate to "/deposit/provider"

  @deposit @loading
  Scenario: Exchange rate loading state
    Given exchange rate is loading
    Then I should see loading indicator in rate card
    And "Continue" button should be disabled

  @deposit @error
  Scenario: Exchange rate error state
    Given exchange rate failed to load
    Then I should see error message
    And I should see retry option
```

---

## Feature: Provider Selection

### Screen: ProviderSelectionScreen
**File:** `lib/features/deposit/views/provider_selection_screen.dart`
**Route:** `/deposit/provider`

```gherkin
Feature: Select Payment Provider

  Background:
    Given I have entered deposit amount
    And I am on the provider selection screen

  @smoke @deposit @provider
  Scenario: Display available providers
    Then I should see "Select Payment Method" title
    And I should see list of mobile money providers:
      | Provider      | Logo | Fee Info | Time    |
      | Orange Money  | ✓    | 1%       | Instant |
      | MTN MoMo      | ✓    | 1%       | Instant |
      | Wave          | ✓    | 0.5%     | Instant |

  @deposit @provider @select
  Scenario: Select provider
    When I tap on "Orange Money"
    Then provider should be highlighted
    And "Continue" button should be enabled

  @deposit @provider @details
  Scenario: Provider details display
    For each provider, I should see:
      | Element          | Description              |
      | Logo             | Provider brand logo      |
      | Name             | Provider name            |
      | Fee              | Transaction fee percent  |
      | Processing time  | Instant/Minutes          |
      | Availability     | 24/7 or time range       |

  @deposit @provider @continue
  Scenario: Continue to instructions
    Given I have selected "Orange Money"
    When I tap "Continue"
    Then provider should be saved to state
    And I should navigate to "/deposit/instructions"
```

---

## Feature: Payment Instructions

### Screen: PaymentInstructionsScreen
**File:** `lib/features/deposit/views/payment_instructions_screen.dart`
**Route:** `/deposit/instructions`

```gherkin
Feature: Payment Instructions

  Background:
    Given I have selected provider "Orange Money"
    And I am on the payment instructions screen

  @smoke @deposit @instructions
  Scenario: Display payment instructions
    Then I should see provider-specific instructions
    And I should see:
      | Field            | Value                    |
      | Provider         | Orange Money logo + name |
      | Amount (XOF)     | 60,000 XOF               |
      | Reference        | REF-123456               |
      | Instructions     | Step by step guide       |
    And I should see "I've Made Payment" button

  @deposit @instructions @steps
  Scenario: Display step-by-step instructions
    Given provider is "Orange Money"
    Then instructions should include:
      | Step | Instruction                      |
      | 1    | Open Orange Money app            |
      | 2    | Go to "Transfers" > "Other"      |
      | 3    | Enter merchant code: XXXXX       |
      | 4    | Enter amount: 60,000 XOF         |
      | 5    | Enter reference: REF-123456      |
      | 6    | Confirm with your PIN            |

  @deposit @instructions @copy
  Scenario: Copy payment reference
    When I tap copy icon next to reference "REF-123456"
    Then reference should be copied to clipboard
    And I should see "Copied!" toast

  @deposit @instructions @timer
  Scenario: Countdown timer if applicable
    Given payment expires in 30 minutes
    Then I should see countdown timer "29:59"
    And timer should decrement each second

  @deposit @instructions @confirm
  Scenario: Confirm payment made
    When I tap "I've Made Payment"
    Then I should navigate to "/deposit/status"
```

---

## Feature: Deposit Status

### Screen: DepositStatusScreen
**File:** `lib/features/deposit/views/deposit_status_screen.dart`
**Route:** `/deposit/status`

```gherkin
Feature: Deposit Status Tracking

  Background:
    Given I have made a payment
    And I am on the status screen

  @smoke @deposit @status @pending
  Scenario: Display pending status
    Given deposit status is "pending"
    Then I should see animated loading indicator
    And I should see "Processing your deposit..." message
    And I should see "This may take a few minutes"
    And status should poll every 10 seconds

  @deposit @status @success
  Scenario: Status updates to success
    Given deposit was successful
    Then I should see success checkmark animation
    And I should see "Deposit Successful!" title
    And I should see credited amount "$100.00"
    And I should see transaction ID
    And I should see "Done" button

  @deposit @status @failed
  Scenario: Status updates to failed
    Given deposit failed with reason "Payment timeout"
    Then I should see error icon
    And I should see "Deposit Failed" title
    And I should see failure reason
    And I should see "Try Again" button
    And I should see "Contact Support" link

  @deposit @status @polling
  Scenario: Status polling
    Given deposit is pending
    Then GET /deposit/{id}/status should be called every 10 seconds
    Until status changes to success or failed
    Or timeout after 15 minutes

  @deposit @status @done
  Scenario: Navigate home on success
    Given deposit succeeded
    When I tap "Done"
    Then I should navigate to "/home"
    And wallet balance should reflect new amount

  @deposit @status @retry
  Scenario: Retry on failure
    Given deposit failed
    When I tap "Try Again"
    Then I should navigate to "/deposit/amount"
    And previous amount should be pre-filled

  @deposit @status @support
  Scenario: Contact support
    When I tap "Contact Support"
    Then support options should appear
    With transaction ID for reference
```

---

## State Management

### DepositProvider State
```dart
class DepositState {
  final double? amountXOF;
  final double? amountUSD;
  final String? providerId;
  final String? providerName;
  final String? depositId;
  final String? reference;
  final DepositStatus status;
  final String? error;
  final ExchangeRate? exchangeRate;
}
```

---

## API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/exchange-rates?from=XOF&to=USD` | GET | Get current rate |
| `/deposit/providers` | GET | List providers |
| `/deposit/initiate` | POST | Create deposit |
| `/deposit/{id}/status` | GET | Poll status |

---

## Golden Test Variations

### Amount Screen
1. Initial with exchange rate
2. XOF mode with amount
3. USD mode with amount
4. Minimum validation error
5. Maximum validation error
6. Quick amounts in XOF
7. Quick amounts in USD
8. Exchange rate loading
9. Exchange rate error

### Provider Screen
1. List of providers
2. Provider selected
3. Loading state
4. Empty providers (maintenance)

### Instructions Screen
1. Orange Money instructions
2. MTN MoMo instructions
3. Wave instructions
4. With countdown timer

### Status Screen
1. Pending state
2. Success state
3. Failed state
4. Timeout state

---

*Part of USDC Wallet Complete Testing Suite*
