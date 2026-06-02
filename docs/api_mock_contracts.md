# API Mock Contracts

## Lists
- Prefer `{ "data": [...] }` or endpoint-specific keys already used by the API code.
- Mobile parsers must accept `{ "data": [...] }`, `{ "items": [...] }`, and an endpoint-specific list key when one exists.

## Contacts
- Korido contacts require `isKoridoUser: true` and `joonaPayUserId`.
- Non-Korido contacts require `isKoridoUser: false`.
- Phone fixtures for Cote d'Ivoire must be valid `+225` E.164 numbers with 10 local digits.

## Money Mutations
- Transfer, deposit, and withdrawal mocks must keep wallet balance and transaction history consistent.
- Internal transfer mocks require the same PIN-token path as the app flow.
- Mobile-money deposits send `amount`, `currency`, `providerCode`, and normalized E.164 `phoneNumber`.
- Deposit mocks reject stale `provider`-only initiate payloads.
- Offline transfer drafts are queueable before PIN only as `needsAuthorization`; PIN tokens and idempotency keys are not persisted.

## Profile
- `GET /user/profile` should reflect the authenticated mock user, not a separate static user.
- Profile avatar thumbnails should be valid renderable data URIs or absent.
- `PUT /user/profile`, `POST /user/avatar`, and `DELETE /user/avatar` must update the same profile state returned by `GET /user/profile`.

## Secondary Product Surfaces
- Payment-link create/list/code/pay/cancel mocks must preserve status transitions and route deep links from `korido://pay/{code}` to `/pay/{code}`.
- Payment-link payment screens display the original requested currency and convert XOF/XAF to payable USDC before balance validation.
- Bill-payment validation and payment mocks must reject unknown providers instead of accepting invalid IDs.
- Savings-pot mocks are mutable across create, update, deposit, withdraw, withdraw-all, transaction-history, and delete routes.
- Recurring-transfer mocks are mutable across create, update, pause, resume, history, upcoming, next-date preview, and cancel routes.
- Card mocks return the fields expected by cards UI and service code: `walletId`, `maskedCardNumber`, `cardType`, `spendingLimit`, `remainingLimit`, and `updatedAt`.
- Deposit instructions expose the backend reference token, expiry, and provider metadata before method-specific instructions.
- Withdrawal screens display available balance in USDC because validation and quick amounts operate on USDC.

## Required App Routes
- `GET /wallet`
- `GET /wallet/transactions`
- `POST /transfers/internal`
- `GET /deposits/providers`
- `POST /deposits/initiate`
- `GET /deposits`
- `GET /contacts`
- `POST /contacts/sync`
- `GET /beneficiaries`
- `GET /devices`
- `GET /user/notification-preferences`
- `GET /user/profile`
- `GET /payment-links`
- `POST /payment-links`
- `GET /payment-links/code/:code`
- `POST /payment-links/:id/pay`
- `POST /payment-links/:id/cancel`
- `GET /bill-payments/providers`
- `GET /bill-payments/categories`
- `POST /bill-payments/validate`
- `POST /bill-payments/pay`
- `GET /bill-payments/receipt/:id`
- `GET /bill-payments/history`
- `GET /savings-pots`
- `POST /savings-pots`
- `GET /savings-pots/:id`
- `PUT /savings-pots/:id`
- `POST /savings-pots/:id/deposit`
- `POST /savings-pots/:id/withdraw`
- `POST /savings-pots/:id/withdraw-all`
- `GET /savings-pots/:id/transactions`
- `DELETE /savings-pots/:id`
- `GET /recurring-transfers`
- `POST /recurring-transfers`
- `PUT /recurring-transfers/:id`
- `POST /recurring-transfers/:id/pause`
- `POST /recurring-transfers/:id/resume`
- `GET /recurring-transfers/:id/history`
- `GET /recurring-transfers/upcoming`
- `POST /recurring-transfers/next-dates`
- `DELETE /recurring-transfers/:id`
- `GET /cards`
- `POST /cards`
- `POST /cards/:id/freeze`
- `POST /cards/:id/unfreeze`
- `PUT /cards/:id/limit`
- `GET /cards/:id/transactions`
- `DELETE /cards/:id`
