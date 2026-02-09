// ignore_for_file: avoid_dynamic_calls, avoid_print, undefined_getter
/// Example integration of widget auto-updater in main app
///
/// This file shows how to integrate the widget auto-updater
/// into your existing JoonaPay app.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widget_update_manager.dart';

/// STEP 1: Initialize Widget Auto-Updater in Main App
///
/// Add to your main app widget (e.g., lib/main.dart)
class AppWithWidgetSupport extends ConsumerWidget {
  const AppWithWidgetSupport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize widget auto-updater
    // This watches wallet and user state and updates widgets automatically
    ref.watch(widgetAutoUpdaterProvider);

    return MaterialApp(
      // Your existing app configuration
      title: 'JoonaPay',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

/// STEP 2: Clear Widget Data on Logout
///
/// Add to your logout handler (e.g., lib/features/auth/providers/auth_provider.dart)
class AuthNotifierExample extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.initial();

  Future<void> logout() async {
    // Clear widget data BEFORE clearing auth state
    await ref.read(widgetUpdateManagerProvider).clearWidgetData();

    // Continue with logout
    state = const AuthState.loggedOut();

    // Clear other state
    ref.invalidate(walletStateMachineProvider);
    ref.invalidate(userStateMachineProvider);
  }
}

/// STEP 3: Manual Widget Updates (Optional)
///
/// If you need to trigger widget updates manually
/// (Auto-updater handles most cases)
class ManualWidgetUpdateExample {
  void updateWidgetAfterTransaction(WidgetRef ref) async {
    final widgetManager = ref.read(widgetUpdateManagerProvider);
    final walletState = ref.read(walletStateMachineProvider);
    final userState = ref.read(userStateMachineProvider);

    // Update balance
    await widgetManager.updateFromState(
      balance: walletState.usdcBalance,
      currency: 'USD',
      userName: _getUserName(userState),
    );

    // Update last transaction
    await widgetManager.updateLastTransaction(
      type: 'send',
      amount: 50.0,
      currency: 'USD',
      status: 'completed',
      recipientName: 'Fatou Traore',
    );
  }

  String? _getUserName(UserState userState) {
    if (userState.profile?.firstName != null &&
        userState.profile?.lastName != null) {
      return '${userState.profile!.firstName} ${userState.profile!.lastName}';
    }
    return userState.profile?.firstName;
  }
}

/// STEP 4: Update After Successful Transaction
///
/// Add to your transaction completion handler
class TransactionCompletionExample {
  Future<void> onTransactionComplete(
    WidgetRef ref,
    Transaction transaction,
  ) async {
    // Refresh wallet state (this will auto-update widget via auto-updater)
    await ref.read(walletStateMachineProvider.notifier).refresh();

    // Optionally update transaction info
    final widgetManager = ref.read(widgetUpdateManagerProvider);
    await widgetManager.updateLastTransaction(
      type: transaction.type,
      amount: transaction.amount,
      currency: transaction.currency,
      status: transaction.status,
      recipientName: transaction.recipientName,
    );
  }
}

/// STEP 5: Update on App Foreground (Optional)
///
/// Refresh widget when app comes to foreground
class AppLifecycleExample extends ConsumerStatefulWidget {
  const AppLifecycleExample({super.key});

  @override
  ConsumerState<AppLifecycleExample> createState() =>
      _AppLifecycleExampleState();
}

class _AppLifecycleExampleState extends ConsumerState<AppLifecycleExample>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - refresh wallet
      // This will auto-update widget via auto-updater
      ref.read(walletStateMachineProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Your widget
  }
}

/// STEP 6: Handle Deep Links from Widget
///
/// Add to your app router (e.g., lib/router/app_router.dart)
class DeepLinkHandlerExample {
  static void handleDeepLink(String deepLink) {
    // Widget deep links:
    // - joonapay://home      -> Home screen
    // - joonapay://send      -> Send flow
    // - joonapay://receive   -> Receive QR

    // Implement in your router
    if (deepLink == 'joonapay://send') {
      // Navigate to send screen
      // context.push('/send');
    } else if (deepLink == 'joonapay://receive') {
      // Navigate to receive screen
      // context.push('/receive');
    }
  }
}

/// Example: Complete integration in main.dart
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:flutter_riverpod/flutter_riverpod.dart';
/// import 'services/widget_data/widget_update_manager.dart';
/// import 'router/app_router.dart';
///
/// void main() {
///   runApp(
///     ProviderScope(
///       child: const MyApp(),
///     ),
///   );
/// }
///
/// class MyApp extends ConsumerWidget {
///   const MyApp({super.key});
///
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Initialize widget auto-updater
///     ref.watch(widgetAutoUpdaterProvider);
///
///     return MaterialApp.router(
///       title: 'JoonaPay',
///       routerConfig: appRouter,
///       theme: ThemeData.dark(),
///     );
///   }
/// }
/// ```

/// Example: Logout with widget cleanup
///
/// ```dart
/// Future<void> logout() async {
///   // 1. Clear widget data
///   await ref.read(widgetUpdateManagerProvider).clearWidgetData();
///
///   // 2. Clear auth state
///   await ref.read(authProvider.notifier).logout();
///
///   // 3. Clear other state
///   ref.invalidate(walletStateMachineProvider);
///   ref.invalidate(userStateMachineProvider);
///
///   // 4. Navigate to login
///   context.go('/login');
/// }
/// ```

// Placeholder types for example
class AuthState {
  const AuthState.initial();
  const AuthState.loggedOut();
}

class Transaction {
  final String type;
  final double amount;
  final String currency;
  final String status;
  final String? recipientName;

  Transaction({
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    this.recipientName,
  });
}

class UserState {
  final UserProfile? profile;
  const UserState({this.profile});
}

class UserProfile {
  final String? firstName;
  final String? lastName;
  const UserProfile({this.firstName, this.lastName});
}

// Import placeholders - replace with actual imports
final walletStateMachineProvider = Provider((ref) => WalletState());
final userStateMachineProvider = Provider((ref) => UserState());

class WalletState {
  final double usdcBalance;
  WalletState({this.usdcBalance = 0});
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Container();
}
