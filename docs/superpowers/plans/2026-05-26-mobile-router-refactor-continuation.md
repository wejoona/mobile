# Mobile Router Refactor Continuation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Finish the router refactor by turning the current `part`-based route split into independently owned route modules, then lock route behavior with structure tests.

**Architecture:** Keep `app_router.dart` as the thin `GoRouter` provider. Keep `app_routes.dart` as the route aggregator only. Convert each file under `lib/router/routes/` from `part of '../app_routes.dart'` into standalone libraries with local imports and public route-builder functions.

**Tech Stack:** Flutter, Dart, Riverpod, GoRouter, `flutter_test`.

---

### Task 1: Add Route Structure Contract Test

**Files:**
- Create: `test/router/app_routes_structure_test.dart`
- Read: `lib/router/app_routes.dart`

- [ ] **Step 1: Create the route structure test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/router/app_routes.dart';

void main() {
  test('buildAppRoutes exposes critical Korido routes once', () {
    final paths = _flattenPaths(buildAppRoutes());

    expect(paths, contains('/'));
    expect(paths, contains('/login'));
    expect(paths, contains('/onboarding/phone'));
    expect(paths, contains('/home'));
    expect(paths, contains('/send'));
    expect(paths, contains('/deposit'));
    expect(paths, contains('/kyc'));
    expect(paths, contains('/contacts'));
    expect(paths, contains('/payment-links'));
    expect(paths, contains('/savings-pots'));
    expect(paths, contains('/recurring-transfers'));
    expect(paths, contains('/bill-payments'));
    expect(paths, contains('/beneficiaries'));
    expect(paths, contains('/bank-linking'));

    expect(paths.length, paths.toSet().length);
  });

  test('top-level route groups stay in the expected order', () {
    final topLevelPaths = buildAppRoutes()
        .map((route) => switch (route) {
              GoRoute(:final path) => path,
              ShellRoute() => '<shell>',
              _ => '<unknown>',
            })
        .toList();

    expect(topLevelPaths.take(5), [
      '/',
      '/profile-complete',
      '/onboarding',
      '/onboarding/phone',
      '/onboarding/otp',
    ]);
    expect(topLevelPaths.indexOf('<shell>'), lessThan(topLevelPaths.indexOf('/services')));
    expect(topLevelPaths.indexOf('/kyc'), lessThan(topLevelPaths.indexOf('/request')));
    expect(topLevelPaths.indexOf('/savings-pots'), lessThan(topLevelPaths.indexOf('/scan-to-pay')));
  });
}

List<String> _flattenPaths(List<RouteBase> routes) {
  final paths = <String>[];
  for (final route in routes) {
    switch (route) {
      case GoRoute(:final path, :final routes):
        paths.add(path);
        paths.addAll(_flattenPaths(routes));
      case ShellRoute(:final routes):
        paths.addAll(_flattenPaths(routes));
      default:
        throw StateError('Unsupported route type: ${route.runtimeType}');
    }
  }
  return paths;
}
```

- [ ] **Step 2: Run the route structure test**

Run:

```bash
flutter test --no-pub test/router/app_routes_structure_test.dart
```

Expected: pass before further refactor. If `ShellRoute(:final routes)` is not accepted by the installed GoRouter version, replace the pattern with `case ShellRoute shellRoute: paths.addAll(_flattenPaths(shellRoute.routes));`.

### Task 2: Convert Route Parts Into Standalone Libraries

**Files:**
- Modify: `lib/router/app_routes.dart`
- Modify: `lib/router/routes/auth_state_routes.dart`
- Modify: `lib/router/routes/primary_wallet_routes.dart`
- Modify: `lib/router/routes/kyc_settings_routes.dart`
- Modify: `lib/router/routes/feature_overview_routes.dart`
- Modify: `lib/router/routes/savings_recurring_routes.dart`
- Modify: `lib/router/routes/commerce_routes.dart`
- Modify: `lib/router/routes/business_utility_routes.dart`

- [ ] **Step 1: Replace part declarations in `app_routes.dart` with imports**

Use this shape:

```dart
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/router/routes/auth_state_routes.dart';
import 'package:usdc_wallet/router/routes/business_utility_routes.dart';
import 'package:usdc_wallet/router/routes/commerce_routes.dart';
import 'package:usdc_wallet/router/routes/feature_overview_routes.dart';
import 'package:usdc_wallet/router/routes/kyc_settings_routes.dart';
import 'package:usdc_wallet/router/routes/primary_wallet_routes.dart';
import 'package:usdc_wallet/router/routes/savings_recurring_routes.dart';

List<RouteBase> buildAppRoutes() => [
  ...authStateRoutes(),
  ...primaryWalletRoutes(),
  ...kycSettingsRoutes(),
  ...featureOverviewRoutes(),
  ...savingsRecurringRoutes(),
  ...commerceRoutes(),
  ...businessUtilityRoutes(),
];
```

- [ ] **Step 2: Make each route file standalone**

For each route file:

1. Remove `part of '../app_routes.dart';`
2. Add only imports that file needs.
3. Rename private builders to public builders:

```dart
List<RouteBase> authStateRoutes() => [
  // existing routes unchanged
];
```

Use focused imports. Example for `auth_state_routes.dart`:

```dart
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/features/auth/views/login_otp_view.dart';
import 'package:usdc_wallet/features/auth/views/login_view.dart';
import 'package:usdc_wallet/features/auth/views/otp_view.dart';
import 'package:usdc_wallet/features/fsm_states/views/index.dart';
import 'package:usdc_wallet/features/onboarding/views/kyc_prompt_view.dart';
import 'package:usdc_wallet/features/onboarding/views/onboarding_pin_view.dart';
import 'package:usdc_wallet/features/onboarding/views/onboarding_success_view.dart';
import 'package:usdc_wallet/features/onboarding/views/onboarding_view.dart';
import 'package:usdc_wallet/features/onboarding/views/otp_verification_view.dart';
import 'package:usdc_wallet/features/onboarding/views/phone_input_view.dart';
import 'package:usdc_wallet/features/onboarding/views/profile_complete_view.dart';
import 'package:usdc_wallet/features/onboarding/views/profile_setup_view.dart';
import 'package:usdc_wallet/features/pin/views/pin_screen.dart';
import 'package:usdc_wallet/features/splash/views/splash_view.dart';
import 'package:usdc_wallet/router/page_transitions.dart';
import 'package:usdc_wallet/router/widgets/placeholder_pages.dart';
```

- [ ] **Step 3: Format and analyze router module**

Run:

```bash
dart format lib/router/app_routes.dart lib/router/routes/*.dart
flutter analyze --no-pub --no-fatal-infos lib/router/app_router.dart lib/router/app_routes.dart lib/router/app_redirector.dart lib/router/routes/*.dart lib/router/widgets/*.dart
```

Expected: no issues.

### Task 3: Re-run Route Contract After Standalone Conversion

**Files:**
- Test: `test/router/app_routes_structure_test.dart`

- [ ] **Step 1: Run the route structure test again**

Run:

```bash
flutter test --no-pub test/router/app_routes_structure_test.dart
```

Expected: all tests pass. This proves route paths and route group ordering survived the standalone-module conversion.

### Task 4: Full Focused Regression Check

**Files:**
- Verify router and mobile mock flows.

- [ ] **Step 1: Run focused analyzer**

```bash
flutter analyze --no-pub --no-fatal-infos \
  lib/router/app_router.dart \
  lib/router/app_routes.dart \
  lib/router/app_redirector.dart \
  lib/router/routes/*.dart \
  lib/router/widgets/*.dart \
  lib/config/environment_config.dart \
  lib/main.dart \
  lib/utils/logger.dart \
  lib/mocks/mock_config_provider.dart \
  lib/services/analytics/crash_reporting_service.dart \
  lib/services/device/device_registration_service.dart \
  lib/state/transaction_state_machine.dart
```

Expected: no issues.

- [ ] **Step 2: Run contract tests**

```bash
flutter test --no-pub test/mocks/secondary_surfaces_contract_test.dart
```

Expected: 5 tests pass.

- [ ] **Step 3: Run simulator flow**

```bash
flutter test --no-pub integration_test/flows/secondary_surfaces_flow_test.dart \
  -d D4B4BD57-0447-4B96-A4F0-084F2C6ABF12 \
  --dart-define=USE_MOCKS=true
```

Expected: 4 tests pass on the booted iPhone 16e simulator.

### Task 5: Review Residual Refactor Opportunities

**Files:**
- Read: `lib/router/app_redirector.dart`
- Read: `lib/router/routes/*.dart`

- [ ] **Step 1: Check route module size**

Run:

```bash
wc -l lib/router/app_router.dart lib/router/app_routes.dart lib/router/app_redirector.dart lib/router/routes/*.dart lib/router/widgets/*.dart
```

Expected: no route declaration file over 350 lines. If one grows past 350, split by domain before adding new features.

- [ ] **Step 2: Check for broad suppressions and raw logs**

Run:

```bash
rg "ignore_for_file|ignore: unused_local_variable|debugPrint\\(|String.fromEnvironment\\('DEBUG_SKIP_PIN'\\)|__" \
  lib/router lib/main.dart lib/mocks/mock_config_provider.dart lib/services/analytics/crash_reporting_service.dart lib/services/device/device_registration_service.dart lib/utils/logger.dart lib/config/environment_config.dart
```

Expected: only intentional matches remain in `EnvironmentConfig` and `AppLogger`.

- [ ] **Step 3: Capture final summary**

Summarize:

```text
Router provider is thin.
Route declarations are grouped by domain.
Route modules are standalone libraries with focused imports.
Route structure test protects critical paths and ordering.
Analyzer, contract tests, and simulator flow pass.
```
