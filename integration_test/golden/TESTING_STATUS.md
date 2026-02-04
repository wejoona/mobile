# Golden Tests - Status Report

> **Generated:** 2026-02-04

## Current State

### Test Files Created: 24 files
All golden test files are in `integration_test/golden/tests/`:
- 01_auth_golden_test.dart (5 tests)
- 02_kyc_golden_test.dart (17 tests)
- 03_home_golden_test.dart (7 tests)
- 04_deposit_golden_test.dart (8 tests)
- 05_send_golden_test.dart (8 tests)
- 06_send_external_golden_test.dart (6 tests)
- 07_settings_golden_test.dart (20 tests)
- 08_transactions_golden_test.dart (8 tests)
- 09_cards_golden_test.dart (8 tests)
- 10_notifications_golden_test.dart (4 tests)
- 11_merchant_pay_golden_test.dart (7 tests)
- 12_bill_payments_golden_test.dart (6 tests)
- 13_expenses_golden_test.dart (6 tests)
- 14_payment_links_golden_test.dart (6 tests)
- 15_beneficiaries_golden_test.dart (5 tests)
- 16_bulk_payments_golden_test.dart (5 tests)
- 17_savings_pots_golden_test.dart (6 tests)
- 18_recurring_transfers_golden_test.dart (5 tests)
- 19_alerts_insights_golden_test.dart (5 tests)
- 20_sub_business_golden_test.dart (5 tests)
- 21_fsm_states_golden_test.dart (11 tests)
- 22_feature_flags_golden_test.dart (12 tests)
- 23_receive_referrals_golden_test.dart (6 tests)
- 24_pin_feature_golden_test.dart (7 tests)

**Total: ~180 screen test cases**

---

## Golden Files Generated

### Auth Flow (4 files)
- `goldens/auth/1.1_splash.png`
- `goldens/auth/1.3_login.png`
- `goldens/auth/1.4_otp_initial.png`
- `goldens/auth/1.4b_otp_partial.png`

### KYC Flow (8 files)
- `goldens/kyc/2.1_identity_verification.png`
- `goldens/kyc/2.2_document_type.png`
- `goldens/kyc/2.3_document_selected.png`
- `goldens/kyc/2.3b_passport_selected.png`
- `goldens/kyc/2.3c_license_selected.png`
- `goldens/kyc/2.4_personal_info_empty.png`
- `goldens/kyc/2.5_personal_info_filled.png`
- `goldens/kyc/2.6_capture_instructions.png`

---

## Running Tests

### With Mocks (Default)
```bash
flutter test integration_test/golden/tests/01_auth_golden_test.dart --update-goldens
```

### With Real Backend
```bash
flutter test integration_test/golden/tests/ --dart-define=USE_MOCKS=false
```

---

## Backend Issues Identified

### 1. Feature Flags Requires Authentication
- **Endpoint:** `GET /api/v1/feature-flags/me`
- **Issue:** Returns 401 when not authenticated
- **Impact:** App tries to fetch feature flags before auth, causing errors
- **Fix:** Mobile should handle 401 gracefully for feature flags, or backend should allow anonymous access

### 2. Rate Limiting on Auth
- **Endpoint:** `POST /api/v1/auth/login`
- **Issue:** Returns 400 "Too many OTP requests"
- **Impact:** Test phone number `0700000000` hits rate limits during automated testing
- **Fix:** Backend should whitelist test numbers, or tests should use unique numbers

### 3. Phone Number Format Mismatch
- **Issue:** Phone sent as `+2250700000000` but backend may expect different format
- **Impact:** 400 errors during login
- **Fix:** Verify expected phone format between mobile and backend

---

## Known Test Issues

### 1. Teardown Race Condition
- **Symptom:** `GoException: Cannot use Ref after disposed` after tests complete
- **Cause:** FeatureFlagsNotifier accessed during router redirect after test ends
- **Impact:** Shows as failed test but doesn't affect golden generation
- **Status:** Non-blocking, cosmetic issue

### 2. Firebase Not Initialized
- **Symptom:** Firebase initialization errors during tests
- **Impact:** Analytics and crash reporting disabled in tests
- **Status:** Expected behavior, non-blocking

---

## Next Steps

1. **Generate remaining goldens** - Run all test files with mocks
2. **Fix rate limiting** - Whitelist test phone on backend
3. **Fix feature flags** - Handle 401 gracefully in mobile
4. **Run with real backend** - After fixes, validate integration
5. **Design review** - Compare goldens against Figma
6. **CI integration** - Add tests to pipeline

---

## Commands Reference

```bash
# Generate all goldens
cd mobile
flutter test integration_test/golden/tests/ --update-goldens

# Run specific test
flutter test integration_test/golden/tests/01_auth_golden_test.dart --update-goldens

# Run with real backend
flutter test integration_test/golden/tests/ --dart-define=USE_MOCKS=false

# Check test phone rate limit on backend
curl -X POST https://usdc-wallet-api.wejoona.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone": "+2250700000000"}'
```
