# Korido Mobile — Tech Debt Tracker

## Warning Status
- **0 errors** ✅
- **279 warnings** (was ~1251 before refactoring sessions)
  - 244 `avoid_dynamic_calls` — needs case-by-case type annotations
  - 25 `deprecated_member_use` — Radio groupValue/onChanged (Flutter 3.32+ migration)
  - 10 misc (suppressed)

## God Files (>500 lines)
| File | Lines | Action |
|------|-------|--------|
| `router/app_router.dart` | 1829 | Split into feature route files |
| `settings/views/kyc_view.dart` | 1635 | Extract step widgets |
| `wallet/views/wallet_home_screen.dart` | 1532 | Extract section widgets |
| `settings/views/settings_view.dart` | 1223 | Extract setting groups |
| `state/fsm/kyc_fsm.dart` | 980 | Extract state handlers |
| 15+ views 800-950 lines | | Extract reusable widgets |

## Duplicate Entities
| Domain | Feature | Status |
|--------|---------|--------|
| `domain/entities/savings_pot.dart` | *(deleted)* | ✅ Consolidated |
| `domain/entities/expense.dart` | *(deleted)* | ✅ Consolidated |
| `domain/entities/device.dart` | `settings/models/device.dart` | Different schemas — keep both |
| `domain/entities/card.dart` | `cards/models/cards_state.dart` | WalletCard typedef added ✅ |
| `domain/entities/recurring_transfer.dart` | `recurring_transfers/models/recurring_transfer.dart` | Different enums — keep both |

## Stub Providers (missing_providers.dart)
10 stub providers need wiring to real implementations:
- `filteredPaginatedTransactionsProvider`
- `exchangeRateProvider` (stub; real one exists in wallet_provider with params)
- `spendingTrendProvider`, `selectedPeriodProvider`, `spendingByCategoryProvider`
- `spendingSummaryProvider`, `topRecipientsProvider`
- `notificationsNotifierProvider`, `profileNotifierProvider`
- `providersListProvider`

## Completed This Session
- [x] Theme migration: 1121 AppColors → context.colors (130+ files)
- [x] Decomposed missing_states.dart into 7 feature modules
- [x] Typed 4 state classes (Cards, Expenses, Transactions, RecurringTransfer)
- [x] Consolidated SavingsPot + Expense entities (removed duplicates)
- [x] Share.share → SharePlus.instance.share (28 call sites)
- [x] JoonaPay → Korido rebrand (all non-l10n files)
- [x] Deprecated API fixes (Switch, SharedPrefs, Color accessors, Table)
- [x] Removed 9 obsolete lint rules
- [x] Global keyboard dismissal
- [x] AsyncContent<T> + ListScaffold<T> reusable components
- [x] Design system documentation
- [x] Warning count: ~1251 → 279 (78% reduction)

## Next Priority
1. Fix remaining 244 `avoid_dynamic_calls` (biggest category)
2. Migrate Radio widgets to RadioGroup API
3. Split app_router.dart into feature routes
4. Wire stub providers to real implementations
