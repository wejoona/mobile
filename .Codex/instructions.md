# Mobile Codex Instructions

Use this file first for mobile tasks.

## Working Rules

- Prefer existing components from `lib/design/components` over new widgets.
- Use `AppText`, `AppButton`, `AppInput`, `AppCard`, `AppSelect`, badges, and theme tokens before inventing local styles.
- Keep API work aligned with `mobile/.Codex/api-reference.md`; if the contract is unclear, inspect the backend controller/DTO before editing parsing.
- Do not switch to mocks to hide API failures. Use mocks only when the dependency is outside the stack or explicitly unavailable.
- For UI changes, check both light and dark themes. Dark already has strong visual character; light should feel equally intentional, not generic.
- For money and identity screens, prioritize clarity, trust, and low cognitive load over decoration.
- Do not mutate production Kubernetes or GitOps from mobile work.

## Fast Commands

Use `./scripts/codex_mobile.sh <recipe>` as the stable Codex command surface.
Do not prefix commands with `RUN_E2E=... API_URL=...`; add or reuse a named
recipe in the wrapper so approvals remain reusable.

```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
flutter pub get
flutter test
flutter test test/services/auth/auth_service_test.dart test/services/api_contract_alignment_test.dart
flutter run --dart-define=API_URL=http://localhost:3401/api/v1
```

For iOS Simulator against host-local API, use:

```bash
flutter run -d "iPhone" --dart-define=API_URL=http://127.0.0.1:3401/api/v1
```

For physical iPhone, use the Mac LAN IP instead of `localhost`.

## Verification Baseline

- Dev OTP is `123456` when VerifyHQ is started with `VERIFYHQ_DEV_OTP=123456`.
- Auth payloads are:
  - Register: `{ "phone": "+225...", "countryCode": "CI" }`
  - Login: `{ "phone": "+225..." }`
  - Verify OTP: `{ "phone": "+225...", "otp": "123456" }`
