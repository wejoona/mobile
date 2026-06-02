# Route Inventory

Source: `lib/router/app_router.dart`

This inventory lists every registered `GoRoute` path currently declared in the app router. Dynamic segments are shown with their router parameter names.

## Startup, Auth, And Onboarding

- `/`
- `/profile-complete`
- `/onboarding`
- `/onboarding/phone`
- `/onboarding/otp`
- `/onboarding/profile`
- `/onboarding/pin`
- `/onboarding/kyc-prompt`
- `/onboarding/success`
- `/login`
- `/login/otp`
- `/login/pin`
- `/otp`

## FSM And System States

- `/otp-expired`
- `/auth-locked`
- `/auth-suspended`
- `/session-locked`
- `/biometric-prompt`
- `/device-verification`
- `/session-conflict`
- `/wallet-frozen`
- `/wallet-under-review`
- `/kyc-expired`
- `/loading`
- `/force-update`
- `/maintenance`
- `/server-error`
- `/create-wallet`

## Main Shell

- `/home`
- `/cards`
- `/transactions`
- `/settings`

## Wallet, Deposit, Send, And Transfer

- `/services`
- `/deposit`
- `/deposit/amount`
- `/deposit/provider`
- `/deposit/status`
- `/send`
- `/send/amount`
- `/send/confirm`
- `/send/pin`
- `/send/result`
- `/offline/pending-transfers`
- `/send-external`
- `/send-external/amount`
- `/send-external/confirm`
- `/send-external/result`
- `/qr/scan-address`
- `/withdraw`
- `/scan`
- `/receive`
- `/transfer/success`
- `/deposit/instructions`
- `/request`
- `/scheduled`
- `/analytics`
- `/insights`
- `/recipients`
- `/converter`
- `/transactions/export`
- `/bills`
- `/airtime`
- `/savings`
- `/card`
- `/split`
- `/budget`

## Cards

- `/cards/request`
- `/cards/detail/:id`
- `/cards/settings/:id`
- `/cards/transactions/:id`

## Notifications And Transactions

- `/notifications`
- `/transactions/:id`
- `/settings/notifications`
- `/notifications/permission`
- `/notifications/preferences`

## PIN, KYC, And Settings

- `/settings/profile`
- `/settings/pin`
- `/pin/setup`
- `/pin/reset`
- `/pin/confirm`
- `/settings/kyc`
- `/kyc`
- `/kyc/document-type`
- `/kyc/personal-info`
- `/kyc/document-capture`
- `/kyc/selfie`
- `/kyc/liveness-instructions`
- `/kyc/liveness`
- `/kyc/review`
- `/kyc/submitted`
- `/kyc/upgrade`
- `/kyc/address`
- `/kyc/video`
- `/kyc/additional-docs`
- `/settings/security`
- `/settings/biometric`
- `/settings/biometric/enrollment`
- `/settings/limits`
- `/settings/help`
- `/settings/language`
- `/settings/theme`
- `/settings/currency`
- `/settings/devices`
- `/settings/sessions`
- `/profile/verify-email`
- `/settings/profile/edit`
- `/settings/help-screen`
- `/settings/business-setup`
- `/settings/business-profile`
- `/settings/legal/cookies`

## Engagement And Productivity

- `/referrals`
- `/savings-pots`
- `/savings-pots/create`
- `/savings-pots/detail/:id`
- `/savings-pots/edit/:id`
- `/recurring-transfers`
- `/recurring-transfers/create`
- `/recurring-transfers/detail/:id`
- `/scan-to-pay`
- `/payment-receipt`
- `/merchant-dashboard`
- `/merchant-qr`
- `/create-payment-request`
- `/merchant-transactions`

## Bill Payments, Alerts, And Expenses

- `/bill-payments`
- `/bill-payments/form/:providerId`
- `/bill-payments/success/:paymentId`
- `/bill-payments/history`
- `/alerts`
- `/alerts/preferences`
- `/alerts/:id`
- `/expenses`
- `/expenses/add`
- `/expenses/capture`
- `/expenses/detail/:id`
- `/expenses/reports`

## Payment Links, Business, Bulk, Beneficiaries, And Bank Linking

- `/payment-links`
- `/payment-links/create`
- `/payment-links/:id`
- `/payment-links/created/:id`
- `/pay/:code`
- `/sub-businesses`
- `/sub-businesses/create`
- `/sub-businesses/detail/:id`
- `/sub-businesses/:id/staff`
- `/sub-businesses/transfer/:id`
- `/bulk-payments`
- `/bulk-payments/upload`
- `/bulk-payments/preview`
- `/bulk-payments/status/:batchId`
- `/beneficiaries`
- `/beneficiaries/add`
- `/beneficiaries/detail/:id`
- `/beneficiaries/edit/:id`
- `/bank-linking`
- `/bank-linking/select`
- `/bank-linking/link`
- `/bank-linking/verify`
- `/bank-linking/verify/:accountId`
- `/bank-linking/transfer/:accountId`
- `/catalog`

## Automated Coverage

- `test/router/app_route_inventory_test.dart` extracts every `GoRoute(path: ...)` declaration from `app_router.dart`.
- Dynamic segments are replaced with sample values.
- Each concrete sample path must resolve through the real `routerProvider`.
- The full onboarding sequence is also asserted explicitly and in order.
