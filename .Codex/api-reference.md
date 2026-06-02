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
| Search users | GET | `/user/search` |
| Check username | GET | `/user/username/check/:username` |
| Limits | GET | `/user/limits` |
| Set PIN | POST | `/user/pin/set` |
| Change PIN | POST | `/user/pin/change` |
| Verify PIN | POST | `/user/pin/verify` |
| Reset PIN | POST | `/user/pin/reset` |

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
| KYC status | GET | `/wallet/kyc/status` |
| Submit KYC | POST | `/wallet/kyc/submit` |

## Contacts

| Action | Method | Path |
| --- | --- | --- |
| Create contact | POST | `/contacts` |
| List contacts | GET | `/contacts` |
| Favorites | GET | `/contacts/favorites` |
| Recents | GET | `/contacts/recents` |
| Search | GET | `/contacts/search` |
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

## Local OTP Stack

Start VerifyHQ:

```bash
cd /Users/macbook/Ainotek/Projects/JoonaPay/verify-hq
DB_PORT=5432 PORT=3300 NODE_ENV=development VERIFYHQ_DEV_OTP=123456 VERIFYHQ_DEV_API_KEY=dev-test-key DISPATCH_MOCK=true npm run start:api
```

Start Korido API:

```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/usdc-wallet
PORT=3401 VERIFICATION_STRATEGY=verifyhq VERIFYHQ_BASE_URL=http://localhost:3300 VERIFYHQ_API_KEY=dev-test-key VERIFYHQ_OTP_LENGTH=6 CIRCLE_USE_MOCK=true YELLOW_CARD_USE_MOCK=true STELLAR_USE_MOCK=true NTM_USE_MOCK=true npm run start
```
