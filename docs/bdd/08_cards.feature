# STATUS: FEATURE_FLAGGED
# Feature Flag: virtual_cards
# Feature: Virtual Cards Management
# Screens: cards_screen, cards_list_view, card_detail_view, request_card_view, card_settings_view, card_transactions_view

@cards @virtual-cards @feature-flagged
Feature: Virtual Card Management

  Background:
    Given the user is logged in
    And has completed KYC
    And virtual_cards feature flag is enabled

  # ============================================
  # CARD LIST
  # ============================================

  @list
  Scenario: View cards list - no cards
    Given the user has no virtual cards
    When they navigate to cards tab
    Then they should see "No cards yet"
    And "Request Your First Card" button

  @list
  Scenario: View cards list - with cards
    Given the user has 2 virtual cards
    When they view the cards list
    Then both cards should be displayed
    With last 4 digits and status

  @list
  Scenario: Card preview shows limited details
    Given a card exists
    When viewing in the list
    Then they should see:
      | Card design/color |
      | Last 4 digits: •••• 1234 |
      | Status (Active/Frozen) |
      | Current balance |

  # ============================================
  # REQUEST NEW CARD
  # ============================================

  @request
  Scenario: Request virtual card
    Given the user is eligible for a card
    When they tap "Request Card"
    Then they should see card options:
      | Card type (Standard/Premium) |
      | Card design selection |
      | Terms and conditions |

  @request
  Scenario: Select card design
    Given the user is requesting a card
    When they select a design
    Then preview should update
    And they can proceed

  @request
  Scenario: Accept terms and request
    Given the user selected card options
    When they accept terms
    And tap "Request Card"
    Then card should be provisioned
    And success message shown

  @request
  Scenario: Card request denied - KYC not complete
    Given the user hasn't completed KYC
    When they try to request a card
    Then they should see "Complete KYC first"
    And link to KYC flow

  @request
  Scenario: Card limit reached
    Given the user has maximum allowed cards
    When they try to request another
    Then error "Card limit reached" should show

  # ============================================
  # CARD DETAIL
  # ============================================

  @detail
  Scenario: View card details
    Given the user taps on a card
    Then card detail screen should show:
      | Full card design |
      | Card number (masked) |
      | "Reveal Details" button |
      | Expiry date |
      | Status |
      | Spending limit |
      | Available balance |

  @detail
  Scenario: Reveal card number
    Given the user taps "Reveal Details"
    And authenticates (PIN/biometric)
    Then full card number should show
    And CVV should be visible
    And details auto-hide after 30 seconds

  @detail
  Scenario: Copy card number
    Given card details are revealed
    When user taps copy icon
    Then card number should copy to clipboard
    And "Copied!" confirmation shown

  @detail
  Scenario: Add to Apple Wallet
    Given the device is iOS
    And Apple Pay is supported
    When user taps "Add to Apple Wallet"
    Then provisioning flow should start
    And card added to Wallet app

  @detail
  Scenario: Add to Google Wallet
    Given the device is Android
    When user taps "Add to Google Wallet"
    Then provisioning flow should start

  # ============================================
  # CARD SETTINGS
  # ============================================

  @settings
  Scenario: Freeze card
    Given the card is active
    When user taps "Freeze Card"
    Then card should be frozen
    And status should update to "Frozen"
    And transactions should be blocked

  @settings
  Scenario: Unfreeze card
    Given the card is frozen
    When user taps "Unfreeze"
    And authenticates
    Then card should be active again
    And transactions should work

  @settings
  Scenario: Set spending limit
    Given user opens card settings
    When they tap "Spending Limits"
    Then they can set:
      | Daily limit |
      | Per-transaction limit |
      | Monthly limit |
      | ATM withdrawal limit |

  @settings
  Scenario: Enable/disable online transactions
    Given online transactions are enabled
    When user toggles OFF
    Then online transactions should be blocked
    But in-person POS should still work

  @settings
  Scenario: Enable/disable international transactions
    Given the user toggles international
    Then they can control:
      | International online |
      | International POS |
      | ATM abroad |

  @settings
  Scenario: Cancel card
    Given the user wants to cancel card
    When they tap "Cancel Card"
    Then warning should show:
      | Card will be permanently cancelled |
      | Any linked services affected |
    And require confirmation

  @settings
  Scenario: Report card stolen
    Given user taps "Report Lost/Stolen"
    Then card should immediately freeze
    And replacement card offered
    And support notified

  # ============================================
  # CARD TRANSACTIONS
  # ============================================

  @transactions
  Scenario: View card transactions
    Given the user taps "Transactions"
    Then only transactions for this card should show
    Sorted by date

  @transactions
  Scenario: Card transaction detail
    Given user taps on a card transaction
    Then they should see:
      | Merchant name |
      | Amount |
      | Date/time |
      | Location (if available) |
      | Authorization status |
      | Transaction ID |

  @transactions
  Scenario: Disputed transaction
    Given a suspicious transaction exists
    When user taps "Dispute"
    Then dispute form should open
    With transaction details pre-filled

  @transactions
  Scenario: Pending authorization
    Given a merchant authorized but not captured
    Then transaction should show as "Pending"
    And note about authorization hold

  # ============================================
  # CARD NOTIFICATIONS
  # ============================================

  @notifications
  Scenario: Real-time transaction notification
    Given the card is used
    Then instant push notification should arrive
    With merchant, amount, and approve/deny option

  @notifications
  Scenario: Declined transaction notification
    Given a transaction was declined
    Then notification should explain why:
      | Insufficient funds |
      | Card frozen |
      | Limit exceeded |
      | Suspicious activity |

  # ============================================
  # EDGE CASES
  # ============================================

  @edge-case
  Scenario: Card expires soon
    Given card expires in 30 days
    Then warning banner should show
    And renewal option available

  @edge-case
  Scenario: Multiple cards same design
    Given user has 2 cards
    Then they should be distinguishable
    By different last 4 digits
    Or custom labels

  @edge-case
  Scenario: Card feature disabled mid-use
    Given user is viewing cards
    When feature flag is disabled
    Then they should see maintenance message
    And existing cards remain accessible
