# E2E API Tests

These tests run against the **real backend API** (no mocks).

## Usage

### Option 1: Local backend (recommended — has /dev/otp for auto-login)
```bash
# Start backend locally first, then:
dart test test/e2e/ -r expanded --dart-define=API_URL=http://localhost:3000/api/v1
```

### Option 2: Production with pre-auth token
```bash
# Get a token first (login via mobile app, then extract from secure storage)
dart test test/e2e/ -r expanded \
  --dart-define=API_URL=https://api.joonapay.com/api/v1 \
  --dart-define=AUTH_TOKEN=eyJhbGci...
```

### Option 3: Specific test file
```bash
dart test test/e2e/auth_e2e_test.dart -r expanded \
  --dart-define=API_URL=http://localhost:3000/api/v1
```

## Configuration (--dart-define)

| Variable | Default | Description |
|----------|---------|-------------|
| `API_URL` | `https://api.joonapay.com/api/v1` | Backend base URL |
| `AUTH_TOKEN` | (empty) | Pre-configured JWT token (skips login flow) |
| `TEST_PHONE` | `+2250700000000` | Phone number for test user |

## Notes

- **Production** runs `NODE_ENV=production` — `/dev/otp` is disabled, so you MUST provide `AUTH_TOKEN`
- **Local/dev** runs `NODE_ENV=development` — auto-login works via `/dev/otp/:phone`
- Rate limiting: prod has throttle guards, tests may hit 429 if run too fast
- Tests are independent per file but share the `loginFlow()` setup

## Test Coverage

| File | Endpoints Tested |
|------|-----------------|
| `health_e2e_test.dart` | `/health`, `/health/time` |
| `auth_e2e_test.dart` | `/auth/register`, `/auth/login`, `/auth/verify-otp`, `/auth/refresh`, `/auth/logout` |
| `user_e2e_test.dart` | `/user/profile`, `/user/locale`, `/user/pin/*`, `/user/search`, `/user/limits` |
| `wallet_e2e_test.dart` | `/wallet`, `/wallet/limits`, `/wallet/deposit/*`, `/wallet/transfer/*`, `/wallet/pin/*` |
| `transfers_e2e_test.dart` | `/transfers`, `/transfers/internal`, `/transfers/external` |
| `contacts_e2e_test.dart` | `/contacts`, `/contacts/sync` |
| `payment_links_e2e_test.dart` | `/payment-links` CRUD + deactivate |
| `savings_pots_e2e_test.dart` | `/savings-pots` CRUD + deposit/withdraw |
| `cards_e2e_test.dart` | `/cards` CRUD + freeze/unfreeze |
| `devices_e2e_test.dart` | `/devices/register`, `/devices`, `/sessions` |
| `recurring_transfers_e2e_test.dart` | `/recurring-transfers` CRUD + pause/resume |
| `bank_linking_e2e_test.dart` | `/bank-accounts`, `/banks` |
| `bill_payments_e2e_test.dart` | `/bill-payments/*` |
| `beneficiaries_e2e_test.dart` | `/beneficiaries` CRUD |
| `notifications_e2e_test.dart` | `/notifications` |
