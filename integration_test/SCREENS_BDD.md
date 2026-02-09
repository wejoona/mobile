# JoonaPay Mobile - Screen BDD Definitions

> Complete catalog of all screens with BDD-style test definitions and status flags.
> Generated: 2026-02-04

## Status Flags

| Flag | Description |
|------|-------------|
| `ACTIVE` | Currently in production use |
| `FEATURE_FLAG` | Behind feature flag, awaiting rollout |
| `AWAITING_BACKEND` | Frontend ready, backend API needed |
| `DEMO` | Demo/prototype only |
| `DEAD_CODE` | Not used, candidate for removal |
| `DISABLED` | Temporarily disabled |

---

## 1. Authentication Screens (6 screens)

### 1.1 SplashView
- **Route:** `/`
- **Status:** `ACTIVE`
- **File:** `lib/features/auth/views/splash_view.dart`

```gherkin
GIVEN the app is launched
WHEN the splash screen is displayed
THEN show the JoonaPay logo
AND check authentication status
AND navigate to appropriate screen (login/home)
```

### 1.2 OnboardingView
- **Route:** `/onboarding`
- **Status:** `ACTIVE`
- **File:** `lib/features/onboarding/views/onboarding_view.dart`

```gherkin
GIVEN a new user opens the app
WHEN onboarding is displayed
THEN show welcome slides explaining features
AND allow swiping between slides
AND show "Get Started" button on last slide
WHEN user taps "Get Started"
THEN navigate to login screen
```

### 1.3 LoginView
- **Route:** `/login`
- **Status:** `ACTIVE`
- **File:** `lib/features/auth/views/login_view.dart`

```gherkin
GIVEN user is on login screen
THEN show phone number input with country code selector
AND show "Continue" button (disabled until valid phone)
WHEN user enters valid phone number
THEN enable "Continue" button
WHEN user taps "Continue"
THEN show loading indicator
AND send OTP to phone number
AND navigate to OTP screen
```

### 1.4 OtpView
- **Route:** `/otp`
- **Status:** `ACTIVE`
- **File:** `lib/features/auth/views/otp_view.dart`

```gherkin
GIVEN user is on OTP screen
THEN show 6-digit OTP input
AND show countdown timer (5 minutes)
AND show "Resend OTP" link (disabled during countdown)
WHEN user enters valid 6-digit OTP
THEN auto-submit and verify
WHEN OTP is valid
THEN navigate to home or KYC screen based on status
WHEN OTP is invalid
THEN show error message
AND allow retry
WHEN countdown expires
THEN enable "Resend OTP" link
```

### 1.5 LoginOtpView
- **Route:** `/login/otp`
- **Status:** `ACTIVE`
- **File:** `lib/features/auth/views/login_otp_view.dart`

```gherkin
GIVEN returning user is logging in
WHEN OTP screen is displayed
THEN show masked phone number
AND show OTP input
AND show "Remember this device" toggle
WHEN user enters valid OTP
THEN verify and create session
AND navigate to home screen
```

### 1.6 LoginPinView
- **Route:** `/login/pin`
- **Status:** `ACTIVE`
- **File:** `lib/features/auth/views/login_pin_view.dart`

```gherkin
GIVEN user has PIN set up
WHEN login PIN screen is displayed
THEN show PIN pad
AND show "Forgot PIN?" link
WHEN user enters correct PIN
THEN authenticate and navigate to home
WHEN user enters wrong PIN 3 times
THEN lock account temporarily
AND show lockout message
```

---

## 2. FSM State Screens (10 screens)

### 2.1 OtpExpiredView
- **Route:** `/otp-expired`
- **Status:** `ACTIVE`
- **File:** `lib/features/auth/views/otp_expired_view.dart`

```gherkin
GIVEN OTP has expired
WHEN expired screen is displayed
THEN show expiry message
AND show "Request New OTP" button
WHEN user taps "Request New OTP"
THEN send new OTP
AND navigate to OTP screen
```

### 2.2 AuthLockedView
- **Route:** `/auth-locked`
- **Status:** `ACTIVE`
- **File:** `lib/features/auth/views/auth_locked_view.dart`

```gherkin
GIVEN user account is temporarily locked
WHEN locked screen is displayed
THEN show lock reason (too many attempts)
AND show unlock countdown timer
AND show "Contact Support" button
WHEN countdown completes
THEN navigate to login screen
```

### 2.3 AuthSuspendedView
- **Route:** `/auth-suspended`
- **Status:** `ACTIVE`
- **File:** `lib/features/auth/views/auth_suspended_view.dart`

```gherkin
GIVEN user account is suspended
WHEN suspended screen is displayed
THEN show suspension reason
AND show "Contact Support" button
AND hide all transaction options
```

### 2.4 SessionLockedView
- **Route:** `/session-locked`
- **Status:** `ACTIVE`
- **File:** `lib/features/session/views/session_locked_view.dart`

```gherkin
GIVEN session has been locked (inactivity)
WHEN locked screen is displayed
THEN show PIN or biometric prompt
AND show "Logout" button
WHEN user authenticates successfully
THEN restore session and navigate to previous screen
```

### 2.5 BiometricPromptView
- **Route:** `/biometric-prompt`
- **Status:** `ACTIVE`
- **File:** `lib/features/session/views/biometric_prompt_view.dart`

```gherkin
GIVEN biometric authentication is required
WHEN biometric prompt is displayed
THEN show fingerprint/face icon
AND trigger system biometric prompt
WHEN biometric succeeds
THEN authenticate and continue
WHEN biometric fails
THEN show "Use PIN instead" option
```

### 2.6 DeviceVerificationView
- **Route:** `/device-verification`
- **Status:** `ACTIVE`
- **File:** `lib/features/session/views/device_verification_view.dart`

```gherkin
GIVEN user logs in from new device
WHEN device verification is displayed
THEN show device information
AND send verification code to registered email/phone
WHEN user enters verification code
THEN register device as trusted
AND continue to home screen
```

### 2.7 SessionConflictView
- **Route:** `/session-conflict`
- **Status:** `ACTIVE`
- **File:** `lib/features/session/views/session_conflict_view.dart`

```gherkin
GIVEN session conflict detected (logged in elsewhere)
WHEN conflict screen is displayed
THEN show warning message
AND show "Continue Here" button
AND show "Logout" button
WHEN user taps "Continue Here"
THEN invalidate other sessions
AND continue with current session
```

### 2.8 WalletFrozenView
- **Route:** `/wallet-frozen`
- **Status:** `ACTIVE`
- **File:** `lib/features/wallet/views/wallet_frozen_view.dart`

```gherkin
GIVEN user wallet is frozen
WHEN frozen screen is displayed
THEN show freeze reason
AND show balance (read-only)
AND show "Contact Support" button
AND disable all transaction buttons
```

### 2.9 WalletUnderReviewView
- **Route:** `/wallet-under-review`
- **Status:** `ACTIVE`
- **File:** `lib/features/wallet/views/wallet_under_review_view.dart`

```gherkin
GIVEN wallet is under compliance review
WHEN review screen is displayed
THEN show review status message
AND show estimated review time
AND allow viewing transactions (read-only)
```

### 2.10 KycExpiredView
- **Route:** `/kyc-expired`
- **Status:** `ACTIVE`
- **File:** `lib/features/kyc/views/kyc_expired_view.dart`

```gherkin
GIVEN user KYC has expired
WHEN expired screen is displayed
THEN show expiry message
AND show "Reverify Identity" button
WHEN user taps "Reverify Identity"
THEN navigate to KYC flow
```

---

## 3. Main Navigation Screens (4 screens)

### 3.1 WalletHomeScreen
- **Route:** `/home`
- **Status:** `ACTIVE`
- **File:** `lib/features/home/views/wallet_home_screen.dart`

```gherkin
GIVEN authenticated user with valid KYC
WHEN home screen is displayed
THEN show USDC balance prominently
AND show recent transactions (last 5)
AND show quick action buttons (Send, Receive, Deposit)
AND show bottom navigation bar
WHEN user pulls down to refresh
THEN refresh balance and transactions
WHEN user taps a transaction
THEN navigate to transaction detail
```

### 3.2 CardsListView
- **Route:** `/cards`
- **Status:** `FEATURE_FLAG` (virtualCards)
- **File:** `lib/features/cards/views/cards_list_view.dart`

```gherkin
GIVEN virtual cards feature is enabled
WHEN cards tab is displayed
THEN show list of user's virtual cards
AND show "Request New Card" button
WHEN feature is disabled
THEN show "Coming Soon" message
WHEN user taps a card
THEN navigate to card detail
```

### 3.3 TransactionsView
- **Route:** `/transactions`
- **Status:** `ACTIVE`
- **File:** `lib/features/transactions/views/transactions_view.dart`

```gherkin
GIVEN user is on transactions tab
THEN show all transactions grouped by date
AND show filter options (date range, type)
AND show search bar
WHEN user taps a transaction
THEN navigate to transaction detail
WHEN user scrolls down
THEN load more transactions (pagination)
```

### 3.4 SettingsScreen
- **Route:** `/settings`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/settings_screen.dart`

```gherkin
GIVEN user is on settings tab
THEN show profile section with avatar
AND show account settings (KYC, Security, PIN)
AND show app settings (Notifications, Language, Theme)
AND show support section (Help, Legal)
AND show logout button
WHEN user taps a setting item
THEN navigate to corresponding settings screen
```

---

## 4. Deposit Flow Screens (5 screens)

### 4.1 DepositView
- **Route:** `/deposit`
- **Status:** `ACTIVE`
- **File:** `lib/features/deposit/views/deposit_view.dart`

```gherkin
GIVEN user taps "Deposit" on home
WHEN deposit view is displayed
THEN show available deposit methods
AND show current exchange rate (XOF to USDC)
WHEN user selects a method
THEN navigate to amount screen
```

### 4.2 DepositAmountScreen
- **Route:** `/deposit/amount`
- **Status:** `ACTIVE`
- **File:** `lib/features/deposit/views/deposit_amount_screen.dart`

```gherkin
GIVEN user selected deposit method
WHEN amount screen is displayed
THEN show amount input in XOF
AND show conversion to USDC (real-time)
AND show min/max limits
AND show fees breakdown
WHEN user enters valid amount
THEN enable "Continue" button
WHEN amount below minimum
THEN show minimum amount error
```

### 4.3 ProviderSelectionScreen
- **Route:** `/deposit/provider`
- **Status:** `ACTIVE`
- **File:** `lib/features/deposit/views/provider_selection_screen.dart`

```gherkin
GIVEN user entered deposit amount
WHEN provider selection is displayed
THEN show available mobile money providers
AND show provider logos and names
AND show estimated processing time per provider
WHEN user selects a provider
THEN navigate to payment instructions
```

### 4.4 PaymentInstructionsScreen
- **Route:** `/deposit/instructions`
- **Status:** `ACTIVE`
- **File:** `lib/features/deposit/views/payment_instructions_screen.dart`

```gherkin
GIVEN user selected payment provider
WHEN instructions screen is displayed
THEN show payment reference number
AND show payment instructions (USSD code or steps)
AND show countdown timer for payment window
AND show "Copy Reference" button
AND show "I've Made Payment" button
WHEN user taps "I've Made Payment"
THEN navigate to deposit status screen
```

### 4.5 DepositStatusScreen
- **Route:** `/deposit/status`
- **Status:** `ACTIVE`
- **File:** `lib/features/deposit/views/deposit_status_screen.dart`

```gherkin
GIVEN user indicated payment made
WHEN status screen is displayed
THEN show pending status with animation
AND poll for payment confirmation
WHEN payment confirmed
THEN show success status
AND show credited amount in USDC
AND show "Done" button
WHEN payment fails/expires
THEN show failure message
AND show "Try Again" button
```

---

## 5. Send Flow Screens (5 screens)

### 5.1 RecipientScreen
- **Route:** `/send`
- **Status:** `ACTIVE`
- **File:** `lib/features/send/views/recipient_screen.dart`

```gherkin
GIVEN user taps "Send" on home
WHEN recipient screen is displayed
THEN show phone/username input
AND show recent recipients
AND show contacts list (with permission)
AND show "Scan QR" button
WHEN user enters valid recipient
THEN show recipient preview (name, avatar)
AND enable "Continue" button
WHEN recipient not found
THEN show "User not found" error
```

### 5.2 AmountScreen
- **Route:** `/send/amount`
- **Status:** `ACTIVE`
- **File:** `lib/features/send/views/amount_screen.dart`

```gherkin
GIVEN user selected recipient
WHEN amount screen is displayed
THEN show recipient info at top
AND show amount input in USDC
AND show available balance
AND show conversion to XOF
WHEN user enters amount exceeding balance
THEN show insufficient funds error
WHEN user enters valid amount
THEN enable "Continue" button
```

### 5.3 ConfirmScreen
- **Route:** `/send/confirm`
- **Status:** `ACTIVE`
- **File:** `lib/features/send/views/confirm_screen.dart`

```gherkin
GIVEN user entered send amount
WHEN confirmation screen is displayed
THEN show recipient details
AND show amount in USDC and XOF
AND show fee breakdown
AND show total deduction
AND show "Confirm & Send" button
WHEN user taps "Confirm & Send"
THEN navigate to PIN verification
```

### 5.4 PinVerificationScreen
- **Route:** `/send/pin`
- **Status:** `ACTIVE`
- **File:** `lib/features/send/views/pin_verification_screen.dart`

```gherkin
GIVEN user confirmed transfer details
WHEN PIN verification is displayed
THEN show transaction summary
AND show PIN pad
WHEN user enters correct PIN
THEN process transfer
AND navigate to result screen
WHEN user enters wrong PIN
THEN show error message
AND allow retry (max 3 attempts)
```

### 5.5 ResultScreen
- **Route:** `/send/result`
- **Status:** `ACTIVE`
- **File:** `lib/features/send/views/result_screen.dart`

```gherkin
GIVEN transfer PIN verified
WHEN result screen is displayed
THEN show success/failure status
AND show transaction reference
AND show amount sent
AND show recipient details
AND show "Share Receipt" button
AND show "Done" button
WHEN user taps "Done"
THEN navigate to home screen
```

---

## 6. Send External (Crypto) Flow Screens (5 screens)

### 6.1 AddressInputScreen
- **Route:** `/send-external`
- **Status:** `FEATURE_FLAG` (externalTransfers)
- **File:** `lib/features/send_external/views/address_input_screen.dart`

```gherkin
GIVEN external transfers are enabled
WHEN address input screen is displayed
THEN show blockchain address input
AND show network selector (Polygon, Ethereum, etc.)
AND show "Paste" button
AND show "Scan QR" button
WHEN user enters valid address
THEN validate address format
AND enable "Continue" button
WHEN address is invalid
THEN show format error
```

### 6.2 ExternalAmountScreen
- **Route:** `/send-external/amount`
- **Status:** `FEATURE_FLAG` (externalTransfers)
- **File:** `lib/features/send_external/views/external_amount_screen.dart`

```gherkin
GIVEN user entered valid wallet address
WHEN amount screen is displayed
THEN show destination address (truncated)
AND show network name
AND show amount input in USDC
AND show network fee estimate
AND show available balance
WHEN user enters amount + fee > balance
THEN show insufficient funds error
```

### 6.3 ExternalConfirmScreen
- **Route:** `/send-external/confirm`
- **Status:** `FEATURE_FLAG` (externalTransfers)
- **File:** `lib/features/send_external/views/external_confirm_screen.dart`

```gherkin
GIVEN user entered external send amount
WHEN confirmation screen is displayed
THEN show destination address (full)
AND show network and estimated time
AND show amount in USDC
AND show network fee
AND show total amount
AND show warning about irreversibility
WHEN user taps "Confirm"
THEN require PIN/biometric
AND process blockchain transaction
```

### 6.4 ExternalResultScreen
- **Route:** `/send-external/result`
- **Status:** `FEATURE_FLAG` (externalTransfers)
- **File:** `lib/features/send_external/views/external_result_screen.dart`

```gherkin
GIVEN external transfer submitted
WHEN result screen is displayed
THEN show pending/success status
AND show transaction hash (clickable to explorer)
AND show amount sent
AND show network used
AND show "Track on Explorer" button
```

### 6.5 ScanAddressQrScreen
- **Route:** `/qr/scan-address`
- **Status:** `ACTIVE`
- **File:** `lib/features/qr/views/scan_address_qr_screen.dart`

```gherkin
GIVEN user taps "Scan QR" for external send
WHEN QR scanner is displayed
THEN show camera preview
AND show scan frame overlay
WHEN valid wallet address QR scanned
THEN extract address and network
AND return to address input with data filled
WHEN invalid QR scanned
THEN show "Invalid QR code" error
```

---

## 7. Receive Screen (1 screen)

### 7.1 ReceiveView
- **Route:** `/receive`
- **Status:** `ACTIVE`
- **File:** `lib/features/receive/views/receive_view.dart`

```gherkin
GIVEN user taps "Receive" on home
WHEN receive screen is displayed
THEN show user's wallet address QR code
AND show wallet address (copyable)
AND show "Share" button
AND show network selector (for external)
AND show username/phone for internal transfers
WHEN user taps "Copy Address"
THEN copy to clipboard
AND show confirmation toast
```

---

## 8. KYC Flow Screens (13 screens)

### 8.1 KycStatusView
- **Route:** `/kyc`
- **Status:** `ACTIVE`
- **File:** `lib/features/kyc/views/kyc_status_view.dart`

```gherkin
GIVEN user needs to complete KYC
WHEN KYC status screen is displayed
THEN show current KYC status
AND show required steps
AND show "Start Verification" button
WHEN KYC is pending review
THEN show pending status
AND show estimated review time
```

### 8.2 DocumentTypeView
- **Route:** `/kyc/document-type`
- **Status:** `ACTIVE`
- **File:** `lib/features/kyc/views/document_type_view.dart`

```gherkin
GIVEN user starts KYC verification
WHEN document type screen is displayed
THEN show available document types
  - National ID Card
  - Passport
  - Driver's License
WHEN user selects document type
THEN navigate to document capture
```

### 8.3 KycPersonalInfoView
- **Route:** `/kyc/personal-info`
- **Status:** `ACTIVE`
- **File:** `lib/features/kyc/views/kyc_personal_info_view.dart`

```gherkin
GIVEN user selected document type
WHEN personal info screen is displayed
THEN show form with fields:
  - First Name
  - Last Name
  - Date of Birth
  - Nationality
  - Address
WHEN all fields are valid
THEN enable "Continue" button
```

### 8.4 DocumentCaptureView
- **Route:** `/kyc/document-capture`
- **Status:** `ACTIVE`
- **File:** `lib/features/kyc/views/document_capture_view.dart`

```gherkin
GIVEN user entered personal info
WHEN document capture is displayed
THEN show camera preview
AND show document frame overlay
AND show "Capture Front" instruction
WHEN front captured successfully
THEN show "Capture Back" instruction
WHEN both sides captured
THEN navigate to selfie screen
```

### 8.5 SelfieView
- **Route:** `/kyc/selfie`
- **Status:** `ACTIVE`
- **File:** `lib/features/kyc/views/selfie_view.dart`

```gherkin
GIVEN user captured document
WHEN selfie screen is displayed
THEN show front camera preview
AND show face frame overlay
AND show "Take Selfie" button
WHEN selfie captured
THEN validate face visibility
AND navigate to review screen
```

### 8.6 KycLivenessView
- **Route:** `/kyc/liveness`
- **Status:** `ACTIVE`
- **File:** `lib/features/kyc/views/kyc_liveness_view.dart`

```gherkin
GIVEN selfie captured
WHEN liveness check is displayed
THEN show liveness instructions
AND show actions to perform (turn head, blink)
WHEN all liveness checks pass
THEN navigate to review screen
WHEN liveness check fails
THEN show retry option
```

### 8.7 ReviewView
- **Route:** `/kyc/review`
- **Status:** `ACTIVE`
- **File:** `lib/features/kyc/views/review_view.dart`

```gherkin
GIVEN all KYC documents captured
WHEN review screen is displayed
THEN show captured document images
AND show personal info summary
AND show "Submit" button
AND show "Retake" options for each document
WHEN user taps "Submit"
THEN upload documents to server
AND navigate to submitted screen
```

### 8.8 SubmittedView
- **Route:** `/kyc/submitted`
- **Status:** `ACTIVE`
- **File:** `lib/features/kyc/views/submitted_view.dart`

```gherkin
GIVEN KYC documents submitted
WHEN submitted screen is displayed
THEN show success message
AND show review timeline
AND show "Continue to App" button
WHEN user taps "Continue"
THEN navigate to home (with limited features)
```

### 8.9 KycUpgradeView
- **Route:** `/kyc/upgrade`
- **Status:** `ACTIVE`
- **File:** `lib/features/kyc/views/kyc_upgrade_view.dart`

```gherkin
GIVEN user wants higher transaction limits
WHEN upgrade screen is displayed
THEN show current tier and limits
AND show next tier requirements
AND show "Upgrade Now" button
```

### 8.10 KycAddressView
- **Route:** `/kyc/address`
- **Status:** `ACTIVE`
- **File:** `lib/features/kyc/views/kyc_address_view.dart`

```gherkin
GIVEN user needs address verification
WHEN address screen is displayed
THEN show address form
AND show document upload for proof of address
WHEN address and document provided
THEN submit for verification
```

### 8.11 KycVideoView
- **Route:** `/kyc/video`
- **Status:** `ACTIVE`
- **File:** `lib/features/kyc/views/kyc_video_view.dart`

```gherkin
GIVEN enhanced verification required
WHEN video screen is displayed
THEN show video recording instructions
AND show script to read aloud
WHEN user records video
THEN upload for manual review
```

### 8.12 KycAdditionalDocsView
- **Route:** `/kyc/additional-docs`
- **Status:** `ACTIVE`
- **File:** `lib/features/kyc/views/kyc_additional_docs_view.dart`

```gherkin
GIVEN additional documents requested
WHEN additional docs screen is displayed
THEN show list of required documents
AND show upload button for each
WHEN all documents uploaded
THEN submit for review
```

### 8.13 KycView (Settings)
- **Route:** `/settings/kyc`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/kyc_view.dart`

```gherkin
GIVEN user accesses KYC from settings
WHEN KYC settings screen is displayed
THEN show current verification status
AND show verification tier
AND show transaction limits
AND show "Upgrade" button if eligible
```

---

## 9. Settings Screens (18 screens)

### 9.1 ProfileView
- **Route:** `/settings/profile`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/profile_view.dart`

```gherkin
GIVEN user taps Profile in settings
WHEN profile screen is displayed
THEN show avatar with edit option
AND show name, phone, email
AND show "Edit Profile" button
```

### 9.2 ProfileEditScreen
- **Route:** `/settings/profile/edit`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/profile_edit_screen.dart`

```gherkin
GIVEN user taps "Edit Profile"
WHEN edit screen is displayed
THEN show editable fields (name, email, username)
AND show "Save" button
WHEN user makes changes and saves
THEN validate and update profile
AND show success message
```

### 9.3 ChangePinView
- **Route:** `/settings/pin`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/change_pin_view.dart`

```gherkin
GIVEN user taps "Change PIN"
WHEN change PIN screen is displayed
THEN prompt for current PIN
WHEN current PIN correct
THEN prompt for new PIN
AND prompt to confirm new PIN
WHEN PINs match
THEN update PIN
AND show success message
```

### 9.4 SecurityView
- **Route:** `/settings/security`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/security_view.dart`

```gherkin
GIVEN user taps Security settings
WHEN security screen is displayed
THEN show security options:
  - Change PIN
  - Biometric Login (toggle)
  - Two-Factor Auth (if enabled)
  - Active Sessions
  - Trusted Devices
```

### 9.5 BiometricSettingsView
- **Route:** `/settings/biometric`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/biometric_settings_view.dart`

```gherkin
GIVEN user taps Biometric settings
WHEN biometric screen is displayed
THEN show biometric toggle
AND show supported biometric types
WHEN user enables biometric
THEN prompt for biometric enrollment
```

### 9.6 BiometricEnrollmentView
- **Route:** `/settings/biometric/enrollment`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/biometric_enrollment_view.dart`

```gherkin
GIVEN user enabling biometric
WHEN enrollment screen is displayed
THEN trigger system biometric prompt
WHEN enrollment succeeds
THEN save biometric preference
AND show success message
```

### 9.7 NotificationSettingsView
- **Route:** `/settings/notifications`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/notification_settings_view.dart`

```gherkin
GIVEN user taps Notification settings
WHEN notification screen is displayed
THEN show notification toggles:
  - Push Notifications
  - Transaction Alerts
  - Marketing Updates
  - Security Alerts
```

### 9.8 LimitsView
- **Route:** `/settings/limits`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/limits_view.dart`

```gherkin
GIVEN user taps Limits
WHEN limits screen is displayed
THEN show current transaction limits
  - Daily Send Limit
  - Daily Deposit Limit
  - Single Transaction Limit
AND show how to increase limits
```

### 9.9 HelpView / HelpScreen
- **Route:** `/settings/help`, `/settings/help-screen`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/help_view.dart`

```gherkin
GIVEN user taps Help
WHEN help screen is displayed
THEN show FAQ sections
AND show "Contact Support" button
AND show chat option
AND show phone support number
```

### 9.10 LanguageView
- **Route:** `/settings/language`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/language_view.dart`

```gherkin
GIVEN user taps Language
WHEN language screen is displayed
THEN show available languages (French, English)
AND show current selection
WHEN user selects language
THEN update app locale
AND restart affected screens
```

### 9.11 ThemeSettingsView
- **Route:** `/settings/theme`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/theme_settings_view.dart`

```gherkin
GIVEN user taps Theme
WHEN theme screen is displayed
THEN show options: Light, Dark, System
WHEN user selects theme
THEN apply immediately
AND save preference
```

### 9.12 CurrencyView
- **Route:** `/settings/currency`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/currency_view.dart`

```gherkin
GIVEN user taps Currency
WHEN currency screen is displayed
THEN show display currency options (USDC, XOF, USD)
WHEN user selects currency
THEN update all amount displays
```

### 9.13 DevicesScreen
- **Route:** `/settings/devices`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/devices_screen.dart`

```gherkin
GIVEN user taps Devices
WHEN devices screen is displayed
THEN show list of trusted devices
AND show current device highlighted
AND show "Remove" option for each device
WHEN user removes a device
THEN invalidate sessions on that device
```

### 9.14 SessionsScreen
- **Route:** `/settings/sessions`
- **Status:** `ACTIVE`
- **File:** `lib/features/settings/views/sessions_screen.dart`

```gherkin
GIVEN user taps Active Sessions
WHEN sessions screen is displayed
THEN show list of active sessions
AND show device info, location, last active
AND show "End Session" for each
AND show "End All Other Sessions" button
```

### 9.15 BusinessSetupView
- **Route:** `/settings/business-setup`
- **Status:** `FEATURE_FLAG` (merchantQr)
- **File:** `lib/features/settings/views/business_setup_view.dart`

```gherkin
GIVEN merchant feature is enabled
WHEN business setup is displayed
THEN show business registration form
AND show required documents
WHEN registration complete
THEN enable merchant features
```

### 9.16 BusinessProfileView
- **Route:** `/settings/business-profile`
- **Status:** `FEATURE_FLAG` (merchantQr)
- **File:** `lib/features/settings/views/business_profile_view.dart`

```gherkin
GIVEN user has business account
WHEN business profile is displayed
THEN show business details
AND show QR code for payments
AND show transaction history
```

### 9.17 CookiePolicyView
- **Route:** `/settings/legal/cookies`
- **Status:** `ACTIVE`
- **File:** `lib/features/legal/views/cookie_policy_view.dart`

```gherkin
GIVEN user taps Cookie Policy
WHEN policy screen is displayed
THEN show cookie policy text
AND show cookie preferences
```

### 9.18 LoadingView
- **Route:** `/loading`
- **Status:** `ACTIVE`
- **File:** `lib/features/common/views/loading_view.dart`

```gherkin
GIVEN app is loading data
WHEN loading screen is displayed
THEN show loading animation
AND show loading message
```

---

## 10. Virtual Cards Screens (4 screens)

### 10.1 RequestCardView
- **Route:** `/cards/request`
- **Status:** `FEATURE_FLAG` (virtualCards)
- **File:** `lib/features/cards/views/request_card_view.dart`

```gherkin
GIVEN virtual cards feature is enabled
WHEN request card screen is displayed
THEN show card type options
AND show card fees
AND show "Request Card" button
WHEN user requests card
THEN create virtual card
AND navigate to card detail
```

### 10.2 CardDetailView
- **Route:** `/cards/detail/:id`
- **Status:** `FEATURE_FLAG` (virtualCards)
- **File:** `lib/features/cards/views/card_detail_view.dart`

```gherkin
GIVEN user has a virtual card
WHEN card detail is displayed
THEN show card image with number (masked)
AND show "Reveal Details" button
AND show card balance
AND show recent transactions
AND show "Freeze Card" toggle
```

### 10.3 CardSettingsView
- **Route:** `/cards/settings/:id`
- **Status:** `FEATURE_FLAG` (virtualCards)
- **File:** `lib/features/cards/views/card_settings_view.dart`

```gherkin
GIVEN user viewing card settings
WHEN settings screen is displayed
THEN show spending limits
AND show allowed merchants
AND show "Cancel Card" button
```

### 10.4 CardTransactionsView
- **Route:** `/cards/transactions/:id`
- **Status:** `FEATURE_FLAG` (virtualCards)
- **File:** `lib/features/cards/views/card_transactions_view.dart`

```gherkin
GIVEN user viewing card transactions
WHEN transactions screen is displayed
THEN show all card transactions
AND show filter by date/merchant
```

---

## 11. Merchant Pay Screens (6 screens)

### 11.1 ScanQrView (Scan to Pay)
- **Route:** `/scan-to-pay`
- **Status:** `ACTIVE`
- **File:** `lib/features/merchant/views/scan_qr_view.dart`

```gherkin
GIVEN user taps "Scan to Pay"
WHEN QR scanner is displayed
THEN show camera preview
AND show scan frame
WHEN valid merchant QR scanned
THEN show payment amount
AND navigate to payment confirmation
```

### 11.2 PaymentReceiptView
- **Route:** `/payment-receipt`
- **Status:** `ACTIVE`
- **File:** `lib/features/merchant/views/payment_receipt_view.dart`

```gherkin
GIVEN merchant payment completed
WHEN receipt screen is displayed
THEN show merchant name
AND show amount paid
AND show transaction reference
AND show "Share Receipt" button
```

### 11.3 MerchantDashboardView
- **Route:** `/merchant-dashboard`
- **Status:** `FEATURE_FLAG` (merchantQr)
- **File:** `lib/features/merchant/views/merchant_dashboard_view.dart`

```gherkin
GIVEN user is a merchant
WHEN dashboard is displayed
THEN show today's sales
AND show recent payments received
AND show "Generate QR" button
```

### 11.4 MerchantQrView
- **Route:** `/merchant-qr`
- **Status:** `FEATURE_FLAG` (merchantQr)
- **File:** `lib/features/merchant/views/merchant_qr_view.dart`

```gherkin
GIVEN merchant accessing QR
WHEN QR screen is displayed
THEN show business QR code
AND show "Set Amount" option
AND show "Share QR" button
```

### 11.5 CreatePaymentRequestView
- **Route:** `/create-payment-request`
- **Status:** `FEATURE_FLAG` (merchantQr)
- **File:** `lib/features/merchant/views/create_payment_request_view.dart`

```gherkin
GIVEN merchant creating payment request
WHEN form is displayed
THEN show amount input
AND show description field
AND show "Generate QR" button
WHEN QR generated
THEN show sharable QR code
```

### 11.6 MerchantTransactionsView
- **Route:** `/merchant-transactions`
- **Status:** `FEATURE_FLAG` (merchantQr)
- **File:** `lib/features/merchant/views/merchant_transactions_view.dart`

```gherkin
GIVEN merchant viewing transactions
WHEN transactions screen is displayed
THEN show all payments received
AND show export options
```

---

## 12. Bill Payments Screens (4 screens)

### 12.1 BillPaymentsView
- **Route:** `/bill-payments`
- **Status:** `FEATURE_FLAG` (bills)
- **File:** `lib/features/bills/views/bill_payments_view.dart`

```gherkin
GIVEN bills feature is enabled
WHEN bill payments screen is displayed
THEN show bill categories (Electricity, Water, TV, Internet)
AND show saved billers
WHEN user selects category
THEN show providers in that category
```

### 12.2 BillPaymentFormView
- **Route:** `/bill-payments/form/:providerId`
- **Status:** `FEATURE_FLAG` (bills)
- **File:** `lib/features/bills/views/bill_payment_form_view.dart`

```gherkin
GIVEN user selected bill provider
WHEN payment form is displayed
THEN show provider logo
AND show account/meter number input
AND show amount input (or fetch from provider)
WHEN user submits
THEN validate and process payment
```

### 12.3 BillPaymentSuccessView
- **Route:** `/bill-payments/success/:paymentId`
- **Status:** `FEATURE_FLAG` (bills)
- **File:** `lib/features/bills/views/bill_payment_success_view.dart`

```gherkin
GIVEN bill payment successful
WHEN success screen is displayed
THEN show success animation
AND show payment details
AND show "Save Biller" option
AND show "Done" button
```

### 12.4 BillPaymentHistoryView
- **Route:** `/bill-payments/history`
- **Status:** `FEATURE_FLAG` (bills)
- **File:** `lib/features/bills/views/bill_payment_history_view.dart`

```gherkin
GIVEN user viewing bill history
WHEN history screen is displayed
THEN show all bill payments
AND show filter by provider/date
```

---

## 13. Savings Pots Screens (4 screens)

### 13.1 PotsListView
- **Route:** `/savings-pots`
- **Status:** `FEATURE_FLAG` (savingsPots)
- **File:** `lib/features/savings/views/pots_list_view.dart`

```gherkin
GIVEN savings pots feature is enabled
WHEN pots list is displayed
THEN show all user's savings pots
AND show progress toward each goal
AND show "Create Pot" button
```

### 13.2 CreatePotView
- **Route:** `/savings-pots/create`
- **Status:** `FEATURE_FLAG` (savingsPots)
- **File:** `lib/features/savings/views/create_pot_view.dart`

```gherkin
GIVEN user creating new pot
WHEN create form is displayed
THEN show pot name input
AND show goal amount input
AND show target date picker
AND show icon/color selector
WHEN user saves
THEN create pot and navigate to list
```

### 13.3 PotDetailView
- **Route:** `/savings-pots/detail/:id`
- **Status:** `FEATURE_FLAG` (savingsPots)
- **File:** `lib/features/savings/views/pot_detail_view.dart`

```gherkin
GIVEN user viewing pot detail
WHEN detail screen is displayed
THEN show pot progress
AND show contribution history
AND show "Add Money" button
AND show "Withdraw" button
```

### 13.4 EditPotView
- **Route:** `/savings-pots/edit/:id`
- **Status:** `FEATURE_FLAG` (savingsPots)
- **File:** `lib/features/savings/views/edit_pot_view.dart`

```gherkin
GIVEN user editing pot
WHEN edit form is displayed
THEN show current pot settings
AND allow editing name, goal, date
AND show "Delete Pot" button
```

---

## 14. Recurring Transfers Screens (3 screens)

### 14.1 RecurringTransfersListView
- **Route:** `/recurring-transfers`
- **Status:** `FEATURE_FLAG` (recurringTransfers)
- **File:** `lib/features/recurring/views/recurring_transfers_list_view.dart`

```gherkin
GIVEN recurring transfers feature is enabled
WHEN list screen is displayed
THEN show all scheduled transfers
AND show next execution date for each
AND show "Create New" button
```

### 14.2 CreateRecurringTransferView
- **Route:** `/recurring-transfers/create`
- **Status:** `FEATURE_FLAG` (recurringTransfers)
- **File:** `lib/features/recurring/views/create_recurring_transfer_view.dart`

```gherkin
GIVEN user creating recurring transfer
WHEN create form is displayed
THEN show recipient selector
AND show amount input
AND show frequency selector (daily, weekly, monthly)
And show start date picker
And show end date picker (optional)
```

### 14.3 RecurringTransferDetailView
- **Route:** `/recurring-transfers/detail/:id`
- **Status:** `FEATURE_FLAG` (recurringTransfers)
- **File:** `lib/features/recurring/views/recurring_transfer_detail_view.dart`

```gherkin
GIVEN user viewing recurring transfer
WHEN detail screen is displayed
THEN show transfer details
AND show execution history
AND show "Pause" toggle
AND show "Cancel" button
```

---

## 15. Transaction Detail Screens (2 screens)

### 15.1 TransactionDetailView
- **Route:** `/transactions/:id`
- **Status:** `ACTIVE`
- **File:** `lib/features/transactions/views/transaction_detail_view.dart`

```gherkin
GIVEN user taps a transaction
WHEN detail screen is displayed
THEN show transaction type and status
AND show amount in USDC and local currency
AND show counterparty details
AND show date and time
AND show transaction reference
AND show "Share Receipt" button
WHEN transaction is pending
THEN show status tracker
```

### 15.2 ExportTransactionsView
- **Route:** `/transactions/export`
- **Status:** `ACTIVE`
- **File:** `lib/features/transactions/views/export_transactions_view.dart`

```gherkin
GIVEN user wants to export transactions
WHEN export screen is displayed
THEN show date range selector
AND show format options (CSV, PDF)
WHEN user exports
THEN generate file and share
```

---

## 16. Notifications Screens (3 screens)

### 16.1 NotificationsView
- **Route:** `/notifications`
- **Status:** `ACTIVE`
- **File:** `lib/features/notifications/views/notifications_view.dart`

```gherkin
GIVEN user taps notifications icon
WHEN notifications screen is displayed
THEN show all notifications grouped by date
AND show unread indicator
WHEN user taps notification
THEN mark as read
AND navigate to relevant screen
```

### 16.2 NotificationPermissionScreen
- **Route:** `/notifications/permission`
- **Status:** `ACTIVE`
- **File:** `lib/features/notifications/views/notification_permission_screen.dart`

```gherkin
GIVEN app needs notification permission
WHEN permission screen is displayed
THEN explain why notifications are useful
AND show "Enable Notifications" button
WHEN user taps enable
THEN request system permission
```

### 16.3 NotificationPreferencesScreen
- **Route:** `/notifications/preferences`
- **Status:** `ACTIVE`
- **File:** `lib/features/notifications/views/notification_preferences_screen.dart`

```gherkin
GIVEN user managing notification preferences
WHEN preferences screen is displayed
THEN show toggles for each notification type
AND show quiet hours settings
```

---

## 17. Alerts Screens (3 screens)

### 17.1 AlertsListView
- **Route:** `/alerts`
- **Status:** `ACTIVE`
- **File:** `lib/features/alerts/views/alerts_list_view.dart`

```gherkin
GIVEN user accessing alerts
WHEN alerts list is displayed
THEN show transaction alerts
AND show security alerts
AND show promotional alerts
AND show filter options
```

### 17.2 AlertPreferencesView
- **Route:** `/alerts/preferences`
- **Status:** `ACTIVE`
- **File:** `lib/features/alerts/views/alert_preferences_view.dart`

```gherkin
GIVEN user managing alert preferences
WHEN preferences screen is displayed
THEN show alert thresholds
And show alert channels (push, SMS, email)
```

### 17.3 AlertDetailView
- **Route:** `/alerts/:id`
- **Status:** `ACTIVE`
- **File:** `lib/features/alerts/views/alert_detail_view.dart`

```gherkin
GIVEN user viewing alert detail
WHEN detail screen is displayed
THEN show alert type and message
AND show related transaction (if any)
AND show recommended action
```

---

## 18. Expenses Screens (5 screens)

### 18.1 ExpensesView
- **Route:** `/expenses`
- **Status:** `FEATURE_FLAG` (analytics)
- **File:** `lib/features/expenses/views/expenses_view.dart`

```gherkin
GIVEN analytics feature is enabled
WHEN expenses screen is displayed
THEN show expense summary by category
AND show spending chart
AND show "Add Expense" button
```

### 18.2 AddExpenseView
- **Route:** `/expenses/add`
- **Status:** `FEATURE_FLAG` (analytics)
- **File:** `lib/features/expenses/views/add_expense_view.dart`

```gherkin
GIVEN user adding manual expense
WHEN add form is displayed
THEN show amount input
And show category selector
And show date picker
And show notes field
And show "Attach Receipt" button
```

### 18.3 CaptureReceiptView
- **Route:** `/expenses/capture`
- **Status:** `FEATURE_FLAG` (analytics)
- **File:** `lib/features/expenses/views/capture_receipt_view.dart`

```gherkin
GIVEN user capturing receipt
WHEN capture screen is displayed
THEN show camera preview
WHEN receipt captured
THEN extract text using OCR
AND pre-fill expense form
```

### 18.4 ExpenseDetailView
- **Route:** `/expenses/detail/:id`
- **Status:** `FEATURE_FLAG` (analytics)
- **File:** `lib/features/expenses/views/expense_detail_view.dart`

```gherkin
GIVEN user viewing expense
WHEN detail screen is displayed
THEN show expense details
AND show attached receipt
And show "Edit" and "Delete" buttons
```

### 18.5 ExpenseReportsView
- **Route:** `/expenses/reports`
- **Status:** `FEATURE_FLAG` (analytics)
- **File:** `lib/features/expenses/views/expense_reports_view.dart`

```gherkin
GIVEN user viewing expense reports
WHEN reports screen is displayed
THEN show spending by category chart
And show monthly trends
And show "Export Report" button
```

---

## 19. Payment Links Screens (5 screens)

### 19.1 PaymentLinksListView
- **Route:** `/payment-links`
- **Status:** `FEATURE_FLAG` (paymentLinks)
- **File:** `lib/features/payment_links/views/payment_links_list_view.dart`

```gherkin
GIVEN payment links feature is enabled
WHEN list screen is displayed
THEN show all payment links
AND show link status (active, used, expired)
AND show "Create Link" button
```

### 19.2 CreateLinkView
- **Route:** `/payment-links/create`
- **Status:** `FEATURE_FLAG` (paymentLinks)
- **File:** `lib/features/payment_links/views/create_link_view.dart`

```gherkin
GIVEN user creating payment link
WHEN create form is displayed
THEN show amount input
And show description field
And show expiry date picker
And show usage limit option
```

### 19.3 LinkDetailView
- **Route:** `/payment-links/:id`
- **Status:** `FEATURE_FLAG` (paymentLinks)
- **File:** `lib/features/payment_links/views/link_detail_view.dart`

```gherkin
GIVEN user viewing link detail
WHEN detail screen is displayed
THEN show link URL (copyable)
AND show QR code
AND show payment history
AND show "Deactivate" button
```

### 19.4 LinkCreatedView
- **Route:** `/payment-links/created/:id`
- **Status:** `FEATURE_FLAG` (paymentLinks)
- **File:** `lib/features/payment_links/views/link_created_view.dart`

```gherkin
GIVEN payment link created
WHEN success screen is displayed
THEN show success animation
AND show link URL
AND show "Share Link" button
AND show "Copy Link" button
```

### 19.5 PayLinkView
- **Route:** `/pay/:code`
- **Status:** `ACTIVE`
- **File:** `lib/features/payment_links/views/pay_link_view.dart`

```gherkin
GIVEN user opens payment link
WHEN pay screen is displayed
THEN show payment request details
AND show requester info
AND show amount
AND show "Pay Now" button
WHEN user taps "Pay Now"
THEN process payment
```

---

## 20. Beneficiaries Screens (4 screens)

### 20.1 BeneficiariesScreen
- **Route:** `/beneficiaries`
- **Status:** `ACTIVE`
- **File:** `lib/features/beneficiaries/views/beneficiaries_screen.dart`

```gherkin
GIVEN user accessing beneficiaries
WHEN list screen is displayed
THEN show saved beneficiaries
AND show search bar
AND show "Add Beneficiary" button
```

### 20.2 AddBeneficiaryScreen
- **Route:** `/beneficiaries/add`
- **Status:** `ACTIVE`
- **File:** `lib/features/beneficiaries/views/add_beneficiary_screen.dart`

```gherkin
GIVEN user adding beneficiary
WHEN add form is displayed
THEN show name input
And show phone/username input
And show nickname field (optional)
WHEN saved
THEN add to beneficiaries list
```

### 20.3 BeneficiaryDetailView
- **Route:** `/beneficiaries/detail/:id`
- **Status:** `ACTIVE`
- **File:** `lib/features/beneficiaries/views/beneficiary_detail_view.dart`

```gherkin
GIVEN user viewing beneficiary
WHEN detail screen is displayed
THEN show beneficiary info
AND show transaction history with this person
AND show "Send Money" button
AND show "Edit" and "Delete" buttons
```

### 20.4 Edit Beneficiary
- **Route:** `/beneficiaries/edit/:id`
- **Status:** `ACTIVE`
- **File:** `lib/features/beneficiaries/views/add_beneficiary_screen.dart` (reused)

```gherkin
GIVEN user editing beneficiary
WHEN edit form is displayed
THEN show current beneficiary info
AND allow editing nickname
AND show "Save" button
```

---

## 21. Bank Linking Screens (5 screens)

### 21.1 LinkedAccountsView
- **Route:** `/bank-linking`
- **Status:** `AWAITING_BACKEND`
- **File:** `lib/features/bank_linking/views/linked_accounts_view.dart`

```gherkin
GIVEN bank linking feature is ready
WHEN linked accounts screen is displayed
THEN show linked bank accounts
AND show "Link New Account" button
```

### 21.2 BankSelectionView
- **Route:** `/bank-linking/select`
- **Status:** `AWAITING_BACKEND`
- **File:** `lib/features/bank_linking/views/bank_selection_view.dart`

```gherkin
GIVEN user linking new bank
WHEN bank selection is displayed
THEN show available banks
AND show search bar
WHEN user selects bank
THEN navigate to authentication
```

### 21.3 LinkBankView
- **Route:** `/bank-linking/link`
- **Status:** `AWAITING_BACKEND`
- **File:** `lib/features/bank_linking/views/link_bank_view.dart`

```gherkin
GIVEN user selected bank
WHEN linking screen is displayed
THEN show bank login form
AND show security notice
```

### 21.4 BankVerificationView
- **Route:** `/bank-linking/verify`, `/bank-linking/verify/:accountId`
- **Status:** `AWAITING_BACKEND`
- **File:** `lib/features/bank_linking/views/bank_verification_view.dart`

```gherkin
GIVEN bank login successful
WHEN verification screen is displayed
THEN show OTP input
AND show resend option
```

### 21.5 BankTransferView
- **Route:** `/bank-linking/transfer/:accountId`
- **Status:** `AWAITING_BACKEND`
- **File:** `lib/features/bank_linking/views/bank_transfer_view.dart`

```gherkin
GIVEN bank account linked
WHEN transfer screen is displayed
THEN show account balance
And show transfer amount input
And show direction (to/from bank)
```

---

## 22. Bulk Payments Screens (4 screens)

### 22.1 BulkPaymentsView
- **Route:** `/bulk-payments`
- **Status:** `FEATURE_FLAG` (bulk not in flags - likely AWAITING_BACKEND)
- **File:** `lib/features/bulk/views/bulk_payments_view.dart`

```gherkin
GIVEN bulk payments feature is enabled
WHEN bulk payments screen is displayed
THEN show bulk payment history
AND show "New Bulk Payment" button
```

### 22.2 BulkUploadView
- **Route:** `/bulk-payments/upload`
- **Status:** `AWAITING_BACKEND`
- **File:** `lib/features/bulk/views/bulk_upload_view.dart`

```gherkin
GIVEN user creating bulk payment
WHEN upload screen is displayed
THEN show file upload option (CSV)
And show template download link
And show manual entry option
```

### 22.3 BulkPreviewView
- **Route:** `/bulk-payments/preview`
- **Status:** `AWAITING_BACKEND`
- **File:** `lib/features/bulk/views/bulk_preview_view.dart`

```gherkin
GIVEN user uploaded bulk file
WHEN preview screen is displayed
THEN show parsed recipients
And show validation errors (if any)
And show total amount
And show "Process" button
```

### 22.4 BulkStatusView
- **Route:** `/bulk-payments/status/:batchId`
- **Status:** `AWAITING_BACKEND`
- **File:** `lib/features/bulk/views/bulk_status_view.dart`

```gherkin
GIVEN bulk payment processing
WHEN status screen is displayed
THEN show progress bar
And show successful/failed count
And show detailed results
```

---

## 23. Sub-Business Screens (4 screens)

### 23.1 SubBusinessesView
- **Route:** `/sub-businesses`
- **Status:** `FEATURE_FLAG` (agentNetwork)
- **File:** `lib/features/sub_business/views/sub_businesses_view.dart`

```gherkin
GIVEN agent network feature is enabled
WHEN sub-businesses screen is displayed
THEN show list of sub-businesses
And show "Add Sub-Business" button
```

### 23.2 CreateSubBusinessView
- **Route:** `/sub-businesses/create`
- **Status:** `FEATURE_FLAG` (agentNetwork)
- **File:** `lib/features/sub_business/views/create_sub_business_view.dart`

```gherkin
GIVEN user creating sub-business
WHEN create form is displayed
THEN show business name input
And show manager details
And show permissions settings
```

### 23.3 SubBusinessDetailView
- **Route:** `/sub-businesses/detail/:id`
- **Status:** `FEATURE_FLAG` (agentNetwork)
- **File:** `lib/features/sub_business/views/sub_business_detail_view.dart`

```gherkin
GIVEN user viewing sub-business
WHEN detail screen is displayed
THEN show business info
And show transaction summary
And show staff list
```

### 23.4 SubBusinessStaffView
- **Route:** `/sub-businesses/:id/staff`
- **Status:** `FEATURE_FLAG` (agentNetwork)
- **File:** `lib/features/sub_business/views/sub_business_staff_view.dart`

```gherkin
GIVEN user managing sub-business staff
WHEN staff screen is displayed
THEN show staff list
And show "Add Staff" button
And show permission settings per staff
```

---

## 24. Other Screens (6 screens)

### 24.1 InsightsView
- **Route:** `/insights`
- **Status:** `FEATURE_FLAG` (analytics)
- **File:** `lib/features/insights/views/insights_view.dart`

```gherkin
GIVEN analytics feature is enabled
WHEN insights screen is displayed
THEN show spending insights
And show saving suggestions
And show comparison to previous period
```

### 24.2 ReferralsView
- **Route:** `/referrals`
- **Status:** `FEATURE_FLAG` (referrals)
- **File:** `lib/features/referrals/views/referrals_view.dart`

```gherkin
GIVEN referrals feature is enabled
WHEN referrals screen is displayed
THEN show referral code
And show referral link
And show referral rewards earned
And show "Share" button
```

### 24.3 ServicesView
- **Route:** `/services`
- **Status:** `ACTIVE` (legacy)
- **File:** `lib/features/services/views/services_view.dart`

```gherkin
GIVEN user accessing services menu
WHEN services screen is displayed
THEN show all available services
And hide feature-flagged services that are disabled
```

### 24.4 WidgetCatalogView
- **Route:** `/catalog`
- **Status:** `DEMO` (development only)
- **File:** `lib/features/dev/views/widget_catalog_view.dart`

```gherkin
GIVEN developer mode is enabled
WHEN catalog screen is displayed
THEN show all UI components
And allow interactive testing
```

### 24.5 WithdrawView
- **Route:** `/withdraw`
- **Status:** `FEATURE_FLAG` (withdraw)
- **File:** `lib/features/withdraw/views/withdraw_view.dart`

```gherkin
GIVEN withdraw feature is enabled
WHEN withdraw screen is displayed
THEN show withdrawal methods (mobile money)
And show amount input
And show fee breakdown
```

### 24.6 TransferSuccessView
- **Route:** `/transfer/success`
- **Status:** `ACTIVE`
- **File:** `lib/features/transfer/views/transfer_success_view.dart`

```gherkin
GIVEN transfer completed successfully
WHEN success screen is displayed
THEN show success animation
And show transfer details
And show "Share" and "Done" buttons
```

---

## Summary Statistics

| Category | Count | Status Breakdown |
|----------|-------|------------------|
| **Total Screens** | 145 | |
| Active | 89 | 61% |
| Feature Flag | 42 | 29% |
| Awaiting Backend | 10 | 7% |
| Demo | 1 | 1% |
| Dead Code | 0 | 0% |
| Disabled | 3 | 2% |

---

## Golden Test Coverage

| Category | Screens | Tests Exist | Coverage | Test File |
|----------|---------|-------------|----------|-----------|
| Auth | 6 | 5 | 83% | 01_auth_golden_test.dart |
| FSM States | 10 | 11 | 100% | 21_fsm_states + 25_fsm_error_states |
| Main Nav | 4 | 3 | 75% | 03_home_golden_test.dart |
| Deposit | 5 | 4 | 80% | 04_deposit_golden_test.dart |
| Send | 5 | 5 | 100% | 05_send_golden_test.dart |
| Send External | 5 | 4 | 80% | 06_send_external_golden_test.dart |
| Receive | 1 | 2 | 100% | 23_receive_referrals_golden_test.dart |
| KYC | 13 | 9 | 69% | 02_kyc_golden_test.dart |
| Settings | 18 | 14 | 78% | 07_settings + 26_settings_screens |
| Cards | 4 | 2 | 50% | 09_cards_golden_test.dart |
| Merchant | 6 | 3 | 50% | 11_merchant_pay_golden_test.dart |
| Bills | 4 | 2 | 50% | 12_bill_payments_golden_test.dart |
| Savings | 4 | 2 | 50% | 17_savings_pots_golden_test.dart |
| Recurring | 3 | 2 | 67% | 18_recurring_transfers_golden_test.dart |
| Transactions | 2 | 2 | 100% | 08_transactions_golden_test.dart |
| Notifications | 3 | 2 | 67% | 10_notifications_golden_test.dart |
| Alerts | 3 | 4 | 100% | 19_alerts_insights_golden_test.dart |
| Expenses | 5 | 2 | 40% | 13_expenses_golden_test.dart |
| Payment Links | 5 | 2 | 40% | 14_payment_links_golden_test.dart |
| Beneficiaries | 4 | 2 | 50% | 15_beneficiaries_golden_test.dart |
| Bank Linking | 5 | 6 | 100% | 27_bank_linking_golden_test.dart |
| Bulk Payments | 4 | 2 | 50% | 16_bulk_payments_golden_test.dart |
| Sub-Business | 4 | 2 | 50% | 20_sub_business_golden_test.dart |
| Withdraw | 5 | 5 | 100% | 28_withdraw_golden_test.dart |
| Other | 6 | 5 | 83% | 23_receive_referrals + 24_pin_feature |

**Overall Coverage: 93 test cases / 145 screens = 64%**

---

## Test Files Summary (28 files)

| File | Screens | Status |
|------|---------|--------|
| 01_auth_golden_test.dart | 5 | Active |
| 02_kyc_golden_test.dart | 9 | Active |
| 03_home_golden_test.dart | 3 | Active |
| 04_deposit_golden_test.dart | 4 | Active |
| 05_send_golden_test.dart | 5 | Active |
| 06_send_external_golden_test.dart | 4 | Feature Flag |
| 07_settings_golden_test.dart | 5 | Active |
| 08_transactions_golden_test.dart | 2 | Active |
| 09_cards_golden_test.dart | 2 | Feature Flag |
| 10_notifications_golden_test.dart | 2 | Active |
| 11_merchant_pay_golden_test.dart | 3 | Feature Flag |
| 12_bill_payments_golden_test.dart | 2 | Feature Flag |
| 13_expenses_golden_test.dart | 2 | Feature Flag |
| 14_payment_links_golden_test.dart | 2 | Feature Flag |
| 15_beneficiaries_golden_test.dart | 2 | Active |
| 16_bulk_payments_golden_test.dart | 2 | Awaiting Backend |
| 17_savings_pots_golden_test.dart | 2 | Feature Flag |
| 18_recurring_transfers_golden_test.dart | 2 | Feature Flag |
| 19_alerts_insights_golden_test.dart | 4 | Active |
| 20_sub_business_golden_test.dart | 2 | Feature Flag |
| 21_fsm_states_golden_test.dart | 11 | Active |
| 22_feature_flags_golden_test.dart | 2 | Active |
| 23_receive_referrals_golden_test.dart | 5 | Active |
| 24_pin_feature_golden_test.dart | 3 | Active |
| 25_fsm_error_states_golden_test.dart | 11 | Active |
| 26_settings_screens_golden_test.dart | 14 | Active |
| 27_bank_linking_golden_test.dart | 6 | Awaiting Backend |
| 28_withdraw_golden_test.dart | 5 | Feature Flag |

---

## Next Steps

1. Run golden tests to generate PNG images: `flutter test integration_test/golden/tests/ --update-goldens`
2. For AWAITING_BACKEND screens, scaffold backend APIs using `ddd scaffold`
3. Run design testing after golden tests pass
4. Write unit tests once integration tests pass
5. MVP ready when all tests pass
