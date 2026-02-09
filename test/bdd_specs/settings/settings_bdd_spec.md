# STATUS: ACTIVE
# Settings Feature - BDD Specifications

## Overview
Comprehensive settings screen and sub-screens for profile, security, and preferences.

## Screens Covered
- `/settings` - Main Settings Screen
- `/settings/profile` - Profile View
- `/settings/profile/edit` - Profile Edit
- `/settings/kyc` - KYC Settings
- `/settings/pin` - Change PIN
- `/settings/security` - Security Settings
- `/settings/biometric` - Biometric Settings
- `/settings/devices` - Trusted Devices
- `/settings/sessions` - Active Sessions
- `/settings/limits` - Transaction Limits
- `/settings/language` - Language Selection
- `/settings/currency` - Currency Display
- `/settings/theme` - Theme Settings
- `/settings/notifications` - Notification Settings
- `/settings/help` - Help & Support

---

## Feature: Settings Screen

### Screen: SettingsScreen
**File:** `lib/features/settings/views/settings_screen.dart`
**Route:** `/settings`

```gherkin
Feature: Settings Main Screen

  Background:
    Given I am authenticated
    And I am on the settings screen

  @smoke @settings @display
  Scenario: Display settings sections
    Then I should see "Settings" title
    And I should see profile card with:
      | Element       | Content              |
      | Avatar        | Initials in gold     |
      | Name          | User's display name  |
      | Phone         | Formatted phone      |
      | Verified      | Badge if KYC done    |
    And I should see "PROFILE" section
    And I should see "SECURITY" section
    And I should see "PREFERENCES" section
    And I should see "ABOUT" section
    And I should see referral card
    And I should see "Logout" button
    And I should see app version

  @settings @profile_card
  Scenario: Navigate from profile card
    When I tap the profile card
    Then I should navigate to "/settings/profile"

  @settings @profile
  Scenario: Profile section items
    Then "PROFILE" section should contain:
      | Item           | Route                   |
      | Edit Profile   | /settings/profile/edit  |
      | KYC            | /settings/kyc           |

  @settings @security
  Scenario: Security section items
    Then "SECURITY" section should contain:
      | Item              | Route                   |
      | Change PIN        | /settings/pin           |
      | Biometric         | (toggle in-place)       |
      | Devices           | /settings/devices       |
      | Active Sessions   | /settings/sessions      |
      | Security Settings | /settings/security      |
      | Transaction Limits| /settings/limits        |

  @settings @biometric
  Scenario: Toggle biometric authentication
    Given device supports Face ID
    And biometric is disabled
    When I toggle the biometric switch
    Then biometric prompt should appear
    When I authenticate successfully
    Then biometric should be enabled
    And switch should show "on"

  @settings @preferences
  Scenario: Preferences section items
    Then "PREFERENCES" section should contain:
      | Item          | Current Value     | Route                    |
      | Language      | English           | /settings/language       |
      | Currency      | USDC + XOF        | /settings/currency       |
      | Theme         | Dark              | (dialog)                 |
      | Notifications | -                 | /settings/notifications  |

  @settings @theme
  Scenario: Change theme via dialog
    When I tap "Theme"
    Then theme selection dialog should appear
    With options: Light, Dark, System
    When I select "Light"
    Then app should switch to light theme
    And preference should persist

  @settings @about
  Scenario: About section items
    Then "ABOUT" section should contain:
      | Item           | Action              |
      | Help & Support | /settings/help      |
      | Terms          | Open external link  |
      | Privacy Policy | Open external link  |

  @settings @referral
  Scenario: Referral card
    Then referral card should show:
      | Element     | Value                  |
      | Title       | Refer & Earn           |
      | Icon        | Gift card icon         |
      | Styling     | Gold accent            |
    When I tap referral card
    Then I should navigate to "/referrals"

  @settings @logout
  Scenario: Logout
    When I tap "Logout"
    Then confirmation dialog should appear
    When I tap "Logout" in dialog
    Then I should be logged out
    And I should navigate to "/login"

  @settings @logout @cancel
  Scenario: Cancel logout
    When I tap "Logout"
    And tap "Cancel" in dialog
    Then dialog should close
    And I should remain on settings

  @settings @debug
  Scenario: Access debug menu
    When I tap version text 7 times
    Then debug menu dialog should appear
    Showing:
      - App version
      - Environment (dev/staging/prod)
      - Mock mode status
```

---

## Feature: Profile Edit

### Screen: ProfileEditScreen
**File:** `lib/features/settings/views/profile_edit_screen.dart`
**Route:** `/settings/profile/edit`

```gherkin
Feature: Edit Profile

  Background:
    Given I am on the profile edit screen

  @settings @profile @edit
  Scenario: Display edit form
    Then I should see "Edit Profile" title
    And I should see editable fields:
      | Field      | Current Value    |
      | First Name | John             |
      | Last Name  | Doe              |
      | Email      | (optional)       |
    And I should see "Save" button

  @settings @profile @save
  Scenario: Save profile changes
    When I change first name to "Jane"
    And tap "Save"
    Then profile should update
    And I should see success message
    And I should navigate back to settings
```

---

## Feature: Change PIN

### Screen: ChangePinView
**File:** `lib/features/settings/views/change_pin_view.dart`
**Route:** `/settings/pin`

```gherkin
Feature: Change PIN

  Background:
    Given I am on the change PIN screen

  @settings @pin
  Scenario: Change PIN flow
    Then I should see "Enter current PIN" step
    When I enter my current PIN correctly
    Then I should see "Enter new PIN" step
    When I enter new PIN "5678"
    Then I should see "Confirm new PIN" step
    When I enter "5678" again
    Then PIN should be changed
    And I should see success message

  @settings @pin @mismatch
  Scenario: PIN confirmation mismatch
    Given I've entered new PIN "5678"
    When I enter "5679" as confirmation
    Then I should see "PINs don't match" error
    And I should re-enter new PIN
```

---

## Feature: Devices Management

### Screen: DevicesScreen
**File:** `lib/features/settings/views/devices_screen.dart`
**Route:** `/settings/devices`

```gherkin
Feature: Manage Trusted Devices

  Background:
    Given I am on the devices screen

  @settings @devices
  Scenario: Display devices list
    Then I should see "Trusted Devices" title
    And I should see list of devices:
      | Element     | Content                |
      | Device Name | iPhone 15 Pro          |
      | Last Active | Active now / 2h ago    |
      | This Device | Badge on current       |

  @settings @devices @remove
  Scenario: Remove device
    When I tap "Remove" on another device
    Then confirmation should appear
    When I confirm
    Then device should be removed
```

---

## Feature: Language Selection

### Screen: LanguageView
**File:** `lib/features/settings/views/language_view.dart`
**Route:** `/settings/language`

```gherkin
Feature: Select Language

  Background:
    Given I am on the language selection screen

  @settings @language
  Scenario: Display language options
    Then I should see "Language" title
    And I should see language options:
      | Language   | Code |
      | English    | en   |
      | Français   | fr   |

  @settings @language @change
  Scenario: Change language
    Given current language is English
    When I select "Français"
    Then app should switch to French
    And all text should be in French
    And preference should persist
```

---

## Feature: Currency Display

### Screen: CurrencyView
**File:** `lib/features/settings/views/currency_view.dart`
**Route:** `/settings/currency`

```gherkin
Feature: Currency Display Settings

  Background:
    Given I am on the currency settings screen

  @settings @currency
  Scenario: Display currency options
    Then I should see "Currency Display" title
    And I should see "Primary: USDC" (not editable)
    And I should see "Show Reference Currency" toggle
    And I should see reference currency dropdown (XOF, GHS, etc.)

  @settings @currency @reference
  Scenario: Enable reference currency
    Given reference currency is disabled
    When I toggle "Show Reference Currency" on
    And select "XOF"
    Then home screen should show XOF conversions
    And transactions should show XOF amounts
```

---

## Feature: Transaction Limits

### Screen: LimitsView
**File:** `lib/features/settings/views/limits_view.dart`
**Route:** `/settings/limits`

```gherkin
Feature: View Transaction Limits

  Background:
    Given I am on the limits screen

  @settings @limits
  Scenario: Display limits
    Then I should see "Transaction Limits" title
    And I should see limit cards:
      | Type         | Limit    | Used     | Remaining |
      | Daily        | $1,000   | $250     | $750      |
      | Monthly      | $10,000  | $1,500   | $8,500    |
      | Per Transfer | $500     | -        | -         |
    And I should see progress bars

  @settings @limits @increase
  Scenario: Request limit increase
    Then I should see "Request Limit Increase" link
    When I tap it
    Then limit increase form/info should appear
```

---

## API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/users/me` | GET | Get profile |
| `/users/me` | PATCH | Update profile |
| `/auth/change-pin` | POST | Change PIN |
| `/devices` | GET | List devices |
| `/devices/{id}` | DELETE | Remove device |
| `/sessions` | GET | List sessions |
| `/sessions/{id}` | DELETE | End session |
| `/limits` | GET | Get limits |
| `/preferences` | GET/PATCH | User preferences |

---

## Golden Test Variations

### Settings Main
1. Full settings screen - light
2. Full settings screen - dark
3. KYC verified badge
4. KYC unverified
5. Biometric available
6. Biometric unavailable
7. Logout dialog
8. Debug menu

### Profile Edit
1. Edit form
2. Saving state
3. Success message

### Devices
1. Multiple devices
2. Single device (current)
3. Remove confirmation

### Limits
1. Within limits
2. Near daily limit
3. At limit

---

*Part of USDC Wallet Complete Testing Suite*
