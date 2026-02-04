# JoonaPay USDC Wallet - Screen Inventory

> **BDD-style documentation of all screens with status and test requirements**

## Legend

| Status | Meaning |
|--------|---------|
| `ACTIVE` | Production-ready, routed in app |
| `FEATURE_FLAG` | Gated by feature flag, may be disabled |
| `AWAITING_BACKEND` | Frontend ready, backend API pending |
| `DEMO` | Demo/showcase only, not connected |
| `DEAD_CODE` | Not routed, likely obsolete |
| `DISABLED` | Intentionally disabled for MVP |

---

## 1. AUTH FLOW

### 1.1 Splash Screen
- **File:** `lib/features/splash/views/splash_view.dart`
- **Route:** `/`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN the app launches
  WHEN the splash screen displays
  THEN the JoonaPay logo should be visible
  AND the app should auto-navigate based on auth state
  ```

### 1.2 Onboarding Screen
- **File:** `lib/features/onboarding/views/onboarding_view.dart`
- **Route:** `/onboarding`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN a new user opens the app
  WHEN the onboarding screen displays
  THEN the user should see feature highlights
  AND a "Skip" button should be available
  AND a "Get Started" button should be available
  ```

### 1.3 Login Screen
- **File:** `lib/features/auth/views/login_view.dart`
- **Route:** `/login`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN an unauthenticated user
  WHEN the login screen displays
  THEN a phone number input should be visible
  AND a country code selector should be visible (+225 default)
  AND a "Continue" button should be visible
  ```

### 1.4 OTP Screen (Secure Login)
- **File:** `lib/features/auth/views/otp_view.dart`
- **Route:** `/otp`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN a user has entered their phone number
  WHEN the OTP screen displays
  THEN "Secure Login" title should be visible
  AND a custom PinPad with digits 0-9 should be visible
  AND a "Resend Code" option should be visible
  AND entering 6 digits should auto-submit
  ```

### 1.5 Login OTP View
- **File:** `lib/features/auth/views/login_otp_view.dart`
- **Route:** `/login/otp`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN a returning user
  WHEN they verify with OTP
  THEN the standard OTP flow should apply
  ```

### 1.6 Login PIN View
- **File:** `lib/features/auth/views/login_pin_view.dart`
- **Route:** `/login/pin`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN a user has completed OTP
  WHEN PIN is required
  THEN a 6-digit PIN entry should be shown
  ```

### 1.7 Login Phone View
- **File:** `lib/features/auth/views/login_phone_view.dart`
- **Route:** None (component)
- **Status:** `DEAD_CODE` - Superseded by login_view.dart

### 1.8 Legal Document View
- **File:** `lib/features/auth/views/legal_document_view.dart`
- **Route:** None
- **Status:** `DISABLED` - Terms shown inline

---

## 2. FSM STATE SCREENS

### 2.1 Loading View
- **File:** `lib/features/fsm_states/views/loading_view.dart`
- **Route:** `/loading`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN the app is fetching wallet/user data
  WHEN the loading state is active
  THEN a loading indicator should be visible
  ```

### 2.2 OTP Expired View
- **File:** `lib/features/fsm_states/views/otp_expired_view.dart`
- **Route:** `/otp-expired`
- **Status:** `ACTIVE`

### 2.3 Auth Locked View
- **File:** `lib/features/fsm_states/views/auth_locked_view.dart`
- **Route:** `/auth-locked`
- **Status:** `ACTIVE`

### 2.4 Auth Suspended View
- **File:** `lib/features/fsm_states/views/auth_suspended_view.dart`
- **Route:** `/auth-suspended`
- **Status:** `ACTIVE`

### 2.5 Session Locked View
- **File:** `lib/features/fsm_states/views/session_locked_view.dart`
- **Route:** `/session-locked`
- **Status:** `ACTIVE`

### 2.6 Biometric Prompt View
- **File:** `lib/features/fsm_states/views/biometric_prompt_view.dart`
- **Route:** `/biometric-prompt`
- **Status:** `ACTIVE`

### 2.7 Device Verification View
- **File:** `lib/features/fsm_states/views/device_verification_view.dart`
- **Route:** `/device-verification`
- **Status:** `ACTIVE`

### 2.8 Session Conflict View
- **File:** `lib/features/fsm_states/views/session_conflict_view.dart`
- **Route:** `/session-conflict`
- **Status:** `ACTIVE`

### 2.9 Wallet Frozen View
- **File:** `lib/features/fsm_states/views/wallet_frozen_view.dart`
- **Route:** `/wallet-frozen`
- **Status:** `ACTIVE`

### 2.10 Wallet Under Review View
- **File:** `lib/features/fsm_states/views/wallet_under_review_view.dart`
- **Route:** `/wallet-under-review`
- **Status:** `ACTIVE`

### 2.11 KYC Expired View
- **File:** `lib/features/fsm_states/views/kyc_expired_view.dart`
- **Route:** `/kyc-expired`
- **Status:** `ACTIVE`

---

## 3. MAIN NAVIGATION (Bottom Tabs)

### 3.1 Home Screen
- **File:** `lib/features/wallet/views/wallet_home_screen.dart`
- **Route:** `/home`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN an authenticated user with wallet
  WHEN the home screen displays
  THEN the USDC balance should be visible
  AND quick action buttons (Send, Receive, Deposit) should be visible
  AND recent transactions should be listed
  ```

### 3.2 Cards List Screen
- **File:** `lib/features/cards/views/cards_list_view.dart`
- **Route:** `/cards`
- **Status:** `FEATURE_FLAG` (virtualCards)
- **BDD Tests:**
  ```gherkin
  GIVEN the Cards tab is selected
  WHEN the cards list displays
  THEN virtual cards should be listed
  AND a "Request Card" option should be available
  ```

### 3.3 Transactions Screen
- **File:** `lib/features/transactions/views/transactions_view.dart`
- **Route:** `/transactions`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN the History tab is selected
  WHEN the transactions list displays
  THEN all transactions should be listed chronologically
  AND each transaction should show type, amount, date
  AND filtering options should be available
  ```

### 3.4 Settings Screen
- **File:** `lib/features/settings/views/settings_screen.dart`
- **Route:** `/settings`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN the Settings tab is selected
  WHEN the settings screen displays
  THEN profile section should be visible
  AND security options should be available
  AND logout option should be available
  ```

---

## 4. KYC FLOW

### 4.1 KYC Status View (Identity Verification)
- **File:** `lib/features/kyc/views/kyc_status_view.dart`
- **Route:** `/kyc`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN a user needs KYC verification
  WHEN the Identity Verification screen displays
  THEN "Identity Verification" title should be visible
  AND "Start Verification" button should be visible
  AND info cards (Your Data is Secure, Quick Process, Documents Needed) should be visible
  ```

### 4.2 Document Type Selection
- **File:** `lib/features/kyc/views/document_type_view.dart`
- **Route:** `/kyc/document-type`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN user taps "Start Verification"
  WHEN the document type screen displays
  THEN "Select Document Type" title should be visible
  AND National ID Card option should be available
  AND Passport option should be available
  AND Driver's License option should be available
  AND Continue button should be disabled until selection
  ```

### 4.3 Personal Information
- **File:** `lib/features/kyc/views/kyc_personal_info_view.dart`
- **Route:** `/kyc/personal-info`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN user selected a document type
  WHEN the personal info screen displays
  THEN First name input should be visible
  AND Last name input should be visible
  AND Date of birth picker should be visible
  AND info message about matching ID should be visible
  ```

### 4.4 Document Capture
- **File:** `lib/features/kyc/views/document_capture_view.dart`
- **Route:** `/kyc/document-capture`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN user completed personal info
  WHEN the document capture screen displays
  THEN "Capture National ID Card" instructions should be visible
  AND tips for good photo should be listed
  AND Continue button should be visible
  WHEN camera is not available
  THEN "Choose from Gallery" option should appear
  ```

### 4.5 Selfie Capture
- **File:** `lib/features/kyc/views/selfie_view.dart`
- **Route:** `/kyc/selfie`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN user captured document
  WHEN the selfie screen displays
  THEN selfie capture instructions should be visible
  AND face frame overlay should be visible
  ```

### 4.6 Liveness Check
- **File:** `lib/features/kyc/views/kyc_liveness_view.dart`
- **Route:** `/kyc/liveness`
- **Status:** `ACTIVE`

### 4.7 Review Screen
- **File:** `lib/features/kyc/views/review_view.dart`
- **Route:** `/kyc/review`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN user completed all captures
  WHEN the review screen displays
  THEN captured images should be displayed
  AND Submit button should be available
  ```

### 4.8 Submitted Screen
- **File:** `lib/features/kyc/views/submitted_view.dart`
- **Route:** `/kyc/submitted`
- **Status:** `ACTIVE`
- **BDD Tests:**
  ```gherkin
  GIVEN user submitted KYC
  WHEN the submitted screen displays
  THEN success message should be visible
  AND "Continue" button to home should be available
  ```

### 4.9 KYC Upgrade View
- **File:** `lib/features/kyc/views/kyc_upgrade_view.dart`
- **Route:** `/kyc/upgrade`
- **Status:** `ACTIVE`

### 4.10 KYC Address View
- **File:** `lib/features/kyc/views/kyc_address_view.dart`
- **Route:** `/kyc/address`
- **Status:** `ACTIVE`

### 4.11 KYC Video View
- **File:** `lib/features/kyc/views/kyc_video_view.dart`
- **Route:** `/kyc/video`
- **Status:** `ACTIVE`

### 4.12 KYC Additional Docs View
- **File:** `lib/features/kyc/views/kyc_additional_docs_view.dart`
- **Route:** `/kyc/additional-docs`
- **Status:** `ACTIVE`

---

## 5. DEPOSIT FLOW

### 5.1 Deposit View
- **File:** `lib/features/wallet/views/deposit_view.dart`
- **Route:** `/deposit`
- **Status:** `ACTIVE`

### 5.2 Deposit Amount Screen
- **File:** `lib/features/deposit/views/deposit_amount_screen.dart`
- **Route:** `/deposit/amount`
- **Status:** `ACTIVE`

### 5.3 Provider Selection Screen
- **File:** `lib/features/deposit/views/provider_selection_screen.dart`
- **Route:** `/deposit/provider`
- **Status:** `ACTIVE`

### 5.4 Payment Instructions Screen
- **File:** `lib/features/deposit/views/payment_instructions_screen.dart`
- **Route:** `/deposit/instructions`
- **Status:** `ACTIVE`

### 5.5 Deposit Status Screen
- **File:** `lib/features/deposit/views/deposit_status_screen.dart`
- **Route:** `/deposit/status`
- **Status:** `ACTIVE`

### 5.6 Deposit Instructions View (Legacy)
- **File:** `lib/features/wallet/views/deposit_instructions_view.dart`
- **Route:** `/deposit/instructions` (duplicate)
- **Status:** `DEAD_CODE` - Superseded by payment_instructions_screen.dart

---

## 6. SEND FLOW (Internal Transfer)

### 6.1 Recipient Screen
- **File:** `lib/features/send/views/recipient_screen.dart`
- **Route:** `/send`
- **Status:** `ACTIVE`

### 6.2 Amount Screen
- **File:** `lib/features/send/views/amount_screen.dart`
- **Route:** `/send/amount`
- **Status:** `ACTIVE`

### 6.3 Confirm Screen
- **File:** `lib/features/send/views/confirm_screen.dart`
- **Route:** `/send/confirm`
- **Status:** `ACTIVE`

### 6.4 PIN Verification Screen
- **File:** `lib/features/send/views/pin_verification_screen.dart`
- **Route:** `/send/pin`
- **Status:** `ACTIVE`

### 6.5 Result Screen
- **File:** `lib/features/send/views/result_screen.dart`
- **Route:** `/send/result`
- **Status:** `ACTIVE`

### 6.6 Offline Queue Dialog
- **File:** `lib/features/send/views/offline_queue_dialog.dart`
- **Route:** None (dialog)
- **Status:** `ACTIVE` - Modal component

---

## 7. SEND EXTERNAL FLOW (Crypto Transfer)

### 7.1 Address Input Screen
- **File:** `lib/features/send_external/views/address_input_screen.dart`
- **Route:** `/send-external`
- **Status:** `ACTIVE`

### 7.2 External Amount Screen
- **File:** `lib/features/send_external/views/external_amount_screen.dart`
- **Route:** `/send-external/amount`
- **Status:** `ACTIVE`

### 7.3 External Confirm Screen
- **File:** `lib/features/send_external/views/external_confirm_screen.dart`
- **Route:** `/send-external/confirm`
- **Status:** `ACTIVE`

### 7.4 External Result Screen
- **File:** `lib/features/send_external/views/external_result_screen.dart`
- **Route:** `/send-external/result`
- **Status:** `ACTIVE`

### 7.5 Scan Address QR Screen
- **File:** `lib/features/send_external/views/scan_address_qr_screen.dart`
- **Route:** `/qr/scan-address`
- **Status:** `ACTIVE`

---

## 8. WITHDRAW FLOW

### 8.1 Withdraw View
- **File:** `lib/features/wallet/views/withdraw_view.dart`
- **Route:** `/withdraw`
- **Status:** `FEATURE_FLAG` (withdraw)

---

## 9. CARDS FEATURE

### 9.1 Cards Screen
- **File:** `lib/features/cards/views/cards_screen.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Superseded by cards_list_view.dart

### 9.2 Cards List View
- **File:** `lib/features/cards/views/cards_list_view.dart`
- **Route:** `/cards`
- **Status:** `FEATURE_FLAG`

### 9.3 Request Card View
- **File:** `lib/features/cards/views/request_card_view.dart`
- **Route:** `/cards/request`
- **Status:** `FEATURE_FLAG`

### 9.4 Card Detail View
- **File:** `lib/features/cards/views/card_detail_view.dart`
- **Route:** `/cards/detail/:id`
- **Status:** `FEATURE_FLAG`

### 9.5 Card Settings View
- **File:** `lib/features/cards/views/card_settings_view.dart`
- **Route:** `/cards/settings/:id`
- **Status:** `FEATURE_FLAG`

### 9.6 Card Transactions View
- **File:** `lib/features/cards/views/card_transactions_view.dart`
- **Route:** `/cards/transactions/:id`
- **Status:** `FEATURE_FLAG`

---

## 10. SETTINGS SCREENS

### 10.1 Profile View
- **File:** `lib/features/settings/views/profile_view.dart`
- **Route:** `/settings/profile`
- **Status:** `ACTIVE`

### 10.2 Profile Edit Screen
- **File:** `lib/features/settings/views/profile_edit_screen.dart`
- **Route:** `/settings/profile/edit`
- **Status:** `ACTIVE`

### 10.3 Change PIN View
- **File:** `lib/features/settings/views/change_pin_view.dart`
- **Route:** `/settings/pin`
- **Status:** `ACTIVE`

### 10.4 KYC Settings View
- **File:** `lib/features/settings/views/kyc_view.dart`
- **Route:** `/settings/kyc`
- **Status:** `ACTIVE`

### 10.5 Notification Settings View
- **File:** `lib/features/settings/views/notification_settings_view.dart`
- **Route:** `/settings/notifications`
- **Status:** `ACTIVE`

### 10.6 Security View
- **File:** `lib/features/settings/views/security_view.dart`
- **Route:** `/settings/security`
- **Status:** `ACTIVE`

### 10.7 Biometric Settings View
- **File:** `lib/features/biometric/views/biometric_settings_view.dart`
- **Route:** `/settings/biometric`
- **Status:** `ACTIVE`

### 10.8 Biometric Enrollment View
- **File:** `lib/features/biometric/views/biometric_enrollment_view.dart`
- **Route:** `/settings/biometric/enrollment`
- **Status:** `ACTIVE`

### 10.9 Limits View
- **File:** `lib/features/settings/views/limits_view.dart`
- **Route:** `/settings/limits`
- **Status:** `ACTIVE`

### 10.10 Help View
- **File:** `lib/features/settings/views/help_view.dart`
- **Route:** `/settings/help`
- **Status:** `ACTIVE`

### 10.11 Help Screen
- **File:** `lib/features/settings/views/help_screen.dart`
- **Route:** `/settings/help-screen`
- **Status:** `ACTIVE`

### 10.12 Language View
- **File:** `lib/features/settings/views/language_view.dart`
- **Route:** `/settings/language`
- **Status:** `ACTIVE`

### 10.13 Theme Settings View
- **File:** `lib/features/settings/views/theme_settings_view.dart`
- **Route:** `/settings/theme`
- **Status:** `ACTIVE`

### 10.14 Currency View
- **File:** `lib/features/settings/views/currency_view.dart`
- **Route:** `/settings/currency`
- **Status:** `ACTIVE`

### 10.15 Devices Screen
- **File:** `lib/features/settings/views/devices_screen.dart`
- **Route:** `/settings/devices`
- **Status:** `ACTIVE`

### 10.16 Sessions Screen
- **File:** `lib/features/settings/views/sessions_screen.dart`
- **Route:** `/settings/sessions`
- **Status:** `ACTIVE`

### 10.17 Business Setup View
- **File:** `lib/features/business/views/business_setup_view.dart`
- **Route:** `/settings/business-setup`
- **Status:** `ACTIVE`

### 10.18 Business Profile View
- **File:** `lib/features/business/views/business_profile_view.dart`
- **Route:** `/settings/business-profile`
- **Status:** `ACTIVE`

### 10.19 Cookie Policy View
- **File:** `lib/features/settings/views/cookie_policy_view.dart`
- **Route:** `/settings/legal/cookies`
- **Status:** `ACTIVE`

### 10.20 Performance Monitor View
- **File:** `lib/features/settings/views/performance_monitor_view.dart`
- **Route:** None
- **Status:** `DEMO` - Debug only

### 10.21 Settings View (Legacy)
- **File:** `lib/features/settings/views/settings_view.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Superseded by settings_screen.dart

---

## 11. NOTIFICATIONS

### 11.1 Notifications View
- **File:** `lib/features/notifications/views/notifications_view.dart`
- **Route:** `/notifications`
- **Status:** `ACTIVE`

### 11.2 Notification Permission Screen
- **File:** `lib/features/notifications/views/notification_permission_screen.dart`
- **Route:** `/notifications/permission`
- **Status:** `ACTIVE`

### 11.3 Notification Preferences Screen
- **File:** `lib/features/notifications/views/notification_preferences_screen.dart`
- **Route:** `/notifications/preferences`
- **Status:** `ACTIVE`

---

## 12. TRANSACTIONS

### 12.1 Transaction Detail View
- **File:** `lib/features/transactions/views/transaction_detail_view.dart`
- **Route:** `/transactions/:id`
- **Status:** `ACTIVE`

### 12.2 Export Transactions View
- **File:** `lib/features/transactions/views/export_transactions_view.dart`
- **Route:** `/transactions/export`
- **Status:** `ACTIVE`

---

## 13. FEATURE FLAG GATED SCREENS

### 13.1 Bill Pay View
- **File:** `lib/features/wallet/views/bill_pay_view.dart`
- **Route:** `/bills`
- **Status:** `FEATURE_FLAG` (bills)

### 13.2 Buy Airtime View
- **File:** `lib/features/wallet/views/buy_airtime_view.dart`
- **Route:** `/airtime`
- **Status:** `FEATURE_FLAG` (airtime)

### 13.3 Savings Goals View
- **File:** `lib/features/wallet/views/savings_goals_view.dart`
- **Route:** `/savings`
- **Status:** `FEATURE_FLAG` (savings)

### 13.4 Virtual Card View
- **File:** `lib/features/wallet/views/virtual_card_view.dart`
- **Route:** `/card`
- **Status:** `FEATURE_FLAG` (virtualCards)

### 13.5 Split Bill View
- **File:** `lib/features/wallet/views/split_bill_view.dart`
- **Route:** `/split`
- **Status:** `FEATURE_FLAG` (splitBills)

### 13.6 Budget View
- **File:** `lib/features/wallet/views/budget_view.dart`
- **Route:** `/budget`
- **Status:** `FEATURE_FLAG` (budget)

### 13.7 Analytics View
- **File:** `lib/features/wallet/views/analytics_view.dart`
- **Route:** `/analytics`
- **Status:** `FEATURE_FLAG` (analytics)

### 13.8 Currency Converter View
- **File:** `lib/features/wallet/views/currency_converter_view.dart`
- **Route:** `/converter`
- **Status:** `FEATURE_FLAG` (currencyConverter)

### 13.9 Request Money View
- **File:** `lib/features/wallet/views/request_money_view.dart`
- **Route:** `/request`
- **Status:** `FEATURE_FLAG` (requestMoney)

### 13.10 Saved Recipients View
- **File:** `lib/features/wallet/views/saved_recipients_view.dart`
- **Route:** `/recipients`
- **Status:** `FEATURE_FLAG` (savedRecipients)

### 13.11 Scheduled Transfers View
- **File:** `lib/features/wallet/views/scheduled_transfers_view.dart`
- **Route:** `/scheduled`
- **Status:** `FEATURE_FLAG` (recurringTransfers)

---

## 14. SAVINGS POTS

### 14.1 Pots List View
- **File:** `lib/features/savings_pots/views/pots_list_view.dart`
- **Route:** `/savings-pots`
- **Status:** `FEATURE_FLAG` (savingsPots)

### 14.2 Create Pot View
- **File:** `lib/features/savings_pots/views/create_pot_view.dart`
- **Route:** `/savings-pots/create`
- **Status:** `FEATURE_FLAG`

### 14.3 Pot Detail View
- **File:** `lib/features/savings_pots/views/pot_detail_view.dart`
- **Route:** `/savings-pots/detail/:id`
- **Status:** `FEATURE_FLAG`

### 14.4 Edit Pot View
- **File:** `lib/features/savings_pots/views/edit_pot_view.dart`
- **Route:** `/savings-pots/edit/:id`
- **Status:** `FEATURE_FLAG`

---

## 15. RECURRING TRANSFERS

### 15.1 Recurring Transfers List View
- **File:** `lib/features/recurring_transfers/views/recurring_transfers_list_view.dart`
- **Route:** `/recurring-transfers`
- **Status:** `FEATURE_FLAG`

### 15.2 Create Recurring Transfer View
- **File:** `lib/features/recurring_transfers/views/create_recurring_transfer_view.dart`
- **Route:** `/recurring-transfers/create`
- **Status:** `FEATURE_FLAG`

### 15.3 Recurring Transfer Detail View
- **File:** `lib/features/recurring_transfers/views/recurring_transfer_detail_view.dart`
- **Route:** `/recurring-transfers/detail/:id`
- **Status:** `FEATURE_FLAG`

---

## 16. MERCHANT PAY

### 16.1 Scan QR View
- **File:** `lib/features/merchant_pay/views/scan_qr_view.dart`
- **Route:** `/scan-to-pay`
- **Status:** `ACTIVE`

### 16.2 Payment Receipt View
- **File:** `lib/features/merchant_pay/views/payment_receipt_view.dart`
- **Route:** `/payment-receipt`
- **Status:** `ACTIVE`

### 16.3 Merchant Dashboard View
- **File:** `lib/features/merchant_pay/views/merchant_dashboard_view.dart`
- **Route:** `/merchant-dashboard`
- **Status:** `ACTIVE`

### 16.4 Merchant QR View
- **File:** `lib/features/merchant_pay/views/merchant_qr_view.dart`
- **Route:** `/merchant-qr`
- **Status:** `ACTIVE`

### 16.5 Create Payment Request View
- **File:** `lib/features/merchant_pay/views/create_payment_request_view.dart`
- **Route:** `/create-payment-request`
- **Status:** `ACTIVE`

### 16.6 Merchant Transactions View
- **File:** `lib/features/merchant_pay/views/merchant_transactions_view.dart`
- **Route:** `/merchant-transactions`
- **Status:** `ACTIVE`

### 16.7 Payment Confirm View
- **File:** `lib/features/merchant_pay/views/payment_confirm_view.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Not routed

---

## 17. BILL PAYMENTS

### 17.1 Bill Payments View
- **File:** `lib/features/bill_payments/views/bill_payments_view.dart`
- **Route:** `/bill-payments`
- **Status:** `ACTIVE`

### 17.2 Bill Payment Form View
- **File:** `lib/features/bill_payments/views/bill_payment_form_view.dart`
- **Route:** `/bill-payments/form/:providerId`
- **Status:** `ACTIVE`

### 17.3 Bill Payment Success View
- **File:** `lib/features/bill_payments/views/bill_payment_success_view.dart`
- **Route:** `/bill-payments/success/:paymentId`
- **Status:** `ACTIVE`

### 17.4 Bill Payment History View
- **File:** `lib/features/bill_payments/views/bill_payment_history_view.dart`
- **Route:** `/bill-payments/history`
- **Status:** `ACTIVE`

---

## 18. ALERTS

### 18.1 Alerts List View
- **File:** `lib/features/alerts/views/alerts_list_view.dart`
- **Route:** `/alerts`
- **Status:** `ACTIVE`

### 18.2 Alert Preferences View
- **File:** `lib/features/alerts/views/alert_preferences_view.dart`
- **Route:** `/alerts/preferences`
- **Status:** `ACTIVE`

### 18.3 Alert Detail View
- **File:** `lib/features/alerts/views/alert_detail_view.dart`
- **Route:** `/alerts/:id`
- **Status:** `ACTIVE`

---

## 19. INSIGHTS

### 19.1 Insights View
- **File:** `lib/features/insights/views/insights_view.dart`
- **Route:** `/insights`
- **Status:** `ACTIVE`

---

## 20. EXPENSES

### 20.1 Expenses View
- **File:** `lib/features/expenses/views/expenses_view.dart`
- **Route:** `/expenses`
- **Status:** `ACTIVE`

### 20.2 Add Expense View
- **File:** `lib/features/expenses/views/add_expense_view.dart`
- **Route:** `/expenses/add`
- **Status:** `ACTIVE`

### 20.3 Capture Receipt View
- **File:** `lib/features/expenses/views/capture_receipt_view.dart`
- **Route:** `/expenses/capture`
- **Status:** `ACTIVE`

### 20.4 Expense Detail View
- **File:** `lib/features/expenses/views/expense_detail_view.dart`
- **Route:** `/expenses/detail/:id`
- **Status:** `ACTIVE`

### 20.5 Expense Reports View
- **File:** `lib/features/expenses/views/expense_reports_view.dart`
- **Route:** `/expenses/reports`
- **Status:** `ACTIVE`

---

## 21. PAYMENT LINKS

### 21.1 Payment Links List View
- **File:** `lib/features/payment_links/views/payment_links_list_view.dart`
- **Route:** `/payment-links`
- **Status:** `ACTIVE`

### 21.2 Create Link View
- **File:** `lib/features/payment_links/views/create_link_view.dart`
- **Route:** `/payment-links/create`
- **Status:** `ACTIVE`

### 21.3 Link Detail View
- **File:** `lib/features/payment_links/views/link_detail_view.dart`
- **Route:** `/payment-links/:id`
- **Status:** `ACTIVE`

### 21.4 Link Created View
- **File:** `lib/features/payment_links/views/link_created_view.dart`
- **Route:** `/payment-links/created/:id`
- **Status:** `ACTIVE`

### 21.5 Pay Link View
- **File:** `lib/features/payment_links/views/pay_link_view.dart`
- **Route:** `/pay/:code`
- **Status:** `ACTIVE`

---

## 22. SUB-BUSINESS

### 22.1 Sub Businesses View
- **File:** `lib/features/sub_business/views/sub_businesses_view.dart`
- **Route:** `/sub-businesses`
- **Status:** `ACTIVE`

### 22.2 Create Sub Business View
- **File:** `lib/features/sub_business/views/create_sub_business_view.dart`
- **Route:** `/sub-businesses/create`
- **Status:** `ACTIVE`

### 22.3 Sub Business Detail View
- **File:** `lib/features/sub_business/views/sub_business_detail_view.dart`
- **Route:** `/sub-businesses/detail/:id`
- **Status:** `ACTIVE`

### 22.4 Sub Business Staff View
- **File:** `lib/features/sub_business/views/sub_business_staff_view.dart`
- **Route:** `/sub-businesses/:id/staff`
- **Status:** `ACTIVE`

---

## 23. BULK PAYMENTS

### 23.1 Bulk Payments View
- **File:** `lib/features/bulk_payments/views/bulk_payments_view.dart`
- **Route:** `/bulk-payments`
- **Status:** `ACTIVE`

### 23.2 Bulk Upload View
- **File:** `lib/features/bulk_payments/views/bulk_upload_view.dart`
- **Route:** `/bulk-payments/upload`
- **Status:** `ACTIVE`

### 23.3 Bulk Preview View
- **File:** `lib/features/bulk_payments/views/bulk_preview_view.dart`
- **Route:** `/bulk-payments/preview`
- **Status:** `ACTIVE`

### 23.4 Bulk Status View
- **File:** `lib/features/bulk_payments/views/bulk_status_view.dart`
- **Route:** `/bulk-payments/status/:batchId`
- **Status:** `ACTIVE`

---

## 24. BENEFICIARIES

### 24.1 Beneficiaries Screen
- **File:** `lib/features/beneficiaries/views/beneficiaries_screen.dart`
- **Route:** `/beneficiaries`
- **Status:** `ACTIVE`

### 24.2 Add Beneficiary Screen
- **File:** `lib/features/beneficiaries/views/add_beneficiary_screen.dart`
- **Route:** `/beneficiaries/add`
- **Status:** `ACTIVE`

### 24.3 Beneficiary Detail View
- **File:** `lib/features/beneficiaries/views/beneficiary_detail_view.dart`
- **Route:** `/beneficiaries/detail/:id`
- **Status:** `ACTIVE`

---

## 25. BANK LINKING

### 25.1 Linked Accounts View
- **File:** `lib/features/bank_linking/views/linked_accounts_view.dart`
- **Route:** None
- **Status:** `AWAITING_BACKEND` - Bank linking API not ready

### 25.2 Bank Selection View
- **File:** `lib/features/bank_linking/views/bank_selection_view.dart`
- **Route:** None
- **Status:** `AWAITING_BACKEND`

### 25.3 Link Bank View
- **File:** `lib/features/bank_linking/views/link_bank_view.dart`
- **Route:** None
- **Status:** `AWAITING_BACKEND`

### 25.4 Bank Verification View
- **File:** `lib/features/bank_linking/views/bank_verification_view.dart`
- **Route:** None
- **Status:** `AWAITING_BACKEND`

### 25.5 Bank Transfer View
- **File:** `lib/features/bank_linking/views/bank_transfer_view.dart`
- **Route:** None
- **Status:** `AWAITING_BACKEND`

---

## 26. CONTACTS

### 26.1 Contacts List Screen
- **File:** `lib/features/contacts/views/contacts_list_screen.dart`
- **Route:** None
- **Status:** `DISABLED` - Contact sync not in MVP

### 26.2 Contacts Permission Screen
- **File:** `lib/features/contacts/views/contacts_permission_screen.dart`
- **Route:** None
- **Status:** `DISABLED`

---

## 27. QR PAYMENT

### 27.1 Receive QR Screen
- **File:** `lib/features/qr_payment/views/receive_qr_screen.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Superseded by receive_view

### 27.2 Scan QR Screen
- **File:** `lib/features/qr_payment/views/scan_qr_screen.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Superseded by scan_view

---

## 28. PIN FEATURE

### 28.1 Set PIN View
- **File:** `lib/features/pin/views/set_pin_view.dart`
- **Route:** None (component)
- **Status:** `ACTIVE` - Used inline

### 28.2 Enter PIN View
- **File:** `lib/features/pin/views/enter_pin_view.dart`
- **Route:** None (component)
- **Status:** `ACTIVE`

### 28.3 Confirm PIN View
- **File:** `lib/features/pin/views/confirm_pin_view.dart`
- **Route:** None (component)
- **Status:** `ACTIVE`

### 28.4 Change PIN View
- **File:** `lib/features/pin/views/change_pin_view.dart`
- **Route:** None (component)
- **Status:** `ACTIVE`

### 28.5 Reset PIN View
- **File:** `lib/features/pin/views/reset_pin_view.dart`
- **Route:** None (component)
- **Status:** `ACTIVE`

### 28.6 PIN Locked View
- **File:** `lib/features/pin/views/pin_locked_view.dart`
- **Route:** None (component)
- **Status:** `ACTIVE`

---

## 29. ONBOARDING HELP SCREENS

### 29.1 USDC Explainer View
- **File:** `lib/features/onboarding/views/help/usdc_explainer_view.dart`
- **Route:** None
- **Status:** `DISABLED` - Not in MVP

### 29.2 Deposits Guide View
- **File:** `lib/features/onboarding/views/help/deposits_guide_view.dart`
- **Route:** None
- **Status:** `DISABLED`

### 29.3 Fees Transparency View
- **File:** `lib/features/onboarding/views/help/fees_transparency_view.dart`
- **Route:** None
- **Status:** `DISABLED`

---

## 30. OTHER SCREENS

### 30.1 Services View
- **File:** `lib/features/services/views/services_view.dart`
- **Route:** `/services`
- **Status:** `ACTIVE` - Legacy compatibility

### 30.2 Referrals View
- **File:** `lib/features/referrals/views/referrals_view.dart`
- **Route:** `/referrals`
- **Status:** `ACTIVE`

### 30.3 Receive View
- **File:** `lib/features/wallet/views/receive_view.dart`
- **Route:** `/receive`
- **Status:** `ACTIVE`

### 30.4 Scan View
- **File:** `lib/features/wallet/views/scan_view.dart`
- **Route:** `/scan`
- **Status:** `ACTIVE`

### 30.5 Transfer Success View
- **File:** `lib/features/wallet/views/transfer_success_view.dart`
- **Route:** `/transfer/success`
- **Status:** `ACTIVE`

### 30.6 Offline Pending Transfers Screen
- **File:** `lib/features/offline/views/pending_transfers_screen.dart`
- **Route:** None
- **Status:** `DISABLED` - Offline feature not in MVP

### 30.7 Limits View (Features)
- **File:** `lib/features/limits/views/limits_view.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Duplicate of settings/limits_view

### 30.8 Home View (Legacy)
- **File:** `lib/features/wallet/views/home_view.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Superseded by wallet_home_screen

### 30.9 Send View (Legacy)
- **File:** `lib/features/wallet/views/send_view.dart`
- **Route:** None
- **Status:** `DEAD_CODE` - Superseded by send/recipient_screen

### 30.10 Pending Transfers View
- **File:** `lib/features/wallet/views/pending_transfers_view.dart`
- **Route:** None
- **Status:** `DISABLED`

### 30.11 Wallet Home Accessibility Example
- **File:** `lib/features/wallet/views/wallet_home_accessibility_example.dart`
- **Route:** None
- **Status:** `DEMO` - Accessibility demo

### 30.12 Share Receipt Sheet
- **File:** `lib/features/receipts/views/share_receipt_sheet.dart`
- **Route:** None (bottom sheet)
- **Status:** `ACTIVE` - Modal component

---

## SUMMARY

| Status | Count |
|--------|-------|
| ACTIVE | ~95 |
| FEATURE_FLAG | ~20 |
| AWAITING_BACKEND | 5 |
| DEMO | 2 |
| DEAD_CODE | ~15 |
| DISABLED | ~8 |

---

## GOLDEN TEST REQUIREMENTS

### MVP Critical Path (Must Have Golden Tests)
1. Auth Flow: Login → OTP → KYC → Home
2. Deposit Flow: Home → Deposit → Amount → Provider → Instructions → Status
3. Send Flow: Home → Send → Amount → Confirm → PIN → Result
4. Settings: Profile, Security, Logout

### Feature Flag Screens (Golden Tests When Enabled)
- Cards, Savings Pots, Recurring Transfers
- Bill Payments, Airtime, Withdraw

### Skip Golden Tests
- DEAD_CODE screens
- DEMO screens
- AWAITING_BACKEND screens
