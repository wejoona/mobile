# STATUS: ACTIVE
# Feature: Settings & Account Management
# Screens: settings_screen, profile_view, security_view, change_pin_view, notification_settings_view, etc.

@settings @account
Feature: Settings & Account Management

  Background:
    Given the user is logged in

  # ============================================
  # SETTINGS HOME
  # ============================================

  @settings-home
  Scenario: View settings menu
    Given the user navigates to settings
    Then they should see:
      | Profile section |
      | Security section |
      | Preferences section |
      | About section |
      | Logout button |

  # ============================================
  # PROFILE
  # ============================================

  @profile
  Scenario: View profile
    Given the user taps "Profile"
    Then they should see:
      | Profile photo |
      | Full name |
      | Phone number |
      | Email (if set) |
      | KYC status |
      | Account created date |

  @profile
  Scenario: Edit profile photo
    Given the user is on profile
    When they tap the profile photo
    Then options should appear:
      | Take photo |
      | Choose from gallery |
      | Remove photo |

  @profile
  Scenario: Update display name
    Given the user taps "Edit"
    When they change their display name
    And tap "Save"
    Then name should update
    And confirmation shown

  @profile
  Scenario: Add email address
    Given the user hasn't added email
    When they tap "Add Email"
    And enter a valid email
    Then verification email should be sent
    And email shown as "Pending verification"

  # ============================================
  # SECURITY
  # ============================================

  @security
  Scenario: View security settings
    Given the user taps "Security"
    Then they should see:
      | Change PIN |
      | Biometric authentication |
      | Two-factor authentication |
      | Active sessions |
      | Trusted devices |

  @change-pin
  Scenario: Change PIN successfully
    Given the user taps "Change PIN"
    When they enter current PIN correctly
    And enter new PIN twice
    And PINs match
    Then PIN should be updated
    And confirmation shown

  @change-pin
  Scenario: Change PIN - wrong current PIN
    Given the user enters wrong current PIN
    Then error "Incorrect current PIN" should show
    And remaining attempts displayed

  @change-pin
  Scenario: Change PIN - PINs don't match
    Given the user entered new PIN
    When confirmation PIN doesn't match
    Then error "PINs don't match" should show
    And user retries confirmation

  @biometric
  Scenario: Enable biometric authentication
    Given the user is on security settings
    And device supports biometrics
    When they toggle biometrics ON
    And authenticate with biometric
    Then biometric login should be enabled

  @biometric
  Scenario: Disable biometric authentication
    Given biometrics are enabled
    When user toggles OFF
    And confirms with PIN
    Then biometric login should be disabled

  @sessions
  Scenario: View active sessions
    Given the user has multiple sessions
    When they tap "Active Sessions"
    Then all sessions should list:
      | Device name |
      | Location |
      | Last active time |
      | Current session badge |

  @sessions
  Scenario: Revoke a session
    Given multiple sessions exist
    When user taps "Revoke" on another session
    And confirms
    Then that session should be terminated
    And list should update

  @sessions
  Scenario: Revoke all other sessions
    Given the user taps "Revoke All Others"
    And confirms
    Then all other sessions should terminate
    And only current remains

  # ============================================
  # NOTIFICATION SETTINGS
  # ============================================

  @notifications
  Scenario: View notification preferences
    Given the user opens notification settings
    Then they should see toggles for:
      | Transaction alerts |
      | Marketing messages |
      | Security alerts |
      | Price alerts |
      | Promotional offers |

  @notifications
  Scenario: Disable marketing notifications
    Given marketing is enabled
    When user toggles it OFF
    Then they should stop receiving marketing push notifications
    And preference should save

  @notifications
  Scenario: Security alerts cannot be disabled
    Given security alerts are critical
    Then the toggle should be disabled
    And message "Cannot disable security alerts" shown

  # ============================================
  # LANGUAGE & LOCALE
  # ============================================

  @language
  Scenario: Change app language
    Given the user opens language settings
    When they select "Français"
    Then app should immediately switch to French
    And all UI text should translate

  @language
  Scenario: Language list
    Given user views language options
    Then available languages should show:
      | English |
      | Français |
      | Español |
      | (others based on support) |

  # ============================================
  # THEME
  # ============================================

  @theme
  Scenario: Switch to dark mode
    Given the app is in light mode
    When user selects "Dark"
    Then app theme should change to dark
    And persist across sessions

  @theme
  Scenario: System theme
    Given user selects "System"
    Then app should follow device theme setting

  # ============================================
  # CURRENCY
  # ============================================

  @currency
  Scenario: Change display currency
    Given user opens currency settings
    When they select "EUR"
    Then local currency displays should convert to EUR
    And rates should use EUR conversion

  # ============================================
  # LIMITS
  # ============================================

  @limits
  Scenario: View transaction limits
    Given the user opens limits
    Then they should see:
      | Daily limit and usage |
      | Monthly limit and usage |
      | Single transaction limit |
      | KYC tier and upgrade option |

  @limits
  Scenario: Request limit increase
    Given user wants higher limits
    When they tap "Request Increase"
    Then options should show:
      | Upgrade KYC tier |
      | Contact support |

  # ============================================
  # HELP & SUPPORT
  # ============================================

  @help
  Scenario: Access help center
    Given the user taps "Help"
    Then help center should open with:
      | FAQ section |
      | Contact support |
      | Chat support |
      | Email support |

  @help
  Scenario: Start support chat
    Given the user taps "Chat with Us"
    Then support chat should open
    With conversation history if any

  @help
  Scenario: Email support
    Given user taps "Email Support"
    Then email composer should open
    Pre-filled with support address
    And device/app info

  # ============================================
  # ABOUT
  # ============================================

  @about
  Scenario: View app information
    Given the user taps "About"
    Then they should see:
      | App version |
      | Build number |
      | Terms of Service link |
      | Privacy Policy link |
      | Licenses |

  @about
  Scenario: View Terms of Service
    Given user taps "Terms of Service"
    Then legal document should display
    In a readable format

  @about
  Scenario: View Privacy Policy
    Given user taps "Privacy Policy"
    Then privacy policy should display

  # ============================================
  # LOGOUT
  # ============================================

  @logout
  Scenario: Logout successfully
    Given the user taps "Logout"
    When confirmation dialog appears
    And they tap "Logout"
    Then session should be terminated
    And user redirected to login
    And local sensitive data cleared

  @logout
  Scenario: Cancel logout
    Given the user taps "Logout"
    When they tap "Cancel" in dialog
    Then they should remain logged in
    And stay on settings screen

  # ============================================
  # ACCOUNT DELETION
  # ============================================

  @delete-account
  Scenario: Request account deletion
    Given the user wants to delete account
    When they tap "Delete Account"
    Then they should see warnings about:
      | Data that will be deleted |
      | Funds that need withdrawal first |
      | Waiting period before deletion |

  @delete-account
  Scenario: Cannot delete with positive balance
    Given the user has funds in wallet
    When they try to delete account
    Then error "Withdraw funds first" should show
    And account cannot be deleted
