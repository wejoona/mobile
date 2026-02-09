# STATUS: ACTIVE
# Feature: Send Money (Internal Transfer)
# Screens: recipient_screen, amount_screen, confirm_screen, pin_verification_screen, result_screen

@send @transfer @critical
Feature: Send Money to Another Wallet User

  Background:
    Given the user is logged in
    And has a verified wallet
    And has a balance of $100.00 USDC

  # ============================================
  # RECIPIENT SELECTION
  # ============================================

  @recipient
  Scenario: Enter phone number manually
    Given the user is on the recipient screen
    When they enter phone number "+2250123456789"
    Then the system should validate the number
    And show if the recipient is a registered user

  @recipient
  Scenario: Search for recipient by name
    Given the user has contacts synced
    When they type "John" in the search field
    Then matching contacts should be filtered
    And show both device contacts and saved beneficiaries

  @recipient
  Scenario: Select from recent recipients
    Given the user has sent money before
    When they view the recipient screen
    Then recent recipients should be displayed at the top
    And they can tap to select one

  @recipient
  Scenario: Select from saved beneficiaries
    Given the user has saved beneficiaries
    When they tap the "Beneficiaries" tab
    Then all saved beneficiaries should be displayed
    And they can select one

  @recipient
  Scenario: Scan QR code to select recipient
    Given the user is on the recipient screen
    When they tap the QR scan icon
    And scan a valid wallet QR code
    Then the recipient should be auto-populated
    And the user proceeds to amount screen

  @recipient
  Scenario: Invalid recipient - unregistered phone
    Given the user enters a phone number not registered
    When the validation completes
    Then a message "This user is not registered. Invite them?" should appear
    And an option to send invite link should be available

  @recipient
  Scenario: Cannot send to self
    Given the user enters their own phone number
    When validation runs
    Then an error "Cannot send to yourself" should display

  # ============================================
  # AMOUNT ENTRY
  # ============================================

  @amount
  Scenario: Enter valid amount within balance
    Given the user selected a recipient
    And is on the amount screen
    When they enter "50.00"
    Then the amount should be accepted
    And local currency equivalent should be shown
    And the "Continue" button should be enabled

  @amount
  Scenario: Enter amount exceeding balance
    Given the user has $100.00 balance
    When they enter "150.00"
    Then an error "Insufficient balance" should display
    And the "Continue" button should be disabled

  @amount
  Scenario: Enter amount below minimum
    Given minimum transfer is $1.00
    When they enter "0.50"
    Then an error "Minimum transfer is $1.00" should display
    And the "Continue" button should be disabled

  @amount
  Scenario: Enter amount exceeding daily limit
    Given the user's daily limit is $500
    And they've already sent $450 today
    When they enter "100.00"
    Then a warning "Exceeds daily limit. Remaining: $50" should display

  @amount
  Scenario: Add transfer note
    Given the user entered a valid amount
    When they tap "Add Note"
    And enter "For dinner last night"
    Then the note should be saved
    And displayed on the confirmation screen

  @amount
  Scenario: Use quick amount buttons
    Given the user is on the amount screen
    When they tap the "$25" quick button
    Then the amount field should populate with "25.00"

  @amount
  Scenario: Toggle between USDC and local currency
    Given the user is on the amount screen
    When they tap the currency toggle
    Then they can enter amount in local currency
    And see USDC equivalent in real-time

  # ============================================
  # CONFIRMATION
  # ============================================

  @confirm
  Scenario: Review transfer details
    Given the user completed amount entry
    When they are on the confirmation screen
    Then they should see:
      | Recipient name    |
      | Recipient phone   |
      | Amount in USDC    |
      | Amount in local   |
      | Transfer fee      |
      | Total deduction   |
      | Note (if any)     |

  @confirm
  Scenario: Fee calculation displayed
    Given the transfer fee is 0.5%
    And the user is sending $100
    When viewing confirmation
    Then the fee should show as "$0.50"
    And total should be "$100.50"

  @confirm
  Scenario: Zero-fee transfer
    Given the user is sending to a wallet user
    And internal transfers are fee-free
    Then the fee should show as "$0.00"
    And a "No fees!" badge should appear

  @confirm
  Scenario: Edit transfer before confirming
    Given the user is on confirmation screen
    When they tap "Edit"
    Then they should return to amount screen
    And previous values should be preserved

  @confirm
  Scenario: Confirm transfer
    Given all details are correct
    When the user taps "Confirm"
    Then they should proceed to PIN verification

  # ============================================
  # PIN VERIFICATION
  # ============================================

  @pin-verify
  Scenario: Correct PIN completes transfer
    Given the user is on PIN verification
    When they enter the correct PIN
    Then the transfer should be executed
    And they should see the result screen

  @pin-verify
  Scenario: Incorrect PIN
    Given the user is verifying with PIN
    When they enter an incorrect PIN
    Then an error should display
    And remaining attempts shown
    And PIN input cleared

  @pin-verify
  Scenario: Biometric verification
    Given the user has biometrics enabled for transactions
    When they are on PIN screen
    And tap the biometric icon
    And authenticate successfully
    Then the transfer should execute

  @pin-verify
  Scenario: Cancel transfer
    Given the user is on PIN verification
    When they tap the back button
    Then they should return to confirmation
    And transfer should NOT be executed

  @pin-verify
  Scenario: PIN locked during transfer
    Given the user failed PIN 5 times
    When they fail again
    Then the transfer should be cancelled
    And PIN should be locked
    And they see auth_locked_view

  # ============================================
  # RESULT SCREEN
  # ============================================

  @result
  Scenario: Successful transfer
    Given the transfer completed successfully
    When the result screen displays
    Then they should see success animation
    And transfer amount
    And transaction ID
    And recipient name
    And "Share Receipt" button
    And "Done" button

  @result
  Scenario: Failed transfer - insufficient funds
    Given the transfer failed due to insufficient funds
    When the result screen displays
    Then they should see error message
    And reason for failure
    And "Try Again" button

  @result
  Scenario: Failed transfer - network error
    Given the transfer failed due to network
    When the result screen displays
    Then they should see "Network error" message
    And "Retry" button
    And the transfer should be queued for retry

  @result
  Scenario: Share receipt
    Given the transfer was successful
    When the user taps "Share Receipt"
    Then a receipt image/PDF should be generated
    And the share sheet should open

  @result
  Scenario: View transaction after success
    Given the transfer was successful
    When the user taps "View Transaction"
    Then they should navigate to transaction detail
    With all transfer information

  @result
  Scenario: Return to home after transfer
    Given the transfer completed
    When the user taps "Done"
    Then they should return to home screen
    And the balance should be updated
    And the transaction should appear in history

  # ============================================
  # EDGE CASES
  # ============================================

  @edge-case
  Scenario: Transfer during balance update
    Given the user initiated a transfer
    And another incoming transfer arrived simultaneously
    When the transfer completes
    Then both transactions should process correctly
    And balance should reflect both

  @edge-case
  Scenario: App backgrounded during transfer
    Given the user confirmed a transfer
    And entered PIN
    When the app goes to background
    And returns to foreground
    Then the transfer result should be shown
    Or loading state if still processing

  @edge-case
  Scenario: Network lost during transfer
    Given the user is on PIN verification
    When network connectivity is lost
    And they enter PIN
    Then the transfer should be queued
    And a message "Will retry when online" should show
    And it should auto-retry when connected

  @edge-case
  Scenario: Duplicate transfer prevention
    Given the user just completed a transfer
    When they quickly initiate another identical transfer
    Then a warning "Duplicate transfer detected" should show
    And they should confirm it's intentional
