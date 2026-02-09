// ignore_for_file: undefined_identifier, argument_type_not_assignable, non_bool_condition, undefined_class, avoid_dynamic_calls, avoid_print
/// Example Integration
///
/// This file demonstrates how to integrate offline-first features
/// into existing screens and services.
///
/// DO NOT import this file in production code.
/// Use it as a reference for implementation patterns.

// ignore_for_file: unused_local_variable, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import '../../design/tokens/index.dart';
import '../../design/components/primitives/index.dart';
import 'index.dart';

// ============================================================================
// Example 1: Adding Offline Banner to Wallet Screen
// ============================================================================

class WalletViewWithOffline extends ConsumerWidget {
  const WalletViewWithOffline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Column(
        children: [
          // Add offline banner at the top
          const OfflineBanner(),

          // Your existing content
          Expanded(
            child: SafeArea(
              top: false, // Banner handles safe area
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _buildHeader(l10n),
                    SizedBox(height: AppSpacing.xl),
                    _buildBalanceCard(l10n, ref),
                    // ... rest of content
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.navigation_home,
          style: AppTypography.headlineMedium,
        ),
        // Add compact offline indicator in header
        const OfflineIndicator(),
      ],
    );
  }

  Widget _buildBalanceCard(AppLocalizations l10n, WidgetRef ref) {
    return AppCard(
      child: Column(
        children: [
          Text('Balance', style: AppTypography.bodyMedium),
          SizedBox(height: AppSpacing.sm),
          Text('\$1,234.56', style: AppTypography.headlineLarge),
        ],
      ),
    );
  }
}

// ============================================================================
// Example 2: Service with Retry Logic
// ============================================================================

class WalletState {
  final double? balance;
  final bool isLoading;
  final bool isCached;
  final String? error;

  const WalletState({
    this.balance,
    this.isLoading = false,
    this.isCached = false,
    this.error,
  });

  WalletState copyWith({
    double? balance,
    bool? isLoading,
    bool? isCached,
    String? error,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      isLoading: isLoading ?? this.isLoading,
      isCached: isCached ?? this.isCached,
      error: error,
    );
  }
}

class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() => const WalletState();

  /// Load balance with automatic retry
  Future<void> loadBalance() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final retryService = ref.read(retryServiceProvider);

      // Method 1: Execute with result
      final result = await retryService.execute<double>(
        operation: () async {
          // Simulate API call
          await Future.delayed(const Duration(seconds: 1));
          return 1234.56;
        },
        config: RetryConfig.api,
      );

      if (result.success) {
        state = state.copyWith(
          balance: result.data,
          isLoading: false,
          isCached: false,
        );
      } else {
        // Try loading from cache
        await _loadFromCache();
      }
    } catch (e) {
      await _loadFromCache();
    }
  }

  /// Load balance with extension method (simpler)
  Future<void> loadBalanceWithExtension() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final balance = await _fetchBalance().withRetry(
        ref,
        config: RetryConfig.api,
      );

      state = state.copyWith(
        balance: balance,
        isLoading: false,
        isCached: false,
      );
    } catch (e) {
      await _loadFromCache();
    }
  }

  Future<double> _fetchBalance() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return 1234.56;
  }

  Future<void> _loadFromCache() async {
    // Try loading from offline cache
    try {
      // final offlineManager = await ref.read(offlineModeManagerFutureProvider.future);
      // final cached = await offlineManager.getBalance();

      // Simulate cached data
      final cached = (data: 1234.56, isCached: true);

      state = state.copyWith(
        balance: cached.data,
        isLoading: false,
        isCached: cached.isCached,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load balance',
      );
    }
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletState>(
  WalletNotifier.new,
);

// ============================================================================
// Example 3: Transfer with Auto Retry Queue
// ============================================================================

class TransferNotifier extends Notifier<void> {
  @override
  void build() {}

  /// Send transfer with automatic retry
  Future<void> sendTransfer({
    required String recipientPhone,
    required double amount,
    String? description,
  }) async {
    final queue = ref.read(autoRetryQueueProvider);
    final transferId = DateTime.now().millisecondsSinceEpoch.toString();

    // Add to retry queue
    queue.enqueue(
      id: 'transfer_$transferId',
      operation: () => _performTransfer(
        recipientPhone: recipientPhone,
        amount: amount,
        description: description,
      ),
      config: RetryConfig.critical, // Critical operation - 5 attempts
      onSuccess: () {
        _showSuccessMessage('Transfer completed successfully!');
      },
      onFailure: (error) {
        _showErrorMessage('Transfer failed: $error');
      },
    );
  }

  Future<void> _performTransfer({
    required String recipientPhone,
    required double amount,
    String? description,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Simulate random failure for demo
    if (DateTime.now().second % 2 == 0) {
      throw Exception('Network error');
    }
  }

  void _showSuccessMessage(String message) {
    // Show success toast/snackbar
  }

  void _showErrorMessage(String message) {
    // Show error toast/snackbar
  }
}

// ============================================================================
// Example 4: Transaction List with Offline Badges
// ============================================================================

class TransactionListWithBadges extends ConsumerWidget {
  const TransactionListWithBadges({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = [
      {'title': 'Sent to John', 'amount': '-\$50', 'pending': false},
      {'title': 'Sent to Alice', 'amount': '-\$25', 'pending': true},
      {'title': 'Received from Bob', 'amount': '+\$100', 'pending': false},
    ];

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isPending = tx['pending'] as bool;

        return ListTile(
          title: Row(
            children: [
              Text(tx['title'] as String),
              if (isPending) ...[
                SizedBox(width: AppSpacing.sm),
                const OfflineBadge(), // Show "Queued" badge
              ],
            ],
          ),
          subtitle: Text(isPending ? 'Pending' : 'Completed'),
          trailing: Text(
            tx['amount'] as String,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }
}

// ============================================================================
// Example 5: Settings with Pending Operations Count
// ============================================================================

class SettingsViewWithPending extends ConsumerWidget {
  const SettingsViewWithPending({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pendingCount = ref.watch(pendingCountProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(l10n.navigation_settings),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.lg),
        children: [
          // Show pending operations section if any
          if (pendingCount > 0) ...[
            _buildPendingSection(l10n, ref, pendingCount),
            SizedBox(height: AppSpacing.xl),
          ],

          // Regular settings items
          _buildSettingsItem(
            icon: Icons.person,
            title: 'Profile',
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: Icons.security,
            title: 'Security',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSection(
    AppLocalizations l10n,
    WidgetRef ref,
    int count,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sync, color: AppColors.warningText, size: 20),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Pending Operations',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningBase.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: AppColors.warningText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'These operations will be processed when you\'re back online.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'View Details',
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.small,
            onPressed: () {
              // Navigate to pending operations screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.gold500),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// ============================================================================
// Example 6: Custom Retry Configuration
// ============================================================================

class CustomRetryExample {
  Future<void> exampleWithCustomConfig(WidgetRef ref) async {
    // Create custom retry config
    final customConfig = RetryConfig(
      maxAttempts: 5,
      strategy: RetryStrategy.exponential,
      initialDelaySeconds: 2,
      maxDelaySeconds: 60,
      requiresOnline: true,
    );

    // Use with retry service
    final retryService = ref.read(retryServiceProvider);

    final result = await retryService.execute(
      operation: () => _criticalOperation(),
      config: customConfig,
    );

    if (result.success) {
      print('Success after ${result.attempts} attempts');
    } else {
      print('Failed: ${result.error}');
    }
  }

  Future<String> _criticalOperation() async {
    await Future.delayed(const Duration(seconds: 1));
    return 'Success';
  }

  // Different strategies for different scenarios
  Future<void> demonstrateStrategies(WidgetRef ref) async {
    // Quick user action - immediate retry
    await _quickAction().withRetry(ref, config: RetryConfig.immediate);

    // Standard API call - exponential backoff
    await _apiCall().withRetry(ref, config: RetryConfig.api);

    // Critical transfer - aggressive retry
    await _transfer().withRetry(ref, config: RetryConfig.critical);

    // Background sync - fixed intervals
    await _backgroundSync().withRetry(ref, config: RetryConfig.background);
  }

  Future<void> _quickAction() async {}
  Future<void> _apiCall() async {}
  Future<void> _transfer() async {}
  Future<void> _backgroundSync() async {}
}
