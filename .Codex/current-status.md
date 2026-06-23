# Mobile Current Status

Last updated: 2026-06-23 GMT

## Standing

- Active branch: `develop`, tracking `origin/develop`.
- Latest pushed mobile code/build commit: `4df5b14d fix: canonicalize wallet receive contract`.
- Latest pushed API commit: `954f7ffc fix: carry deposit country into initiation`.
- Latest pushed dashboard commit: `0ba72f1 fix: stabilize dashboard support gates`.
- Repo status should be clean unless a new slice is in progress.
- Do not promote to `staging` until Codemagic-equivalent local gates pass.
- Close confirmed user reports here after focused verification; do not re-audit closed items unless new evidence or related code changes appear.

## Closed User Reports

- Active sessions 401 handling: closed. Mobile refreshes once, then locks instead of clearing local state; backend session routes return mobile-safe envelopes. Focused settings/session mobile tests and backend session e2e passed.
- Login/signup/onboarding confusion: closed. `/login` is the default auth entry, `/signup` is explicit account creation, product introduction remains `/onboarding`, and signup no longer owns tutorial progress markers or login Terms checkbox. Focused auth route/UI tests passed.
- Startup crash capture: closed for current code. Sentry now wraps app bootstrap before Firebase/Hive/shared-pref cleanup, and platform errors report to both Crashlytics and Sentry. Focused crash-reporting contract tests passed.
- Profile photo update: closed. Mobile requires one-face device evidence before avatar upload; backend rejects missing/stale/unbound proof and updates profile/avatar caches. Focused profile/avatar mobile tests and backend profile e2e passed.
- Contacts permission/Korido lookup: closed. Contact screens request permission only from explicit actions, sync hashed phone batches, and display Korido account badges from backend lookup/sync responses. Focused contacts mobile tests and backend contacts e2e passed.
- Send-money recipient safety: closed. Mobile rejects self-send by id/phone/username before submit, sends one canonical recipient identifier, and backend rejects self-transfer again before ledger movement. Focused send mobile tests and backend transfer tests passed.
- Home balance refresh/display: closed on current `develop`. `GET /wallet` is the canonical balance source, zero-balance wallets are loaded states, degraded/local-mirror balances show warnings instead of endless loading, and pull-to-refresh has bounded recovery. Focused wallet state/balance tests, mobile API alignment tests, backend get-balance tests, and wallet controller e2e passed on 2026-06-19.
- Transaction history fake/stale data concern: closed on current `develop`. Full History and home transaction refresh use `/wallet/transactions`; the duplicate feature-local transaction parser was removed so the domain `Transaction`/`TransactionPage` models are the only mobile transaction parser. Focused transaction state/API alignment tests and backend transaction controller e2e passed on 2026-06-19.
- Login OTP no-feedback report: closed on current `develop`. `/login/otp` shows the full-screen `OtpVerificationOverlay` with "Code accepted. Securing your session..." while verification/PIN handoff runs, holds it for at least 1.6 seconds, then routes to `/login/pin`. Focused login interaction tests passed on 2026-06-19.
- Signup/onboarding file-ownership confusion: closed on current `develop`. Account-creation screens now live under `features/signup/views` with `Signup*` class names, signup steps use the generic design-system `FlowStepProgress`, and `features/onboarding` keeps the product tutorial/post-login onboarding surfaces. Focused auth/router tests passed on 2026-06-19.
- KYC secondary route loops: closed on current `develop`. `/kyc/address`, `/kyc/video`, and `/kyc/additional-docs` now use the KYC wizard redirect, have explicit route contracts, and cannot bypass document/personal/selfie prerequisites into submitted/evidence loops. Focused route-contract and KYC status contract tests passed; committed as `d93058f8`.
- Wallet receive contract drift: closed on current `develop`. The receive screen uses the canonical `/wallet` balance/address state, and stale mobile-only `/wallet/receive` plus `/wallet/address` constants/helper/mock were removed. API alignment contract tests passed; committed as `4df5b14d`.

## Verified Recently

- iPhone 17 simulator boots the app with `ENV=staging`.
- Login is dark-theme default.
- Login no longer shows the Terms checkbox.
- Login no longer shows signup/onboarding progress markers.
- Login's `Sign up` action goes to `/signup` with `context.go`; the current `/signup` auth-entry screen has no back button, no tutorial progress marker, and no Terms/Privacy checkbox.
- Phone input keeps country prefix and local number visually separate.
- Login phone state now stores country, dial code, local number, and E.164 separately; malformed duplicated-prefix input such as `+225|+2250748805663` is repaired before API calls.
- Auth API now accepts ISO country codes and calling/dial codes at the boundary, including lowercase ISO and formatted local numbers, then normalizes to canonical E.164 phone plus ISO country before domain use cases.
- Contact matching now sends only canonical SHA-256 hashes to `/contacts/check`; the backend now rejects raw `phoneNumbers` with `400` before lookup, hashing, or repository access.
- User-bound biometric unlock now revokes stale stored biometric bindings immediately when the stored binding belongs to a different Korido user.
- Staging API health, login, and OTP verification worked for `0748805663` with OTP `123456` when DNS was resolving.
- Staging API public smokes returned HTTP 200 on 2026-06-18: `/health`, `/config/mobile-version`, and `/config/countries`.
- Full non-golden mobile test gate passed after the phone-state canonicalization slice: 469 tests.
- Focused biometric/session security tests passed after stale-binding revocation: 40 tests.
- Signup phone entry and legal consent now live under `features/signup`; product onboarding remains a separate intro route.
- Signup/account setup state now lives under `features/signup/providers/signup_flow_provider.dart` with `SignupFlow*` names; product tutorial onboarding keeps the onboarding naming.
- PIN routes are centralized under `ApiEndpoints.userPin*`; mobile services, reset flow, security interceptors, and PIN mocks now derive from the same `/user/pin/*` source of truth.
- API startup diagnostics now log the actual `ENV` plus build mode, and certificate pinning logs whether it was active or skipped for the current build.
- Backend contact controller e2e suite passed after the hash-only privacy boundary change: 23 tests, plus `npm run build` and `git diff --check`.
- Auth route contract tests passed after rechecking the reported TestFlight signup leak: `login_terms_boundary_test.dart`, `onboarding_routes_test.dart`, and `login_view_interaction_test.dart` passed 14 tests.
- Backend phone value-object and auth controller verification passed after canonical country-input hardening: 8 value-object tests, 20 auth controller e2e tests, `npm run build`, and `git diff --check`.
- Live staging checks with `+2250748805663` and OTP `123456` returned HTTP 200 for login, OTP verify, `/wallet`, `/sessions`, `/devices`, `/user/profile`, `/user/profile` update, and `/user/email-status`.
- Current staging wallet for that account is valid but zero-balance and degraded/local-mirror because ledger balance is temporarily unavailable; mobile should show zero plus sync warning, not fabricate funds.
- Wallet refresh path rechecked: pull-to-refresh has bounded UI timeouts, keeps last known/degraded state, and focused wallet state/balance tests passed 23 tests.
- Live staging wallet smoke for `+2250748805663` returned wallet `286c3d68-c47b-4d1c-baeb-dc2a8d2b8e56`, `USDC=0`, `sourceOfTruth=local_mirror`, `readStatus=degraded`, and backend warning `Ledger balance is temporarily unavailable. Showing local mirror balance.`
- Profile update API, profile thumbnail shape, and avatar upload cache replacement are healthy: mobile creates one-face device evidence bound to the uploaded bytes, backend rejects missing/stale/unbound proof, `UserAvatar` now uses the dedicated profile-photo cache, and avatar replacement/removal clears stale local/profile-photo caches. Focused profile contract tests passed 29 tests.
- Reset PIN account-recovery risk path now fails closed: account recovery fallback is red/manual review, missing liveness/step-up challenge tokens route to account-recovery support review instead of a retry dead-end, and focused PIN/session recovery contract tests passed 14 tests.
- Contacts permission and Korido account lookup are verified: first-time list access routes to a dedicated permission prompt instead of inline error, explicit actions request/open settings, Korido lookup uses backend search, and Korido contacts display account badges. Focused contacts permission/lookup contract tests passed 3 tests.
- Notifications feed, unread count, read/read-all actions, explicit permission flow, and device-token registration are verified against the backend contract; the legacy device-token helper no longer hardcodes iOS and requires an explicit platform. Focused API alignment tests passed 94 tests.
- Active sessions and device management are hardened around auth/security failures: session reads refresh once and lock instead of wiping local state on ordinary 401, device reads wait for auth, and device actions now normalize Dio failures to `ApiException` so blacklist and 401 outcomes clear or lock state consistently. Focused settings/API contract tests passed 102 tests.
- Authenticator app 2FA is verified as an intentional backend-enforced waitlist/capability, not a fake local toggle: mobile shows it as coming soon, subscribes to `two_factor_auth` with `requestedFeature=backend_enforced_mfa`, does not store local TOTP state/secrets, and the API service catalog marks it policy-governed with `requiresBackendEnforcement=true`.
- Email verification is verified end to end at the contract/usecase level: mobile checks `/user/email-status`, auto-requests a code when an email has no pending verification, resends through `/user/resend-email-verification`, verifies through `/user/verify-email`, and backend stores hashed 6-digit codes with non-production default `123456`. Mobile profile contract tests passed 29 tests; backend email verification usecase tests passed 6 tests.
- Transaction limits and money-flow permissions are technically implemented across mobile and API: mobile gates send, deposit, and withdrawal with live `/user/limits` before submission; backend exposes `/user/limits` and `/user/limits/usage`, retires `/wallet/limits` with a canonical endpoint hint, enforces per-transaction/daily/monthly limits before ledger movement, blocks manual-review states, and supports admin overrides. Mobile limits/deposit tests passed 16 tests; backend limit/enforcement tests passed 25 tests. Numeric tiers still need compliance sign-off before being called UEMOA-calibrated policy.
- Send-recipient identity safety is verified: transfer requests keep exactly one stable recipient identifier, malformed phone input is normalized before submit, username-only/masked recipients remain supported, lookup-selected users send by stable `recipientId`, and self-send is guarded by current user id/phone/username checks before money movement. Focused send recipient contract tests passed 11 tests.
- Cash-out/withdraw phone handling is now country-aware on current `develop`: withdraw state carries explicit country context, the routed withdraw screen passes the selected country, local cash-out numbers are rejected without a country context, and duplicated/international numbers still normalize to clean E.164. Focused API alignment tests passed 97 tests on 2026-06-19.
- Send-recipient phone entry is now metadata-driven on current `develop`: the dial-code selector derives from `countriesProvider`/`SupportedCountries`, initializes from user/selected country, derives local length from `CountryConfig`, and no longer keeps a hardcoded `+225` default/list in the screen. Focused API alignment tests passed 98 tests on 2026-06-19.
- Deposit initiation is now country-aware on current `develop`: routed amount selection stores the effective country with source currency, mobile sends `countryCode` to `/wallet/deposit`, backend resolves shared-currency channels using explicit country before legacy currency fallback, and compatibility helpers no longer invent missing channel/currency values. Focused mobile deposit contract tests, mobile API alignment tests, backend initiate-deposit tests, backend build, analyzer warning gate, and diff checks passed on 2026-06-19.
- Legacy duplicate deposit surfaces are removed on current `develop`: `MobileMoneyForm`, `DepositScreenWired`, static deposit method cards/tiles/providers, and the legacy deposit repository were deleted after reference checks proved the router uses the API-backed amount/provider/instructions/status flow. Focused deposit/API contract tests passed 116 tests, analyzer found no errors/warnings, and diff check was clean on 2026-06-19.
- Backoffice device blacklist/deactivation is verified at the dashboard service boundary: Filament user device actions create reasoned blacklist records, sync through Korido API registered-device endpoints when available, deactivate registered devices, disable push tokens, revoke sessions, and record API sync metadata. Focused dashboard Pest tests passed 2 tests / 12 assertions.
- App-version compatibility is verified for the staging-candidate path: mobile checks `/config/mobile-version` on startup, redirects to `/force-update` when `forceUpgrade=true`, and now has focused coverage that HTTP 426 responses trigger a version-policy refresh. Focused API client and force-update tests passed 34 tests.
- Codemagic-equivalent analyzer warning gate passed locally on 2026-06-18: `dart analyze --format machine` returned exit code 0 with no `ERROR` or `WARNING` records.
- Codemagic-style non-golden Flutter test batches passed locally on 2026-06-18: 469 tests passed, with only the existing skipped tests.
- Android release bundle is now owned by Gradle instead of a Codemagic-only shell patch: the release build strips the generated `integration_test` plugin registration before Java compilation, `codemagic.yaml` no longer carries the perl registrant edit, the release-config test passed 5 tests, and the Codemagic-equivalent `:app:bundleRelease` command passed locally.
- iOS release build now passes locally with Xcode Beta 27 without consuming TestFlight: `DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer flutter build ios --release --no-codesign --dart-define=ENV=staging --dart-define=API_URL=https://staging-korido-api.joonapay.com/api/v1` built `build/ios/iphoneos/Runner.app` on 2026-06-19. The build updated `ios/Podfile.lock` from stale `file_picker` to the current `file_selector_ios` plugin graph, matching `pubspec.lock`.
- iPhone 17 simulator launch now passes with Xcode Beta 27 and the staging API URL on 2026-06-19: the app booted to the dark login screen, issued the expected `GET /config/countries` request to `https://staging-korido-api.joonapay.com/api/v1`, and the screenshot is stored at `/private/tmp/korido-iphone17-smoke.png`.
- iPhone 17 live signup smoke passed with Xcode Beta 27 and staging API on 2026-06-19: registration followed explicit phone -> legal consent -> OTP -> profile -> PIN -> KYC-skip -> home, opened deposit, transactions, notifications, devices, sessions, notification settings, and logged out. The smoke also verified signup no longer posts unauthenticated `/legal/consent`, and push notifications now degrade cleanly when Firebase is unavailable in the integration runtime.
- Shared PIN/security keypad sizing was nudged on current `develop`: keys are now `68x64`, digits render at `24px`, and icons at `25px` so PIN entry feels more proportional across login unlock, signup PIN, reset PIN, session lock, and transaction confirmation surfaces.
- Live staging API smoke passed on 2026-06-18 for the mobile candidate account `+2250748805663` with dev OTP `123456`: login, OTP verification, profile, email status, limits, wallet, transactions, sessions, devices, notifications, contacts, cards capability, deposit providers/channels, and feature subscriptions all returned HTTP 200 with parseable JSON. Wallet remains intentionally degraded/local-mirror with zero balance until ledger availability is restored.
- Memory refresh completed on 2026-06-19 02:03 GMT: mobile and API repos were clean on `develop` after deposit cleanup; dashboard only had its known generated `.phpunit.cache/test-results` dirt.

## Known Watch Items

- `staging-korido-api.joonapay.com` resolves publicly through system DNS, Cloudflare DNS, and Google DNS.
- Staging candidate is not ready until the remaining KYC/backoffice approval state, PIN recovery pending/manual-review flow, notification/dispatch ownership, transaction-stats filter semantics, and money-flow edge smokes are closed with the current API URL.
- Non-golden Flutter tests now pass locally using Codemagic's 40-file batch pattern.
- Android release bundle passes locally using Codemagic's direct Gradle path.
- Xcode tooling is visible again. Global `xcode-select` currently points to `/Applications/Xcode.app` 26.5; `/Applications/Xcode-beta.app` 27.0 is installed and should be used for beta iOS 27 checks via `DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer` unless the user wants the global selector changed.
- Local protected-route smoke checks that read an auth token from `/tmp` require unsandboxed network execution in Codex; sandboxed Node/system DNS lookup returned `ENOTFOUND` while `dig` and unsandboxed curl resolved the same hostname.
- Mobile app version is currently `1.0.0+2`; the staging API version policy does not block that build, but defaults should stay intentional for future pre-release trains.
- Signup/onboarding naming split is complete at the provider, route-view, and setup-progress layers; account setup views are now signup-owned.

## Next Gate

Immediate next development slice:

- Fix canonical notification/dispatch ownership and user-visible KYC/PIN recovery state before broad visual sweeps.
- Preserve return context across KYC submitted/manual-review states where the user started from a gated money flow.

Before promoting to `staging`, finish release-build checks locally without consuming a TestFlight build:

- Login/session/money-flow smoke on the iPhone 17 simulator against `https://staging-korido-api.joonapay.com/api/v1`.
- Final `git diff --check` before promotion.
