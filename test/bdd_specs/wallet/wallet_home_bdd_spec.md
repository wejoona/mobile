# STATUS: ACTIVE
# Wallet Home Feature - BDD Specifications

## Overview
Main wallet home screen showing balance, quick actions, and recent transactions.

## Screens Covered
- `/home` - Wallet Home Screen

---

## Feature: Wallet Home Screen

### Screen: WalletHomeScreen
**File:** `lib/features/wallet/views/wallet_home_screen.dart`
**Route:** `/home`

```gherkin
Feature: Wallet Home Screen

  Background:
    Given I am authenticated
    And I have navigated to the home screen

  # ==========================================
  # Header Section
  # ==========================================

  @smoke @home @header
  Scenario: Display time-based greeting
    Given current time is 10:00 AM
    Then I should see "Good morning"
    Given current time is 2:00 PM
    Then I should see "Good afternoon"
    Given current time is 6:00 PM
    Then I should see "Good evening"
    Given current time is 11:00 PM
    Then I should see "Good night"

  @home @header
  Scenario: Display user profile section
    Given my name is "John Doe"
    Then I should see avatar with initials "JD"
    And I should see my display name
    And I should see notification icon
    And I should see settings icon

  @home @header @phone
  Scenario: Phone number as name shows greeting only
    Given my name is only phone number "+2250123456789"
    Then I should see only greeting without name

  # ==========================================
  # Balance Card Section
  # ==========================================

  @smoke @home @balance
  Scenario: Display balance card with animation
    Given my wallet is loaded
    And my balance is $1,234.56
    Then I should see animated balance count-up
    And final balance should show "$1,234.56"
    And I should see "USDC" badge

  @home @balance @hide
  Scenario: Toggle balance visibility
    Given balance is visible
    When I tap the visibility toggle
    Then balance should show "******"
    And icon should change to "show"
    When I tap the visibility toggle again
    Then balance should be visible again
    And preference should persist across sessions

  @home @balance @reference
  Scenario: Display reference currency
    Given reference currency is enabled as XOF
    And exchange rate is 600 XOF = 1 USD
    And my balance is $100
    Then I should see "≈ 60,000 XOF" below balance

  @home @balance @pending
  Scenario: Display pending balance
    Given I have $50 pending deposits
    Then I should see "+$50.00 pending" indicator
    With warning color styling

  @home @balance @compact
  Scenario: Large balance formatting
    Given my balance is $1,234,567.89
    Then balance should display as "$1.2M"
    Given my balance is $12,345.67
    Then balance should display as "$12.3K"

  @home @balance @loading
  Scenario: Balance loading state
    Given wallet is loading
    Then I should see skeleton loader
    And balance area should show loading indicator

  @home @balance @error
  Scenario: Balance error state
    Given wallet loading fails
    Then I should see error card
    And I should see "Failed to load balance" message
    And I should see "Retry" button

  # ==========================================
  # Create Wallet (No Wallet State)
  # ==========================================

  @home @wallet @create
  Scenario: Display create wallet card
    Given I don't have a wallet yet
    Then I should see "Activate Your Wallet" card
    And I should see wallet icon
    And I should see activation benefits description
    And I should see "Activate Wallet" button

  @home @wallet @create @action
  Scenario: Activate wallet
    Given I don't have a wallet
    When I tap "Activate Wallet"
    Then I should see loading dialog
    And POST /wallet/create should be called
    When creation succeeds
    Then balance should refresh
    And I should see new wallet balance

  @home @wallet @create @error
  Scenario: Wallet creation error
    Given I don't have a wallet
    When I tap "Activate Wallet"
    And creation fails
    Then I should see error snackbar
    And I should remain on create wallet state

  # ==========================================
  # Quick Actions Section
  # ==========================================

  @smoke @home @actions
  Scenario: Display quick action buttons
    Then I should see 4 quick action buttons:
      | Icon | Label    | Route          |
      | send | Send     | /send          |
      | qr   | Receive  | /receive       |
      | add  | Deposit  | /deposit       |
      | history | History | /transactions |

  @home @actions @navigation
  Scenario Outline: Quick action navigation
    When I tap "<action>" button
    Then I should navigate to "<route>"

    Examples:
      | action   | route          |
      | Send     | /send          |
      | Receive  | /receive       |
      | Deposit  | /deposit       |
      | History  | /transactions  |

  # ==========================================
  # KYC Banner Section
  # ==========================================

  @home @kyc @banner
  Scenario: Display KYC banner for unverified user
    Given my KYC status is "pending"
    Then I should see KYC verification banner
    With warning styling
    And I should see "Complete Verification" text

  @home @kyc @banner @action
  Scenario: Navigate to KYC from banner
    Given KYC banner is displayed
    When I tap the banner
    Then I should navigate to "/kyc"

  @home @kyc @banner @hidden
  Scenario: Hide KYC banner for verified user
    Given my KYC status is "verified"
    Then KYC banner should not be displayed

  # ==========================================
  # Limits Warning Banner
  # ==========================================

  @home @limits @banner
  Scenario: Display limits warning when approaching limit
    Given my daily limit is $1000
    And I have used $900 today
    Then I should see limits warning banner
    With "$100 remaining today" message

  @home @limits @banner @at_limit
  Scenario: Display at limit warning
    Given my daily limit is $1000
    And I have used $1000 today
    Then I should see "Daily limit reached" warning

  @home @limits @banner @hidden
  Scenario: Hide limits banner when not near limit
    Given my daily limit is $1000
    And I have used $500 today
    Then limits warning banner should not be displayed

  # ==========================================
  # Recent Transactions Section
  # ==========================================

  @smoke @home @transactions
  Scenario: Display recent transactions
    Given I have transactions
    Then I should see "Recent Activity" section
    And I should see up to 5 recent transactions
    And I should see "View All" link

  @home @transactions @item
  Scenario: Transaction item display
    Given I have a deposit of $100
    Then transaction should show:
      | Field    | Value           |
      | Type     | Deposit         |
      | Amount   | +$100.00        |
      | Color    | Green (success) |
      | Date     | Today/Yesterday/Date |

  @home @transactions @navigation
  Scenario: Navigate to transaction detail
    When I tap on a transaction
    Then I should navigate to "/transactions/{id}"
    With transaction data passed

  @home @transactions @empty
  Scenario: Empty transactions state
    Given I have no transactions
    Then I should see empty state illustration
    And I should see "No transactions yet"
    And I should see "Make your first deposit" message

  @home @transactions @viewall
  Scenario: Navigate to all transactions
    When I tap "View All"
    Then I should navigate to "/transactions"

  # ==========================================
  # Pull to Refresh
  # ==========================================

  @home @refresh
  Scenario: Pull to refresh
    When I pull down on the screen
    Then refresh indicator should appear
    And wallet balance should reload
    And transactions should reload
    And indicator should dismiss on complete

  # ==========================================
  # Responsive Layouts
  # ==========================================

  @home @responsive @portrait
  Scenario: Mobile portrait layout
    Given I am on a phone in portrait
    Then I should see single column layout
    With balance card full width
    And quick actions in row
    And transactions below

  @home @responsive @tablet
  Scenario: Tablet layout
    Given I am on a tablet
    Then I should see two-column layout
    With balance card on left (60% width)
    And quick actions grid on right (40% width)
    And transactions full width below

  @home @responsive @landscape
  Scenario: Landscape layout
    Given I am in landscape orientation
    Then I should see horizontal split layout
    With balance and actions on left
    And transactions list on right

  # ==========================================
  # Offline State
  # ==========================================

  @home @offline
  Scenario: Offline banner display
    Given I am offline
    Then I should see offline status banner at top
    With "You're offline" message
    And pending sync indicator if applicable
```

---

## State Machine States

The home screen responds to multiple state providers:
- `walletStateMachineProvider` - Balance, wallet status
- `transactionStateMachineProvider` - Recent transactions
- `userStateMachineProvider` - User info, KYC status
- `limitsProvider` - Transaction limits

---

## Test Data Requirements

### Mock Wallet States
```dart
// Loaded state
WalletState(
  status: WalletStatus.loaded,
  walletId: 'wallet-123',
  usdcBalance: 1234.56,
  pendingBalance: 50.0,
)

// Loading state
WalletState(status: WalletStatus.loading)

// Error state
WalletState(
  status: WalletStatus.error,
  error: 'Failed to load',
)

// No wallet state
WalletState(
  status: WalletStatus.loaded,
  walletId: '',
)
```

### Mock Transactions
```dart
[
  Transaction(
    id: 'tx-1',
    type: TransactionType.deposit,
    amount: 100.0,
    status: TransactionStatus.completed,
    createdAt: DateTime.now(),
  ),
  // ... up to 5 for display
]
```

---

## Golden Test Variations

1. **Initial Load** - Skeleton loading
2. **Loaded - With Balance** - Normal state
3. **Loaded - Hidden Balance** - Masked balance
4. **Loaded - With Reference Currency** - XOF conversion shown
5. **Loaded - With Pending** - Pending balance indicator
6. **No Wallet** - Create wallet card
7. **Error State** - Error with retry
8. **Empty Transactions** - No history
9. **With Transactions** - 5 items shown
10. **KYC Banner** - Unverified user
11. **Limits Banner** - Near limit warning
12. **Dark Mode** - All above in dark theme
13. **Tablet Layout** - Responsive
14. **Landscape Layout** - Responsive

---

*Part of USDC Wallet Complete Testing Suite*
