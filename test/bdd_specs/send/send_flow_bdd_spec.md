# STATUS: ACTIVE
# Send Flow Feature - BDD Specifications

## Overview
Internal transfer flow for sending USDC to other JoonaPay users.

## Screens Covered
- `/send` - Recipient Screen
- `/send/amount` - Amount Screen
- `/send/confirm` - Confirm Screen
- `/send/pin` - PIN Verification Screen
- `/send/result` - Result Screen

---

## Feature: Select Recipient

### Screen: RecipientScreen
**File:** `lib/features/send/views/recipient_screen.dart`
**Route:** `/send`

```gherkin
Feature: Select Send Recipient

  Background:
    Given I am authenticated with a wallet
    And I am on the recipient selection screen

  @smoke @send @recipient
  Scenario: Display recipient screen
    Then I should see "Select Recipient" title
    And I should see phone number input with "+225" prefix
    And I should see "From Contacts" button
    And I should see "From Beneficiaries" button
    And I should see disabled "Continue" button

  @send @recipient @recent
  Scenario: Display recent recipients
    Given I have sent money before
    Then I should see "Recent Recipients" section
    And I should see list of recent recipients with:
      | Field  | Content           |
      | Avatar | Initials/Photo    |
      | Name   | Recipient name    |
      | Phone  | Masked phone      |

  @send @recipient @input
  Scenario: Enter phone number manually
    When I enter "0123456789"
    Then I should see valid indicator
    And "Continue" button should be enabled

  @send @recipient @validation
  Scenario: Validate phone number
    When I enter "123" (less than 10 digits)
    Then I should see "Enter 10 digits" error
    And "Continue" button should be disabled

  @send @recipient @contacts
  Scenario: Select from contacts
    Given contacts permission is granted
    When I tap "From Contacts"
    Then contact picker bottom sheet should open
    When I select a contact with phone "+2250123456789"
    Then phone input should show "0123456789"

  @send @recipient @contacts @permission
  Scenario: Handle contacts permission denied
    Given contacts permission is denied
    When I tap "From Contacts"
    Then I should see permission denied message

  @send @recipient @beneficiaries
  Scenario: Select from beneficiaries
    Given I have saved beneficiaries
    When I tap "From Beneficiaries"
    Then beneficiary picker bottom sheet should open
    When I select "John Doe"
    Then phone input should populate with their number

  @send @recipient @recent @select
  Scenario: Select recent recipient
    When I tap on a recent recipient card
    Then phone input should populate with their number

  @send @recipient @continue
  Scenario: Continue to amount screen
    Given I have entered valid phone "0123456789"
    When I tap "Continue"
    Then recipient should be set in send provider
    And I should navigate to "/send/amount"
```

---

## Feature: Enter Amount

### Screen: AmountScreen
**File:** `lib/features/send/views/amount_screen.dart`
**Route:** `/send/amount`

```gherkin
Feature: Enter Send Amount

  Background:
    Given I have selected a recipient
    And I am on the amount screen

  @smoke @send @amount
  Scenario: Display amount screen
    Then I should see "Enter Amount" title
    And I should see recipient info card
    And I should see available balance display
    And I should see amount input with "$" prefix
    And I should see optional note input (max 200 chars)
    And I should see disabled "Continue" button

  @send @amount @redirect
  Scenario: Redirect when no recipient
    Given no recipient is selected in state
    Then I should be redirected to "/send"

  @send @amount @recipient_card
  Scenario: Display recipient info
    Given recipient is "John Doe" with phone "+2250123456789"
    Then recipient card should show:
      | Field  | Value               |
      | Avatar | Gold circle with JD |
      | Name   | John Doe            |
      | Phone  | +225 01 23 45 67 89 |

  @send @amount @balance
  Scenario: Display available balance
    Given my balance is $500.00
    Then I should see "Available Balance"
    And I should see "$500.00" in gold color

  @send @amount @input
  Scenario: Enter valid amount
    Given my balance is $500
    When I enter "100"
    Then input should be valid
    And "Continue" button should be enabled

  @send @amount @max
  Scenario: Set maximum amount
    Given my balance is $500
    When I tap "Max"
    Then amount should be set to "500.00"

  @send @amount @insufficient
  Scenario: Amount exceeds balance
    Given my balance is $100
    When I enter "150"
    Then I should see "Insufficient balance" error
    And "Continue" button should be disabled

  @send @amount @limits @daily
  Scenario: Amount exceeds daily limit
    Given my daily limit is $500
    And I have sent $400 today
    When I enter "150"
    Then I should see "Exceeds daily limit" error
    And I should see remaining: "$100"

  @send @amount @limits @monthly
  Scenario: Amount exceeds monthly limit
    Given my monthly limit is $5000
    And I have sent $4900 this month
    When I enter "150"
    Then I should see "Exceeds monthly limit" error

  @send @amount @limits @banner
  Scenario: Display limits warning banner
    Given I am near my daily limit
    Then limits warning banner should display
    With remaining amount information

  @send @amount @fee
  Scenario: Display fee preview
    Given fee rate is 1%
    When I enter "100"
    Then fee preview card should show:
      | Field  | Value  |
      | Amount | $100   |
      | Fee    | $1.00  |
      | Total  | $101   |

  @send @amount @note
  Scenario: Add optional note
    When I enter note "Birthday gift"
    Then note should be saved (max 200 chars)

  @send @amount @continue
  Scenario: Continue to confirmation
    Given I have entered valid amount $100
    When I tap "Continue"
    Then amount and note should be saved to state
    And I should navigate to "/send/confirm"
```

---

## Feature: Confirm Transfer

### Screen: ConfirmScreen
**File:** `lib/features/send/views/confirm_screen.dart`
**Route:** `/send/confirm`

```gherkin
Feature: Confirm Send Transfer

  Background:
    Given I have entered recipient and amount
    And I am on the confirmation screen

  @smoke @send @confirm
  Scenario: Display confirmation details
    Then I should see "Confirm Transfer" title
    And I should see transfer summary card:
      | Field        | Value              |
      | To           | John Doe           |
      | Phone        | +225 01 23 45 67 89 |
      | Amount       | $100.00            |
      | Fee          | $1.00              |
      | Total        | $101.00            |
    And I should see note if entered
    And I should see "Confirm & Send" button

  @send @confirm @proceed
  Scenario: Proceed to PIN verification
    When I tap "Confirm & Send"
    Then I should navigate to "/send/pin"
```

---

## Feature: PIN Verification

### Screen: PinVerificationScreen
**File:** `lib/features/send/views/pin_verification_screen.dart`
**Route:** `/send/pin`

```gherkin
Feature: PIN Verification for Transfer

  Background:
    Given I have confirmed transfer details
    And I am on the PIN verification screen

  @smoke @send @pin
  Scenario: Display PIN entry
    Then I should see "Enter PIN" title
    And I should see transfer summary
    And I should see 4-digit PIN input

  @send @pin @correct
  Scenario: Correct PIN processes transfer
    When I enter my correct PIN
    Then transfer should be submitted
    And I should see processing indicator
    And on success, I should navigate to "/send/result"

  @send @pin @incorrect
  Scenario: Incorrect PIN shows error
    When I enter incorrect PIN
    Then I should see "Incorrect PIN" error
    And PIN should clear
    And I should see attempts remaining
```

---

## Feature: Transfer Result

### Screen: ResultScreen
**File:** `lib/features/send/views/result_screen.dart`
**Route:** `/send/result`

```gherkin
Feature: Transfer Result

  Background:
    Given a transfer has been processed
    And I am on the result screen

  @smoke @send @result @success
  Scenario: Display success result
    Given transfer was successful
    Then I should see success checkmark animation
    And I should see "Transfer Successful" title
    And I should see transfer details:
      | Field          | Value         |
      | Amount         | $100.00       |
      | Recipient      | John Doe      |
      | Transaction ID | TX-12345      |
    And I should see "Done" button
    And I should see "Share Receipt" button

  @send @result @failure
  Scenario: Display failure result
    Given transfer failed with reason "Insufficient funds"
    Then I should see error icon
    And I should see "Transfer Failed" title
    And I should see error reason
    And I should see "Try Again" button

  @send @result @done
  Scenario: Navigate home
    When I tap "Done"
    Then I should navigate to "/home"
    And send state should reset

  @send @result @share
  Scenario: Share receipt
    When I tap "Share Receipt"
    Then receipt should be generated
    And native share sheet should open
```

---

## State Management

### SendMoneyProvider State
```dart
class SendMoneyState {
  final Recipient? recipient;
  final double? amount;
  final String? note;
  final double fee;
  final double total;
  final double availableBalance;
  final List<RecentRecipient> recentRecipients;
  final SendStatus status;
  final String? error;
  final String? transactionId;
}
```

---

## API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/transfers/recent` | GET | Get recent recipients |
| `/beneficiaries` | GET | Get saved beneficiaries |
| `/wallet` | GET | Get available balance |
| `/limits` | GET | Get transaction limits |
| `/transfers/internal` | POST | Execute transfer |

---

## Golden Test Variations

### Recipient Screen
1. Empty state - no recent recipients
2. With recent recipients
3. Phone input validation states
4. Contact picker open
5. Beneficiary picker open
6. Loading state

### Amount Screen
1. Initial state with recipient card
2. Amount entered with fee preview
3. Insufficient balance error
4. Daily limit error
5. Limits warning banner
6. With optional note

### Confirm Screen
1. Full confirmation details
2. With note
3. Without note

### PIN Screen
1. Empty PIN input
2. PIN entry in progress
3. Processing state

### Result Screen
1. Success state
2. Failure state
3. Dark mode variants

---

*Part of USDC Wallet Complete Testing Suite*
