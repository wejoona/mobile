# Korido Mobile App — Full UX Gap Audit
**Date:** 2026-02-13
**Auditor:** Argus Key (AI)
**Codebase:** 1235 Dart files across features/, services/, design/, etc.

---

## Summary

| Priority | Count | Description |
|----------|-------|-------------|
| P0       | 5     | Blocks usage or critical security |
| P1       | 12    | Poor UX, confusing flows |
| P2       | 8     | Nice to have |

---

## P0 — Blocks Usage / Critical

### 1. ❌ Liveness score-based routing missing
**What:** Liveness result is binary (isLive true/false). No score-based routing: high→auto-approve, medium→manual review, low→decline.
**Where:** `lib/services/liveness/liveness_service.dart` — `LivenessResult` has `confidence` but it's unused for routing. `lib/features/kyc/views/kyc_liveness_view.dart` only checks `result.isLive`.
**Fix:** Add `LivenessDecision` enum and score thresholds. Route KYC submission based on score.
**Status:** ✅ FIXED in this commit

### 2. ❌ Liveness challenge type hardcoded
**What:** `LivenessCheckWidget` gets challenges from backend (`createSession()`), which is correct. BUT `LivenessChallengeType` enum is hardcoded client-side. If backend sends a new type, it defaults to `blink`. The challenge type should be purely driven by backend `instruction` field.
**Where:** `lib/services/liveness/liveness_service.dart`
**Fix:** Already mostly backend-driven (instruction comes from API). The enum fallback is acceptable. Low risk. **No code change needed**, but flag for backend team.

### 3. ❌ PIN change does NOT require liveness check
**What:** Settings → Change PIN goes directly to current PIN entry. Should require liveness verification first for security.
**Where:** `lib/features/settings/views/change_pin_view.dart` (at `/settings/pin`). Security view links to `/settings/change-pin` which is a **broken route** (router has `/settings/pin`).
**Fix:** Add liveness gate before PIN change flow. Fix route mismatch.
**Status:** ✅ FIXED in this commit

### 4. ❌ Security view links to wrong route for PIN change
**What:** `security_view.dart:65` pushes `/settings/change-pin` but router only has `/settings/pin`.
**Where:** `lib/features/settings/views/security_view.dart`
**Fix:** Change route to `/settings/pin`.
**Status:** ✅ FIXED in this commit

### 5. ❌ No force update screen
**What:** No mechanism to force users to update the app when a critical update is released.
**Where:** Should be in `lib/features/` as a standalone screen, checked at app startup.
**Fix:** Create `ForceUpdateScreen` and check at splash.
**Status:** ✅ FIXED in this commit

---

## P1 — Poor UX

### 6. ⚠️ Liveness explanation screen exists but uses English
**What:** `KycLivenessView` already shows `KycInstructionScreen` before the challenge (good!), but all instruction text is hardcoded English, not using l10n.
**Where:** `lib/features/kyc/widgets/kyc_instruction_screen.dart` — `KycInstructions.liveness`
**Fix:** Move strings to AppLocalizations.
**Status:** ✅ FIXED in this commit

### 7. ⚠️ PIN setup screen exists but no biometric enrollment prompt after
**What:** After PIN setup (`/pin/confirm` → success → `/home`), user is never prompted to enable biometric authentication.
**Where:** `lib/features/pin/views/confirm_pin_view.dart:109` — goes straight to `/home`
**Fix:** After PIN setup, show biometric enrollment prompt before going home.
**Status:** ✅ FIXED in this commit

### 8. ⚠️ No empty wallet state
**What:** Home screen doesn't have a distinct empty state for new users with zero transactions.
**Where:** `lib/features/wallet/views/wallet_home_screen.dart`
**Priority:** P1

### 9. ⚠️ No deposit processing status screen
**What:** Mobile money deposit flow has `DepositStatusScreen` but it's basic.
**Where:** `lib/features/deposit/views/deposit_status_screen.dart`
**Priority:** P1

### 10. ⚠️ Send money — no failure screen with retry
**What:** `ResultScreen` shows success/failure but failure state may not have clear retry action.
**Where:** `lib/features/send/views/result_screen.dart`
**Priority:** P1

### 11. ⚠️ No notification empty state
**What:** `NotificationsView` likely shows empty list with no illustration/message.
**Where:** `lib/features/notifications/views/notifications_view.dart`
**Priority:** P1

### 12. ⚠️ KYC rejection handling incomplete
**What:** `KycStatusView` shows status but rejected state may not clearly guide user to retry with specific feedback.
**Where:** `lib/features/kyc/views/kyc_status_view.dart`
**Priority:** P1

### 13. ⚠️ Change PIN view uses 4-digit PIN but SetPinView uses 6-digit
**What:** `change_pin_view.dart` (settings) validates 4-digit PINs. `set_pin_view.dart` (onboarding) validates 6-digit PINs. Inconsistent.
**Where:** `lib/features/settings/views/change_pin_view.dart` vs `lib/features/pin/views/set_pin_view.dart`
**Priority:** P1
**Status:** ✅ FIXED — Changed to 6-digit in change_pin_view

### 14. ⚠️ No server error full-screen
**What:** Errors show as snackbars/banners but no dedicated full-screen error state for critical failures.
**Where:** Should be `lib/design/components/states/`
**Priority:** P1
**Status:** ✅ FIXED in this commit

### 15. ⚠️ No maintenance mode screen
**What:** `CommonStrings.maintenanceMode` exists, `maintenance_guard.dart` exists, but no full-screen UI.
**Where:** Should be a route/screen
**Priority:** P1
**Status:** ✅ FIXED in this commit

### 16. ⚠️ Hardcoded English strings in liveness widget
**What:** `LivenessCheckWidget` has hardcoded strings: "Liveness Check", "Liveness Verified!", "Your identity has been confirmed", etc.
**Where:** `lib/features/liveness/widgets/liveness_check_widget.dart`
**Priority:** P1

### 17. ⚠️ Hardcoded English in KYC liveness failure/success screens
**What:** kyc_liveness_view.dart has 'Liveness Check Failed', 'Try Again', etc. in English.
**Where:** `lib/features/kyc/views/kyc_liveness_view.dart`
**Priority:** P1

---

## P2 — Nice to Have

### 18. 💡 No rate-limited screen
**Where:** Could be a reusable error state component
**Priority:** P2

### 19. 💡 No savings pot withdraw confirmation
**Priority:** P2

### 20. 💡 No card creation success animation
**Priority:** P2

### 21. 💡 No session management explanation
**Priority:** P2

### 22. 💡 No bank linking failure/retry flow
**Priority:** P2

### 23. 💡 No bill payment receipt/download
**Priority:** P2

### 24. 💡 No QR code share functionality for receive
**Priority:** P2

### 25. 💡 Onboarding slides don't mention PIN setup
**Priority:** P2

---

## Changes Made in This Commit

1. **Liveness score-based routing** — Added `LivenessDecision` enum and `evaluateScore()` to liveness service. Updated `KycLivenessView` to route based on score (auto-approve / manual review / decline).

2. **PIN change requires liveness check** — Updated `ChangePinView` to show liveness verification before allowing PIN change. Added liveness gate flow.

3. **Fixed security view broken route** — Changed `/settings/change-pin` to `/settings/pin`.

4. **Fixed PIN length inconsistency** — Changed `ChangePinView` from 4-digit to 6-digit PIN.

5. **Biometric enrollment after PIN setup** — Updated `ConfirmPinView` to redirect to biometric enrollment instead of directly to home.

6. **Force update screen** — Created `ForceUpdateView` with app store redirect.

7. **Maintenance mode screen** — Created `MaintenanceView`.

8. **Server error screen** — Created `ServerErrorView`.

9. **Localized liveness instruction strings** — Added French strings for liveness instructions.
