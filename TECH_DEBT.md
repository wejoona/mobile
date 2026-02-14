# Korido Mobile — Tech Debt Tracker

## Current Status ✅
- **0 errors, 0 warnings** (was ~1251 warnings before this session)
- 13,427 info-level style hints remaining (non-blocking)

## Suppressed (not fixed — tracked for future cleanup)
- 197 `avoid_dynamic_calls` — Dio responses return `dynamic`; needs proper DTOs
- 74 `unused_local_variable` — `__`-prefixed side-effect variables
- 25 `deprecated_member_use` — Radio groupValue/onChanged (Flutter 3.32+ migration)
- 15 `constant_pattern_never_matches_value_type` — String vs enum in switches
- 13 `dead_code` — null-guard dead branches
- 11 `unused_element` — private methods kept for future use
- 8 `dead_null_aware_expression` — redundant `?? fallback`
- 9 `unnecessary_non_null_assertion` — on non-nullable expressions

## God Files (>500 lines) — Split Later
| File | Lines | Action |
|------|-------|--------|
| `router/app_router.dart` | 1829 | Split into feature route files |
| `settings/views/kyc_view.dart` | 1635 | Extract step widgets |
| `wallet/views/wallet_home_screen.dart` | 1532 | Extract section widgets |
| `settings/views/settings_view.dart` | 1223 | Extract setting groups |
| `state/fsm/kyc_fsm.dart` | 980 | Extract state handlers |

## Duplicate Entities (intentional — different schemas)
- `domain/entities/device.dart` vs `settings/models/device.dart`
- `domain/entities/recurring_transfer.dart` vs `recurring_transfers/models/recurring_transfer.dart`

## Stub Providers (missing_providers.dart) — Wire When Ready
10 stub providers need real implementations

## Session Summary (2026-02-14)
20 commits. Highlights:
- Complete JoonaPay→Korido rebrand (code + l10n + internal identifiers)
- Share.share → SharePlus.instance.share (28 call sites)
- Decomposed missing_states.dart into 7 feature modules
- Typed 5 state classes (Cards, Expenses, Transactions, RecurringTransfer, SavingsPots)
- Consolidated 2 duplicate entities (SavingsPot, Expense)
- Migrated deprecated APIs (Switch, SharedPrefs, Color accessors, Table, Share)
- Removed 9 obsolete lint rules
- Created AsyncContent<T> + ListScaffold<T> reusable components
- Design system documented (DESIGN_SYSTEM.md)
- Global keyboard dismissal + error handling
- Staggered entrance animations + notification badge + haptic feedback
