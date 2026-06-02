# Korido Mobile API Contract Inventory

Last updated: 2026-06-02

Local API base used for dogfood: `http://127.0.0.1:3011/api/v1`

VerifyHQ local health: `http://127.0.0.1:3300/health`

## Auth

Mobile uses `/auth/register`, `/auth/verify-otp`, `/auth/login`, `/auth/refresh`, and `/auth/logout`. Logout must send the stored `refreshToken`; sending an empty body causes a backend `400`.

Status: live API verified in simulator in the previous MVP pass.

## KYC

Mobile KYC flow uses `/kyc/documents`, `/kyc/submit`, `/kyc/status`, and VerifyHQ-backed liveness routes when enabled. Simulator-safe flow can reach manual review with the local VerifyHQ sandbox.

Status: live API verified in simulator in the previous MVP pass.

## Wallet And Deposit

Wallet creation uses `/wallet/create`; balance and transaction list use wallet endpoints. The dedicated deposit flow uses `/deposits/providers`, `POST /deposits/initiate`, `POST /deposits/confirm`, `GET /deposits/:id`, and `GET /wallet/exchange-rate` for the mobile exchange-rate alias.

Risk: two mobile deposit clients still coexist: the dedicated deposit feature uses `/deposits/*`, while legacy wallet helpers still expose `/wallet/deposit/*`. Keep the dogfood UI on one path per screen and avoid mixing their response models.

## Transactions

History uses `/wallet/transactions`. Transaction detail is safe when the route receives a `Transaction` in `extra`.

Risk: direct transaction detail navigation without route `extra` needs a detail-by-id fallback if deep links or notification links are used.

## Cards

Cards API uses:

- `GET /cards`
- `POST /cards`
- `GET /cards/:id`
- `DELETE /cards/:id`
- `PUT /cards/:id/freeze`
- `PUT /cards/:id/unfreeze`
- `GET /cards/:id/transactions`

Status: existing contract tests verify freeze/unfreeze verbs and empty transaction response parsing.

## Feature Subscriptions

Coming-soon/waitlist actions use authenticated `POST /feature-subscriptions`.

Required body:

```json
{
  "featureKey": "virtual_card",
  "source": "cards_screen",
  "metadata": {
    "surface": "cards",
    "featureName": "Korido virtual card",
    "locale": "en"
  }
}
```

Backend derives `userId` from JWT. Mobile must not send `userId`.

Duplicate behavior: backend updates an active `(userId, featureKey, source)` subscription and still returns `201`.

Status: mobile Cards "Notify Me" now calls this route through `FeatureSubscriptionsService`.

## Contacts

Relevant mobile surfaces reference `/contacts/sync`, `/contacts/check`, and `/contacts/recents`.

Risk: send-recipient, saved recipients, recents, and contacts sync appear to use mixed contracts. Align one contact-match contract before polishing contacts UI.

## Devices And Sessions

Settings trust screens call `/devices` and `/sessions`.

Status: previous simulator pass showed `/sessions` returned `[]` without `401`.

Risk: mocks and live routes need a prefix/shape check so local dogfood does not hide auth regressions.

## Notifications And Preferences

Notification feed and read-all use notification endpoints; preferences use `/user/notification-preferences`.

Risk: list response parsing and read/read-all verbs should be checked together because mock/live shapes may differ.

## Next Contract Priorities

1. Deposit instruction flow: retire or isolate the legacy `/wallet/deposit/*` helpers so the active dogfood UI has one deposit contract.
2. Contacts discovery: align sync, recents, invite, and Korido-user badge payloads.
3. Transaction detail: add by-id fallback for direct route opens.
4. Notifications: verify list, unread count, read-all, and preferences persistence.
