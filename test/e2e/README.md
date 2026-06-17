# E2E API Tests

These tests run against the **real backend API** (no mocks).

## Usage

### Option 1: Local stack

Start the in-stack dependencies first:

```bash
cd /Users/macbook/Ainotek/Projects/JoonaPay/verify-hq
DB_PORT=5432 \
PORT=3300 \
NODE_ENV=development \
VERIFYHQ_DEV_OTP=123456 \
VERIFYHQ_DEV_API_KEY=dev-test-key \
VERIFYHQ_VERIFICATION_RATE_LIMIT_PER_MINUTE=1000 \
DISPATCH_MOCK=true \
npm run start:api
```

```bash
cd /Users/macbook/Ainotek/Projects/JoonaPay/bill-pay
PORT=3400 \
NODE_ENV=development \
ADMIN_SECRET=dev-admin-secret \
BILL_PAY_PROVIDER=mock \
BILL_PAY_PROVIDER_WEBHOOK_SECRET=dev-secret \
VERIFYHQ_BASE_URL=http://localhost:3300 \
VERIFYHQ_API_KEY=dev-test-key \
npm run start
```

Create a local Bill Pay API client and keep the returned `apiKey` out of git:

```bash
curl -fsS -X POST http://127.0.0.1:3400/admin/api-clients \
  -H 'Content-Type: application/json' \
  -H 'X-Admin-Secret: dev-admin-secret' \
  -d '{"name":"Korido local E2E","permissions":["bills:read","bills:write"],"rateLimit":1000}'
```

Start Korido API with the returned key:

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

Then run the E2E tests from the mobile repo:

```bash
RUN_E2E=true API_URL=http://127.0.0.1:3401/api/v1 flutter test test/e2e --no-pub -j 1
```

### Option 2: Production with pre-auth token
```bash
# Get a token first (login via mobile app, then extract from secure storage)
RUN_E2E=true \
API_URL=https://api.joonapay.com/api/v1 \
AUTH_TOKEN=eyJhbGci... \
flutter test test/e2e --no-pub -j 1
```

### Option 3: Production auth smoke with default OTP
```bash
RUN_E2E=true API_URL=http://127.0.0.1:3401/api/v1 flutter test test/e2e/auth_e2e_test.dart --no-pub
```

### Option 4: Specific test file
```bash
RUN_E2E=true API_URL=http://127.0.0.1:3401/api/v1 flutter test test/e2e/auth_e2e_test.dart --no-pub
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `RUN_E2E` | `false` | Must be `true` to run these real-backend tests |
| `API_URL` | `https://api.joonapay.com/api/v1` | Backend base URL |
| `AUTH_TOKEN` | (empty) | Pre-configured JWT token (skips login flow) |
| `DEFAULT_OTP` | `123456` | OTP fallback when `/dev/otp` is unavailable |
| `TEST_PHONE` | `+2250700000000` | Phone number for test user |
| `TEST_COUNTRY` | `CI` | Country used to normalize local-format `TEST_PHONE` values |

## Notes

- **Production** runs `NODE_ENV=production` — `/dev/otp` is disabled, so provide `AUTH_TOKEN`.
- **Local/dev** uses Korido API -> VerifyHQ with dev OTP `123456`; Circle, Yellow Card, Stellar, and NTM are mocked at the dependency boundary.
- `YELLOW_CARD_ENABLED=true` is required with `YELLOW_CARD_USE_MOCK=true`; otherwise deposit routes use the no-op adapter and return provider-unavailable errors.
- `VAULT_MASTER_KEY` must be 64 hex characters for local encrypted PIN and deposit payload flows.
- Run the full folder with `-j 1`. OTP verification is intentionally stateful and VerifyHQ enforces request/attempt limits, so parallel runs can trip legitimate throttles.
- Tests are independent per file but each file may create authenticated users through `loginFlow()`.

## Test Coverage

| File | Endpoints Tested |
|------|-----------------|
| `health_e2e_test.dart` | `/health`, `/health/time` |
| `auth_e2e_test.dart` | `/auth/register`, `/auth/login`, `/auth/verify-otp`, `/auth/refresh`, `/auth/logout` |
| `user_e2e_test.dart` | `/user/profile`, `/user/locale`, `/user/pin/*`, `/user/search`, `/user/limits` |
| `wallet_e2e_test.dart` | `/wallet`, `/wallet/limits`, `/deposits/*`, `/transfers/*`, `/withdrawals/*` |
| `transfers_e2e_test.dart` | `/transfers`, `/transfers/internal`, `/transfers/external` |
| `contacts_e2e_test.dart` | `/contacts`, `/contacts/sync`, `/contacts/lookup`, `/contacts/invite` |
| `payment_links_e2e_test.dart` | `/payment-links` CRUD + deactivate |
| `savings_pots_e2e_test.dart` | `/savings-pots` CRUD + deposit/withdraw |
| `cards_e2e_test.dart` | `/cards` CRUD + freeze/unfreeze |
| `devices_e2e_test.dart` | `/devices/register`, `/devices`, `/sessions` |
| `recurring_transfers_e2e_test.dart` | `/recurring-transfers` CRUD + pause/resume |
| `bank_linking_e2e_test.dart` | `/bank-accounts`, `/banks` |
| `bill_payments_e2e_test.dart` | `/bill-payments/*` |
| `beneficiaries_e2e_test.dart` | `/beneficiaries` CRUD |
| `notifications_e2e_test.dart` | `/notifications` |
