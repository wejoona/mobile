# Korido Mobile Release Risk Audit

Last checked: 2026-06-04

## Current Verified Baseline

- Full Flutter suite: `648 passed, 418 skipped`.
- Analyzer severity count: `INFO 13256`, no warnings or errors.
- iPhone 17 simulator live API flow passed against `http://127.0.0.1:3401/api/v1`.
- Current pushed mobile `main`: `da0cd48`.

## Dependency Risk

`flutter pub outdated` reports 110 packages behind latest. This is not a safe single-step upgrade for release readiness because several direct dependencies have major-version jumps:

- Firebase: `firebase_core 3.x -> 4.x`, `firebase_messaging 15.x -> 16.x`, `firebase_crashlytics 4.x -> 5.x`.
- Native permissions/device stack: `permission_handler 11.x -> 12.x`, `device_info_plus 11.x -> 13.x`, `local_auth 2.x -> 3.x`.
- Contacts/notifications: `flutter_contacts 1.x -> 2.x`, `flutter_local_notifications 18.x -> 21.x`.
- Media/KYC: `camera 0.11.x -> 0.12.x`, `image_gallery_saver_plus 4.x -> 5.x`.
- Navigation/UI: `go_router 17.0.1 -> 17.3.0`, `fl_chart 0.69.x -> 1.2.x`.

## iOS Build Warnings

Flutter currently warns that these plugins do not support Swift Package Manager for iOS:

- `sms_autofill`
- `safe_device`
- `permission_handler_apple`
- `image_gallery_saver_plus`
- `flutter_local_notifications`
- `flutter_image_compress_common`
- `flutter_contacts`

The app already has `flutter.config.enable-swift-package-manager: false` in `pubspec.yaml`, so this is a future-compatibility warning, not the current build blocker. Do not switch iOS package mode during a release-hardening pass without a dedicated branch and simulator/device verification.

## Recommended Upgrade Order

1. Patch-only upgrades first: `dio`, `flutter_secure_storage`, `flutter_svg`, `image_picker`, `mobile_scanner`, `shared_preferences`, `uuid`, `in_app_review`, `safe_device`.
2. Native permission/contact stack together: `permission_handler`, `flutter_contacts`, `device_info_plus`.
3. Notification stack together: `firebase_core`, `firebase_messaging`, `flutter_local_notifications`, `firebase_crashlytics`.
4. KYC/media stack together: `camera`, `image_gallery_saver_plus`, `flutter_image_compress`, `file_picker`.
5. Navigation/UI upgrades after screenshots: `go_router`, `fl_chart`.

Each group needs at minimum:

- `flutter pub get`
- `dart analyze --format=machine .`
- `flutter test --no-pub`
- iPhone 17 simulator flows for auth, onboarding, KYC, withdraw, notifications, contacts, and live API login.

## Decision

Do not run `flutter pub upgrade --major-versions` as part of normal production-readiness cleanup. Treat dependency upgrades as grouped release tasks with isolated verification.
