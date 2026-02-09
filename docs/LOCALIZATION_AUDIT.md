# Localization Audit Report

**Generated:** 2026-02-06  
**Project:** JoonaPay USDC Wallet Mobile App  
**Path:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile`

---

## Executive Summary

| Language | Keys | Coverage | Status |
|----------|------|----------|--------|
| **English (EN)** | 2,022 | 100% (template) | ✅ Complete |
| **French (FR)** | 2,022 | 100.0% | ✅ Complete |
| **Portuguese (PT)** | 1,904 | 94.2% | ⚠️ 118 missing |
| **Arabic (AR)** | 596 | 29.4% | ❌ 1,427 missing |

**Hardcoded Strings Found:** ~90 instances in production code

---

## 1. Translation Coverage Details

### 1.1 French (FR) - ✅ COMPLETE
- **Keys:** 2,022 / 2,022
- **Coverage:** 100%
- **Status:** Full parity with English template
- **Action Required:** None for key coverage

### 1.2 Portuguese (PT) - ⚠️ NEEDS ATTENTION
- **Keys:** 1,904 / 2,022  
- **Coverage:** 94.2%
- **Missing:** 118 keys

#### Missing Keys in Portuguese (118 total):

**Authentication & Security (26 keys):**
```
auth_accountLocked
auth_accountSuspended
auth_contactSupport
auth_lockedReason
auth_otpExpired
auth_otpExpiredMessage
auth_suspendedContactMessage
auth_suspendedReason
auth_suspendedUntil
auth_tryAgainIn
biometric_authenticateReason
biometric_promptReason
biometric_promptTitle
biometric_tryAgain
biometric_usePinInstead
common_backToHome
common_backToLogin
common_contactSupport
common_logout
device_deviceId
device_newDeviceDetected
device_verificationOptions
device_verificationOptionsDesc
device_verificationRequired
device_verifyWithEmail
device_verifyWithOtp
```

**KYC (23 keys):**
```
kyc_camera_unavailable
kyc_camera_unavailable_description
kyc_chooseFromGallery
kyc_currentRestrictions
kyc_expired
kyc_expiredMessage
kyc_expiredOn
kyc_expiredTitle
kyc_personalInfo_dateOfBirth
kyc_personalInfo_dateRequired
kyc_personalInfo_firstName
kyc_personalInfo_firstNameRequired
kyc_personalInfo_lastName
kyc_personalInfo_lastNameRequired
kyc_personalInfo_matchIdHint
kyc_personalInfo_selectDate
kyc_personalInfo_subtitle
kyc_personalInfo_title
kyc_remindLater
kyc_renewDocuments
kyc_renewalMessage
kyc_renewalRequired
kyc_restriction1, kyc_restriction2, kyc_restriction3
```

**Session Management (14 keys):**
```
session_conflict
session_conflictMessage
session_continueHere
session_enterPinToUnlock
session_expiring
session_expiringMessage
session_forceLogoutWarning
session_locked
session_lockedMessage
session_otherDevice
session_stayLoggedIn
session_unlockReason
session_useBiometric
```

**State Messages (22 keys):**
```
state_accountLocked, state_accountLockedDescription
state_accountSuspended, state_accountSuspendedDescription
state_biometricPrompt, state_biometricPromptDescription
state_deviceChanged, state_deviceChangedDescription
state_kycExpired, state_kycExpiredDescription
state_kycManualReview, state_kycManualReviewDescription
state_kycUpgrading, state_kycUpgradingDescription
state_otpExpired, state_otpExpiredDescription
state_sessionConflict, state_sessionConflictDescription
state_tokenRefreshing
state_walletFrozen, state_walletFrozenDescription
state_walletLimited, state_walletLimitedDescription
state_walletUnderReview, state_walletUnderReviewDescription
```

**Wallet (17 keys):**
```
wallet_checkStatus
wallet_estimatedTime
wallet_frozen
wallet_frozenContactMessage
wallet_frozenContactSupport
wallet_frozenReason
wallet_frozenTitle
wallet_frozenUntil
wallet_reviewEstimate
wallet_reviewRestriction1, wallet_reviewRestriction2, wallet_reviewRestriction3
wallet_reviewStarted
wallet_reviewStatus
wallet_underReview
wallet_underReviewReason
wallet_underReviewTitle
wallet_whileUnderReview
```

**Other (16 keys):**
```
settings_appearance
settings_themeDarkDescription
settings_themeLightDescription
settings_themeSystemDescription
transactions_connectionErrorMessage
transactions_connectionErrorTitle
transactions_emptyStateAction
transactions_emptyStateMessage
transactions_emptyStateTitle
transactions_noAccountMessage
transactions_noAccountTitle
```

### 1.3 Arabic (AR) - ❌ INCOMPLETE
- **Keys:** 596 / 2,022
- **Coverage:** 29.4%
- **Missing:** 1,427 keys
- **Status:** Partial implementation, needs significant work

---

## 2. Hardcoded Strings Found

**Total: ~90 instances** in production feature code (excluding examples/demos)

### 2.1 High Priority - User-Facing Messages (45 instances)

| File | Line | Hardcoded String |
|------|------|------------------|
| `features/receipts/views/share_receipt_sheet.dart` | 307 | `'Reference number copied'` |
| `features/receipts/views/share_receipt_sheet.dart` | 323 | `'Enter Email Address'` |
| `features/receipts/views/share_receipt_sheet.dart` | 333 | `'Cancel'` |
| `features/settings/views/profile_edit_screen.dart` | 311 | `'Profile updated successfully'` |
| `features/settings/views/profile_edit_screen.dart` | 321 | `'Failed to update profile: ...'` |
| `features/settings/views/kyc_view.dart` | 1061 | `'Failed to pick image: $e'` |
| `features/settings/views/kyc_view.dart` | 1102 | `'Liveness check passed! You can now take your selfie.'` |
| `features/settings/views/kyc_view.dart` | 1111 | `'Liveness check failed: ...'` |
| `features/settings/views/kyc_view.dart` | 1124 | `'Please complete liveness check first'` |
| `features/settings/views/kyc_view.dart` | 1149 | `'Failed to take selfie: $e'` |
| `features/settings/views/kyc_view.dart` | 1218 | `'KYC submitted successfully!'` |
| `features/settings/views/kyc_view.dart` | 1228 | `'Failed to submit KYC: ...'` |
| `features/settings/views/help_view.dart` | 572 | `'Connecting to support agent...'` |
| `features/settings/views/help_screen.dart` | 309 | `'Copied to clipboard'` |
| `features/settings/views/help_screen.dart` | 319 | `'Opening WhatsApp...'` |
| `features/settings/views/help_screen.dart` | 329 | `'Opening live chat...'` |
| `features/settings/views/help_screen.dart` | 380 | `'Problem reported. We\'ll get back to you soon.'` |
| `features/pin/views/enter_pin_view.dart` | 130 | `'Biometric authentication coming soon'` |
| `features/deposit/views/payment_instructions_screen.dart` | 410 | `'Checking payment status...'` |
| `features/kyc/views/kyc_video_view.dart` | 493 | `'Camera initialization failed'` |
| `features/kyc/views/document_capture_view.dart` | 157 | `'Failed to pick image: $e'` |
| `features/bulk_payments/views/bulk_upload_view.dart` | 256 | `'Failed to load file: $e'` |
| `features/expenses/views/expense_reports_view.dart` | 423, 482 | `'Error: $e'` |
| `features/merchant_pay/views/merchant_transactions_view.dart` | 87 | `'Failed to load transactions'` |
| `features/merchant_pay/views/merchant_dashboard_view.dart` | 33 | `'Merchant Dashboard'` |
| `features/merchant_pay/views/merchant_dashboard_view.dart` | 442 | `'Failed to load analytics'` |
| `features/merchant_pay/views/merchant_dashboard_view.dart` | 539 | `'See All'` |
| `features/merchant_pay/views/merchant_dashboard_view.dart` | 554 | `'Failed to load transactions'` |
| `features/merchant_pay/views/merchant_dashboard_view.dart` | 566 | `'No transactions yet'` |
| `features/merchant_pay/views/merchant_qr_view.dart` | 53 | `'Failed to share QR code'` |
| `features/merchant_pay/views/merchant_qr_view.dart` | 68 | `'QR data copied to clipboard'` |
| `features/merchant_pay/views/merchant_qr_view.dart` | 81 | `'My QR Code'` |
| `features/merchant_pay/views/create_payment_request_view.dart` | 133 | `'Request Payment'` |
| `features/merchant_pay/views/payment_confirm_view.dart` | 194 | `'Cancel'` |
| `features/merchant_pay/widgets/qr_scanner_widget.dart` | 236 | `'Try Again'` |
| `features/alerts/views/alert_detail_view.dart` | 299 | `'View Transaction'` |
| `features/transactions/views/export_transactions_view.dart` | 484 | `'Transactions exported as $format'` |
| `features/qr_payment/views/receive_qr_screen.dart` | 325, 376 | `'Failed to save/share: $e'` |
| `features/qr_payment/views/scan_qr_screen.dart` | 233 | `'Gallery import coming soon'` |
| `features/wallet/views/virtual_card_view.dart` | 665 | `'Funds added to card'` |
| `features/wallet/views/virtual_card_view.dart` | 693 | `'Card number copied'` |
| `features/wallet/views/scheduled_transfers_view.dart` | 323, 350 | `'Schedule created/deleted'` |
| `features/wallet/views/bill_pay_view.dart` | 406, 524 | Payment messages |
| `features/wallet/views/buy_airtime_view.dart` | 635, 681, 700 | Airtime purchase messages |
| `features/wallet/views/savings_goals_view.dart` | 595, 796, 808, 817, 825, 830 | Goal management messages |

### 2.2 Medium Priority - Labels & Buttons (25 instances)

| File | Line | Hardcoded String |
|------|------|------------------|
| `features/payment_links/views/create_link_view.dart` | 64 | `'CFA '` (currency prefix) |
| `features/expenses/views/capture_receipt_view.dart` | 348 | `'XOF '` (currency prefix) |
| `features/expenses/views/add_expense_view.dart` | 81 | `'XOF '` (currency prefix) |
| `features/sub_business/widgets/sub_business_card.dart` | 131, 147 | `'Transfer'`, `'View'` |
| `features/wallet/views/scan_view.dart` | 114, 295, 335 | QR code messages |
| `features/wallet/views/deposit_instructions_view.dart` | 283 | `'Copied to clipboard'` |
| `features/wallet/views/request_money_view.dart` | 342 | `'Payment link copied!'` |
| `features/wallet/views/saved_recipients_view.dart` | 313, 335, 343, 355, 370, 395, 433, 441, 445 | Recipient management |
| `features/wallet/views/withdraw_view.dart` | 190, 212 | Withdrawal messages |
| `features/wallet/views/budget_view.dart` | 619, 775, 784, 791, 801 | Budget messages |
| `features/wallet/views/split_bill_view.dart` | 666 | `'Payment requests sent...'` |
| `features/wallet/widgets/risk_step_up_dialog.dart` | 269, 300 | `'Close'`, `'Cancel'` |
| `features/send_external/views/external_result_screen.dart` | 292 | `'Would open: $explorerUrl'` |
| `features/notifications/views/notifications_view.dart` | 361 | `'Failed to mark all as read'` |

### 2.3 Low Priority - Developer/Debug (20 instances)

| File | Line | Note |
|------|------|------|
| `features/settings/views/performance_monitor_view.dart` | 25 | Debug view title |
| `features/settings/views/settings_screen.dart` | 298 | Debug URL message |
| `features/alerts/views/alert_detail_view.dart` | 457 | Action name (dynamic) |

---

## 3. Recommendations

### 3.1 Immediate Actions (High Priority)

1. **Complete Portuguese Translations (118 keys)**
   - Focus on authentication and security strings first
   - KYC flow is critical for user onboarding
   - Session management affects UX significantly

2. **Fix High-Priority Hardcoded Strings (~45 instances)**
   - Create new l10n keys for all user-facing messages
   - Prioritize error messages and success notifications
   - Update SnackBar messages to use localized strings

### 3.2 Short-Term Actions (Medium Priority)

1. **Arabic Translation Completion**
   - Current 29.4% coverage is insufficient for production
   - Consider whether AR is a launch target language
   - If yes, allocate translation resources (~1,427 keys)

2. **Standardize Currency Prefixes**
   - Move `'CFA '`, `'XOF '` prefixes to l10n
   - Consider locale-aware currency formatting

3. **Review Button Labels**
   - `'Cancel'`, `'Delete'`, `'View'`, etc. should use existing l10n keys
   - Ensure consistent usage of `l10n.action_cancel` pattern

### 3.3 Long-Term Actions (Low Priority)

1. **Translation Quality Audit**
   - Review FR translations for consistency and tone
   - Check for proper pluralization rules
   - Verify date/time format localization

2. **Automated Tooling**
   - Add lint rule to detect hardcoded strings
   - Consider CI check for l10n key parity
   - Set up translation management platform (e.g., Lokalise, Crowdin)

---

## 4. File Locations

```
lib/l10n/
├── app_en.arb          # Template (2,022 keys)
├── app_fr.arb          # French (2,022 keys) ✅
├── app_pt.arb          # Portuguese (1,904 keys) ⚠️
├── app_ar.arb          # Arabic (596 keys) ❌
├── app_localizations.dart
├── app_localizations_en.dart
├── app_localizations_fr.dart
├── app_localizations_pt.dart
└── app_localizations_ar.dart

l10n.yaml               # Flutter localization config
```

---

## 5. Quick Reference: Adding Missing PT Keys

To add missing Portuguese translations:

1. Open `lib/l10n/app_pt.arb`
2. Copy the key-value pairs from `app_en.arb` for missing keys
3. Translate the values to Portuguese
4. Run `flutter gen-l10n` to regenerate
5. Test the app in Portuguese locale

Example for a missing key:
```json
// In app_en.arb
"auth_accountLocked": "Account Locked",

// Add to app_pt.arb
"auth_accountLocked": "Conta Bloqueada",
```

---

## 6. Summary Statistics

| Metric | Value |
|--------|-------|
| Total l10n keys | 2,022 |
| Languages supported | 4 (EN, FR, PT, AR) |
| Languages complete | 2 (EN, FR) |
| Missing PT keys | 118 |
| Missing AR keys | 1,427 |
| Hardcoded strings | ~90 |
| High-priority fixes | ~45 |

---

*Report generated by localization audit script*
