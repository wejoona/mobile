# Korido Dogfood MVP Readiness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Korido ready for internal team dogfooding before pilot by connecting real API-backed screens, tightening trust-critical flows, and verifying the full simulator journey.

**Architecture:** Work mobile-first in an isolated worktree, but validate every data screen against the API contract before changing UI. Use existing backend modules where they exist, especially `feature-subscriptions`; do not repair production deploys by mutating live k3s resources.

**Tech Stack:** Flutter + Riverpod + GoRouter + Dio mobile app, NestJS + TypeORM backend, VerifyHQ local service, Flutter simulator tests/goldens, GitOps/ArgoCD for production deployment.

---

## Required Skills

- Use `$korido-mobile-mvp-verification` for simulator/API proof.
- Use `$korido-api-contract-alignment` for fake data, 400/401, and live API mismatch.
- Use `$korido-mobile-design-coherence` for light/dark, fonts, color, and screen polish.
- Use `$korido-dogfood-mvp-product-review` for MVP gap selection.
- Use `$korido-gitops-deployment-guardrails` before any deploy or production diagnosis.

## Source Map

Mobile root: `/Users/macbook/JoonaPay/USDC-Wallet/mobile`

Backend root: `/Users/macbook/JoonaPay/USDC-Wallet/usdc-wallet`

Existing backend feature waitlist module:
- `/Users/macbook/JoonaPay/USDC-Wallet/usdc-wallet/src/modules/feature-subscriptions/application/controllers/feature-subscription.controller.ts`
- `/Users/macbook/JoonaPay/USDC-Wallet/usdc-wallet/src/modules/feature-subscriptions/application/dto/requests/create-feature-subscription.dto.ts`
- `/Users/macbook/JoonaPay/USDC-Wallet/usdc-wallet/src/migrations/1780361823625-create_feature_subscriptions_table.ts`

Important mobile surfaces:
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/router/app_router.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/wallet/views/wallet_home_screen.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/transactions/views/transactions_view.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/transactions/views/transaction_detail_view.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/cards/views/cards_screen.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/cards/views/request_card_view.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/contacts/views/contacts_view.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/contacts/providers/contact_sync_provider.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/settings/views/devices_screen.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/settings/views/sessions_screen.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/notifications/views/notifications_view.dart`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/notifications/views/notification_preferences_screen.dart`

---

### Task 1: Isolated Branch And Service Preflight

**Files:**
- Read: `/Users/macbook/JoonaPay/USDC-Wallet/AGENTS.md`
- Read: `/Users/macbook/JoonaPay/USDC-Wallet/mobile/.claude/context.md`
- Create worktree outside the dirty main tree.

- [ ] **Step 1: Confirm current repo state**

```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
git fetch origin
git status --short --branch
```

Expected: output names current branch, dirty files, and whether `main` is behind origin. Do not continue in this dirty tree for new implementation work.

- [ ] **Step 2: Create an isolated MVP worktree**

```bash
mkdir -p /Users/macbook/.config/superpowers/worktrees/mobile
git worktree add /Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp origin/main -b feature/korido-dogfood-mvp
cd /Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp
git status --short --branch
```

Expected: branch `feature/korido-dogfood-mvp`, clean or only generated Flutter metadata after setup.

- [ ] **Step 3: Verify local stack health**

```bash
curl -fsS http://127.0.0.1:3011/api/v1/health
curl -fsS http://127.0.0.1:3300/health
```

Expected: Korido API returns `{"status":"ok"...}` and VerifyHQ returns service health with database/liveness/storage `ok`.

- [ ] **Step 4: Commit no code**

No commit for this task. It only establishes execution safety.

---

### Task 2: API Contract Inventory For Dogfood Screens

**Files:**
- Create: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/docs/mobile_api_contract_inventory.md`
- Modify only if needed: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/test/services/api_contract_alignment_test.dart`

- [ ] **Step 1: Write the inventory skeleton**

Create sections for Auth, KYC, Wallet, Transactions, Deposit, Cards, Contacts, Devices, Sessions, Notifications, Feature Subscriptions.

- [ ] **Step 2: Hit live backend endpoints used by each screen**

Use simulator logs or Dio logs during flows. Record status code, route, request body shape, response body shape, and whether screen data is real, mocked, or absent.

- [ ] **Step 3: Add failing contract tests for mismatches**

For each mismatch, add a test named with the contract, for example:

```dart
test('feature subscriptions send featureKey and source to backend', () async {
  final request = FeatureSubscriptionRequest(
    featureKey: 'virtual_card',
    source: 'cards_screen',
    metadata: {'surface': 'cards'},
  );

  expect(request.toJson(), {
    'featureKey': 'virtual_card',
    'source': 'cards_screen',
    'metadata': {'surface': 'cards'},
  });
});
```

- [ ] **Step 4: Run the contract tests**

```bash
flutter test test/services/api_contract_alignment_test.dart
```

Expected before fixes: any real mismatch fails with an explicit expected/actual diff. Expected after fixes: all contract tests pass.

- [ ] **Step 5: Commit inventory and tests**

```bash
git add docs/mobile_api_contract_inventory.md test/services/api_contract_alignment_test.dart
git commit -m "test: inventory dogfood API contracts"
```

---

### Task 3: Wire Feature Subscriptions For Coming-Soon Actions

**Files:**
- Create: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/services/feature_subscriptions/feature_subscription_request.dart`
- Create: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/services/feature_subscriptions/feature_subscriptions_service.dart`
- Create: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/services/feature_subscriptions/feature_subscriptions_provider.dart`
- Create: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/mocks/services/feature_subscriptions/feature_subscriptions_mock.dart`
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/mocks/mock_registry.dart`
- Modify: card/vCard coming-soon buttons under `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/cards/`
- Test: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/test/features/cards/feature_subscription_contract_test.dart`

- [ ] **Step 1: Write request serialization test**

```dart
test('serializes feature waitlist subscription with feature context', () {
  final request = FeatureSubscriptionRequest(
    featureKey: 'virtual_card',
    source: 'cards_screen',
    metadata: {'locale': 'en', 'region': 'US'},
  );

  expect(request.toJson(), {
    'featureKey': 'virtual_card',
    'source': 'cards_screen',
    'metadata': {'locale': 'en', 'region': 'US'},
  });
});
```

- [ ] **Step 2: Run the failing test**

```bash
flutter test test/features/cards/feature_subscription_contract_test.dart
```

Expected: fails because the request/service files do not exist.

- [ ] **Step 3: Implement the mobile service**

Use Dio through the existing API client/provider style. The service must call:

```text
POST /feature-subscriptions
```

Required body:

```json
{
  "featureKey": "virtual_card",
  "source": "cards_screen",
  "metadata": {
    "locale": "en",
    "region": "US"
  }
}
```

- [ ] **Step 4: Wire UI buttons**

Buttons that currently say "stay informed" or "coming soon" must call the service with a specific `featureKey`, not a generic newsletter flag. Use `virtual_card`, `physical_card`, or `vcard` depending on the screen.

- [ ] **Step 5: Add success and duplicate states**

Show a compact confirmation after subscription. If backend returns an existing active subscription, show the same confirmation instead of an error.

- [ ] **Step 6: Run tests**

```bash
flutter test test/features/cards/feature_subscription_contract_test.dart test/services/api_contract_alignment_test.dart
```

Expected: all feature subscription and contract tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/services/feature_subscriptions lib/mocks/services/feature_subscriptions lib/mocks/mock_registry.dart lib/features/cards test/features/cards test/services/api_contract_alignment_test.dart
git commit -m "feat: wire feature waitlist subscriptions"
```

---

### Task 4: Contacts And Korido Account Discovery

**Files:**
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/contacts/providers/contact_sync_provider.dart`
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/contacts/widgets/korido_account_badge.dart`
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/contacts/widgets/contact_list_item.dart`
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/send/views/recipient_screen.dart`
- Test: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/test/services/contacts/contact_sync_contract_test.dart`
- Test: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/test/features/send/recipient_screen_contract_test.dart`

- [ ] **Step 1: Write badge mapping test**

```dart
test('marks synced contacts that have Korido accounts', () {
  final contact = SyncedContact(
    id: '1',
    displayName: 'Awa Kouadio',
    phoneNumber: '+2250700000000',
    hasKoridoAccount: true,
    userId: 'user-1',
  );

  expect(contact.hasKoridoAccount, isTrue);
  expect(contact.userId, 'user-1');
});
```

- [ ] **Step 2: Run the failing or confirming test**

```bash
flutter test test/services/contacts/contact_sync_contract_test.dart
```

Expected: fails if the model/provider does not expose account discovery cleanly; passes if already wired.

- [ ] **Step 3: Implement permission-first sync**

Contacts screens must request permission only when the user enters the contact feature or taps sync. Show denied, limited, empty, loading, and synced states.

- [ ] **Step 4: Use the badge in contacts and send recipient flows**

Korido users get a compact account badge. Non-Korido contacts get invite action. The send flow should naturally prefer Korido users for internal instant transfer.

- [ ] **Step 5: Run tests and simulator path**

```bash
flutter test test/services/contacts/contact_sync_contract_test.dart test/features/send/recipient_screen_contract_test.dart
flutter test test/golden/all_screens/contacts_golden_test.dart test/golden/send/recipient_screen_golden_test.dart
```

Expected: tests pass and goldens match intended visual state.

- [ ] **Step 6: Commit**

```bash
git add lib/features/contacts lib/features/send test/services/contacts test/features/send test/golden
git commit -m "feat: improve Korido contact discovery"
```

---

### Task 5: Settings Trust Surfaces

**Files:**
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/settings/views/devices_screen.dart`
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/settings/views/sessions_screen.dart`
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/settings/repositories/devices_repository.dart`
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/settings/repositories/sessions_repository.dart`
- Test: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/test/features/settings/devices_contract_test.dart`
- Test: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/test/features/settings/sessions_contract_test.dart`

- [ ] **Step 1: Write current-device and empty-session tests**

```dart
test('sessions screen treats empty API list as a valid empty state', () {
  const sessions = <Session>[];

  expect(sessions, isEmpty);
});
```

- [ ] **Step 2: Verify no 401 regression**

Run app with a logged-in test user and open Devices and Active Sessions. If `GET /sessions` returns 401, capture token state and fix auth header propagation, not the UI copy.

- [ ] **Step 3: Improve states**

Devices: current device highlighted, trusted/untrusted visible, revoke action clear.

Sessions: current session, empty state, revoke all, and error retry.

- [ ] **Step 4: Run tests**

```bash
flutter test test/features/settings/devices_contract_test.dart test/features/settings/sessions_contract_test.dart
```

Expected: no 401 contract failure and empty state is accepted.

- [ ] **Step 5: Commit**

```bash
git add lib/features/settings test/features/settings
git commit -m "fix: harden settings trust surfaces"
```

---

### Task 6: Notifications And Preferences

**Files:**
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/notifications/providers/notifications_provider.dart`
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/notifications/providers/notification_count_provider.dart`
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/notifications/views/notifications_view.dart`
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/services/preferences/notification_preferences_service.dart`
- Test: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/test/features/settings/notification_preferences_contract_test.dart`
- Test: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/test/e2e/notifications_e2e_test.dart`

- [ ] **Step 1: Add read-all persistence test**

```dart
test('read all notifications clears unread count', () async {
  final countBefore = 2;
  final countAfter = 0;

  expect(countBefore, greaterThan(countAfter));
  expect(countAfter, 0);
});
```

- [ ] **Step 2: Verify live flow**

Open notification feed from Home, mark all read, refresh, and confirm unread dots/count do not return unless backend sends unread notifications.

- [ ] **Step 3: Fix preference persistence**

Newsletter/marketing, transaction, security, and KYC reminders must map to backend DTO fields. Do not conflate feature waitlists with newsletter preference.

- [ ] **Step 4: Run tests**

```bash
flutter test test/features/settings/notification_preferences_contract_test.dart test/e2e/notifications_e2e_test.dart
```

Expected: notification preference contract and feed behavior pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/notifications lib/services/preferences test/features/settings test/e2e/notifications_e2e_test.dart
git commit -m "fix: persist notification states"
```

---

### Task 7: Money Movement And Transaction Detail Polish

**Files:**
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/transactions/views/transactions_view.dart`
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/transactions/views/transaction_detail_view.dart`
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/deposit/views/payment_instructions_screen.dart`
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/features/wallet/views/transfer_success_view.dart`
- Test: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/test/features/transactions/transaction_detail_contract_test.dart`
- Test: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/test/golden/transactions/transaction_detail_golden_test.dart`

- [ ] **Step 1: Write compact detail test**

```dart
test('deposit transaction detail includes amount fee rate provider and reference', () {
  final fields = ['amountPaid', 'fee', 'exchangeRate', 'provider', 'reference'];

  expect(fields, containsAll(['amountPaid', 'fee', 'exchangeRate', 'provider', 'reference']));
});
```

- [ ] **Step 2: Make success/detail screens compact**

Remove unnecessary vertical height from success screens. Primary information must be visible without long scrolling on a standard iPhone simulator.

- [ ] **Step 3: Harmonize deposit instruction copy**

Use localized strings. Avoid mixed English/French in one flow unless the user locale is mixed by design.

- [ ] **Step 4: Run tests**

```bash
flutter test test/features/transactions/transaction_detail_contract_test.dart test/golden/transactions/transaction_detail_golden_test.dart
```

Expected: tests pass and detail screen remains visually compact.

- [ ] **Step 5: Commit**

```bash
git add lib/features/transactions lib/features/deposit lib/features/wallet test/features/transactions test/golden/transactions
git commit -m "fix: clarify transaction and deposit details"
```

---

### Task 8: Full Light/Dark Design Coherence Pass

**Files:**
- Modify shared tokens first:
  - `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/design/tokens/typography.dart`
  - `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/design/tokens/colors.dart`
  - `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/design/theme/app_theme.dart`
  - `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/lib/design/components/primitives/app_text.dart`
- Modify screen-specific files only after token/component changes.
- Test: golden suites under `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/test/golden/`

- [ ] **Step 1: Capture screenshots**

Run the app in simulator and capture at least: splash, login, register, OTP, PIN, KYC screens, Home, Deposit, History, Transaction Detail, Cards, Contacts, Settings, Devices, Sessions, Notifications.

- [ ] **Step 2: Compare light and dark one-to-one**

Document differences in hierarchy, contrast, typography, spacing, empty states, scroll height, and CTA clarity.

- [ ] **Step 3: Patch shared typography and colors**

Balance numbers must use one money display style across Home, transaction detail, deposit, and cards. Light theme must feel intentionally premium, not washed out.

- [ ] **Step 4: Update goldens intentionally**

```bash
flutter test --update-goldens test/golden/wallet/wallet_home_golden_test.dart test/golden/transactions/transaction_detail_golden_test.dart test/golden/settings/settings_screen_golden_test.dart test/golden/send/recipient_screen_golden_test.dart
```

Expected: only intended golden baselines change.

- [ ] **Step 5: Run design tests**

```bash
flutter test test/design/components/app_text_theme_test.dart test/golden/wallet/wallet_home_golden_test.dart test/golden/transactions/transaction_detail_golden_test.dart test/golden/settings/settings_screen_golden_test.dart test/golden/send/recipient_screen_golden_test.dart
```

Expected: all selected design/golden tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/design lib/features test/golden test/design
git commit -m "style: unify Korido mobile design coherence"
```

---

### Task 9: Full Simulator Dogfood Script

**Files:**
- Create: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/docs/mobile_dogfood_runbook.md`
- Modify if useful: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/integration_test/flows/korido_onboarding_flow_test.dart`
- Modify if useful: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/integration_test/helpers/korido_flow_driver.dart`

- [ ] **Step 1: Write the manual dogfood runbook**

Include phone input, OTP `123456`, PIN, KYC, wallet create, deposit, transaction detail, devices, sessions, notifications, contacts, cards waitlist, and logout.

- [ ] **Step 2: Execute in simulator**

```bash
flutter run -d <simulator-udid> \
  --dart-define=API_URL=http://127.0.0.1:3011/api/v1 \
  --dart-define=DEBUG_SKIP_PIN=true
```

Expected: new user reaches Home, creates wallet, sees real API-backed data screens, and logs out cleanly.

- [ ] **Step 3: Record evidence**

Save screenshots under `/tmp/korido-dogfood/` and list API endpoints exercised in the runbook.

- [ ] **Step 4: Commit runbook**

```bash
git add docs/mobile_dogfood_runbook.md integration_test/flows/korido_onboarding_flow_test.dart integration_test/helpers/korido_flow_driver.dart
git commit -m "docs: add Korido dogfood runbook"
```

---

### Task 10: Final Test Gate And Deployment-Safe Handoff

**Files:**
- Modify: `/Users/macbook/.config/superpowers/worktrees/mobile/korido-dogfood-mvp/docs/mobile_verification_status.md`
- Read if deploying: `/Users/macbook/JoonaPay/USDC-Wallet/AGENTS.md`
- Read if deploying: `/Users/macbook/JoonaPay/USDC-Wallet/docs/runbooks/KORIDO_GITOPS_RECOVERY_MEMORY.md`

- [ ] **Step 1: Run full mobile tests**

```bash
flutter test
```

Expected: all non-skipped tests pass. Record pass count and skipped count.

- [ ] **Step 2: Run analyzer on changed files**

```bash
dart analyze
```

Expected: no errors or warnings. Existing info-level style noise may be reported separately if the repo already carries it.

- [ ] **Step 3: Verify local service health**

```bash
curl -fsS http://127.0.0.1:3011/api/v1/health
curl -fsS http://127.0.0.1:3300/health
```

Expected: both return healthy responses.

- [ ] **Step 4: Write verification status**

`docs/mobile_verification_status.md` must include: branch, commit, simulator device, API URL, VerifyHQ URL, new-user flow result, screens exercised, tests run, known remaining gaps, and deployment status.

- [ ] **Step 5: Push only after diff review**

```bash
git status --short
git diff --stat
git log --oneline origin/main..HEAD
git push -u origin feature/korido-dogfood-mvp
```

Expected: pushed feature branch. Do not merge to `main` until the diff is reviewed and CI is understood.

- [ ] **Step 6: Deployment handoff if user asks to release**

Use `$korido-gitops-deployment-guardrails`. Verify source commit, CI image tag, GitOps commit, Argo app health, running pod image, and host health. Do not mutate live k3s resources as a deploy shortcut.

---

## Acceptance Criteria

- A new test user can complete onboarding, OTP, PIN, KYC, wallet creation, deposit, transaction history/detail, devices, sessions, notifications, contacts, cards waitlist, and logout in simulator.
- Screens named above use live API data when the local stack is available.
- Coming-soon buttons subscribe to a specific feature through `/feature-subscriptions`.
- Contacts request permission at the right moment and visually identify Korido users.
- Active sessions and devices do not show authentication regressions.
- Light and dark themes feel coherent across the full route set.
- `flutter test` passes.
- Analyzer has no blocking errors or warnings.
- Production deployment remains GitOps-owned.
