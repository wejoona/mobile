# STATUS: ACTIVE
# Feature: Finite State Machine (FSM) State Screens
# Screens: All fsm_states/views/*.dart

@fsm @state-management @security
Feature: FSM State-Driven Screens

  Background:
    Given the app uses FSM for navigation control

  # ============================================
  # LOADING STATE
  # ============================================

  @loading
  Scenario: App loading state
    Given the app is initializing
    When loading_view is shown
    Then user should see loading indicator
    And app logo
    And initialization should complete
    And navigate to appropriate screen

  @loading
  Scenario: Loading timeout
    Given loading takes more than 30 seconds
    Then error message should show
    And "Retry" option available

  # ============================================
  # OTP EXPIRED
  # ============================================

  @otp-expired
  Scenario: OTP expired during verification
    Given user is verifying OTP
    And OTP has expired
    When FSM transitions to otp_expired
    Then otp_expired_view should show
    With message "Code expired"
    And "Get New Code" button

  @otp-expired
  Scenario: Request new OTP from expired view
    Given user is on otp_expired_view
    When they tap "Get New Code"
    Then new OTP should be sent
    And user returns to OTP entry

  # ============================================
  # AUTH LOCKED
  # ============================================

  @auth-locked
  Scenario: Account locked after failed attempts
    Given user failed PIN/OTP 5 times
    When FSM transitions to auth_locked
    Then auth_locked_view should show
    With lockout duration displayed
    And "Contact Support" option

  @auth-locked
  Scenario: Lockout countdown
    Given account is locked for 15 minutes
    Then countdown timer should display
    And update in real-time
    When timer reaches 0
    Then user should be able to try again

  @auth-locked
  Scenario: Contact support from locked
    Given user is on auth_locked_view
    When they tap "Contact Support"
    Then support options should show
    And they can request unlock

  # ============================================
  # AUTH SUSPENDED
  # ============================================

  @auth-suspended
  Scenario: Account suspended
    Given user's account is suspended
    When FSM transitions to auth_suspended
    Then auth_suspended_view should show
    With suspension reason
    And "Appeal" or "Contact Support" options

  @auth-suspended
  Scenario: Appeal suspension
    Given user believes suspension is error
    When they tap "Appeal"
    Then appeal form should open
    With account details pre-filled

  # ============================================
  # SESSION LOCKED
  # ============================================

  @session-locked
  Scenario: Session timeout
    Given user has been idle for 15 minutes
    When FSM detects inactivity
    Then session_locked_view should show
    And require re-authentication

  @session-locked
  Scenario: Unlock with PIN
    Given user is on session_locked_view
    When they enter correct PIN
    Then session should resume
    And they return to previous screen

  @session-locked
  Scenario: Unlock with biometric
    Given biometrics are enabled
    When user authenticates with Face ID
    Then session should resume

  @session-locked
  Scenario: Failed unlock attempts
    Given user fails to unlock 3 times
    Then they should be logged out
    And must fully re-authenticate

  # ============================================
  # BIOMETRIC PROMPT
  # ============================================

  @biometric-prompt
  Scenario: Biometric required
    Given action requires biometric verification
    When FSM transitions to biometric_prompt
    Then biometric_prompt_view should show
    And native biometric dialog appears

  @biometric-prompt
  Scenario: Biometric success
    Given user authenticates successfully
    Then FSM should proceed to next state
    And action should complete

  @biometric-prompt
  Scenario: Biometric fallback to PIN
    Given biometric fails or unavailable
    When user taps "Use PIN instead"
    Then PIN entry should show
    And they can authenticate with PIN

  # ============================================
  # DEVICE VERIFICATION
  # ============================================

  @device-verification
  Scenario: New device detected
    Given user logs in from new device
    When FSM detects unrecognized device
    Then device_verification_view should show
    With "Verify this device" prompt

  @device-verification
  Scenario: Verify via OTP
    Given user is on device verification
    When they receive and enter OTP
    Then device should be verified
    And optionally trusted

  @device-verification
  Scenario: Trust this device
    Given device was verified
    When user enables "Trust this device"
    Then future logins skip verification

  # ============================================
  # SESSION CONFLICT
  # ============================================

  @session-conflict
  Scenario: Multiple active sessions
    Given user is logged in on Device A
    And logs in on Device B
    When Device A detects conflict
    Then session_conflict_view should show
    With options:
      | Continue here |
      | Allow other device |

  @session-conflict
  Scenario: Continue current session
    Given user chooses "Continue here"
    Then other session should terminate
    And current session continues

  @session-conflict
  Scenario: Allow other session
    Given user chooses "Allow other device"
    Then current session should end
    And user logged out locally

  # ============================================
  # WALLET FROZEN
  # ============================================

  @wallet-frozen
  Scenario: Wallet frozen by admin
    Given user's wallet was frozen
    When FSM detects frozen status
    Then wallet_frozen_view should show
    With freeze reason if available
    And "Contact Support" option

  @wallet-frozen
  Scenario: Actions blocked when frozen
    Given wallet is frozen
    Then all financial actions should be blocked
    And user cannot send/receive/withdraw
    But can view balance and history

  @wallet-frozen
  Scenario: Request unfreeze
    Given user taps "Request Review"
    Then support ticket should create
    With account details

  # ============================================
  # WALLET UNDER REVIEW
  # ============================================

  @wallet-under-review
  Scenario: Wallet under compliance review
    Given wallet flagged for review
    When FSM detects review status
    Then wallet_under_review_view should show
    With message "Your account is under review"
    And estimated review time

  @wallet-under-review
  Scenario: Limited functionality during review
    Given wallet is under review
    Then some actions may be limited
    And user informed of restrictions

  @wallet-under-review
  Scenario: Review complete
    Given review is completed
    And wallet cleared
    Then normal functionality resumes
    And user notified

  # ============================================
  # KYC EXPIRED
  # ============================================

  @kyc-expired
  Scenario: KYC documents expired
    Given user's ID documents have expired
    When FSM detects expiration
    Then kyc_expired_view should show
    With "Renew Documents" option

  @kyc-expired
  Scenario: Limited functionality with expired KYC
    Given KYC is expired
    Then transaction limits may be reduced
    And some features disabled

  @kyc-expired
  Scenario: Renew KYC
    Given user taps "Renew Documents"
    Then they should navigate to KYC flow
    With document renewal focus

  # ============================================
  # FSM TRANSITIONS
  # ============================================

  @transitions
  Scenario: Deep link to blocked screen
    Given wallet is frozen
    And user clicks deep link to /send
    Then FSM should intercept
    And show wallet_frozen_view instead

  @transitions
  Scenario: State recovery after app restart
    Given user was on session_locked_view
    When app is killed and restarted
    Then FSM should restore state
    And user sees appropriate screen

  @transitions
  Scenario: Multiple state flags
    Given wallet is frozen AND KYC expired
    Then most critical state should show first
    And user guided through resolution
