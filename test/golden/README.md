# USDC Wallet - Golden Tests

> Step 2: Golden Tests with Real Backend
> Created: 2025-02-04
> Last Updated: 2025-02-05

---

## Overview

This directory contains golden tests for ALL USDC Wallet screens, including:
- Active screens (MVP)
- Feature-flagged screens
- Dead code screens
- Demo screens
- Disabled screens

## Current Status

| Metric | Value |
|--------|-------|
| Golden Test Files | 47 |
| Screens with Tests | 130+ |
| Total Screens | 177 |
| UI Issues Found | 2 |
| Backend Issues Found | 2 |

## Directory Structure

```
test/golden/
├── README.md                    # This file
├── BACKEND_ISSUES.md           # Issues discovered during testing
├── run_golden_tests.sh         # Test runner script
├── helpers/
│   └── golden_test_helper.dart # Test utilities and wrapper
├── auth/                       # Auth flow tests
│   ├── login_view_golden_test.dart
│   ├── otp_view_golden_test.dart
│   └── login_pin_view_golden_test.dart
├── splash/
│   └── splash_view_golden_test.dart
├── onboarding/
│   └── onboarding_view_golden_test.dart
├── wallet/
│   └── wallet_home_golden_test.dart
├── send/
│   ├── recipient_screen_golden_test.dart
│   ├── amount_screen_golden_test.dart
│   ├── confirm_screen_golden_test.dart
│   └── result_screen_golden_test.dart
├── deposit/
│   ├── deposit_amount_golden_test.dart
│   ├── provider_selection_golden_test.dart
│   ├── payment_instructions_golden_test.dart
│   └── deposit_status_golden_test.dart
├── transactions/
│   ├── transactions_view_golden_test.dart
│   └── transaction_detail_golden_test.dart
├── settings/
│   └── settings_screen_golden_test.dart
├── kyc/
│   └── kyc_status_golden_test.dart
└── all_screens/                # Comprehensive tests for all features
    ├── alerts_golden_test.dart
    ├── bank_linking_golden_test.dart
    ├── beneficiaries_golden_test.dart
    ├── bill_payments_golden_test.dart
    ├── biometric_golden_test.dart
    ├── bulk_payments_golden_test.dart
    ├── business_golden_test.dart
    ├── cards_golden_test.dart
    ├── contacts_golden_test.dart
    ├── expenses_golden_test.dart
    ├── fsm_states_golden_test.dart
    ├── insights_golden_test.dart
    ├── kyc_full_golden_test.dart
    ├── limits_golden_test.dart
    ├── merchant_pay_golden_test.dart
    ├── notifications_golden_test.dart
    ├── offline_golden_test.dart
    ├── onboarding_additional_golden_test.dart
    ├── onboarding_full_golden_test.dart
    ├── payment_links_golden_test.dart
    ├── pin_golden_test.dart
    ├── qr_payment_golden_test.dart
    ├── recurring_transfers_golden_test.dart
    ├── referrals_golden_test.dart
    ├── savings_pots_golden_test.dart
    ├── send_external_golden_test.dart
    ├── settings_views_golden_test.dart
    ├── sub_business_golden_test.dart
    └── wallet_views_golden_test.dart
```

## Running Tests

### Generate/Update Golden Files
```bash
# All tests
flutter test --update-goldens test/golden/

# Specific feature
flutter test --update-goldens test/golden/auth/

# Single test file
flutter test --update-goldens test/golden/auth/login_view_golden_test.dart
```

### Verify Golden Files (CI/CD)
```bash
flutter test test/golden/
```

### Using the runner script
```bash
./test/golden/run_golden_tests.sh          # Verify
./test/golden/run_golden_tests.sh --update # Update
```

## Test Matrix

Each screen tests:
- **Light mode** - Default light theme
- **Dark mode** - Dark theme variant
- **States** (where applicable):
  - Initial/Loading
  - Loaded/Populated
  - Empty
  - Error
- **Responsive** (selected screens):
  - Phone (390x844)
  - Tablet (768x1024)

## Golden File Naming Convention

```
goldens/{feature}/{screen}/{variant}_{theme}_{device}.png

Examples:
- goldens/auth/login_view/default_light.png
- goldens/auth/login_view/default_dark.png
- goldens/auth/login_view/tablet_light.png
```

## Issues Found

### UI Issues
1. **LoginView overflow** - Row overflow at lines 196 and 480
   - See `BACKEND_ISSUES.md` for details

### Network Issues
1. **pumpAndSettle timeout** - Screens making real API calls timeout
   - Affects: WalletHomeScreen, TransactionsView
   - Needs: Mock provider overrides

## Adding New Tests

1. Create test file in appropriate directory
2. Use `GoldenTestWrapper` for consistent setup
3. Follow naming convention
4. Run with `--update-goldens` to generate baseline

Example:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/example/views/example_view.dart';

import '../helpers/golden_test_helper.dart';

void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('ExampleView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      
      await tester.pumpWidget(
        const GoldenTestWrapper(
          isDarkMode: false,
          child: ExampleView(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/example/example_view/default_light.png'),
      );
    });
  });
}
```

## Related Files

- `test/bdd_specs/MASTER_BDD_SPECIFICATIONS.md` - BDD specs for all screens
- `test/bdd_specs/DEAD_CODE_AUDIT.md` - List of dead code screens
- `test/helpers/test_wrapper.dart` - Base test wrapper
- `test/helpers/test_theme.dart` - Test theme (no Google Fonts)

---

*Part of USDC Wallet Complete Testing Suite*
