# JoonaPay Mobile - Complete Sitemap

> **AI Agents: READ THIS BEFORE CREATING ANY SCREEN OR WIDGET**
> If it exists here, USE IT. Do not duplicate.

---

## Status Legend

| Status | Meaning |
|--------|---------|
| `LIVE` | Real API integration |
| `MOCK` | Uses mock data only |
| `PARTIAL` | Some features mocked |
| `UNUSED` | Dead code, not in router |
| `WIP` | Work in progress |
| `TODO` | Placeholder only |

---

## Pages & Screens

### Auth & Onboarding

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/` | `splash/views/splash_view.dart` | LIVE | Entry point, checks auth state |
| `/onboarding` | `onboarding/views/onboarding_view.dart` | LIVE | 4-page tutorial, tracks completion |
| `/login` | `auth/views/login_view.dart` | LIVE | **USE THIS** - has CountryPicker, login/register toggle |
| `/login/otp` | `auth/views/login_otp_view.dart` | MOCK | Dev OTP: 123456 |
| `/login/pin` | `auth/views/login_pin_view.dart` | LIVE | PIN verification |
| `/otp` | `auth/views/otp_view.dart` | MOCK | Standalone OTP |
| - | `auth/views/login_phone_view.dart` | UNUSED | Simplified duplicate, DO NOT USE |
| - | `auth/views/legal_document_view.dart` | LIVE | Terms/Privacy viewer |

#### Onboarding Sub-screens (internal flow)

| File | Status | Notes |
|------|--------|-------|
| `onboarding/views/welcome_view.dart` | LIVE | Welcome screen |
| `onboarding/views/phone_input_view.dart` | MOCK | Phone entry with country picker |
| `onboarding/views/otp_verification_view.dart` | MOCK | OTP during registration |
| `onboarding/views/profile_setup_view.dart` | MOCK | Name entry |
| `onboarding/views/onboarding_pin_view.dart` | LIVE | PIN creation |
| `onboarding/views/kyc_prompt_view.dart` | LIVE | KYC upsell |
| `onboarding/views/onboarding_success_view.dart` | LIVE | Success screen |

---

### Main Navigation (ShellRoute)

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/home` | `wallet/views/wallet_home_screen.dart` | PARTIAL | Balance live, actions mock |
| `/cards` | `cards/views/cards_screen.dart` | MOCK | Virtual cards TODO |
| `/transactions` | `transactions/views/transactions_view.dart` | MOCK | Transaction list |
| `/settings` | `settings/views/settings_screen.dart` | LIVE | Settings hub |

---

### Send Money Flow

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/send` | `send/views/recipient_screen.dart` | MOCK | Recipient selection |
| `/send/amount` | `send/views/amount_screen.dart` | MOCK | Amount entry |
| `/send/confirm` | `send/views/confirm_screen.dart` | MOCK | Review transfer |
| `/send/pin` | `send/views/pin_verification_screen.dart` | LIVE | PIN check |
| `/send/result` | `send/views/result_screen.dart` | MOCK | Success/failure |

---

### External Transfer Flow

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/send-external` | `send_external/views/address_input_screen.dart` | MOCK | Wallet address input |
| `/send-external/amount` | `send_external/views/external_amount_screen.dart` | MOCK | Amount entry |
| `/send-external/confirm` | `send_external/views/external_confirm_screen.dart` | MOCK | Review |
| `/send-external/result` | `send_external/views/external_result_screen.dart` | MOCK | Result |
| `/qr/scan-address` | `send_external/views/scan_address_qr_screen.dart` | MOCK | Scan wallet QR |

---

### Deposit Flow

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/deposit` | `wallet/views/deposit_view.dart` | MOCK | Method selection |
| `/deposit/amount` | `deposit/views/deposit_amount_screen.dart` | MOCK | Enter amount |
| `/deposit/provider` | `deposit/views/provider_selection_screen.dart` | MOCK | Select MoMo provider |
| `/deposit/instructions` | `deposit/views/payment_instructions_screen.dart` | MOCK | USSD instructions |
| `/deposit/status` | `deposit/views/deposit_status_screen.dart` | MOCK | Pending/success |
| - | `wallet/views/deposit_instructions_view.dart` | MOCK | Alternative instructions |

---

### Withdraw Flow

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/withdraw` | `wallet/views/withdraw_view.dart` | MOCK | Withdrawal flow |

---

### KYC Flow

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/kyc` | `kyc/views/kyc_status_view.dart` | PARTIAL | Status display |
| `/kyc/document-type` | `kyc/views/document_type_view.dart` | LIVE | Select ID type |
| `/kyc/document-capture` | `kyc/views/document_capture_view.dart` | LIVE | Camera capture |
| `/kyc/selfie` | `kyc/views/selfie_view.dart` | LIVE | Selfie capture |
| `/kyc/review` | `kyc/views/review_view.dart` | LIVE | Review submission |
| `/kyc/submitted` | `kyc/views/submitted_view.dart` | LIVE | Confirmation |

---

### Settings Screens

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/settings/profile` | `settings/views/profile_view.dart` | MOCK | View profile |
| `/settings/profile/edit` | `settings/views/profile_edit_screen.dart` | MOCK | Edit profile |
| `/settings/pin` | `settings/views/change_pin_view.dart` | LIVE | Change PIN |
| `/settings/security` | `settings/views/security_view.dart` | PARTIAL | Biometric settings |
| `/settings/devices` | `settings/views/devices_screen.dart` | MOCK | Device management |
| `/settings/sessions` | `settings/views/sessions_screen.dart` | MOCK | Active sessions |
| `/settings/notifications` | `settings/views/notification_settings_view.dart` | MOCK | Notification prefs |
| `/settings/language` | `settings/views/language_view.dart` | LIVE | Language selection |
| `/settings/currency` | `settings/views/currency_view.dart` | MOCK | Display currency |
| `/settings/limits` | `settings/views/limits_view.dart` | MOCK | Transaction limits |
| `/settings/help` | `settings/views/help_view.dart` | LIVE | Help center |
| `/settings/help-screen` | `settings/views/help_screen.dart` | LIVE | Problem report |
| `/settings/kyc` | `settings/views/kyc_view.dart` | PARTIAL | KYC from settings |
| - | `settings/views/settings_view.dart` | UNUSED | Old settings, don't use |

---

### Bill Payments

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/bill-payments` | `bill_payments/views/bill_payments_view.dart` | MOCK | Provider list |
| `/bill-payments/form/:id` | `bill_payments/views/bill_payment_form_view.dart` | MOCK | Payment form |
| `/bill-payments/success/:id` | `bill_payments/views/bill_payment_success_view.dart` | MOCK | Success screen |
| `/bill-payments/history` | `bill_payments/views/bill_payment_history_view.dart` | MOCK | Payment history |
| `/bills` | `wallet/views/bill_pay_view.dart` | MOCK | Legacy bills entry |
| `/airtime` | `wallet/views/buy_airtime_view.dart` | MOCK | Airtime purchase |

---

### Savings Pots

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/savings-pots` | `savings_pots/views/pots_list_view.dart` | MOCK | List pots |
| `/savings-pots/create` | `savings_pots/views/create_pot_view.dart` | MOCK | Create pot |
| `/savings-pots/detail/:id` | `savings_pots/views/pot_detail_view.dart` | MOCK | Pot details |
| `/savings-pots/edit/:id` | `savings_pots/views/edit_pot_view.dart` | MOCK | Edit pot |
| `/savings` | `wallet/views/savings_goals_view.dart` | MOCK | Legacy savings |

---

### Recurring Transfers

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/recurring-transfers` | `recurring_transfers/views/recurring_transfers_list_view.dart` | MOCK | List scheduled |
| `/recurring-transfers/create` | `recurring_transfers/views/create_recurring_transfer_view.dart` | MOCK | Create recurring |
| `/recurring-transfers/detail/:id` | `recurring_transfers/views/recurring_transfer_detail_view.dart` | MOCK | Details |
| `/scheduled` | `wallet/views/scheduled_transfers_view.dart` | MOCK | Legacy scheduled |

---

### Merchant Payments

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/scan-to-pay` | `merchant_pay/views/scan_qr_view.dart` | MOCK | Scan merchant QR |
| `/payment-receipt` | `merchant_pay/views/payment_receipt_view.dart` | MOCK | Receipt |
| `/merchant-dashboard` | `merchant_pay/views/merchant_dashboard_view.dart` | MOCK | Merchant view |
| `/merchant-qr` | `merchant_pay/views/merchant_qr_view.dart` | MOCK | Show QR |
| `/create-payment-request` | `merchant_pay/views/create_payment_request_view.dart` | MOCK | Create request |
| `/merchant-transactions` | `merchant_pay/views/merchant_transactions_view.dart` | MOCK | Merchant history |
| - | `merchant_pay/views/payment_confirm_view.dart` | MOCK | Confirm payment |

---

### Beneficiaries

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/beneficiaries` | `beneficiaries/views/beneficiaries_screen.dart` | MOCK | List saved |
| `/beneficiaries/add` | `beneficiaries/views/add_beneficiary_screen.dart` | MOCK | Add new |
| `/beneficiaries/detail/:id` | `beneficiaries/views/beneficiary_detail_view.dart` | MOCK | View details |
| `/beneficiaries/edit/:id` | (reuses add_beneficiary_screen) | MOCK | Edit mode |

---

### Payment Links

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/payment-links` | `payment_links/views/payment_links_list_view.dart` | MOCK | List links |
| `/payment-links/create` | `payment_links/views/create_link_view.dart` | MOCK | Create link |
| `/payment-links/created/:id` | `payment_links/views/link_created_view.dart` | MOCK | Success + share |
| `/payment-links/detail/:id` | `payment_links/views/link_detail_view.dart` | MOCK | Link details |

---

### Alerts & Insights

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/alerts` | `alerts/views/alerts_list_view.dart` | MOCK | Alert list |
| `/alerts/preferences` | `alerts/views/alert_preferences_view.dart` | MOCK | Alert settings |
| `/alerts/:id` | `alerts/views/alert_detail_view.dart` | MOCK | Alert detail |
| `/insights` | `insights/views/insights_view.dart` | MOCK | Spending insights |
| `/analytics` | `wallet/views/analytics_view.dart` | MOCK | Analytics view |

---

### Other Routes

| Route | File | Status | Notes |
|-------|------|--------|-------|
| `/receive` | `wallet/views/receive_view.dart` | MOCK | Receive QR |
| `/scan` | `wallet/views/scan_view.dart` | MOCK | General scanner |
| `/transfer/success` | `wallet/views/transfer_success_view.dart` | MOCK | Transfer success |
| `/notifications` | `notifications/views/notifications_view.dart` | LIVE | Notification list |
| `/notifications/permission` | `notifications/views/notification_permission_screen.dart` | LIVE | Permission request |
| `/notifications/preferences` | `notifications/views/notification_preferences_screen.dart` | MOCK | Prefs |
| `/transactions/:id` | `transactions/views/transaction_detail_view.dart` | MOCK | Tx detail |
| `/transactions/export` | `transactions/views/export_transactions_view.dart` | MOCK | Export CSV |
| `/referrals` | `referrals/views/referrals_view.dart` | MOCK | Referral program |
| `/services` | `services/views/services_view.dart` | MOCK | Services hub |
| `/request` | `wallet/views/request_money_view.dart` | MOCK | Request money |
| `/recipients` | `wallet/views/saved_recipients_view.dart` | MOCK | Saved recipients |
| `/converter` | `wallet/views/currency_converter_view.dart` | MOCK | Currency converter |
| `/card` | `wallet/views/virtual_card_view.dart` | TODO | Virtual card |
| `/split` | `wallet/views/split_bill_view.dart` | MOCK | Split bill |
| `/budget` | `wallet/views/budget_view.dart` | MOCK | Budget tracking |

---

### Not in Router (Internal/Unused)

| File | Status | Notes |
|------|--------|-------|
| `wallet/views/home_view.dart` | UNUSED | Old home, use wallet_home_screen |
| `wallet/views/send_view.dart` | UNUSED | Old send, use send/ flow |
| `pin/views/*.dart` | INTERNAL | Used as components, not routes |
| `contacts/views/*.dart` | WIP | Contact picker flow |
| `limits/views/limits_view.dart` | DUPLICATE | Use settings/views/limits_view |
| `qr_payment/views/*.dart` | WIP | Alternative QR flow |
| `offline/views/pending_transfers_screen.dart` | LIVE | Offline queue dialog |
| `debug/performance_debug_screen.dart` | DEV | Debug only |

---

## Widgets

### Design System (Primitives) - USE THESE

| Widget | File | Purpose |
|--------|------|---------|
| `AppButton` | `design/components/primitives/app_button.dart` | All buttons |
| `AppText` | `design/components/primitives/app_text.dart` | All text |
| `AppInput` | `design/components/primitives/app_input.dart` | All inputs |
| `AppCard` | `design/components/primitives/app_card.dart` | All cards |
| `AppSelect` | `design/components/primitives/app_select.dart` | Dropdowns |
| `AppSkeleton` | `design/components/primitives/app_skeleton.dart` | Loading states |
| `AppRefreshIndicator` | `design/components/primitives/app_refresh_indicator.dart` | Pull to refresh |
| `OfflineBanner` | `design/components/primitives/offline_banner.dart` | Offline indicator |

### Design System (Composed)

| Widget | File | Purpose |
|--------|------|---------|
| `BalanceCard` | `design/components/composed/balance_card.dart` | Balance display |
| `PinPad` | `design/components/composed/pin_pad.dart` | PIN entry |
| `PinConfirmationSheet` | `design/components/composed/pin_confirmation_sheet.dart` | PIN modal |
| `TransactionRow` | `design/components/composed/transaction_row.dart` | Tx list item |

### Feature Widgets

#### Alerts
| Widget | File |
|--------|------|
| `AlertBadge` | `alerts/widgets/alert_badge.dart` |
| `AlertCard` | `alerts/widgets/alert_card.dart` |

#### Beneficiaries
| Widget | File |
|--------|------|
| `BeneficiaryCard` | `beneficiaries/widgets/beneficiary_card.dart` |
| `BeneficiarySelectSheet` | `beneficiaries/widgets/beneficiary_select_sheet.dart` |

#### Bill Payments
| Widget | File |
|--------|------|
| `CategorySelector` | `bill_payments/widgets/category_selector.dart` |
| `ProviderCard` | `bill_payments/widgets/provider_card.dart` |

#### Contacts
| Widget | File |
|--------|------|
| `ContactCard` | `contacts/widgets/contact_card.dart` |
| `InviteSheet` | `contacts/widgets/invite_sheet.dart` |

#### Insights
| Widget | File |
|--------|------|
| `SpendingSummaryCard` | `insights/widgets/spending_summary_card.dart` |
| `SpendingPieChart` | `insights/widgets/spending_pie_chart.dart` |
| `SpendingLineChart` | `insights/widgets/spending_line_chart.dart` |
| `SpendingByCategorySection` | `insights/widgets/spending_by_category_section.dart` |
| `SpendingTrendSection` | `insights/widgets/spending_trend_section.dart` |
| `TopRecipientsSection` | `insights/widgets/top_recipients_section.dart` |
| `EmptyInsightsState` | `insights/widgets/empty_insights_state.dart` |

#### Limits
| Widget | File |
|--------|------|
| `LimitCard` | `limits/widgets/limit_card.dart` |
| `LimitProgressBar` | `limits/widgets/limit_progress_bar.dart` |
| `LimitWarningBanner` | `limits/widgets/limit_warning_banner.dart` |
| `UpgradePrompt` | `limits/widgets/upgrade_prompt.dart` |

#### Merchant Pay
| Widget | File |
|--------|------|
| `QrScannerWidget` | `merchant_pay/widgets/qr_scanner_widget.dart` |

#### Onboarding
| Widget | File |
|--------|------|
| `CountryPickerWidget` | `onboarding/widgets/country_picker_widget.dart` |

#### Payment Links
| Widget | File |
|--------|------|
| `PaymentLinkCard` | `payment_links/widgets/payment_link_card.dart` |
| `ShareLinkSheet` | `payment_links/widgets/share_link_sheet.dart` |

#### PIN
| Widget | File |
|--------|------|
| `PinDots` | `pin/widgets/pin_dots.dart` |
| `PinPad` | `pin/widgets/pin_pad.dart` |

#### QR Payment
| Widget | File |
|--------|------|
| `QrDisplay` | `qr_payment/widgets/qr_display.dart` |

#### Receipts
| Widget | File |
|--------|------|
| `ReceiptWidget` | `receipts/widgets/receipt_widget.dart` |

#### Recurring Transfers
| Widget | File |
|--------|------|
| `RecurringTransferCard` | `recurring_transfers/widgets/recurring_transfer_card.dart` |
| `FrequencyPicker` | `recurring_transfers/widgets/frequency_picker.dart` |
| `EndConditionPicker` | `recurring_transfers/widgets/end_condition_picker.dart` |
| `ExecutionHistoryList` | `recurring_transfers/widgets/execution_history_list.dart` |

#### Savings Pots
| Widget | File |
|--------|------|
| `PotCard` | `savings_pots/widgets/pot_card.dart` |
| `AddToPotSheet` | `savings_pots/widgets/add_to_pot_sheet.dart` |
| `WithdrawFromPotSheet` | `savings_pots/widgets/withdraw_from_pot_sheet.dart` |
| `ColorPicker` | `savings_pots/widgets/color_picker.dart` |
| `EmojiPicker` | `savings_pots/widgets/emoji_picker.dart` |

#### Send
| Widget | File |
|--------|------|
| `PinInputWidget` | `send/widgets/pin_input_widget.dart` |
| `RecentRecipientCard` | `send/widgets/recent_recipient_card.dart` |
| `BeneficiaryPickerBottomSheet` | `send/widgets/beneficiary_picker_bottom_sheet.dart` |
| `ContactPickerBottomSheet` | `send/widgets/contact_picker_bottom_sheet.dart` |

#### Transactions
| Widget | File |
|--------|------|
| `FilterBottomSheet` | `transactions/widgets/filter_bottom_sheet.dart` |

#### Wallet
| Widget | File |
|--------|------|
| `RiskStepUpDialog` | `wallet/widgets/risk_step_up_dialog.dart` |

#### Liveness
| Widget | File |
|--------|------|
| `LivenessCheckWidget` | `liveness/widgets/liveness_check_widget.dart` |

---

## State Machines

### Auth State (`features/auth/providers/auth_provider.dart`)
```
initial → loading → otpSent → otpVerified → authenticated
                 ↘ error ↙
```

### Login State (`features/auth/providers/login_provider.dart`)
```
phone → otp → pin → success
```

### User State (`state/user_state_machine.dart`)
```
unknown → loading → guest → authenticated → locked
                        ↘ sessionExpired ↙
```

### Wallet State (`state/wallet_state_machine.dart`)
```
loading → loaded → refreshing → error
              ↑__________|
```

### Send State (`features/send/providers/send_provider.dart`)
```
idle → selectingRecipient → enteringAmount → confirming → verifyingPin → processing → success/failure
```

### Onboarding State (`features/onboarding/providers/onboarding_provider.dart`)
```
welcome → phone → otp → profile → pin → kyc → success
```

---

## Feature Flags

| Flag Key | Controls | Default |
|----------|----------|---------|
| `withdraw` | `/withdraw` route | false |
| `airtime` | `/airtime` route | false |
| `bills` | `/bills` route | false |
| `savings` | `/savings` route | false |
| `savingsPots` | `/savings-pots/*` routes | false |
| `virtualCards` | `/card` route | false |
| `splitBills` | `/split` route | false |
| `budget` | `/budget` route | false |
| `recurringTransfers` | `/scheduled` route | false |
| `analytics` | `/analytics` route | false |
| `currencyConverter` | `/converter` route | false |
| `requestMoney` | `/request` route | false |
| `savedRecipients` | `/recipients` route | false |

---

## API Integration Status

| Service | Status | Notes |
|---------|--------|-------|
| Auth (login/register) | MOCK | Dev OTP: 123456 |
| Wallet balance | MOCK | Hardcoded balance |
| Transactions list | MOCK | Fake transactions |
| Send internal | MOCK | Simulated transfer |
| Send external | MOCK | Simulated transfer |
| KYC submission | PARTIAL | Camera real, upload mock |
| Notifications | LIVE | FCM integration |
| Feature flags | LIVE | Real API fetch |
| Deposits | MOCK | MoMo simulation |
| Withdrawals | MOCK | MoMo simulation |
| Bill payments | MOCK | All providers mocked |
| Beneficiaries | MOCK | Local storage only |
| Payment links | MOCK | Local storage only |

---

*Last updated: 2026-01-29*
*Update this file when adding new screens/widgets*
