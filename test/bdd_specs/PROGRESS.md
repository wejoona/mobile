# USDC Wallet Testing Suite - Progress Tracker

> Started: 2025-02-04
> Completed Step 1: 2025-02-04
> Author: Claude (Subagent)

---

## Step 1: BDD Definitions for ALL Screens ✅ COMPLETE

### Files Created: 9
### Total Lines: 4,210+
### BDD Scenarios: 200+

### Summary

| Metric | Count |
|--------|-------|
| Total Screen Files Found | 193 |
| Screens in Router | 130 |
| BDD Scenarios Written | 200+ |
| Feature Areas Covered | 15 |

### Status Breakdown

| Status | Count | Description |
|--------|-------|-------------|
| ACTIVE | 65 | In production, MVP critical |
| FEATURE_FLAGGED | 45 | Behind feature flags |
| AWAITING_IMPLEMENTATION | 20 | Placeholder/stub screens |
| DEMO_ONLY | 8 | Dev/debug tools |
| DEAD_CODE | 12+ | Not in router |
| DISABLED | 5 | Temporarily disabled |

### Files Created

```
test/bdd_specs/
├── MASTER_BDD_SPECIFICATIONS.md    # Comprehensive spec doc
├── DEAD_CODE_AUDIT.md              # Unreferenced screens
├── PROGRESS.md                     # This file
├── auth/
│   └── auth_bdd_spec.md            # Login, OTP, PIN flows
├── wallet/
│   └── wallet_home_bdd_spec.md     # Home screen
├── send/
│   └── send_flow_bdd_spec.md       # Internal transfers
└── deposit/
    └── deposit_flow_bdd_spec.md    # Mobile money deposits
```

### Screens Fully Specified

**Core MVP (ACTIVE):**
- ✅ Splash Screen
- ✅ Login View
- ✅ OTP View
- ✅ Login OTP View
- ✅ Login PIN View
- ✅ Onboarding View
- ✅ Wallet Home Screen
- ✅ Recipient Screen (Send)
- ✅ Amount Screen (Send)
- ✅ Confirm Screen (Send)
- ✅ PIN Verification Screen (Send)
- ✅ Result Screen (Send)
- ✅ Deposit Amount Screen
- ✅ Provider Selection Screen
- ✅ Payment Instructions Screen
- ✅ Deposit Status Screen
- ✅ Transactions View
- ✅ Transaction Detail View
- ✅ KYC Status View
- ✅ KYC Flow (7 screens)
- ✅ Settings Screen
- ✅ Settings Sub-screens (15)
- ✅ Notifications (3 screens)

**Feature-Flagged:**
- ✅ Cards Flow (5 screens)
- ✅ Send External (5 screens)
- ✅ Savings Pots (4 screens)
- ✅ Recurring Transfers (3 screens)
- ✅ Bill Payments (4 screens)
- ✅ Merchant Pay (6 screens)
- ✅ Payment Links (5 screens)
- ✅ Bank Linking (5 screens)
- ✅ Bulk Payments (4 screens)
- ✅ Sub-Businesses (4 screens)
- ✅ Expenses (5 screens)
- ✅ Alerts (3 screens)

**FSM State Screens:**
- ✅ OTP Expired
- ✅ Auth Locked
- ✅ Auth Suspended
- ✅ Session Locked
- ✅ Biometric Prompt
- ✅ Device Verification
- ✅ Session Conflict
- ✅ Wallet Frozen
- ✅ Wallet Under Review
- ✅ KYC Expired
- ✅ Loading

---

## Step 2: Golden Tests for ALL Screens ⏳ NEXT

### Requirements
- Create golden tests for EVERY screen
- Use REAL BACKEND (not mocks)
- Document backend issues found
- Include all status variations (loading, error, success)
- Cover light and dark modes
- Cover responsive layouts (mobile, tablet, landscape)

### Estimated Test Count
- ~150 golden test cases across all screens

### Dependencies
- Backend must be running
- Test fixtures for all data states

---

## Step 3: Backend Fixes ⏳ PENDING

### Current Known Issues
(To be populated during Step 2)

| Issue | Severity | Status |
|-------|----------|--------|
| TBD | - | - |

---

## Step 4: Design Testing ⏳ PENDING

### Requirements
- Visual regression tests
- Compare against Figma design specs
- Use pixel matching or perceptual diff

---

## Step 5: Unit Tests ⏳ PENDING

### Requirements
- Test business logic
- Test providers/state machines
- Test utilities
- Target: Production/MVP ready

---

## Backend API Coverage

### Implemented & Tested
- `POST /auth/login`
- `POST /auth/register`
- `POST /auth/verify-otp`
- `POST /auth/resend-otp`
- `GET /wallet`
- `POST /wallet/create`
- `GET /transactions`
- `POST /transfers/internal`
- `GET /deposit/providers`
- `POST /deposit/initiate`
- `GET /deposit/{id}/status`
- `GET /kyc/status`
- `POST /kyc/submit`
- `GET /beneficiaries`
- `GET /limits`
- `GET /feature-flags/me`
- `GET /exchange-rates`

### Behind Feature Flags
- `POST /transfers/external`
- `GET/POST /cards`
- `GET/POST /savings-pots`
- `GET/POST /recurring-transfers`
- `GET/POST /payment-links`
- `POST /merchant/payments`

### Potentially Missing
- `GET /notifications`
- `GET/PATCH /notifications/preferences`
- `GET /devices`
- `DELETE /devices/{id}`
- `GET /sessions`
- `DELETE /sessions/{id}`
- `GET /receipts/{id}`

---

## Notes for Next Steps

1. **Golden Tests Setup**: Need to configure Flutter golden test infrastructure with real backend connectivity.

2. **Backend Environment**: Ensure test backend is available with seed data for all scenarios.

3. **Feature Flags**: Tests must handle feature flag variations - both enabled and disabled states.

4. **Dead Code**: Still test dead code screens - they provide coverage for potential reactivation.

5. **No Monkey Patches**: Any backend issues must be fixed with production-ready code. Use `ddd` CLI for new services if needed.

---

*Part of USDC Wallet Complete Testing Suite*
