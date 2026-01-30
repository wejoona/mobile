# State Management Documentation

> Complete guide to state management in the JoonaPay mobile app using Riverpod

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Provider Organization](#provider-organization)
3. [State Machines](#state-machines)
4. [Best Practices](#best-practices)
5. [Common Patterns](#common-patterns)
6. [Testing](#testing)
7. [Debugging](#debugging)
8. [Examples](#examples)

---

## Architecture Overview

### Technology Stack
- **State Management:** Riverpod 2.x
- **Pattern:** Modern `Notifier` + `NotifierProvider` (not deprecated `StateNotifier`)
- **State:** Immutable state classes with `copyWith()`
- **Architecture:** State machines for complex flows

### Provider Types Used

| Provider Type | Use Case | Example |
|--------------|----------|---------|
| `NotifierProvider` | Mutable state with business logic | `WalletStateMachine`, `UserStateMachine` |
| `FutureProvider` | Async data fetching with auto-caching | `transactionsProvider` |
| `FutureProvider.family` | Parameterized async data | `transactionProvider(id)` |
| `Provider` | Computed/derived values | `usdBalanceProvider`, `isAuthenticatedProvider` |
| `StreamProvider` | Real-time data streams | Not currently used |

### Why Notifier Over StateNotifier?

```dart
// OLD (deprecated StateNotifier)
class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(MyState());
}

// NEW (modern Notifier)
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() => MyState();
}
```

Benefits:
- Better integration with Riverpod 2.x lifecycle
- Simpler API with `ref` access
- More consistent with other provider types
- Future-proof for Riverpod 3.x

---

## Provider Organization

### Directory Structure

```
lib/
├── state/                          # Global state machines
│   ├── app_state.dart             # State class definitions
│   ├── wallet_state_machine.dart  # Wallet balance management
│   ├── user_state_machine.dart    # Auth & user profile
│   └── transaction_state_machine.dart # Transaction list
│
├── features/
│   ├── auth/
│   │   └── providers/
│   │       ├── auth_provider.dart          # Auth flow
│   │       └── login_provider.dart         # Login multi-step flow
│   ├── send/
│   │   └── providers/
│   │       └── send_provider.dart          # Send money flow
│   ├── recurring_transfers/
│   │   └── providers/
│   │       ├── recurring_transfers_provider.dart # List management
│   │       └── create_recurring_transfer_provider.dart # Creation flow
│   └── transactions/
│       └── providers/
│           └── transactions_provider.dart   # Filtering & pagination
│
└── design/
    └── theme/
        └── theme_provider.dart              # App theme state
```

### Global vs Scoped Providers

**Global State Machines (Never Auto-Dispose)**
```dart
// Located in lib/state/
final walletStateMachineProvider = NotifierProvider<WalletStateMachine, WalletState>(
  WalletStateMachine.new,
);
```

Used for:
- User authentication state
- Wallet balance
- Transaction list
- App-wide settings

**Feature-Scoped Providers (Auto-Dispose)**
```dart
// Located in lib/features/{feature}/providers/
final paginatedTransactionsProvider = NotifierProvider.autoDispose<
  PaginatedTransactionsNotifier, PaginatedTransactionsState>(
  PaginatedTransactionsNotifier.new,
);
```

Used for:
- Form state
- Temporary UI state
- Feature-specific data that doesn't need to persist

### Provider Dependencies

Providers can depend on other providers:

```dart
class WalletStateMachine extends Notifier<WalletState> {
  @override
  WalletState build() => const WalletState();

  // Access other providers via ref
  WalletService get _service => ref.read(walletServiceProvider);

  Future<void> fetch() async {
    final response = await _service.getBalance();
    // Update state...
  }
}
```

**Dependency Graph:**
```
UserStateMachine
├─> AuthService
├─> UserService
├─> SecureStorage
└─> Triggers:
    ├─> WalletStateMachine.fetch()
    └─> TransactionStateMachine.fetch()

WalletStateMachine
├─> WalletService
└─> Used by:
    ├─> usdBalanceProvider
    ├─> totalBalanceProvider
    └─> isWalletLoadingProvider

TransactionStateMachine
├─> TransactionsService
├─> TransactionFilterProvider (listen)
└─> WalletStateMachine (for refresh)
```

---

## State Machines

### Overview

State machines manage complex application state with well-defined transitions. JoonaPay uses three core state machines:

1. **UserStateMachine** - Authentication & user profile
2. **WalletStateMachine** - Wallet balance & address
3. **TransactionStateMachine** - Transaction list with pagination

### 1. UserStateMachine

**File:** `lib/state/user_state_machine.dart`

**States:**
```dart
enum AuthStatus {
  initial,      // App startup, checking stored auth
  loading,      // Processing auth action
  authenticated,// User logged in
  unauthenticated, // User logged out or session expired
  otpSent,      // OTP sent to phone
  error,        // Auth error occurred
}
```

**State Transitions:**
```
initial ──checkStoredAuth()──> authenticated/unauthenticated
          │
unauthenticated ──requestOtp()──> otpSent ──verifyOtp()──> authenticated
                                      │                          │
                                      └──error──> error          │
                                                                 │
authenticated ──────────────────────logout()─────────> unauthenticated
```

**Key Methods:**
```dart
class UserStateMachine extends Notifier<UserState> {
  Future<bool> requestOtp(String phone);    // Request OTP
  Future<bool> verifyOtp(String otp);       // Verify OTP & login
  Future<void> logout();                    // Logout & clear state
  void updateProfile({...});                // Update user info
  void clearError();                        // Clear error state
}
```

**Usage:**
```dart
final userState = ref.watch(userStateMachineProvider);

if (userState.isAuthenticated) {
  // User is logged in
  Text('Welcome ${userState.displayName}');
}

// Trigger login
ref.read(userStateMachineProvider.notifier).requestOtp(phone);
```

**Convenience Providers:**
```dart
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(userStateMachineProvider).isAuthenticated;
});

final userDisplayNameProvider = Provider<String>((ref) {
  return ref.watch(userStateMachineProvider).displayName;
});

final kycStatusProvider = Provider<KycStatus>((ref) {
  return ref.watch(userStateMachineProvider).kycStatus;
});
```

### 2. WalletStateMachine

**File:** `lib/state/wallet_state_machine.dart`

**States:**
```dart
enum WalletStatus {
  initial,    // Not yet loaded
  loading,    // First time loading
  loaded,     // Successfully loaded
  error,      // Failed to load
  refreshing, // Pull-to-refresh
}
```

**State Transitions:**
```
initial ──fetch()──> loading ──success──> loaded
                        │                   │
                        └──error──> error   │
                                            │
loaded ──refresh()──> refreshing ──success──> loaded
         │                │
         └──error─────────┘ (stays loaded, no error shown)
```

**Key Methods:**
```dart
class WalletStateMachine extends Notifier<WalletState> {
  Future<void> fetch();                     // Fetch wallet balance
  Future<void> refresh();                   // Refresh (pull-to-refresh)
  void updateBalanceOptimistic({...});      // Optimistic update
  void reset();                             // Reset on logout
}
```

**Special Handling:**
- 404 "Wallet not found" → Sets loaded state with empty wallet (triggers "Create Wallet" card)
- Refresh errors → Keep old data, don't show error (better UX)

**Usage:**
```dart
final walletState = ref.watch(walletStateMachineProvider);

Text('Balance: ${walletState.usdBalance.toStringAsFixed(2)} USD');

// Refresh
ref.read(walletStateMachineProvider.notifier).refresh();

// Optimistic update after transfer
ref.read(walletStateMachineProvider.notifier).updateBalanceOptimistic(
  subtractUsd: 100.0,
  addPending: 100.0,
);
```

**Convenience Providers:**
```dart
final usdBalanceProvider = Provider<double>((ref) {
  return ref.watch(walletStateMachineProvider).usdBalance;
});

final totalBalanceProvider = Provider<double>((ref) {
  return ref.watch(walletStateMachineProvider).totalBalance;
});

final walletAddressProvider = Provider<String?>((ref) {
  return ref.watch(walletStateMachineProvider).walletAddress;
});
```

### 3. TransactionStateMachine

**File:** `lib/state/transaction_state_machine.dart`

**States:**
```dart
enum TransactionListStatus {
  initial,     // Not yet loaded
  loading,     // First time loading
  loaded,      // Successfully loaded
  loadingMore, // Loading next page
  error,       // Failed to load
  refreshing,  // Pull-to-refresh
}
```

**State Transitions:**
```
initial ──fetch()──> loading ──success──> loaded
                        │                   │
                        └──error──> error   │
                                            │
loaded ──loadMore()──> loadingMore ──success──> loaded (appends)
       │                  │
       └──refresh()──> refreshing ──success──> loaded (replaces)
```

**Key Methods:**
```dart
class TransactionStateMachine extends Notifier<TransactionListState> {
  Future<void> fetch();                     // Fetch initial page
  Future<void> refresh();                   // Refresh (pull-to-refresh)
  Future<void> loadMore();                  // Load next page
  void addTransaction(Transaction tx);      // Add new transaction
  void updateTransaction(String id, TransactionStatus status); // Update status
  void reset();                             // Reset on logout
}
```

**Filter Integration:**
```dart
@override
TransactionListState build() {
  // Listen to filter changes and reload
  ref.listen(transactionFilterProvider, (previous, next) {
    if (previous != next) {
      fetch();
    }
  });

  _autoFetch();
  return const TransactionListState();
}
```

**Usage:**
```dart
final txState = ref.watch(transactionStateMachineProvider);

ListView.builder(
  itemCount: txState.transactions.length,
  itemBuilder: (context, index) {
    final tx = txState.transactions[index];
    return TransactionTile(transaction: tx);
  },
);

// Load more on scroll
if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
  ref.read(transactionStateMachineProvider.notifier).loadMore();
}
```

**Convenience Providers:**
```dart
final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  final state = ref.watch(transactionStateMachineProvider);
  return state.transactions.take(5).toList();
});

final pendingTransactionsProvider = Provider<List<Transaction>>((ref) {
  final state = ref.watch(transactionStateMachineProvider);
  return state.transactions.where((tx) => tx.isPending).toList();
});
```

---

## Best Practices

### 1. ref.watch vs ref.read

**ref.watch** - Reactive listening (rebuilds on change)
```dart
Widget build(BuildContext context, WidgetRef ref) {
  final walletState = ref.watch(walletStateMachineProvider);
  return Text('${walletState.usdBalance}'); // Rebuilds when balance changes
}
```

**ref.read** - One-time read (actions, no rebuild)
```dart
void _handleSend() {
  ref.read(sendMoneyProvider.notifier).executeTransfer();
  // Does NOT rebuild when sendMoneyProvider changes
}
```

**Rule:** Use `watch` in `build()`, use `read` in callbacks.

### 2. Invalidation Patterns

**Manual Invalidation:**
```dart
// Invalidate a provider to force re-fetch
ref.invalidate(transactionsProvider);
```

**Auto-Invalidation with TTL:**
```dart
final transactionsProvider = FutureProvider<TransactionPage>((ref) async {
  final service = ref.watch(transactionsServiceProvider);
  final link = ref.keepAlive();

  // Auto-invalidate after 1 minute
  Timer(const Duration(minutes: 1), () {
    link.close();
  });

  return service.getTransactions();
});
```

**Cross-Provider Invalidation:**
```dart
// After successful transfer, invalidate related providers
ref.invalidate(walletStateMachineProvider);
ref.invalidate(transactionStateMachineProvider);
```

### 3. Error Handling

**Pattern 1: Error in State**
```dart
class MyState {
  final bool isLoading;
  final String? error;
  final MyData? data;

  const MyState({
    this.isLoading = false,
    this.error,
    this.data,
  });
}

class MyNotifier extends Notifier<MyState> {
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _service.fetch();
      state = state.copyWith(isLoading: false, data: data);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
```

**Pattern 2: AsyncValue (FutureProvider)**
```dart
final dataProvider = FutureProvider((ref) async {
  return await ref.read(serviceProvider).fetch();
});

// In widget
Widget build(BuildContext context, WidgetRef ref) {
  final dataAsync = ref.watch(dataProvider);

  return dataAsync.when(
    data: (data) => DataView(data: data),
    loading: () => CircularProgressIndicator(),
    error: (error, stack) => ErrorView(error: error.toString()),
  );
}
```

### 4. Loading States

**Multiple Loading States:**
```dart
enum Status {
  initial,     // Not started
  loading,     // First load (show spinner)
  loaded,      // Data loaded
  refreshing,  // Pull-to-refresh (show refresh indicator)
  loadingMore, // Pagination (show bottom spinner)
  error,       // Error occurred
}
```

**Usage:**
```dart
if (state.status == Status.loading) {
  return CircularProgressIndicator();
}

if (state.status == Status.refreshing) {
  return RefreshProgressIndicator(
    child: ListView(...),
  );
}

if (state.status == Status.loadingMore) {
  return Column(
    children: [
      ListView(...),
      CircularProgressIndicator(), // Bottom spinner
    ],
  );
}
```

### 5. Immutability

**Always use copyWith for state updates:**
```dart
// GOOD
state = state.copyWith(
  isLoading: false,
  data: newData,
  error: null, // Explicitly clear error
);

// BAD - Don't mutate state
state.isLoading = false; // Won't trigger rebuild!
state.data = newData;
```

**Nullable field handling:**
```dart
class MyState {
  final String? error;

  MyState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false, // Flag for clearing nullable
  }) {
    return MyState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Usage
state = state.copyWith(clearError: true);
```

---

## Common Patterns

### 1. AsyncValue Handling

**Basic Pattern:**
```dart
final dataProvider = FutureProvider((ref) async {
  return await ref.read(serviceProvider).fetchData();
});

// In widget
Widget build(BuildContext context, WidgetRef ref) {
  final dataAsync = ref.watch(dataProvider);

  return dataAsync.when(
    data: (data) => DataView(data: data),
    loading: () => Center(child: CircularProgressIndicator()),
    error: (error, stack) => ErrorView(error: error),
  );
}
```

**Map Pattern:**
```dart
final displayText = dataAsync.when(
  data: (data) => data.title,
  loading: () => 'Loading...',
  error: (error, stack) => 'Error: $error',
);
```

**maybeWhen Pattern:**
```dart
return dataAsync.maybeWhen(
  data: (data) => DataView(data: data),
  orElse: () => LoadingView(),
);
```

### 2. Pagination

**Notifier-Based Pagination:**
```dart
class PaginatedTransactionsNotifier extends Notifier<PaginatedTransactionsState> {
  static const int _pageSize = 20;

  @override
  PaginatedTransactionsState build() {
    Future.microtask(() => loadInitial());
    return const PaginatedTransactionsState(isLoading: true);
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final page = await _service.getTransactions(page: 1, pageSize: _pageSize);

      state = state.copyWith(
        transactions: page.transactions,
        isLoading: false,
        hasMore: page.hasMore,
        currentPage: 1,
        total: page.total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final page = await _service.getTransactions(page: nextPage, pageSize: _pageSize);

      state = state.copyWith(
        transactions: [...state.transactions, ...page.transactions],
        isLoading: false,
        hasMore: page.hasMore,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = const PaginatedTransactionsState(isLoading: true);
    await loadInitial();
  }
}
```

**Scroll Controller Integration:**
```dart
class TransactionListView extends ConsumerStatefulWidget {
  @override
  ConsumerState<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends ConsumerState<TransactionListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      ref.read(paginatedTransactionsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paginatedTransactionsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(paginatedTransactionsProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.transactions.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.transactions.length) {
            return Center(child: CircularProgressIndicator());
          }
          return TransactionTile(transaction: state.transactions[index]);
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

### 3. Optimistic Updates

**Pattern:**
```dart
class SendMoneyNotifier extends Notifier<SendMoneyState> {
  Future<bool> executeTransfer() async {
    // 1. Optimistically update wallet balance
    ref.read(walletStateMachineProvider.notifier).updateBalanceOptimistic(
      subtractUsd: state.amount!,
      addPending: state.amount!,
    );

    // 2. Optimistically add transaction to list
    final tempTx = Transaction(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.transfer,
      status: TransactionStatus.pending,
      amount: state.amount!,
      // ... other fields
    );
    ref.read(transactionStateMachineProvider.notifier).addTransaction(tempTx);

    // 3. Execute API call
    try {
      final result = await _service.createInternalTransfer(
        recipientPhone: state.recipient!.phoneNumber,
        amount: state.amount!,
      );

      // 4. Update with real transaction
      ref.read(transactionStateMachineProvider.notifier).updateTransaction(
        tempTx.id,
        TransactionStatus.completed,
      );

      return true;
    } catch (e) {
      // 5. Rollback on error
      ref.read(walletStateMachineProvider.notifier).refresh();
      ref.read(transactionStateMachineProvider.notifier).refresh();

      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}
```

### 4. Cache + Network Pattern

**FutureProvider with TTL:**
```dart
final transactionsProvider = FutureProvider<TransactionPage>((ref) async {
  final service = ref.watch(transactionsServiceProvider);
  final link = ref.keepAlive();

  // Cache for 1 minute
  Timer(const Duration(minutes: 1), () {
    link.close();
  });

  return service.getTransactions();
});
```

**Manual Cache Control:**
```dart
class DataNotifier extends Notifier<DataState> {
  DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 5);

  Future<void> fetch({bool forceRefresh = false}) async {
    final now = DateTime.now();

    // Use cache if fresh
    if (!forceRefresh &&
        _lastFetch != null &&
        now.difference(_lastFetch!) < _cacheDuration) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final data = await _service.fetch();
      state = state.copyWith(isLoading: false, data: data);
      _lastFetch = now;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
```

### 5. Multi-Step Flow

**Example: Login Flow**
```dart
enum LoginStep {
  phone,      // Enter phone number
  otp,        // Enter OTP code
  pin,        // Enter/create PIN
  success,    // Login complete
}

class LoginState {
  final LoginStep currentStep;
  final String? phoneNumber;
  final String? otp;
  final int otpResendCountdown;
  final int pinAttempts;
  final bool isLocked;
  final String? error;

  const LoginState({
    this.currentStep = LoginStep.phone,
    this.phoneNumber,
    this.otp,
    this.otpResendCountdown = 0,
    this.pinAttempts = 0,
    this.isLocked = false,
    this.error,
  });
}

class LoginNotifier extends Notifier<LoginState> {
  Timer? _resendTimer;

  Future<void> submitPhoneNumber() async {
    // Call API
    await _authService.login(phone: state.phoneNumber!);

    // Move to next step
    state = state.copyWith(currentStep: LoginStep.otp);
    _startResendCountdown();
  }

  Future<void> verifyOtp() async {
    final response = await _authService.verifyOtp(
      phone: state.phoneNumber!,
      otp: state.otp!,
    );

    // Move to next step
    state = state.copyWith(
      currentStep: LoginStep.pin,
      sessionToken: response.accessToken,
    );
  }

  Future<bool> verifyPin(String pin) async {
    // Verify PIN
    final success = await _pinService.verify(pin);

    if (success) {
      state = state.copyWith(currentStep: LoginStep.success);
      return true;
    } else {
      final newAttempts = state.pinAttempts + 1;

      if (newAttempts >= 3) {
        state = state.copyWith(
          isLocked: true,
          error: 'Too many attempts. Locked for 15 minutes.',
        );
      } else {
        state = state.copyWith(
          pinAttempts: newAttempts,
          error: 'Incorrect PIN, ${3 - newAttempts} attempts remaining',
        );
      }
      return false;
    }
  }

  void goToStep(LoginStep step) {
    state = state.copyWith(currentStep: step);
  }
}
```

**Navigation Based on Step:**
```dart
Widget build(BuildContext context, WidgetRef ref) {
  final loginState = ref.watch(loginProvider);

  return switch (loginState.currentStep) {
    LoginStep.phone => PhoneNumberView(),
    LoginStep.otp => OtpVerificationView(),
    LoginStep.pin => PinEntryView(),
    LoginStep.success => HomeView(),
  };
}
```

---

## Testing

### Provider Override Pattern

```dart
void main() {
  testWidgets('displays wallet balance', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletStateMachineProvider.overrideWith(() => MockWalletStateMachine()),
        ],
        child: MyApp(),
      ),
    );

    expect(find.text('1000.00 USD'), findsOneWidget);
  });
}
```

### Mock Providers

**Mock Notifier:**
```dart
class MockWalletStateMachine extends Notifier<WalletState> {
  @override
  WalletState build() {
    return const WalletState(
      status: WalletStatus.loaded,
      usdBalance: 1000.0,
      usdcBalance: 500.0,
    );
  }

  @override
  Future<void> fetch() async {
    // No-op for tests
  }
}
```

**Mock FutureProvider:**
```dart
void main() {
  testWidgets('displays transactions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionsProvider.overrideWith((ref) async {
            return TransactionPage(
              transactions: [
                Transaction(id: '1', amount: 100),
                Transaction(id: '2', amount: 200),
              ],
              total: 2,
              hasMore: false,
            );
          }),
        ],
        child: MyApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('100'), findsOneWidget);
  });
}
```

### Testing Async Providers

```dart
void main() {
  test('loads transactions successfully', () async {
    final container = ProviderContainer(
      overrides: [
        transactionsServiceProvider.overrideWithValue(MockTransactionsService()),
      ],
    );

    // Trigger the provider
    final transactionsFuture = container.read(transactionsProvider.future);

    // Wait for result
    final transactions = await transactionsFuture;

    expect(transactions.transactions.length, 2);

    container.dispose();
  });
}
```

### Testing Notifier Methods

```dart
void main() {
  test('updates balance optimistically', () {
    final container = ProviderContainer();
    final notifier = container.read(walletStateMachineProvider.notifier);

    // Initial state
    expect(container.read(walletStateMachineProvider).usdBalance, 0);

    // Update
    notifier.updateBalanceOptimistic(addUsd: 100);

    // Verify
    expect(container.read(walletStateMachineProvider).usdBalance, 100);

    container.dispose();
  });
}
```

---

## Debugging

### 1. Riverpod DevTools

Enable in `main.dart`:
```dart
void main() {
  runApp(
    ProviderScope(
      observers: [ProviderLogger()],
      child: MyApp(),
    ),
  );
}

class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "newValue": "$newValue"
}''');
  }
}
```

### 2. Logging Provider Changes

**In Notifier:**
```dart
class WalletStateMachine extends Notifier<WalletState> {
  @override
  WalletState build() => const WalletState();

  Future<void> fetch() async {
    debugPrint('[WalletStateMachine] fetch() started');

    state = state.copyWith(status: WalletStatus.loading);
    debugPrint('[WalletStateMachine] status = loading');

    try {
      final response = await _service.getBalance();
      debugPrint('[WalletStateMachine] response: ${response.usdBalance}');

      state = state.copyWith(
        status: WalletStatus.loaded,
        usdBalance: response.usdBalance,
      );
      debugPrint('[WalletStateMachine] status = loaded, balance = ${state.usdBalance}');
    } catch (e) {
      debugPrint('[WalletStateMachine] error: $e');
      state = state.copyWith(status: WalletStatus.error, error: e.toString());
    }
  }
}
```

### 3. State Inspection

**Read Provider in DevTools Console:**
```dart
// In Flutter DevTools Console:
ProviderScope.containerOf(context).read(walletStateMachineProvider)
```

**Print State Tree:**
```dart
void printProviderState(WidgetRef ref) {
  final wallet = ref.read(walletStateMachineProvider);
  final user = ref.read(userStateMachineProvider);
  final transactions = ref.read(transactionStateMachineProvider);

  debugPrint('''
Provider State Tree:
├─ User: ${user.status} (${user.displayName})
├─ Wallet: ${wallet.status} (${wallet.usdBalance} USD)
└─ Transactions: ${transactions.status} (${transactions.transactions.length} items)
  ''');
}
```

### 4. Breakpoint Debugging

**Add breakpoints in Notifier methods:**
```dart
Future<void> executeTransfer() async {
  debugger(); // Breakpoint here

  final result = await _service.createTransfer(...);

  debugger(); // Breakpoint after API call

  state = state.copyWith(result: result);
}
```

---

## Examples

### Example 1: Simple CRUD Provider

```dart
// State
class TodoListState {
  final bool isLoading;
  final String? error;
  final List<Todo> todos;

  const TodoListState({
    this.isLoading = false,
    this.error,
    this.todos = const [],
  });

  TodoListState copyWith({
    bool? isLoading,
    String? error,
    List<Todo>? todos,
  }) {
    return TodoListState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      todos: todos ?? this.todos,
    );
  }
}

// Notifier
class TodoListNotifier extends Notifier<TodoListState> {
  @override
  TodoListState build() {
    Future.microtask(() => loadTodos());
    return const TodoListState();
  }

  TodoService get _service => ref.read(todoServiceProvider);

  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final todos = await _service.getTodos();
      state = state.copyWith(isLoading: false, todos: todos);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addTodo(String title) async {
    try {
      final newTodo = await _service.createTodo(title);
      state = state.copyWith(todos: [...state.todos, newTodo]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateTodo(String id, {bool? completed}) async {
    try {
      final updated = await _service.updateTodo(id, completed: completed);
      final todos = state.todos.map((t) => t.id == id ? updated : t).toList();
      state = state.copyWith(todos: todos);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _service.deleteTodo(id);
      final todos = state.todos.where((t) => t.id != id).toList();
      state = state.copyWith(todos: todos);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Provider
final todoListProvider = NotifierProvider<TodoListNotifier, TodoListState>(
  TodoListNotifier.new,
);
```

### Example 2: Paginated List Provider

```dart
// State
class PaginatedProductsState {
  final List<Product> products;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const PaginatedProductsState({
    this.products = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
  });

  PaginatedProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return PaginatedProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

// Notifier
class PaginatedProductsNotifier extends Notifier<PaginatedProductsState> {
  static const int _pageSize = 20;

  @override
  PaginatedProductsState build() {
    Future.microtask(() => loadInitial());
    return const PaginatedProductsState(isLoading: true);
  }

  ProductService get _service => ref.read(productServiceProvider);

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final page = await _service.getProducts(page: 1, pageSize: _pageSize);

      state = state.copyWith(
        products: page.products,
        isLoading: false,
        hasMore: page.hasMore,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final page = await _service.getProducts(page: nextPage, pageSize: _pageSize);

      state = state.copyWith(
        products: [...state.products, ...page.products],
        isLoading: false,
        hasMore: page.hasMore,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = const PaginatedProductsState(isLoading: true);
    await loadInitial();
  }
}

// Provider
final paginatedProductsProvider = NotifierProvider<
  PaginatedProductsNotifier, PaginatedProductsState>(
  PaginatedProductsNotifier.new,
);
```

### Example 3: Form State Provider

```dart
// State
class ContactFormState {
  final String name;
  final String email;
  final String message;
  final Map<String, String> errors;
  final bool isSubmitting;
  final bool isSubmitted;

  const ContactFormState({
    this.name = '',
    this.email = '',
    this.message = '',
    this.errors = const {},
    this.isSubmitting = false,
    this.isSubmitted = false,
  });

  bool get isValid => errors.isEmpty && name.isNotEmpty && email.isNotEmpty;

  ContactFormState copyWith({
    String? name,
    String? email,
    String? message,
    Map<String, String>? errors,
    bool? isSubmitting,
    bool? isSubmitted,
  }) {
    return ContactFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      message: message ?? this.message,
      errors: errors ?? this.errors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

// Notifier
class ContactFormNotifier extends Notifier<ContactFormState> {
  @override
  ContactFormState build() => const ContactFormState();

  void updateName(String name) {
    state = state.copyWith(name: name);
    _validateName();
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
    _validateEmail();
  }

  void updateMessage(String message) {
    state = state.copyWith(message: message);
  }

  void _validateName() {
    final errors = Map<String, String>.from(state.errors);

    if (state.name.isEmpty) {
      errors['name'] = 'Name is required';
    } else if (state.name.length < 2) {
      errors['name'] = 'Name must be at least 2 characters';
    } else {
      errors.remove('name');
    }

    state = state.copyWith(errors: errors);
  }

  void _validateEmail() {
    final errors = Map<String, String>.from(state.errors);
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (state.email.isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!emailRegex.hasMatch(state.email)) {
      errors['email'] = 'Invalid email format';
    } else {
      errors.remove('email');
    }

    state = state.copyWith(errors: errors);
  }

  Future<bool> submit() async {
    _validateName();
    _validateEmail();

    if (!state.isValid) return false;

    state = state.copyWith(isSubmitting: true);

    try {
      await ref.read(contactServiceProvider).submitContact(
        name: state.name,
        email: state.email,
        message: state.message,
      );

      state = state.copyWith(isSubmitting: false, isSubmitted: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errors: {'submit': e.toString()},
      );
      return false;
    }
  }

  void reset() {
    state = const ContactFormState();
  }
}

// Provider
final contactFormProvider = NotifierProvider.autoDispose<
  ContactFormNotifier, ContactFormState>(
  ContactFormNotifier.new,
);
```

### Example 4: Multi-Step Flow Provider

```dart
// State
enum OnboardingStep {
  welcome,
  phoneNumber,
  otp,
  personalInfo,
  pin,
  complete,
}

class OnboardingState {
  final OnboardingStep currentStep;
  final String? phoneNumber;
  final String? countryCode;
  final String? otp;
  final String? firstName;
  final String? lastName;
  final String? pin;
  final bool isLoading;
  final String? error;

  const OnboardingState({
    this.currentStep = OnboardingStep.welcome,
    this.phoneNumber,
    this.countryCode,
    this.otp,
    this.firstName,
    this.lastName,
    this.pin,
    this.isLoading = false,
    this.error,
  });

  double get progress {
    return switch (currentStep) {
      OnboardingStep.welcome => 0.0,
      OnboardingStep.phoneNumber => 0.2,
      OnboardingStep.otp => 0.4,
      OnboardingStep.personalInfo => 0.6,
      OnboardingStep.pin => 0.8,
      OnboardingStep.complete => 1.0,
    };
  }

  bool get canGoNext {
    return switch (currentStep) {
      OnboardingStep.welcome => true,
      OnboardingStep.phoneNumber => phoneNumber != null && phoneNumber!.isNotEmpty,
      OnboardingStep.otp => otp != null && otp!.length == 6,
      OnboardingStep.personalInfo => firstName != null && lastName != null,
      OnboardingStep.pin => pin != null && pin!.length == 6,
      OnboardingStep.complete => false,
    };
  }

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    String? phoneNumber,
    String? countryCode,
    String? otp,
    String? firstName,
    String? lastName,
    String? pin,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      otp: otp ?? this.otp,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      pin: pin ?? this.pin,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier
class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  AuthService get _authService => ref.read(authServiceProvider);

  void goToStep(OnboardingStep step) {
    state = state.copyWith(currentStep: step, error: null);
  }

  void updatePhoneNumber(String phone, String countryCode) {
    state = state.copyWith(phoneNumber: phone, countryCode: countryCode);
  }

  Future<void> submitPhoneNumber() async {
    if (!state.canGoNext) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.register(
        phone: state.phoneNumber!,
        countryCode: state.countryCode!,
      );

      state = state.copyWith(
        isLoading: false,
        currentStep: OnboardingStep.otp,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateOtp(String otp) {
    state = state.copyWith(otp: otp);
  }

  Future<void> verifyOtp() async {
    if (!state.canGoNext) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.verifyOtp(
        phone: state.phoneNumber!,
        otp: state.otp!,
      );

      state = state.copyWith(
        isLoading: false,
        currentStep: OnboardingStep.personalInfo,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updatePersonalInfo(String firstName, String lastName) {
    state = state.copyWith(firstName: firstName, lastName: lastName);
  }

  void submitPersonalInfo() {
    if (!state.canGoNext) return;
    state = state.copyWith(currentStep: OnboardingStep.pin);
  }

  Future<void> submitPin(String pin) async {
    state = state.copyWith(pin: pin, isLoading: true, error: null);

    try {
      // Save PIN and complete onboarding
      await ref.read(pinServiceProvider).setPin(pin);

      state = state.copyWith(
        isLoading: false,
        currentStep: OnboardingStep.complete,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const OnboardingState();
  }
}

// Provider
final onboardingProvider = NotifierProvider.autoDispose<
  OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
```

---

## Additional Resources

- [Riverpod Documentation](https://riverpod.dev)
- [Flutter State Management Guide](https://docs.flutter.dev/development/data-and-backend/state-mgmt)
- [JoonaPay API Reference](../mobile/.claude/api-reference.md)
- [JoonaPay Testing Guide](./TESTING.md)

---

## Summary

### Key Takeaways

1. Use **Notifier** (not StateNotifier) for all new providers
2. Global state machines never auto-dispose
3. Feature-scoped providers use `.autoDispose`
4. Always use `copyWith()` for immutable updates
5. `ref.watch` in build, `ref.read` in callbacks
6. Handle loading, error, and empty states explicitly
7. Use optimistic updates for better UX
8. Implement TTL-based caching for FutureProviders
9. Test providers with `ProviderScope` overrides
10. Log state changes for debugging

### Provider Count: 46 files

Most providers follow consistent patterns documented here. When in doubt, copy an existing provider pattern.
