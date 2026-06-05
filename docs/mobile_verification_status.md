# Mobile Verification Status

## Green Simulator Flows
- Onboarding to home
- Deposit
- Send money
- Receive QR
- Transaction history
- Settings/security/devices/sessions/notifications/help
- Contacts and beneficiaries
- Profile edit and profile photo removal
- Offline queued transfer reauthorization and send
- Secondary cash-out and payments flow: withdrawal, bill payment, external transfer
- Secondary deposit instructions with reference and expiry
- Secondary product surfaces: payment links, savings pots, recurring transfers, cards

## Next Flow
- Simulator visual pass on iPhone 16 Pro with the live API, focused on cards, send, deposit, notifications, and settings child screens.

## Known Non-Blocking Noise
- Firebase not initialized in mock/dev simulator runs
- UIScene lifecycle warning
- Swift Package Manager plugin adoption warnings
- Analyzer info-level style lints

## Latest Verification
- 2026-06-05 live API readiness:
  - Pushed `008a9aa fix: polish session device display` to `origin/main`.
    - Session timeout warning actions are stacked full-width to avoid translated button truncation.
    - Mobile sends Korido device-aware `User-Agent` headers with security/device headers.
    - Active Sessions recognizes iOS user agents and strips IPv6-mapped IPv4 prefixes such as `::ffff:`.
  - Pushed `2fcc906 fix: localize empty states` to `origin/main`.
    - Cards, deposit, notifications, and transactions empty states now use existing localization keys instead of hardcoded French.
  - `RUN_E2E=true API_URL=https://api.joonapay.com/api/v1 dart test -j 1 test/e2e/cards_e2e_test.dart test/e2e/feature_subscriptions_e2e_test.dart test/e2e/contacts_e2e_test.dart test/e2e/notifications_e2e_test.dart test/e2e/wallet_e2e_test.dart test/e2e/transfers_e2e_test.dart` passed 47 live API tests.
  - `RUN_E2E=true API_URL=https://api.joonapay.com/api/v1 dart test -j 1 test/e2e` passed 123 live API tests.
  - `flutter test test/services/api_contract_alignment_test.dart test/features/settings/device_contract_test.dart` passed 29 focused contract tests.
  - Focused analyzer on the localized empty-state widgets reports only info-level existing diagnostics (`diagnostic_describe_all_properties`), no errors.
- 2026-05-26 secondary surfaces:
  - `flutter test integration_test/flows/secondary_surfaces_flow_test.dart -d D4B4BD57-0447-4B96-A4F0-084F2C6ABF12 --dart-define=USE_MOCKS=true` passed 4 simulator tests.
  - `flutter test integration_test/flows/secondary_surfaces_flow_test.dart --plain-name "requests a virtual card and opens its details" -d D4B4BD57-0447-4B96-A4F0-084F2C6ABF12 --dart-define=USE_MOCKS=true` passed 1 simulator test.
  - `flutter test test/mocks/secondary_surfaces_contract_test.dart` passed 5 tests.
  - Fixed during simulator sweep: payment-link created route now loads by route id; recurring transfer rows open details; card empty state opens request flow; card request accepts verified mock KYC state and refreshes list data after creation.
  - `flutter test test/router/app_route_inventory_test.dart test/mocks/mock_interceptor_test.dart test/mocks/money_invariants_test.dart test/features/deposit/deposit_response_contract_test.dart test/features/send/confirm_screen_offline_test.dart test/services/offline/pending_transfer_queue_test.dart test/mocks/secondary_surfaces_contract_test.dart` passed 30 tests.
  - `flutter test integration_test/flows/cashout_and_payments_flow_test.dart -d D4B4BD57-0447-4B96-A4F0-084F2C6ABF12 --dart-define=USE_MOCKS=true` passed 3 simulator tests.
  - `flutter test integration_test/flows/deposit_flow_test.dart -d D4B4BD57-0447-4B96-A4F0-084F2C6ABF12 --dart-define=USE_MOCKS=true` passed 1 simulator test.
- 2026-05-26 focused analyzer checks:
  - `flutter analyze --no-fatal-infos lib/features/payment_links/views/create_link_view.dart lib/features/payment_links/views/link_created_view.dart lib/features/cards/views/cards_list_view.dart lib/features/cards/views/request_card_view.dart lib/features/recurring_transfers/views/recurring_transfers_list_view.dart integration_test/helpers/korido_flow_driver.dart integration_test/flows/secondary_surfaces_flow_test.dart` exited 0 with info-level lint noise only.
  - `flutter analyze --no-fatal-infos test/mocks/secondary_surfaces_contract_test.dart lib/mocks/services/savings_pots/savings_pots_mock.dart lib/services/savings_pots/savings_pots_service.dart lib/mocks/services/recurring_transfers/recurring_transfers_mock.dart lib/services/cards/cards_service.dart lib/mocks/services/cards/cards_mock.dart lib/mocks/mock_registry.dart lib/mocks/services/bill_payments/bill_payments_mock.dart lib/router/app_router.dart lib/features/cards/views/cards_list_view.dart lib/features/payment_links/views/payment_links_list_view.dart lib/features/payment_links/widgets/payment_link_card.dart lib/features/payment_links/views/pay_link_view.dart lib/features/deposit/views/payment_instructions_screen.dart lib/features/wallet/views/withdraw_view.dart lib/services/deep_link/deep_link_handler.dart` exited 0 with info-level lint noise only.
- `flutter test test/mocks/mock_interceptor_test.dart test/mocks/money_invariants_test.dart test/features/deposit/deposit_response_contract_test.dart`
- `flutter test test/features/send/confirm_screen_offline_test.dart test/services/offline/pending_transfer_queue_test.dart`
- `flutter test integration_test/flows/deposit_flow_test.dart -d D4B4BD57-0447-4B96-A4F0-084F2C6ABF12 --dart-define=USE_MOCKS=true`
- `flutter test integration_test/flows/profile_offline_recovery_flow_test.dart -d D4B4BD57-0447-4B96-A4F0-084F2C6ABF12 --dart-define=USE_MOCKS=true`
- `flutter run -d D4B4BD57-0447-4B96-A4F0-084F2C6ABF12 --dart-define=USE_MOCKS=true` after clearing stale simulator app state; clean boot reached onboarding screen.
