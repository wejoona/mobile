# STATUS: ACTIVE
# Feature: Home & Wallet Management
# Screens: wallet_home_screen, receive_view, scan_view, transfer_success_view

@home @wallet @critical
Feature: Wallet Home Screen & Core Wallet Features

  Background:
    Given the user is logged in
    And has a verified wallet

  # ============================================
  # HOME SCREEN - BALANCE
  # ============================================

  @balance
  Scenario: Display wallet balance
    Given the user has 250.00 USDC
    When they view the home screen
    Then they should see "250.00 USDC" prominently
    And local currency equivalent below

  @balance
  Scenario: Balance hide/show toggle
    Given the balance is currently visible
    When the user taps the eye icon
    Then the balance should be hidden (e.g., "••••••")
    And the preference should persist

  @balance
  Scenario: Show hidden balance
    Given the balance is hidden
    When the user taps the eye icon
    Then the full balance should be revealed

  @balance
  Scenario: Balance count-up animation
    Given the user just logged in
    When the home screen loads
    Then the balance should animate from 0 to actual amount
    With smooth count-up effect

  @balance
  Scenario: Pending balance shown
    Given the user has a pending incoming transfer
    When they view home
    Then pending amount should show separately
    Or as a note under main balance

  # ============================================
  # HOME SCREEN - GREETING
  # ============================================

  @greeting
  Scenario Outline: Time-based greeting
    Given the current time is <time>
    When the user views the home screen
    Then they should see "<greeting>, [Name]"

    Examples:
      | time  | greeting       |
      | 06:00 | Good morning   |
      | 12:00 | Good afternoon |
      | 18:00 | Good evening   |
      | 23:00 | Good night     |

  # ============================================
  # HOME SCREEN - QUICK ACTIONS
  # ============================================

  @quick-actions
  Scenario: Send quick action
    Given the user is on home screen
    When they tap "Send"
    Then they should navigate to "/send"

  @quick-actions
  Scenario: Receive quick action
    Given the user taps "Receive"
    Then they should navigate to "/receive"

  @quick-actions
  Scenario: Deposit quick action
    Given the user taps "Deposit"
    Then they should navigate to "/deposit"

  @quick-actions
  Scenario: Scan quick action
    Given the user taps "Scan"
    Then the camera should open for QR scanning

  # ============================================
  # HOME SCREEN - KYC BANNER
  # ============================================

  @kyc-banner
  Scenario: KYC banner shown for unverified users
    Given the user has not completed KYC
    When they view the home screen
    Then a "Complete Verification" banner should appear
    And tapping it navigates to "/kyc"

  @kyc-banner
  Scenario: KYC banner hidden after verification
    Given the user completed KYC
    Then the verification banner should not appear

  @kyc-banner
  Scenario: KYC limit warning banner
    Given the user is approaching their tier limit
    When they view home
    Then a warning banner should show remaining limit
    And option to upgrade tier

  # ============================================
  # HOME SCREEN - RECENT TRANSACTIONS
  # ============================================

  @transactions-preview
  Scenario: Display recent transactions
    Given the user has transaction history
    When they view the home screen
    Then the last 3-5 transactions should be visible
    With type icon, amount, and date

  @transactions-preview
  Scenario: View all transactions
    Given there are transactions shown
    When the user taps "View All"
    Then they should navigate to "/transactions"

  @transactions-preview
  Scenario: Tap on transaction
    Given transactions are visible
    When the user taps on a specific transaction
    Then they should see transaction detail view

  @transactions-preview
  Scenario: Empty transaction state
    Given the user has no transactions
    When they view home
    Then a message "No transactions yet" should appear
    And "Make your first deposit" prompt

  # ============================================
  # HOME SCREEN - PULL TO REFRESH
  # ============================================

  @refresh
  Scenario: Pull to refresh updates balance
    Given the user is on home
    When they pull down to refresh
    Then a loading indicator should appear
    And balance should update from backend
    And transactions should refresh

  @refresh
  Scenario: Pull to refresh with haptic feedback
    Given device supports haptics
    When user pulls to refresh
    Then haptic feedback should trigger
    At the refresh threshold

  # ============================================
  # RECEIVE SCREEN
  # ============================================

  @receive
  Scenario: Display receive QR code
    Given the user opens receive screen
    Then they should see their wallet QR code
    And wallet address below the QR
    And "Copy Address" button
    And "Share" button

  @receive
  Scenario: Copy wallet address
    Given the user is on receive screen
    When they tap "Copy Address"
    Then the address should copy to clipboard
    And "Copied!" toast should appear

  @receive
  Scenario: Share QR code
    Given the user taps "Share"
    Then share sheet should open
    With QR code image
    And wallet address in text

  @receive
  Scenario: Request specific amount
    Given the user wants to receive exactly $50
    When they tap "Set Amount"
    And enter "50.00"
    Then the QR code should update
    To include the requested amount
    And payer will see pre-filled amount

  @receive
  Scenario: Generate new QR for security
    Given user is concerned about security
    When they tap "Regenerate Address"
    Then a confirmation prompt should appear
    And upon confirmation, new address generated

  # ============================================
  # SCAN SCREEN
  # ============================================

  @scan
  Scenario: Scan valid payment QR
    Given the user opens scan screen
    And camera permission is granted
    When they scan a valid payment QR
    Then payment details should be extracted
    And user proceeds to payment flow

  @scan
  Scenario: Scan wallet address QR
    Given the user scans a wallet address QR
    Then they should be redirected to send flow
    With recipient pre-filled

  @scan
  Scenario: Scan invalid QR
    Given the user scans an unrecognized QR
    Then an error "Invalid QR code" should show
    And option to try again

  @scan
  Scenario: Camera permission denied
    Given camera permission is not granted
    When user opens scan
    Then they should see permission request
    And instructions to enable in settings

  @scan
  Scenario: Low light warning
    Given the environment is dark
    When scanning
    Then a "Low light - turn on flash?" prompt should appear

  # ============================================
  # TRANSFER SUCCESS SCREEN
  # ============================================

  @success
  Scenario: Display transfer success
    Given a transfer completed successfully
    When success screen shows
    Then they should see:
      | Success animation |
      | Amount transferred |
      | Recipient name |
      | Transaction ID |
      | Date/time |
      | "Share Receipt" button |
      | "Done" button |

  @success
  Scenario: Share receipt from success
    Given the success screen is displayed
    When user taps "Share Receipt"
    Then receipt should be generated
    And share sheet should open

  @success
  Scenario: Navigate home from success
    Given the success screen is displayed
    When user taps "Done"
    Then they should return to home
    And balance should be updated

  # ============================================
  # NOTIFICATIONS
  # ============================================

  @notifications
  Scenario: View notification bell badge
    Given the user has unread notifications
    When they view home
    Then the notification bell should show badge count

  @notifications
  Scenario: Open notifications
    Given the user taps the notification bell
    Then they should navigate to "/notifications"

  # ============================================
  # SETTINGS ACCESS
  # ============================================

  @settings
  Scenario: Open settings from home
    Given the user taps the settings/gear icon
    Then they should navigate to "/settings"

  # ============================================
  # OFFLINE MODE
  # ============================================

  @offline
  Scenario: View home while offline
    Given the device is offline
    When user opens home
    Then cached balance should display
    And "Offline mode" banner should appear
    And some actions may be disabled

  @offline
  Scenario: Queue transfer while offline
    Given the device is offline
    When user initiates a transfer
    Then transfer should be queued
    And "Will send when online" message shown
    And pending transfers banner visible
