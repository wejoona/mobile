# STATUS: ACTIVE
# Feature: Transaction History & Details
# Screens: transactions_view, transaction_detail_view, export_transactions_view

@transactions @history
Feature: Transaction History Management

  Background:
    Given the user is logged in
    And has transaction history

  # ============================================
  # TRANSACTION LIST
  # ============================================

  @list
  Scenario: View all transactions
    Given the user navigates to transactions
    Then they should see a chronological list
    With transactions grouped by date
    And each showing: type icon, recipient/sender, amount, status

  @list
  Scenario: Transaction type icons
    Given different transaction types exist
    Then each type should have distinct icon:
      | Sent       | Outgoing arrow   |
      | Received   | Incoming arrow   |
      | Deposit    | Plus/Download    |
      | Withdrawal | Minus/Upload     |
      | Bill Pay   | Receipt icon     |

  @list
  Scenario: Transaction status indicators
    Given transactions with different statuses exist
    Then status should be indicated:
      | Completed | Green checkmark  |
      | Pending   | Yellow clock     |
      | Failed    | Red X            |
      | Cancelled | Grey X           |

  @list
  Scenario: Infinite scroll pagination
    Given the user has more than 20 transactions
    When they scroll to the bottom
    Then more transactions should load
    And loading indicator should appear briefly

  @list
  Scenario: Pull to refresh transactions
    Given the user is on transactions list
    When they pull down to refresh
    Then latest transactions should fetch
    And list should update

  # ============================================
  # FILTERING
  # ============================================

  @filter
  Scenario: Filter by type - Sent
    Given the user taps filter
    And selects "Sent"
    Then only sent transactions should display

  @filter
  Scenario: Filter by type - Received
    Given the user selects "Received" filter
    Then only received transactions should display

  @filter
  Scenario: Filter by type - Deposits
    Given the user selects "Deposits" filter
    Then only deposit transactions should display

  @filter
  Scenario: Filter by date range
    Given the user selects date filter
    And chooses "Last 7 days"
    Then only transactions from past week should show

  @filter
  Scenario: Filter by custom date range
    Given the user selects "Custom"
    And sets start date "2025-01-01"
    And sets end date "2025-01-31"
    Then only transactions in that range should show

  @filter
  Scenario: Clear filters
    Given filters are applied
    When the user taps "Clear Filters"
    Then all transactions should be visible again

  # ============================================
  # SEARCHING
  # ============================================

  @search
  Scenario: Search by recipient name
    Given the user has transactions with "John"
    When they search "John"
    Then transactions with John should appear

  @search
  Scenario: Search by note
    Given transaction has note "rent payment"
    When user searches "rent"
    Then that transaction should appear

  @search
  Scenario: Search by amount
    Given the user searches "50"
    Then transactions with amount containing 50 should show

  @search
  Scenario: No results found
    Given the user searches "xyz123"
    And no matches exist
    Then "No transactions found" should display
    And suggestion to adjust search

  # ============================================
  # TRANSACTION DETAIL
  # ============================================

  @detail
  Scenario: View transaction detail - Sent
    Given the user taps on a sent transaction
    Then they should see:
      | Transaction type: Sent |
      | Amount: $50.00 |
      | To: John Doe |
      | Phone: +225... |
      | Date: Jan 15, 2025 |
      | Time: 14:32 |
      | Status: Completed |
      | Transaction ID: TXN123456 |
      | Fee: $0.00 |
      | Note: (if any) |

  @detail
  Scenario: View transaction detail - Received
    Given the user taps on a received transaction
    Then they should see similar details
    With "From" instead of "To"

  @detail
  Scenario: View transaction detail - Deposit
    Given the user taps on a deposit
    Then they should see:
      | Type: Deposit |
      | Method: Mobile Money |
      | Provider: MTN |
      | Amount deposited (local) |
      | Amount received (USDC) |
      | Exchange rate used |
      | Fee |

  @detail
  Scenario: Copy transaction ID
    Given the user is on transaction detail
    When they tap the transaction ID
    Then it should copy to clipboard
    And "Copied!" confirmation shown

  # ============================================
  # RECEIPTS
  # ============================================

  @receipt
  Scenario: Download receipt
    Given the user is viewing a completed transaction
    When they tap "Download Receipt"
    Then a PDF receipt should generate
    And save to device/downloads

  @receipt
  Scenario: Share receipt
    Given the user taps "Share Receipt"
    Then share sheet should open
    With receipt image or PDF

  @receipt
  Scenario: Receipt contents
    Given a receipt is generated
    Then it should include:
      | Company logo |
      | Transaction type |
      | Amount |
      | Date/time |
      | Transaction ID |
      | Sender/receiver info |
      | Status |
      | QR code for verification |

  # ============================================
  # EXPORT TRANSACTIONS
  # ============================================

  @export
  Scenario: Export as CSV
    Given the user wants to export
    When they tap "Export"
    And select "CSV" format
    And choose date range
    And tap "Export"
    Then CSV file should download
    With all transaction data

  @export
  Scenario: Export as PDF statement
    Given the user selects "PDF Statement"
    Then a formatted bank-style statement should generate
    With summary and transaction list

  @export
  Scenario: Export filtered transactions
    Given filters are applied
    When user exports
    Then only filtered transactions should be included

  @export
  Scenario: Email export
    Given the user wants to email export
    When they tap "Send to Email"
    And enter email address
    Then export file should be emailed

  # ============================================
  # PENDING TRANSACTIONS
  # ============================================

  @pending
  Scenario: View pending transaction
    Given a transaction is pending
    When user views it
    Then status should show "Pending"
    And estimated completion time
    And option to track progress

  @pending
  Scenario: Cancel pending transaction
    Given a transaction is still pending
    And cancellation is allowed
    When user taps "Cancel"
    And confirms
    Then transaction should be cancelled
    And funds returned if applicable

  @pending
  Scenario: Pending transaction completes
    Given a pending transaction completes
    Then push notification should be sent
    And status should update in list

  # ============================================
  # FAILED TRANSACTIONS
  # ============================================

  @failed
  Scenario: View failed transaction
    Given a transaction failed
    When user views detail
    Then they should see failure reason
    And "Report Issue" option
    And "Try Again" if applicable

  @failed
  Scenario: Retry failed transaction
    Given the user taps "Try Again"
    Then a new transfer should be initiated
    With same details pre-filled

  @failed
  Scenario: Report issue with transaction
    Given the user taps "Report Issue"
    Then support form should open
    Pre-filled with transaction details

  # ============================================
  # EDGE CASES
  # ============================================

  @edge-case
  Scenario: Empty transaction history
    Given the user has no transactions
    When they view transactions
    Then "No transactions yet" should display
    And "Make your first deposit" suggestion

  @edge-case
  Scenario: Very old transactions
    Given user wants to see 2 year old transactions
    When they scroll or filter that far back
    Then historical transactions should load
    With possible loading delay
