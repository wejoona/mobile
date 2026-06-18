# Mobile Current Status

Last updated: 2026-06-18 08:24 GMT

## Standing

- Active branch: `develop`, tracking `origin/develop`.
- Latest pushed mobile commit: `96dab7f6 fix: canonicalize login phone state`.
- Repo status should be clean unless a new slice is in progress.
- Do not promote to `staging` until Codemagic-equivalent local gates pass.

## Verified Recently

- iPhone 17 simulator boots the app with `ENV=staging`.
- Login is dark-theme default.
- Login no longer shows the Terms checkbox.
- Login no longer shows signup/onboarding progress markers.
- Phone input keeps country prefix and local number visually separate.
- Login phone state now stores country, dial code, local number, and E.164 separately; malformed duplicated-prefix input such as `+225|+2250748805663` is repaired before API calls.
- Staging API health, login, and OTP verification worked for `0748805663` with OTP `123456` when DNS was resolving.
- Staging API public smokes returned HTTP 200 on 2026-06-18: `/health`, `/config/mobile-version`, and `/config/countries`.
- Full non-golden mobile test gate passed after the phone-state canonicalization slice: 469 tests.

## Known Watch Items

- `staging-korido-api.joonapay.com` resolves publicly through system DNS, Cloudflare DNS, and Google DNS.
- Debug logs still include some noisy/misleading environment and certificate-pinning messages.
- Staging candidate is not ready until the local replay of Codemagic gates passes: analyzer warning gate, non-golden Flutter tests, iOS release build without signing, and Android release bundle check.
- Non-golden Flutter tests now pass locally using Codemagic's 40-file batch pattern.
- Android release bundle passes locally using Codemagic's direct Gradle path.
- iOS release build is currently blocked by machine Xcode state: `xcode-select` points to Command Line Tools and no local Xcode app bundle was found by `mdfind`/filesystem search.
- Simulator/phone launch is currently blocked for the same local Xcode visibility issue: `xcrun simctl` is unavailable under Command Line Tools.
- Mobile app version is currently `1.0.0+2`; the staging API version policy does not block that build, but defaults should stay intentional for future pre-release trains.

## Next Gate

Before promoting to `staging`, finish release-build checks locally without consuming a TestFlight build:

- Restore/select a full Xcode installation and rerun iOS release build without signing.
- Final `git diff --check` before promotion.
