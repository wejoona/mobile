# STATUS: ACTIVE
# Feature: Deposit Flow (Mobile Money & Bank)
# Screens: deposit_view, deposit_amount_screen, provider_selection_screen, payment_instructions_screen, deposit_status_screen

@deposit @critical
Feature: Deposit Funds into Wallet

  Background:
    Given the user is logged in
    And has a verified wallet
    And KYC status allows deposits

  # ============================================
  # DEPOSIT OPTIONS
  # ============================================

  @deposit-options
  Scenario: View available deposit methods
    Given the user is on the home screen
    When they tap "Deposit"
    Then they should see available deposit methods:
      | Mobile Money  |
      | Bank Transfer |
      | Card Payment  |
    And each method shows estimated processing time

  @deposit-options
  Scenario: Mobile Money option availability
    Given Mobile Money is enabled in user's region
    Then Mobile Money option should be visible
    And show supported providers (MTN, Orange, etc.)

  @deposit-options
  Scenario: Bank Transfer option availability
    Given Bank Transfer is enabled
    Then Bank Transfer option should be visible
    And show processing time "1-3 business days"

  @deposit-options
  Scenario: Card Payment option availability
    Given Card payments are enabled
    Then Card option should be visible
    And show "Instant" processing time
    And note any card processing fees

  # ============================================
  # MOBILE MONEY DEPOSIT
  # ============================================

  @mobile-money @amount
  Scenario: Enter deposit amount - Mobile Money
    Given the user selected Mobile Money
    When they are on the deposit amount screen
    And they enter "50000" (local currency)
    Then the USDC equivalent should be calculated
    And conversion rate should be displayed
    And any fees should be shown

  @mobile-money @amount
  Scenario: Minimum deposit amount
    Given minimum deposit is 1000 local currency
    When the user enters "500"
    Then an error "Minimum deposit is 1000 XOF" should display
    And "Continue" should be disabled

  @mobile-money @amount
  Scenario: Maximum deposit amount
    Given maximum single deposit is 1,000,000 local currency
    When the user enters "2000000"
    Then an error "Maximum deposit is 1,000,000 XOF" should display

  @mobile-money @amount
  Scenario: KYC tier limit warning
    Given the user is KYC Tier 1
    And Tier 1 monthly limit is 500,000 XOF
    And user has deposited 400,000 this month
    When they try to deposit 200,000
    Then a warning should show remaining limit
    And option to upgrade KYC tier

  @mobile-money @provider
  Scenario: Select Mobile Money provider
    Given the user entered a valid amount
    When they proceed to provider selection
    Then available providers should be listed:
      | MTN Mobile Money |
      | Orange Money     |
      | Wave             |
    And each shows logo and any provider-specific fees

  @mobile-money @provider
  Scenario: Provider with best rate highlighted
    Given multiple providers available
    Then the provider with best conversion rate
    Should be highlighted as "Best Rate"

  @mobile-money @instructions
  Scenario: View payment instructions - MTN
    Given the user selected MTN Mobile Money
    When payment instructions screen shows
    Then they should see:
      | USSD code: *133# |
      | Reference number |
      | Exact amount in XOF |
      | Expiration time |
    And "I've Sent the Payment" button

  @mobile-money @instructions
  Scenario: Copy reference number
    Given the user is viewing payment instructions
    When they tap the reference number
    Then it should copy to clipboard
    And show "Copied!" confirmation

  @mobile-money @instructions
  Scenario: Share payment instructions
    Given the user taps "Share Instructions"
    Then a shareable message should be generated
    With all payment details
    And share sheet should open

  @mobile-money @status
  Scenario: Check deposit status - Pending
    Given the user marked "I've Sent Payment"
    When viewing the status screen
    Then they should see "Pending" status
    And "Waiting for payment confirmation"
    And estimated wait time

  @mobile-money @status
  Scenario: Check deposit status - Processing
    Given the Mobile Money payment was received
    When viewing the status screen
    Then status should update to "Processing"
    And message "Payment received, crediting your wallet..."

  @mobile-money @status
  Scenario: Check deposit status - Complete
    Given the deposit processing finished
    When viewing the status screen
    Then status should show "Complete" with success animation
    And USDC amount credited
    And "View in Transactions" link
    And "Done" button

  @mobile-money @status
  Scenario: Check deposit status - Failed
    Given the payment was not received within timeout
    When viewing the status screen
    Then status should show "Failed"
    And reason (e.g., "Payment not received")
    And "Try Again" button

  @mobile-money @status
  Scenario: Payment timeout
    Given payment instructions were generated
    And 30 minutes have passed without payment
    When user checks status
    Then deposit should be marked expired
    And user can initiate new deposit

  # ============================================
  # BANK TRANSFER DEPOSIT
  # ============================================

  @bank-transfer
  Scenario: View bank transfer details
    Given the user selected Bank Transfer
    When they enter an amount
    And proceed to instructions
    Then they should see:
      | Bank name |
      | Account number |
      | Account name |
      | Reference code |
      | Amount to transfer |

  @bank-transfer
  Scenario: Bank transfer processing time
    Given bank transfer initiated
    Then processing time "1-3 business days" should display
    And user should be notified when complete

  # ============================================
  # CARD PAYMENT DEPOSIT
  # ============================================

  @card-payment
  Scenario: Enter card details
    Given the user selected Card Payment
    When they proceed to card entry
    Then they should see secure card form:
      | Card number |
      | Expiry date |
      | CVV |
      | Cardholder name |

  @card-payment
  Scenario: 3D Secure verification
    Given the user entered valid card details
    And 3D Secure is required
    When they submit the payment
    Then 3D Secure challenge should appear
    And user completes verification

  @card-payment
  Scenario: Card payment success
    Given card payment was authorized
    Then funds should credit instantly
    And success confirmation shown

  @card-payment
  Scenario: Card payment declined
    Given the card was declined
    Then error message should show reason
    And user can try different card

  # ============================================
  # NOTIFICATIONS & HISTORY
  # ============================================

  @notifications
  Scenario: Push notification on deposit complete
    Given a deposit was processing
    When it completes successfully
    Then user should receive push notification
    With amount and new balance

  @history
  Scenario: View deposit in transaction history
    Given a deposit completed
    When user views transactions
    Then deposit should appear with:
      | Type: Deposit |
      | Amount |
      | Method (Mobile Money/Bank/Card) |
      | Provider |
      | Status |
      | Date/Time |

  # ============================================
  # EDGE CASES
  # ============================================

  @edge-case
  Scenario: Duplicate deposit prevention
    Given the user just initiated a deposit
    And it's still pending
    When they try to start another deposit
    Then a warning "You have a pending deposit" should show
    And option to check existing deposit status

  @edge-case
  Scenario: Deposit while wallet frozen
    Given the user's wallet is frozen
    When they try to deposit
    Then they should see wallet_frozen_view
    And cannot proceed with deposit

  @edge-case
  Scenario: Rate change during deposit
    Given the user is viewing deposit instructions
    And the exchange rate changes significantly
    When they check the amount
    Then a note about rate lock should appear
    And locked rate should still apply

  @edge-case
  Scenario: App closed during deposit
    Given deposit instructions were generated
    When user closes and reopens app
    Then they should see pending deposit banner on home
    And can continue checking status
