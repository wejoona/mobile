# Backend Issues Log - Golden Testing Phase

**Generated:** 2026-02-04
**Purpose:** Document backend issues discovered during golden test creation

---

## Critical Issues

### 1. Feature Flags Endpoint Returns 401 Unauthenticated

**Endpoint:** `GET /api/v1/feature-flags/me`
**Service:** usdc-wallet

**Issue:**
The mobile app attempts to fetch feature flags during cold start (before authentication). The backend returns HTTP 401 Unauthorized, causing:
- Console errors during app initialization
- Feature flags defaulting to disabled states
- Potential UI/UX issues if flags are expected to be available

**Current Mobile Behavior:**
```dart
// App catches the 401 and continues with defaults
[ERROR] [FeatureFlags] Failed to fetch: 401 Unauthorized
[DEBUG] [FeatureFlags] Using defaults: {billPayments: false, airtime: false, ...}
```

**Proposed Solutions:**

**Option A (Backend):** Allow anonymous access to feature flags
- Return defaults for unauthenticated requests
- Authenticated users get personalized flags

**Option B (Backend):** Create separate public/private endpoints
- `GET /api/v1/feature-flags/public` → global defaults
- `GET /api/v1/feature-flags/me` → user-specific (authenticated)

**Option C (Mobile):** Handle gracefully (current implementation)
- Already implemented but logs errors
- Could suppress 401 errors for this specific endpoint

**Recommendation:** Option A or B - cleaner separation of concerns

---

### 2. Rate Limiting Blocks Test Phone Numbers

**Endpoint:** `POST /api/v1/auth/login`
**Service:** usdc-wallet

**Issue:**
During automated testing, the test phone number `0700000000` hits rate limits after ~3-5 login attempts. This causes:
- `400 Bad Request: Too many OTP requests`
- Test suite failures on subsequent runs
- Development workflow friction

**Current Rate Limits:**
- OTP requests: ~3 per 5 minutes per phone
- No bypass for test numbers

**Proposed Solutions:**

**Option A (Backend):** Whitelist test phone numbers
```typescript
// In auth service
const TEST_PHONES = ['+2250700000000', '+2250700000001', '+2250712345678'];
if (TEST_PHONES.includes(phone) && process.env.NODE_ENV !== 'production') {
  // Skip rate limiting for test numbers
}
```

**Option B (Backend):** Environment-based rate limit override
```bash
# In development/staging
OTP_RATE_LIMIT_DISABLED=true
```

**Option C (Mobile):** Use mock mode exclusively for automated tests
- Already implemented (`--dart-define=USE_MOCKS=true`)
- Real backend tests reserved for manual QA

**Recommendation:** Option A - enables real backend testing

---

### 3. Phone Number Format Inconsistency

**Endpoint:** `POST /api/v1/auth/login`
**Service:** usdc-wallet

**Issue:**
Occasional `400 Bad Request` errors suggest phone format mismatch:
- Mobile sends: `+2250700000000` (with country code)
- Backend may expect: `0700000000` (without)
- Or vice versa

**Current Mobile Implementation:**
```dart
final fullPhone = '${countryCode}${phoneNumber}'; // +2250700000000
```

**Proposed Solutions:**

**Option A (Backend):** Normalize phone numbers on receipt
```typescript
// Normalize to E.164 format
const normalized = normalizePhone(phone, defaultCountry);
```

**Option B (Documentation):** Clarify expected format in API spec
- Mobile team adjusts accordingly

**Recommendation:** Option A - backend should be forgiving

---

## Non-Critical Issues

### 4. Firebase Not Initialized in Tests

**Status:** Expected Behavior
**Impact:** None - analytics/crashlytics disabled during tests

**Logs:**
```
[ERROR] [Firebase initialization failed] Firebase has not been correctly initialized.
[DEBUG] [Crashlytics] Service disabled - Firebase not configured
```

**Resolution:** No action needed. Firebase is intentionally not configured in test environment.

---

### 5. GoRouter Ref Disposal Race Condition

**Status:** Cosmetic Issue
**Impact:** Test appears to fail but goldens are generated correctly

**Symptom:**
```
GoException: Cannot use Ref after disposed
```

**Cause:**
`FeatureFlagsNotifier` is accessed during router redirect after test teardown.

**Resolution:**
- Non-blocking for golden generation
- Fix: Wrap feature flag access in mounted check
- Priority: Low

---

## Recommendations for Backend Team

1. **Whitelist test phones** in dev/staging for automated testing
2. **Add anonymous feature flags** endpoint or allow 200 with defaults
3. **Document API contracts** for phone formats, error codes
4. **Consider test bypass header** for rate-limited endpoints:
   ```
   X-Test-Bypass: <secret-token>  # Only in non-production
   ```

---

## Contact

For backend changes, coordinate with:
- Backend Team Lead
- API Documentation owner

Changes should be tested with:
```bash
# Mobile test suite (with real backend)
cd mobile
flutter test integration_test/golden/tests/ --dart-define=USE_MOCKS=false
```
