# Mobile Current Status

Last updated: 2026-06-18 10:04 GMT

## Standing

- Active branch: `develop`, tracking `origin/develop`.
- Latest pushed mobile code commit: `17ae80df fix: harden device action auth errors`.
- Latest pushed API commit: `b2728ec5 fix: canonicalize auth country inputs`.
- Repo status should be clean unless a new slice is in progress.
- Do not promote to `staging` until Codemagic-equivalent local gates pass.

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

## Known Watch Items

- `staging-korido-api.joonapay.com` resolves publicly through system DNS, Cloudflare DNS, and Google DNS.
- Staging candidate is not ready until the local replay of Codemagic gates passes: analyzer warning gate, non-golden Flutter tests, iOS release build without signing, and Android release bundle check.
- Non-golden Flutter tests now pass locally using Codemagic's 40-file batch pattern.
- Android release bundle passes locally using Codemagic's direct Gradle path.
- iOS release build is currently blocked by machine Xcode state: `xcode-select` points to `/Library/Developer/CommandLineTools`, `/Applications` and `~/Applications` do not contain a discoverable Xcode app, `mdfind` returns no `com.apple.dt.Xcode`, and `xcrun simctl` is unavailable.
- Simulator/phone launch is currently blocked for the same local Xcode visibility issue; Flutter sees only macOS and Chrome devices.
- Mobile app version is currently `1.0.0+2`; the staging API version policy does not block that build, but defaults should stay intentional for future pre-release trains.
- Signup/onboarding naming split is complete at the provider layer; remaining account setup view filenames under `features/onboarding/views` can be moved only as a dedicated route-safe cleanup slice.

## Next Gate

Before promoting to `staging`, finish release-build checks locally without consuming a TestFlight build:

- Restore/select a full Xcode installation and rerun iOS release build without signing.
- Final `git diff --check` before promotion.
