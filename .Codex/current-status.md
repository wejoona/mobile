# Mobile Current Status

Last updated: 2026-06-18 09:51 GMT

## Standing

- Active branch: `develop`, tracking `origin/develop`.
- Latest pushed mobile commit: `cce4d131 refactor: canonicalize user pin endpoints`.
- Latest pushed API commit: `bfa38bba fix: align mobile version policy defaults`.
- Repo status should be clean unless a new slice is in progress.
- Do not promote to `staging` until Codemagic-equivalent local gates pass.

## Verified Recently

- iPhone 17 simulator boots the app with `ENV=staging`.
- Login is dark-theme default.
- Login no longer shows the Terms checkbox.
- Login no longer shows signup/onboarding progress markers.
- Phone input keeps country prefix and local number visually separate.
- Login phone state now stores country, dial code, local number, and E.164 separately; malformed duplicated-prefix input such as `+225|+2250748805663` is repaired before API calls.
- Contact matching now sends only canonical SHA-256 hashes to `/contacts/check`; the old raw-phone contact check path is disabled.
- User-bound biometric unlock now revokes stale stored biometric bindings immediately when the stored binding belongs to a different Korido user.
- Staging API health, login, and OTP verification worked for `0748805663` with OTP `123456` when DNS was resolving.
- Staging API public smokes returned HTTP 200 on 2026-06-18: `/health`, `/config/mobile-version`, and `/config/countries`.
- Full non-golden mobile test gate passed after the phone-state canonicalization slice: 469 tests.
- Focused biometric/session security tests passed after stale-binding revocation: 40 tests.
- Signup phone entry and legal consent now live under `features/signup`; product onboarding remains a separate intro route.
- Signup/account setup state now lives under `features/signup/providers/signup_flow_provider.dart` with `SignupFlow*` names; product tutorial onboarding keeps the onboarding naming.
- PIN routes are centralized under `ApiEndpoints.userPin*`; mobile services, reset flow, security interceptors, and PIN mocks now derive from the same `/user/pin/*` source of truth.
- Live staging checks with `+2250748805663` and OTP `123456` returned HTTP 200 for login, OTP verify, `/wallet`, `/sessions`, `/devices`, `/user/profile`, `/user/profile` update, and `/user/email-status`.
- Current staging wallet for that account is valid but zero-balance and degraded/local-mirror because ledger balance is temporarily unavailable; mobile should show zero plus sync warning, not fabricate funds.
- Profile update API and profile thumbnail shape are healthy; avatar upload still depends on on-device face detection and multipart upload in manual device testing.

## Known Watch Items

- `staging-korido-api.joonapay.com` resolves publicly through system DNS, Cloudflare DNS, and Google DNS.
- Debug logs still include some noisy/misleading environment and certificate-pinning messages.
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
