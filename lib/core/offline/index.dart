/// Offline-First Module
///
/// Provides offline functionality including:
/// - Offline banner showing connectivity status
/// - Automatic retry logic for failed operations
/// - Offline indicators and badges
///
/// Usage:
/// ```dart
/// // Show offline banner at top of screen
/// Scaffold(
///   body: Column(
///     children: [
///       const OfflineBanner(),
///       Expanded(child: YourContent()),
///     ],
///   ),
/// )
///
/// // Use retry service for API calls
/// final retryService = ref.read(retryServiceProvider);
/// final result = await retryService.execute(
///   operation: () => sdk.wallet.getBalance(),
///   config: RetryConfig.api,
/// );
///
/// // Or use extension method
/// final balance = await sdk.wallet.getBalance().withRetry(ref);
/// ```

export 'package:usdc_wallet/core/offline/offline_banner.dart';
export 'package:usdc_wallet/core/offline/retry_service.dart';
