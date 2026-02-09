/// Error Handling System
///
/// Comprehensive error handling with boundaries, reporting, and user feedback
///
/// ## Quick Start
///
/// 1. Wrap app with RootErrorBoundary in main.dart:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///
///   runApp(
///     ProviderScope(
///       child: RootErrorBoundary(
///         child: MyApp(),
///       ),
///     ),
///   );
/// }
/// ```
///
/// 2. Wrap features with ErrorBoundary:
/// ```dart
/// ErrorBoundary(
///   errorContext: 'WalletScreen',
///   child: WalletView(),
/// )
/// ```
///
/// 3. Use ErrorHandlerMixin in widgets:
/// ```dart
/// class MyWidgetState extends ConsumerState<MyWidget> with ErrorHandlerMixin {
///   Future<void> _loadData() async {
///     await handleAsyncError(() async {
///       final data = await api.fetchData();
///       setState(() => _data = data);
///     });
///   }
/// }
/// ```
///
/// ## Components
///
/// - [ErrorBoundary] - Catches widget tree errors
/// - [RootErrorBoundary] - Root-level error boundary
/// - [AsyncErrorBoundary] - For FutureBuilder errors
/// - [ErrorReporter] - Crashlytics reporting
/// - [ErrorHandlerMixin] - Widget error handling
/// - [NotifierErrorHandler] - Notifier error handling
///
/// ## Error Types
///
/// - [NetworkError] - Network/API errors
/// - [AuthError] - Authentication errors
/// - [ValidationError] - Input validation errors
/// - [BusinessError] - Business logic errors
/// - [StorageError] - Storage errors
/// - [BiometricError] - Biometric errors
/// - [MediaError] - Camera/media errors
/// - [QRCodeError] - QR code errors
///
/// ## UI Components
///
/// - [ErrorFallbackUI] - Full-screen error display
/// - [CompactErrorWidget] - Inline error display
/// - [EmptyStateErrorWidget] - Empty state with error
/// - [SnackbarError] - Transient error notification

// Core error handling
export 'error_boundary.dart';
export 'error_reporter.dart';
export 'error_types.dart';
export 'error_fallback_ui.dart';
export 'error_handler_mixin.dart';
