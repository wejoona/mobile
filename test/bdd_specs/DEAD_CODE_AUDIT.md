# Dead Code Audit - USDC Wallet

> Generated: 2025-02-04

## Summary

After comparing all screen/view files against the router imports, the following files are identified as **dead code** - they exist but are not imported/routed to in the application.

## Dead Code Files

### 1. Duplicate/Legacy Files

| File | Status | Reason |
|------|--------|--------|
| `lib/features/cards/views/cards_screen.dart` | DEAD_CODE | Duplicate of `cards_list_view.dart` |
| `lib/features/settings/views/help_screen.dart` | DEAD_CODE | Duplicate of `help_view.dart` |
| `lib/features/offline/views/pending_transfers_screen.dart` | DEAD_CODE | Replaced by offline sync system |
| `lib/features/contacts/views/contacts_list_screen.dart` | DEAD_CODE | Contact picker is inline |
| `lib/features/contacts/views/contacts_permission_screen.dart` | DEAD_CODE | Permission handled inline |
| `lib/features/qr_payment/views/receive_qr_screen.dart` | DEAD_CODE | Replaced by `receive_view.dart` |
| `lib/features/qr_payment/views/scan_qr_screen.dart` | DEAD_CODE | Replaced by `scan_view.dart` |

### 2. Demo/Debug Files (Not for Production)

| File | Status | Reason |
|------|--------|--------|
| `lib/core/rtl/examples/rtl_debug_screen.dart` | DEMO_ONLY | RTL testing tool |
| `lib/features/debug/performance_debug_screen.dart` | DEMO_ONLY | Performance monitoring |
| `lib/catalog/widget_catalog_view.dart` | DEMO_ONLY | In router but for dev only |
| `lib/design/components/states/states_demo_view.dart` | DEMO_ONLY | State preview |
| `lib/features/wallet/views/wallet_home_accessibility_example.dart` | DEMO_ONLY | Accessibility example |

### 3. Awaiting Implementation

| File | Status | Reason |
|------|--------|--------|
| `lib/features/wallet/views/home_view.dart` | AWAITING_IMPLEMENTATION | Possible legacy home |
| `lib/features/wallet/views/send_view.dart` | AWAITING_IMPLEMENTATION | Possible legacy send |
| `lib/features/wallet/views/pending_transfers_view.dart` | AWAITING_IMPLEMENTATION | May be reimplemented |
| `lib/features/pin/views/change_pin_view.dart` | AWAITING_IMPLEMENTATION | Duplicate in settings |
| `lib/features/pin/views/confirm_pin_view.dart` | AWAITING_IMPLEMENTATION | Part of legacy flow |
| `lib/features/pin/views/enter_pin_view.dart` | AWAITING_IMPLEMENTATION | Part of legacy flow |
| `lib/features/pin/views/pin_locked_view.dart` | AWAITING_IMPLEMENTATION | Handled by FSM |
| `lib/features/pin/views/reset_pin_view.dart` | AWAITING_IMPLEMENTATION | May be reimplemented |
| `lib/features/pin/views/set_pin_view.dart` | AWAITING_IMPLEMENTATION | Part of onboarding |
| `lib/features/kyc/widgets/kyc_instruction_screen.dart` | AWAITING_IMPLEMENTATION | Widget, not route |

### 4. Onboarding Sub-Views (Used via parent)

| File | Status | Reason |
|------|--------|--------|
| `lib/features/onboarding/views/enhanced_onboarding_view.dart` | DEAD_CODE | Not in router |
| `lib/features/onboarding/views/help/deposits_guide_view.dart` | DEAD_CODE | Not directly routed |
| `lib/features/onboarding/views/help/fees_transparency_view.dart` | DEAD_CODE | Not directly routed |
| `lib/features/onboarding/views/help/usdc_explainer_view.dart` | DEAD_CODE | Not directly routed |
| `lib/features/onboarding/views/kyc_prompt_view.dart` | DEAD_CODE | Not in router |
| `lib/features/onboarding/views/onboarding_pin_view.dart` | DEAD_CODE | Not in router |
| `lib/features/onboarding/views/onboarding_success_view.dart` | DEAD_CODE | Not in router |
| `lib/features/onboarding/views/otp_verification_view.dart` | DEAD_CODE | Not in router |
| `lib/features/onboarding/views/phone_input_view.dart` | DEAD_CODE | Not in router |
| `lib/features/onboarding/views/profile_setup_view.dart` | DEAD_CODE | Not in router |
| `lib/features/onboarding/views/welcome_post_login_view.dart` | DEAD_CODE | Not in router |
| `lib/features/onboarding/views/welcome_view.dart` | DEAD_CODE | Not in router |

### 5. Auth Sub-Views

| File | Status | Reason |
|------|--------|--------|
| `lib/features/auth/views/legal_document_view.dart` | ACTIVE | Used via Navigator.push |
| `lib/features/auth/views/login_phone_view.dart` | DEAD_CODE | Part of login_view |

## Recommendations

### Immediate Actions
1. **Delete** duplicate files after confirming they're not imported elsewhere
2. **Move** demo files to a `/debug` or `/dev` directory with clear exclusion from production builds
3. **Review** onboarding sub-views - they may need to be integrated into the router or consolidated

### Code Cleanup Commands

```bash
# Find all unused imports
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
dart analyze --fatal-warnings

# Check for unused files
flutter pub run unused_files:unused_files lib/
```

## Impact on Testing

For golden tests, we should still test dead code files:
- They may be reactivated in future
- Tests will help identify when code becomes stale
- Easier to detect breaking changes

Each dead code file should be flagged in its BDD spec with `# STATUS: DEAD_CODE` and tested with a note that the screen is not currently routed.

---

*Generated during USDC Wallet Complete Testing Suite - Step 1*
