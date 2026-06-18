# Mobile Current Status

Last updated: 2026-06-18

## Standing

- Active branch: `develop`, tracking `origin/develop`.
- Latest mobile commit: `ec864545 fix: canonicalize phone number value`.
- Repo status was clean after the phone canonicalization slice.
- Do not promote to `staging` until Codemagic-equivalent local gates pass.

## Verified Recently

- iPhone 17 simulator boots the app with `ENV=staging`.
- Login is dark-theme default.
- Login no longer shows the Terms checkbox.
- Login no longer shows signup/onboarding progress markers.
- Phone input keeps country prefix and local number visually separate.
- Staging API health, login, and OTP verification worked for `0748805663` with OTP `123456` when DNS was resolving.

## Known Watch Items

- Mac DNS resolution for `staging-korido-api.joonapay.com` became intermittent during the last check.
- Debug logs still include some noisy/misleading environment and certificate-pinning messages.
- Staging candidate is not ready until the local replay of Codemagic gates passes: analyzer warning gate, non-golden Flutter tests, iOS release build without signing, and Android release bundle check.
- Non-golden Flutter tests now pass locally using Codemagic's 40-file batch pattern.

## Next Gate

Run release-build checks locally without consuming a TestFlight build:

- iOS release build without signing.
- Android release bundle check.
- Final `git diff --check` before promotion.
