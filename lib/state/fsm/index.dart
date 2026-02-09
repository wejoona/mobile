/// FSM (Finite State Machine) State Management
///
/// This module provides a type-safe, predictable state management system
/// for the JoonaPay wallet app.
///
/// ## Architecture Overview
///
/// ```
/// ┌─────────────────────────────────────────────────────────────────┐
/// │                        APP FSM                                   │
/// │  (Orchestrates all sub-FSMs and determines navigation)          │
/// ├─────────────────────────────────────────────────────────────────┤
/// │                                                                  │
/// │  ┌──────────┐    ┌──────────┐    ┌──────────┐                  │
/// │  │ AUTH FSM │    │WALLET FSM│    │  KYC FSM │                  │
/// │  └──────────┘    └──────────┘    └──────────┘                  │
/// │                                                                  │
/// └─────────────────────────────────────────────────────────────────┘
/// ```
///
/// ## Key Concepts
///
/// ### States
/// Each FSM has explicit states that represent all possible conditions:
/// - `AuthUnauthenticated`, `AuthAuthenticated`, `AuthVerifying`, etc.
/// - `WalletNone`, `WalletReady`, `WalletCreating`, etc.
/// - `KycNone`, `KycVerified`, `KycPending`, etc.
///
/// ### Events
/// Events trigger state transitions:
/// - `AuthLogin`, `AuthVerifyOtp`, `AuthLogout`
/// - `WalletFetch`, `WalletCreate`, `WalletLoaded`
/// - `KycStart`, `KycSubmit`, `KycApproved`
///
/// ### Guards
/// Guards prevent invalid transitions:
/// - Cannot access home without authentication
/// - Cannot transact without wallet
/// - Cannot deposit/withdraw without KYC
///
/// ### Effects
/// Effects are side-effects triggered by transitions:
/// - `FetchEffect` - Fetch data from API
/// - `NavigateEffect` - Navigate to a route
/// - `ClearEffect` - Clear stored data
/// - `NotifyEffect` - Show notification
///
/// ## Usage
///
/// ```dart
/// // In your widget
/// final appState = ref.watch(appFsmProvider);
/// final fsm = ref.read(appFsmProvider.notifier);
///
/// // Check state
/// if (appState.isAuthenticated) {
///   // User is logged in
/// }
///
/// // Dispatch events
/// fsm.login(phone, countryCode);
/// fsm.verifyOtp(otp);
/// fsm.logout();
///
/// // Check guards
/// final canDeposit = appState.canDeposit;
/// ```
///
/// ## Benefits
///
/// 1. **Predictable**: Every possible state is explicit
/// 2. **Type-safe**: Invalid states are prevented at compile time
/// 3. **Testable**: FSM logic is pure and easily unit tested
/// 4. **Debuggable**: All transitions are logged
/// 5. **Stakeholder-friendly**: FSM diagrams are easy to discuss
library;

export 'fsm_base.dart';
export 'auth_fsm.dart';
export 'wallet_fsm.dart';
export 'kyc_fsm.dart';
export 'session_fsm.dart';
export 'app_fsm.dart';
export 'fsm_provider.dart';
