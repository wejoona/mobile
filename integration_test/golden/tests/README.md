# Golden Tests - Screen Coverage

> **BDD-style golden tests for all JoonaPay USDC Wallet screens**

## Test Files

| File | Screens Covered | Count |
|------|-----------------|-------|
| `01_auth_golden_test.dart` | Splash, Onboarding, Login, OTP, PIN | 5 |
| `02_kyc_golden_test.dart` | Identity Verification, Document Type, Personal Info, Capture, Selfie, Liveness, Review, Submitted | 16 |
| `03_home_golden_test.dart` | Home, Zero Balance, Cards Tab, Transactions Tab, Settings Tab | 7 |
| `04_deposit_golden_test.dart` | Deposit View, Amount, Provider, Instructions, Status | 8 |
| `05_send_golden_test.dart` | Recipient, Amount, Confirm, PIN, Result, Offline Queue | 8 |
| `06_send_external_golden_test.dart` | Address Input, Amount, Confirm, Result, QR Scan | 6 |
| `07_settings_golden_test.dart` | All Settings sub-screens (Profile, Security, Language, etc.) | 20 |
| `08_transactions_golden_test.dart` | Transactions List, Detail, Export, Filters | 8 |
| `09_cards_golden_test.dart` | Cards List, Request, Detail, Settings, Transactions | 8 |
| `10_notifications_golden_test.dart` | Notifications, Permission, Preferences | 4 |
| `11_merchant_pay_golden_test.dart` | Scan QR, Payment Confirm, Receipt, Dashboard, Merchant QR | 7 |
| `12_bill_payments_golden_test.dart` | Bill Payments, Form, Success, History | 6 |
| `13_expenses_golden_test.dart` | Expenses, Add, Capture Receipt, Detail, Reports | 6 |
| `14_payment_links_golden_test.dart` | Links List, Create, Detail, Created, Pay Link | 6 |
| `15_beneficiaries_golden_test.dart` | Beneficiaries List, Add, Detail | 5 |
| `16_bulk_payments_golden_test.dart` | Bulk Payments, Upload, Preview, Status | 5 |
| `17_savings_pots_golden_test.dart` | Pots List, Create, Detail, Edit | 6 |
| `18_recurring_transfers_golden_test.dart` | Recurring List, Create, Detail | 5 |
| `19_alerts_insights_golden_test.dart` | Alerts, Preferences, Detail, Insights | 5 |
| `20_sub_business_golden_test.dart` | Sub Businesses, Create, Detail, Staff | 5 |
| `21_fsm_states_golden_test.dart` | Loading, OTP Expired, Auth Locked, Suspended, Session, Biometric, Wallet Frozen, etc. | 11 |
| `22_feature_flags_golden_test.dart` | Bill Pay, Airtime, Savings, Virtual Card, Split Bill, Budget, Analytics, etc. | 12 |
| `23_receive_referrals_golden_test.dart` | Receive, Scan, Referrals, Services, Transfer Success | 6 |
| `24_pin_feature_golden_test.dart` | Set PIN, Enter PIN, Confirm PIN, Change PIN, Reset PIN, Locked | 7 |

**Total: ~180 screens covered**

---

## Running Tests

### Generate goldens (with mocks):
```bash
flutter test integration_test/golden/tests/ --update-goldens
```

### Run specific test file:
```bash
flutter test integration_test/golden/tests/01_auth_golden_test.dart --update-goldens
```

### Run with real backend:
```bash
flutter test integration_test/golden/tests/ --update-goldens --dart-define=USE_MOCKS=false
```

---

## Test Structure

Each test follows the BDD pattern:

```dart
testWidgets('Screen Name', (tester) async {
  /// GIVEN preconditions
  /// WHEN action is taken
  /// THEN expected result

  await loginToHome(tester);

  // Navigate to screen
  await tester.tap(find.text('Button'));
  await tester.pumpAndSettle();

  // Capture golden
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/category/screen_name.png'),
  );
});
```

---

## Golden File Locations

Goldens are organized by category:

```
goldens/
├── auth/           # 1.x screens
├── kyc/            # 2.x screens
├── home/           # 3.x screens
├── deposit/        # 4.x screens
├── send/           # 5.x screens
├── send_external/  # 6.x screens
├── settings/       # 7.x screens
├── transactions/   # 8.x screens
├── cards/          # 9.x screens
├── notifications/  # 10.x screens
├── merchant/       # 11.x screens
├── bills/          # 12.x screens
├── expenses/       # 13.x screens
├── payment_links/  # 14.x screens
├── beneficiaries/  # 15.x screens
├── bulk/           # 16.x screens
├── savings_pots/   # 17.x screens
├── recurring/      # 18.x screens
├── alerts/         # 19.x screens
├── insights/       # 19.x screens
├── sub_business/   # 20.x screens
├── fsm/            # 21.x screens
├── feature_flags/  # 22.x screens
├── pin/            # 24.x screens
└── other/          # 23.x screens
```

---

## Screen Status Legend

Tests document screen status:

| Status | Meaning |
|--------|---------|
| `ACTIVE` | Production-ready |
| `FEATURE_FLAG` | Gated by feature flag |
| `AWAITING_BACKEND` | Frontend ready, backend pending |
| `DEMO` | Demo only |
| `DEAD_CODE` | Not routed |
| `DISABLED` | Intentionally disabled |

---

## Test Data

- **Phone:** `0700000000`
- **OTP:** `123456`
- **Test User:** Amadou Diallo
- **Country:** Côte d'Ivoire (+225)

---

## Next Steps

After golden tests pass:
1. Design testing (visual review)
2. Unit tests for business logic
3. CI integration for regression detection
