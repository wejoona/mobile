# Mobile API Reference

Base path: `/api/v1`.

Use with local API:

```bash
--dart-define=API_URL=http://127.0.0.1:3401/api/v1
```

## Auth

| Action | Method | Path | Body | Notes |
| --- | --- | --- | --- | --- |
| Register/request OTP | POST | `/auth/register` | `{ "phone": "+225...", "countryCode": "CI" }` | Existing phone sends login OTP. |
| Login/request OTP | POST | `/auth/login` | `{ "phone": "+225..." }` | Requires registered user. |
| Verify OTP | POST | `/auth/verify-otp` | `{ "phone": "+225...", "otp": "123456" }` | Returns access token, refresh token, user, `kycStatus`, `expiresIn`. |
| Refresh | POST | `/auth/refresh` | `{ "refreshToken": "..." }` | Public endpoint. |
| Logout | POST | `/auth/logout` | `{ "refreshToken": "..." }` | Authenticated cleanup. |
| Logout all | POST | `/auth/logout-all` | none | Authenticated. |

## User

| Action | Method | Path |
| --- | --- | --- |
| Profile | GET | `/user/profile` |
| Update profile | PUT | `/user/profile` |
| Upload avatar | POST | `/user/avatar` |
| Delete avatar | DELETE | `/user/avatar` |
| Protected avatar | GET | `/user/avatar/:userId` |
| Search users | GET | `/user/search` |
| Check username | GET | `/user/username/check/:username` |
| Search username | GET | `/user/username/search` |
| User by username | GET | `/user/by-username/:username` |
| Limits | GET | `/user/limits` |
| Limit usage | GET | `/user/limits/usage` |
| Verify email | POST | `/user/verify-email` |
| Email status | GET | `/user/email-status` |
| Resend email verification | POST | `/user/resend-email-verification` |
| Set PIN | POST | `/user/pin/set` |
| Change PIN | POST | `/user/pin/change` |
| Verify PIN | POST | `/user/pin/verify` |
| Reset PIN | POST | `/user/pin/reset` |

Avatar URL handling: the API may return absolute URLs, `/user/avatar/...`, `user/avatar/...`, or `/api/...`; mobile should normalize them against the configured API origin and keep authenticated image loading for protected avatar routes.

## Sessions And Devices

| Action | Method | Path | Notes |
| --- | --- | --- | --- |
| Active sessions | GET | `/sessions` | Response includes `sessions`, `items`, and `total`. |
| All sessions | GET | `/sessions/all` | Includes revoked/expired sessions. |
| Revoke session | DELETE | `/sessions/:id` | Authenticated. |
| Revoke other sessions | DELETE | `/sessions` | Preserves current session when backend can identify it. |
| Register device | POST | `/devices/register` | Used for device management/risk continuity. |
| Update FCM token | POST | `/devices/fcm-token` | Push-token registration. |
| List devices | GET | `/devices` | Current user's active devices. |
| List all devices | GET | `/devices/all` | Current user's full device history. |
| Trust device | POST | `/devices/:id/trust` | User/device management. |
| Untrust device | POST | `/devices/:id/untrust` | User/device management. |
| Rename device | POST | `/devices/:id/rename` | User-facing label. |
| Register device key | POST | `/devices/:id/register-key` | Device public-key binding. |
| Delete device | DELETE | `/devices/:id` | Remove one device. |
| Delete current device | DELETE | `/devices` | Remove current device. |

## Wallet And Money

| Action | Method | Path |
| --- | --- | --- |
| Wallet summary/balance | GET | `/wallet` |
| Create wallet | POST | `/wallet/create` |
| Deposit channels | GET | `/wallet/deposit/channels` |
| Deposit providers | GET | `/wallet/deposit/providers` |
| Initiate deposit | POST | `/wallet/deposit` |
| Deposit status | GET | `/wallet/deposit/:id` |
| Exchange rate | GET | `/wallet/exchange-rate` |
| Internal transfer | POST | `/wallet/transfer/internal` |
| External transfer | POST | `/wallet/transfer/external` |
| Estimate external fee | GET | `/wallet/transfer/external/estimate-fee` |
| Withdraw | POST | `/wallet/withdraw` |
| KYC status | GET | `/kyc/status` |
| Submit KYC | POST | `/kyc/submit` |
| Upload KYC documents | POST | `/kyc/documents` |
| Upload single KYC document | POST | `/kyc/documents/single` |
| Create liveness session | POST | `/kyc/liveness/session` |
| Submit liveness challenge | POST | `/kyc/liveness/challenge` |
| Liveness status | GET | `/kyc/liveness/status` |
| Submit document verification | POST | `/kyc/document/submit` |
| Verification status | GET | `/kyc/verification/status` |

KYC state should drive the mobile FSM: unverified users can start KYC, pending/manual-review users should see review state, rejected users should see retry/remediation, and approved/verified/auto-approved users should unlock higher-risk flows according to backend limits and risk decisions.

`GET /user/limits` and `GET /wallet/limits` include a `permissions` object:

```json
{
  "canSend": true,
  "canDeposit": true,
  "canWithdraw": true,
  "canReceive": true,
  "blockReason": null,
  "reviewRequired": false
}
```

Mobile money-flow screens must check these booleans before presenting transfer, deposit, or withdrawal actions. When `reviewRequired=true`, show the backend `blockReason` and route the user to the manual-review/SLA state instead of retrying liveness or showing a generic limit error.

Use only `/kyc/liveness/*` for product liveness. The legacy backend `/liveness/*` mock controller is not part of the mobile/API contract and must not be used for KYC, account recovery, or money-flow step-up.

### Liveness Capability Contract

`POST /kyc/liveness/session` accepts:

```json
{
  "capabilities": {
    "supportedCaptureModes": ["photo"],
    "preferredCaptureMode": "photo",
    "supportedMimeTypes": ["image/jpeg"],
    "maxVideoDurationSeconds": null,
    "supportsOnDeviceFaceDetection": false,
    "supportsReferenceSelfie": true
  }
}
```

The API responds with `providerCapabilities`, `clientCapabilities`, `negotiatedCapabilities`, `requiredCaptureMode`, `acceptedCaptureModes`, `requiredEvidence`, and `evidencePolicy`. The current mobile liveness widget supports photo challenge capture only; if the API negotiates `video`, route the flow to manual review instead of attempting an unsupported capture.

Each challenge may include `recommendedCaptureMode`, `requiresMotionEvidence`, `manualReviewRecommended`, and `manualReviewReason`. Pose challenges such as smile, turn-left, turn-right, look-up, and blink can be completed as photo challenges. Motion challenges such as nod need video or a provider-backed motion signal; photo-only clients must route these to manual review instead of pretending a still image proves motion.

`POST /kyc/liveness/challenge` is multipart and currently accepts photo evidence only:

- fields: `sessionToken`, `challengeId`, `captureMode=photo`, `mediaType=photo`, optional `mimeType`
- file: `photo`

Successful challenge/reference-selfie responses include review-safe `evidence` metadata with `kind`, `challengeId`, `captureMode`, `mediaType`, `mimeType`, `byteSize`, `provider`, `storage`, redacted `sessionTokenRef`, `submittedAt`, and `reviewUsage`. Do not expose raw biometric media in mobile state; raw files stay with the provider/session storage unless a dedicated evidence storage flow is added.

When the final liveness challenge completes, the response should include `livenessCheckId` and `livenessProofId`. Mobile should pass `livenessProofId` to `/step-up/validate`; if missing, fall back to the session token only for simulator or older API compatibility.

Provider unavailability returns a retryable `KYC_PROVIDER_UNAVAILABLE` response with `supportReviewRequired=true`; mobile account recovery and KYC should route the user to manual review with an SLA instead of looping on liveness.

Account recovery manual review uses `POST /support/tickets` with `category=account_recovery`. The API dedupes active account-recovery tickets for the user and appends new outage/risk signals to the same ticket. Ticket responses may include `reviewSla` with `label`, `firstResponseDueAt`, and `resolutionDueAt`; prefer those values over hardcoded SLA copy.

## Contacts

| Action | Method | Path |
| --- | --- | --- |
| Create contact | POST | `/contacts` |
| List contacts | GET | `/contacts` |
| Favorites | GET | `/contacts/favorites` |
| Recents | GET | `/contacts/recents` |
| Search | GET | `/contacts/search` |
| Lookup Korido users | GET | `/contacts/lookup?query=ama` |
| Update | PUT | `/contacts/:id` |
| Toggle favorite | PUT | `/contacts/:id/favorite` |
| Delete | DELETE | `/contacts/:id` |
| Check Korido users | POST | `/contacts/check` |
| Sync contact list | POST | `/contacts/sync` |
| Invite | POST | `/contacts/invite` |

## Feature Subscriptions

| Action | Method | Path | Notes |
| --- | --- | --- | --- |
| Subscribe | POST | `/feature-subscriptions` | Include `featureKey`, `source`, locale/region when available. |
| List mine | GET | `/feature-subscriptions` | Authenticated. |

## Secondary Features

Capability responses use:

```json
{
  "feature": "payment_links",
  "available": true,
  "status": "available",
  "reason": null,
  "featureReason": null,
  "provider": null,
  "retryable": false,
  "supportReviewRequired": false
}
```

| Feature | Capability | Primary routes | Notes |
| --- | --- | --- | --- |
| Cards | GET `/cards` metadata | GET `/cards`, POST `/cards`, PUT `/cards/:id/freeze`, PUT `/cards/:id/unfreeze`, PUT `/cards/:id/limit`, DELETE `/cards/:id` | List response includes `available/status/reason/featureReason/provider`. |
| Bank linking | GET `/banks`, GET `/bank-accounts` metadata | POST `/bank-accounts`, POST `/bank-accounts/:id/verify`, POST `/bank-accounts/:id/deposit`, POST `/bank-accounts/:id/withdraw`, DELETE `/bank-accounts/:id` | Disabled providers return `BANK_LINKING_UNAVAILABLE`. |
| Bill payments | GET `/bill-payments/providers` | GET `/bill-payments/categories`, POST `/bill-payments/validate`, POST `/bill-payments/pay`, GET `/bill-payments/history`, GET `/bill-payments/:id` | Network/downstream 5xx returns `BILL_PAYMENTS_UNAVAILABLE`. |
| Payment links | GET `/payment-links/capability` | GET `/payment-links`, POST `/payment-links`, GET `/payment-links/:id`, GET `/payment-links/code/:code`, POST `/payment-links/code/:code/pay`, DELETE `/payment-links/:id` | Existing list response remains `{ links, total }`. |
| Savings pots | GET `/savings-pots/capability` | GET `/savings-pots`, GET `/savings-pots/:id`, POST `/savings-pots`, PUT `/savings-pots/:id`, POST `/savings-pots/:id/deposit`, POST `/savings-pots/:id/withdraw`, DELETE `/savings-pots/:id` | List response remains an array for current mobile parsers. |
| Recurring transfers | GET `/recurring-transfers/capability` | GET `/recurring-transfers`, GET `/recurring-transfers/upcoming`, GET `/recurring-transfers/:id`, POST `/recurring-transfers`, PATCH `/recurring-transfers/:id`, POST `/recurring-transfers/:id/pause`, POST `/recurring-transfers/:id/resume`, DELETE `/recurring-transfers/:id` | List response includes `transfers` and `data` aliases. |
| Referrals | GET `/referrals/capability` | GET `/referrals`, GET `/referrals/history`, GET `/referrals/code`, GET `/referrals/stats`, POST `/referrals/apply` | `/referrals` returns mobile summary object; `/history` returns raw referral array. |

Savings Pots also expose `GET /savings-pots/active`, `GET /savings-pots/:id/transactions`, and `POST /savings-pots/:id/withdraw-all`. The routed mobile savings experience should use these API-backed screens, not local placeholder goal state.

## Risk And Step-Up

| Action | Method | Path | Notes |
| --- | --- | --- | --- |
| Score session | POST | `/risk/session` | Device/session risk context. |
| Risk profile | GET | `/risk/profile` | Current user. |
| Register risk device | POST | `/risk/device/register` | Risk service device record. |
| Screen operation | POST | `/risk/screen` | General risk/compliance screen. |
| Step-up transaction | POST | `/step-up/transaction` | Use for risky money movement. |
| Step-up operation | POST | `/step-up/operation` | Generic sensitive operation challenge. |
| Validate step-up | POST | `/step-up/validate` | Complete challenge. |
| Step-up status | GET | `/step-up/status/:challengeToken` | Poll challenge. |
| Send step-up OTP | POST | `/step-up/send-otp` | OTP challenge. |
| Verify step-up OTP | POST | `/step-up/verify-otp` | OTP challenge. |
| Step-up config | GET | `/step-up/config` | Policy/config surface. |

`POST /step-up/validate` with `livenessSessionId` must reference a real VerifyHQ/Korido liveness proof that is `PASSED`, belongs to the current user, and satisfies live/anti-spoof/face-match thresholds. Older mobile builds may send the liveness `sessionToken`; the API resolves recent user checks for compatibility. If VerifyHQ is unavailable and the response includes `supportReviewRequired=true`, PIN reset and KYC flows must route to manual review with SLA copy instead of showing a generic validation error.

High-risk PIN reset, new-device, profile-photo, KYC, and money movement flows should request step-up/liveness only when risk warrants it; do not make low-end devices run expensive face/liveness checks unless the backend risk decision requires it.

## Admin And Backoffice Surfaces

| Action | Method | Path | Notes |
| --- | --- | --- | --- |
| Admin dashboard | GET | `/admin/dashboard` | Backoffice summary. |
| Enhanced dashboard | GET | `/admin/dashboard/enhanced` | Expanded backoffice summary. |
| Admin users | GET | `/admin/users` | User search/list. |
| Admin user detail | GET | `/admin/users/:userId` | User profile and operational state. |
| Set user limit override | PUT | `/admin/users/:userId/limit-override` | Special limits. |
| Delete user limit override | DELETE | `/admin/users/:userId/limit-override` | Remove special limits. |
| Suspend user | POST | `/admin/users/:userId/suspend` | Compliance/security action. |
| Unsuspend user | POST | `/admin/users/:userId/unsuspend` | Compliance/security action. |
| Reset user PIN | POST | `/admin/users/:userId/reset-pin` | Support flow. |
| Unlock user PIN | POST | `/admin/users/:userId/unlock-pin` | Support flow. |
| Force logout user | POST | `/admin/users/:userId/force-logout` | Security/session action. |
| Deactivate device | POST | `/admin/devices/:deviceId/deactivate` | Backoffice device blacklist/deactivation surface. |
| Pending KYC | GET | `/admin/kyc/pending` | Manual review queue. |
| Approve KYC | POST | `/admin/users/:userId/kyc/approve` | Manual override/review. |
| Reject KYC | POST | `/admin/users/:userId/kyc/reject` | Manual override/review. |
| Audit logs | GET | `/admin/audit-logs` | Backoffice audit trail. |

## Local OTP Stack

Start VerifyHQ:

```bash
cd /Users/macbook/Ainotek/Projects/JoonaPay/verify-hq
DB_PORT=5432 PORT=3300 NODE_ENV=development VERIFYHQ_DEV_OTP=123456 VERIFYHQ_DEV_API_KEY=dev-test-key DISPATCH_MOCK=true npm run start:api
```

Start Bill Pay if testing bill-payment or full simulator flows:

```bash
cd /Users/macbook/Ainotek/Projects/JoonaPay/bill-pay
PORT=3400 NODE_ENV=development ADMIN_SECRET=dev-admin-secret BILL_PAY_PROVIDER=mock BILL_PAY_PROVIDER_WEBHOOK_SECRET=dev-secret VERIFYHQ_BASE_URL=http://localhost:3300 VERIFYHQ_API_KEY=dev-test-key npm run start
```

Create a local Bill Pay API key and use the returned `apiKey` below:

```bash
curl -fsS -X POST http://127.0.0.1:3400/admin/api-clients \
  -H 'Content-Type: application/json' \
  -H 'X-Admin-Secret: dev-admin-secret' \
  -d '{"name":"Korido local E2E","permissions":["bills:read","bills:write"],"rateLimit":1000}'
```

Start Korido API:

```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/usdc-wallet
PORT=3401 \
JWT_SECRET=dev-local-jwt-secret-for-simulator-only-32 \
JWT_REFRESH_SECRET=dev-local-refresh-secret-for-simulator-only-32 \
VAULT_MASTER_KEY=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef \
BILL_PAY_BASE_URL=http://localhost:3400 \
BILL_PAY_API_KEY=<bill-pay-api-key> \
VERIFICATION_STRATEGY=verifyhq \
VERIFYHQ_BASE_URL=http://localhost:3300 \
VERIFYHQ_API_KEY=dev-test-key \
VERIFYHQ_OTP_LENGTH=6 \
CIRCLE_USE_MOCK=true \
YELLOW_CARD_ENABLED=true \
YELLOW_CARD_USE_MOCK=true \
STELLAR_USE_MOCK=true \
NTM_USE_MOCK=true \
npm run start
```

`YELLOW_CARD_ENABLED=true` is required with the mock flag for deposit screens. Without it, the API starts with the no-op payment adapter and deposit initiation fails.
