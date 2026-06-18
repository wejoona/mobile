# Mobile Current Status

Last updated: 2026-06-18 07:12 GMT

## Standing

- Active branch: `develop`, tracking `origin/develop`.
- Latest pushed mobile commit: `659468bf test: align auth phone contracts`.
- Current active slice: replace beta CSV picker dependency with stable `file_selector`.
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
- Android release bundle passes locally using Codemagic's direct Gradle path.
- iOS release build is currently blocked by machine Xcode state: `xcode-select` points to Command Line Tools and no local Xcode app bundle was found by `mdfind`/filesystem search.

## Next Gate

Before promoting to `staging`, finish release-build checks locally without consuming a TestFlight build:

- Restore/select a full Xcode installation and rerun iOS release build without signing.
- Final `git diff --check` before promotion.
