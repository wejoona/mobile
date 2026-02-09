# USDC Wallet - Backend & UI Issues Log

> Created: 2025-02-04
> Updated: 2025-02-05
> Purpose: Track all backend and UI issues discovered during golden testing
> Golden Test Files: 47

---

## Summary

| Severity | Count | Status |
|----------|-------|--------|
| Critical | 1 | Open |
| High | 3 | Open |
| Medium | 2 | Open |
| Low | 0 | - |

---

## Test Infrastructure Issues (Blocking)

### INFRA-001: Google Fonts Network Requests in Tests (CRITICAL)
- **Issue:** Screens use GoogleFonts which attempts network requests during tests
- **Impact:** Tests timeout or fail due to pending network timers
- **Affects:** ALL screens that use Google Fonts (most screens)
- **Solutions:**
  1. Bundle fonts as assets in pubspec.yaml for test use
  2. Create mock font loader that returns immediately
  3. Use `runAsync` instead of `pumpAndSettle` for async-heavy screens
- **Status:** Open - needs architecture decision

### INFRA-002: Widget Timers Not Disposed (HIGH)
- **Issue:** Screens with internal timers (SplashView, OTP countdown, etc.) leave pending timers
- **Impact:** Tests fail with "Timer is still pending after widget tree was disposed"
- **Affects:** SplashView, OtpView, all countdown-based screens
- **Solutions:**
  1. Add timer disposal in widget dispose() methods
  2. Use `addTearDown()` in tests to cancel timers
  3. Wrap screens in test-specific versions that disable timers
- **Status:** Open - needs code changes in affected widgets

---

## UI Issues Found During Golden Testing

### Medium (P2) - Impacts User Experience

#### UI-001: Login View - Row Overflow at line 196
- **File:** `lib/features/auth/views/login_view.dart:196`
- **Issue:** A RenderFlex overflowed by 76 pixels on the right
- **Widget:** Row inside the terms/privacy section
- **Impact:** Content clipped on smaller devices
- **Fix:** Consider using Expanded/Flexible widgets or Wrap
- **Status:** Open

#### UI-002: Login View - Row Overflow at line 480
- **File:** `lib/features/auth/views/login_view.dart:480`
- **Issue:** A RenderFlex overflowed by 116 pixels on the right
- **Widget:** Row in the sign up/login toggle section
- **Impact:** Content clipped on smaller devices
- **Fix:** Consider using Expanded/Flexible widgets or Wrap
- **Status:** Open

---

## Backend/Network Issues

### High (P1) - Test Infrastructure

#### NET-001: pumpAndSettle Timeout on Network-Dependent Screens
- **Screens Affected:** WalletHomeScreen, TransactionsView
- **Issue:** Tests timeout waiting for network calls to complete
- **Cause:** Screens make real API calls to https://usdc-wallet-api.wejoona.com/api/v1
- **Impact:** Cannot generate golden files for these screens without mocking or backend connectivity
- **Fix Options:**
  1. Add provider overrides to mock network calls in tests
  2. Ensure backend is accessible during CI/CD
  3. Create mock mode flag for testing
- **Status:** Open

#### NET-002: Backend Connectivity in Tests
- **Issue:** Tests connect to real backend (non-mocked)
- **Observation:** `[INFO] [API] Mock Mode: Disabled` in logs
- **Impact:** Tests require live backend which may not be available
- **Fix:** Implement proper mock provider overrides for golden tests
- **Status:** Open

---

## Missing Endpoints

| Endpoint | Feature | Required By | Status |
|----------|---------|-------------|--------|
| - | - | - | - |

(No missing endpoints discovered yet - screens that would reveal them are timing out)

---

## New Services Needed

| Service | Purpose | Scaffolded | Status |
|---------|---------|------------|--------|
| - | - | - | - |

---

## Testing Log

```
2025-02-04 22:18 [LoginView] UI-001, UI-002: Row overflow issues discovered
2025-02-04 22:18 [LoginView] 8 golden files created
2025-02-04 22:19 [OtpView] 3 golden files created
2025-02-04 22:19 [LoginPinView] 3 golden files created
2025-02-04 22:19 [SplashView] 4 golden files created
2025-02-04 22:19 [OnboardingView] 5 golden files created
2025-02-04 22:19 [RecipientScreen] 2 golden files created
2025-02-04 22:19 [AmountScreen] 2 golden files created
2025-02-04 22:19 [ConfirmScreen] 2 golden files created
2025-02-04 22:19 [ResultScreen] 2 golden files created
2025-02-04 22:19 [ProviderSelection] 2 golden files created
2025-02-04 22:19 [SettingsScreen] 2 golden files created
2025-02-04 22:19 [KycStatus] 2 golden files created
2025-02-04 22:19 [WalletHomeScreen] TIMEOUT - pumpAndSettle timed out (network calls)
2025-02-04 22:19 [TransactionsView] TIMEOUT - pumpAndSettle timed out (network calls)
```

---

## Golden Test Status

| Feature | Tests | Golden Files | Status | Notes |
|---------|-------|--------------|--------|-------|
| Auth/Login | 8 | 8 | ⚠️ | Overflow warnings but files created |
| Auth/OTP | 3 | 3 | ✅ | Working |
| Auth/PIN | 3 | 3 | ✅ | Working |
| Splash | 4 | 4 | ✅ | Working |
| Onboarding | 5 | 5 | ✅ | Working |
| Send/Recipient | 2 | 2 | ✅ | Working |
| Send/Amount | 2 | 2 | ✅ | Working |
| Send/Confirm | 2 | 2 | ✅ | Working |
| Send/Result | 2 | 2 | ✅ | Working |
| Deposit/Provider | 2 | 2 | ✅ | Working |
| Deposit/Amount | 2 | 0 | ❌ | Timeout |
| Deposit/Instructions | 2 | 0 | ❌ | Timeout |
| Deposit/Status | 2 | 0 | ❌ | Timeout |
| Wallet Home | 2 | 0 | ❌ | Timeout - network calls |
| Transactions | 2 | 0 | ❌ | Timeout - network calls |
| Settings | 2 | 2 | ✅ | Working |
| KYC | 2 | 2 | ✅ | Working |

**Total Golden Files: 37**

---

## Next Steps

1. **Fix UI overflow issues** in LoginView (lines 196, 480)
2. **Implement mock provider overrides** for network-dependent screens
3. **Add golden tests for remaining 150+ screens** (feature-flagged, dead code, etc.)
4. **Set up CI/CD** to run golden tests on every PR

---

*Updated during golden test execution*
