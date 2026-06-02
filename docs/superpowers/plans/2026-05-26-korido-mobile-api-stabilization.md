# Korido Mobile API Stabilization Implementation Plan

Goal: make Korido mobile simulator-proven and API-aligned, with mocks matching API contracts rather than bypassing them.

## Ground Truth
- Mobile repo: `/Users/macbook/JoonaPay/USDC-Wallet/mobile`
- Backend repo: `/Users/macbook/JoonaPay/USDC-Wallet/usdc-wallet`
- Mock mode flag: `--dart-define=USE_MOCKS=true`
- Simulator: `D4B4BD57-0447-4B96-A4F0-084F2C6ABF12`
- Default OTP: `123456`
- Current green simulator flows are tracked in `/Users/macbook/JoonaPay/USDC-Wallet/mobile/docs/mobile_verification_status.md`.

## Execution Order
- [x] Phase 0: stabilize workbench and verification ledger.
- [x] Phase 2: test and fix people-to-send pickers.
- [x] Phase 1: lock API/mock contract routes with tests and docs.
- [x] Phase 3: verify money invariants and simulator money journey.
- [x] Phase 4: profile, photo, security, and offline review/fixes.
- [x] Phase 5: secondary product surfaces.
- [ ] Phase 6: design continuity and accessibility.
- [ ] Phase 7: live API readiness.
- [ ] Phase 8: release gate.

## Phase 0 Checklist
- [x] Snapshot dirty mobile worktree with `git status --short`.
- [x] Review scoped contacts/beneficiaries diff without reverting unrelated work.
- [x] Create mobile verification ledger.

## Phase 2 Checklist
- [x] Add simulator coverage for send from contacts and beneficiaries.
- [x] Run the send simulator test red.
- [x] Gate native contact permission outside mock mode.
- [x] Make contact picker load API-backed mock contacts in mock mode.
- [x] Run the send simulator test green.

## Phase 1 Checklist
- [x] Add required mock route contract table.
- [x] Verify every route returns a parseable envelope.
- [x] Document API mock contract conventions.

## Verification Commands
```bash
flutter test test/mocks/mock_interceptor_test.dart
flutter test integration_test/flows/send_money_flow_test.dart -d D4B4BD57-0447-4B96-A4F0-084F2C6ABF12 --dart-define=USE_MOCKS=true
flutter analyze lib/features/send/views/recipient_screen.dart lib/features/send/widgets/contact_picker_bottom_sheet.dart integration_test/flows/send_money_flow_test.dart
```

## Phase 3 Checklist
- [x] Add money invariant tests for PIN, balance, transfer list, history, and deposit status.
- [x] Run mock API money invariant tests green.
- [x] Run simulator sweep for wallet, deposit, send, receive QR, transaction history, and contacts/beneficiaries.

## Phase 4 Checklist
- [x] Align profile mock state with authenticated user data and persistent avatar state.
- [x] Return a valid data URI avatar thumbnail from mocks.
- [x] Align deposit initiate payload with backend-style `currency` + `providerCode`.
- [x] Reject stale deposit payloads that still send `provider` only.
- [x] Queue offline transfer drafts before PIN verification when the app already knows it is offline.
- [x] Keep queued offline drafts as `needsAuthorization` and never persist PIN replay headers.
- [x] Make the Korido account badge size-safe in constrained rows.
- [x] Run unit/widget tests for API contracts, deposit payloads, offline queue safety, and offline confirm queueing.
- [x] Run simulator profile/photo/offline recovery flow.

## Phase 5 Checklist
- [x] Add contract coverage for payment links, bill payments, savings pots, recurring transfers, and cards.
- [x] Make savings-pot mocks mutable and align service list/update parsing with API envelope variants.
- [x] Make recurring-transfer mocks persist create/update/pause/resume/cancel state.
- [x] Align cards service payloads and mocks with card UI expectations.
- [x] Reject invalid bill-payment providers during validation and payment.
- [x] Route `/cards` to the real card list instead of a placeholder screen.
- [x] Route payment-link list actions to create/detail views.
- [x] Display payment-link status/action states consistently and handle XOF/XAF-to-USDC payment checks.
- [x] Surface deposit reference, expiry, and provider metadata in deposit instructions.
- [x] Display withdrawal available balance in USDC to match validation.
- [x] Align payment deep links from `korido://pay/{code}` to `/pay/{code}`.
- [x] Run focused unit/widget/API contract verification.
- [x] Run simulator verification for cash-out/payments and deposit instructions.
- [x] Add simulator coverage for payment links, savings pots, recurring transfer details, and virtual card request/details.
- [x] Fix payment-link created screen to load the route id instead of stale state.
- [x] Wire recurring-transfer list rows to detail routes.
- [x] Route card empty state through request flow, accept verified mock KYC state, and refresh card list after creation.
- [x] Run full secondary product simulator sweep.

## Phase 5 Verification Commands
```bash
flutter test test/mocks/secondary_surfaces_contract_test.dart
flutter test test/router/app_route_inventory_test.dart test/mocks/mock_interceptor_test.dart test/mocks/money_invariants_test.dart test/features/deposit/deposit_response_contract_test.dart test/features/send/confirm_screen_offline_test.dart test/services/offline/pending_transfer_queue_test.dart test/mocks/secondary_surfaces_contract_test.dart
flutter analyze --no-fatal-infos test/mocks/secondary_surfaces_contract_test.dart lib/mocks/services/savings_pots/savings_pots_mock.dart lib/services/savings_pots/savings_pots_service.dart lib/mocks/services/recurring_transfers/recurring_transfers_mock.dart lib/services/cards/cards_service.dart lib/mocks/services/cards/cards_mock.dart lib/mocks/mock_registry.dart lib/mocks/services/bill_payments/bill_payments_mock.dart
flutter analyze --no-fatal-infos lib/router/app_router.dart lib/features/cards/views/cards_list_view.dart lib/features/payment_links/views/payment_links_list_view.dart lib/features/payment_links/widgets/payment_link_card.dart lib/features/payment_links/views/pay_link_view.dart lib/features/deposit/views/payment_instructions_screen.dart lib/features/wallet/views/withdraw_view.dart lib/services/deep_link/deep_link_handler.dart
flutter test integration_test/flows/cashout_and_payments_flow_test.dart -d D4B4BD57-0447-4B96-A4F0-084F2C6ABF12 --dart-define=USE_MOCKS=true
flutter test integration_test/flows/deposit_flow_test.dart -d D4B4BD57-0447-4B96-A4F0-084F2C6ABF12 --dart-define=USE_MOCKS=true
flutter test integration_test/flows/secondary_surfaces_flow_test.dart -d D4B4BD57-0447-4B96-A4F0-084F2C6ABF12 --dart-define=USE_MOCKS=true
flutter analyze --no-fatal-infos lib/features/payment_links/views/create_link_view.dart lib/features/payment_links/views/link_created_view.dart lib/features/cards/views/cards_list_view.dart lib/features/cards/views/request_card_view.dart lib/features/recurring_transfers/views/recurring_transfers_list_view.dart integration_test/helpers/korido_flow_driver.dart integration_test/flows/secondary_surfaces_flow_test.dart
```

## Phase 5 Verified Results
- `secondary_surfaces_contract_test.dart`: 5 tests passed.
- Focused route/mock/money/deposit/offline regression bundle: 30 tests passed.
- Focused analyzer on touched files: exit 0, info-level lint noise only.
- `cashout_and_payments_flow_test.dart` on simulator `D4B4BD57-0447-4B96-A4F0-084F2C6ABF12`: 3 tests passed.
- `deposit_flow_test.dart` on simulator `D4B4BD57-0447-4B96-A4F0-084F2C6ABF12`: 1 test passed.
- `secondary_surfaces_flow_test.dart` on simulator `D4B4BD57-0447-4B96-A4F0-084F2C6ABF12`: 4 tests passed.
- Focused card request/detail simulator run: 1 test passed.
- Latest focused analyzer on payment-link/card/recurring-transfer touched files: exit 0, info-level lint noise only.
