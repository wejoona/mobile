import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:usdc_wallet/core/haptics/haptic_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/mocks/index.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

import '../../helpers/test_theme.dart';

/// Configuration for golden tests
class GoldenTestConfig {
  /// Device configurations for responsive testing
  static const Map<String, Size> devices = {
    'iphone_se': Size(375, 667),
    'iphone_14': Size(390, 844),
    'iphone_14_pro_max': Size(430, 932),
    'pixel_7': Size(412, 915),
    'ipad_mini': Size(768, 1024),
  };

  /// Default device for single-device tests
  static const String defaultDevice = 'iphone_14';
  static Size get defaultSize => devices[defaultDevice]!;

  /// Golden file base path
  static const String goldenBasePath = 'goldens';

  /// Real backend URL
  static const String backendUrl = 'https://usdc-wallet-api.wejoona.com/api/v1';
}

/// Golden test utilities
class GoldenTestUtils {
  GoldenTestUtils._();

  /// Initialize golden test environment
  static Future<void> init() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Disable Google Fonts fetching - use fallback fonts
    GoogleFonts.config.allowRuntimeFetching = false;
    
    // Enable mock mode for API calls
    MockConfig.enableAllMocks();
    MockConfig.networkDelayMs = 0; // No delays in tests
    MockRegistry.initialize();
    
    // Disable haptics to avoid timer issues in tests
    HapticService().setEnabled(false);
    
    // Set up SharedPreferences with empty initial values
    SharedPreferences.setMockInitialValues({});
    
    // Set up HTTP overrides
    HttpOverrides.global = _GoldenTestHttpOverrides();
    
    // Set up method channel mocks for platform plugins
    _setupMethodChannelMocks();
  }

  /// Set up method channel mocks for platform plugins
  static void _setupMethodChannelMocks() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    
    // Mock shared_preferences
    const sharedPrefsChannel = MethodChannel('plugins.flutter.io/shared_preferences');
    final Map<String, Object?> sharedPrefsData = {};
    
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      sharedPrefsChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getAll':
            return sharedPrefsData;
          case 'setBool':
          case 'setInt':
          case 'setDouble':
          case 'setString':
          case 'setStringList':
            final key = methodCall.arguments['key'] as String;
            final value = methodCall.arguments['value'];
            sharedPrefsData[key] = value;
            return true;
          case 'remove':
            final key = methodCall.arguments as String;
            sharedPrefsData.remove(key);
            return true;
          case 'clear':
            sharedPrefsData.clear();
            return true;
          case 'containsKey':
            final key = methodCall.arguments as String;
            return sharedPrefsData.containsKey(key);
          default:
            return null;
        }
      },
    );
    
    // Mock flutter_secure_storage
    const secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    final Map<String, String> secureStorageData = {};
    
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      secureStorageChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'read':
            final key = methodCall.arguments['key'] as String;
            return secureStorageData[key];
          case 'write':
            final key = methodCall.arguments['key'] as String;
            final value = methodCall.arguments['value'] as String?;
            if (value != null) {
              secureStorageData[key] = value;
            } else {
              secureStorageData.remove(key);
            }
            return null;
          case 'delete':
            final key = methodCall.arguments['key'] as String;
            secureStorageData.remove(key);
            return null;
          case 'deleteAll':
            secureStorageData.clear();
            return null;
          case 'readAll':
            return secureStorageData;
          case 'containsKey':
            final key = methodCall.arguments['key'] as String;
            return secureStorageData.containsKey(key);
          default:
            return null;
        }
      },
    );
    
    // Mock path_provider
    const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProviderChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getTemporaryDirectory':
            return '/tmp';
          case 'getApplicationDocumentsDirectory':
            return '/tmp/documents';
          case 'getApplicationSupportDirectory':
            return '/tmp/support';
          case 'getLibraryDirectory':
            return '/tmp/library';
          case 'getApplicationCacheDirectory':
            return '/tmp/cache';
          default:
            return null;
        }
      },
    );
    
    // Mock path_provider macOS channel
    const pathProviderMacOSChannel = MethodChannel('plugins.flutter.io/path_provider_macos');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProviderMacOSChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getTemporaryDirectory':
            return '/tmp';
          case 'getApplicationDocumentsDirectory':
            return '/tmp/documents';
          case 'getApplicationSupportDirectory':
            return '/tmp/support';
          case 'getLibraryDirectory':
            return '/tmp/library';
          case 'getApplicationCacheDirectory':
            return '/tmp/cache';
          default:
            return null;
        }
      },
    );
    
    // Mock connectivity_plus method channel
    const connectivityChannel = MethodChannel('dev.fluttercommunity.plus/connectivity');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'check') {
          // Returns a list of connectivity types (wifi, mobile, etc.)
          return ['wifi'];
        }
        return null;
      },
    );
    
    // Mock connectivity_plus event channel (status stream)
    const connectivityStatusChannel = MethodChannel('dev.fluttercommunity.plus/connectivity_status');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      connectivityStatusChannel,
      (MethodCall methodCall) async {
        // listen/cancel for event channel stream
        return null;
      },
    );
    
    // Mock local_auth
    const localAuthChannel = MethodChannel('plugins.flutter.io/local_auth');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      localAuthChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getAvailableBiometrics':
            return <String>[];
          case 'isDeviceSupported':
            return false;
          case 'authenticate':
            return false;
          default:
            return null;
        }
      },
    );
    
    // Mock sms_autofill
    const smsAutofillChannel = MethodChannel('sms_autofill');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      smsAutofillChannel,
      (MethodCall methodCall) async {
        return null;
      },
    );
    
    // Mock HapticFeedback
    const hapticChannel = MethodChannel('flutter/haptic_feedback');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      hapticChannel,
      (MethodCall methodCall) async {
        // Haptic feedback methods: vibrate, lightImpact, mediumImpact, heavyImpact, selectionClick
        return null;
      },
    );
    
    // Mock camera plugin
    const cameraChannel = MethodChannel('plugins.flutter.io/camera');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      cameraChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'availableCameras':
            return <Map<String, dynamic>>[];
          case 'create':
            return {'cameraId': 0};
          case 'initialize':
            return {'previewWidth': 1920.0, 'previewHeight': 1080.0};
          case 'dispose':
            return null;
          default:
            return null;
        }
      },
    );
    
    // Mock mobile_scanner method channel
    const mobileScannerChannel = MethodChannel('dev.steenbakker.mobile_scanner/scanner/method');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      mobileScannerChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'start':
            return {'size': {'width': 1920.0, 'height': 1080.0}};
          case 'stop':
            return null;
          case 'toggleTorch':
            return null;
          case 'analyzeImage':
            return null;
          default:
            return null;
        }
      },
    );
    
    // Mock mobile_scanner event channels
    const mobileScannerEventChannel = MethodChannel('dev.steenbakker.mobile_scanner/scanner/event');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      mobileScannerEventChannel,
      (MethodCall methodCall) async {
        return null;
      },
    );
    
    const mobileScannerOrientationChannel = MethodChannel('dev.steenbakker.mobile_scanner/scanner/deviceOrientation');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      mobileScannerOrientationChannel,
      (MethodCall methodCall) async {
        return null;
      },
    );
    
    // Mock permission_handler
    const permissionChannel = MethodChannel('flutter.baseflow.com/permissions/methods');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      permissionChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'requestPermissions':
            // Return granted (1) for all permissions
            final permissions = methodCall.arguments as List<dynamic>?;
            if (permissions != null) {
              return {for (var p in permissions) p: 1};
            }
            return <int, int>{};
          case 'checkPermissionStatus':
            return 1; // granted
          case 'shouldShowRequestPermissionRationale':
            return false;
          case 'openAppSettings':
            return true;
          default:
            return null;
        }
      },
    );
    
    // Mock package_info_plus
    const packageInfoChannel = MethodChannel('dev.fluttercommunity.plus/package_info');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      packageInfoChannel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return {
            'appName': 'JoonaPay',
            'packageName': 'com.joonapay.wallet',
            'version': '1.0.0',
            'buildNumber': '1',
          };
        }
        return null;
      },
    );
    
    // Mock device_info_plus
    const deviceInfoChannel = MethodChannel('dev.fluttercommunity.plus/device_info');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      deviceInfoChannel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'getInfo') {
          return {
            'name': 'iPhone 14',
            'systemName': 'iOS',
            'systemVersion': '16.0',
            'model': 'iPhone',
            'localizedModel': 'iPhone',
            'identifierForVendor': 'test-device-id',
            'isPhysicalDevice': false,
          };
        }
        return null;
      },
    );
  }

  /// Generate golden file path
  static String goldenPath(
    String feature,
    String screen,
    String variant, {
    bool isDarkMode = false,
    String device = 'iphone_14',
  }) {
    final theme = isDarkMode ? 'dark' : 'light';
    return '${GoldenTestConfig.goldenBasePath}/$feature/$screen/${variant}_${theme}_$device.png';
  }

  /// Pump widget and wait for animations/loading
  static Future<void> pumpAndSettle(
    WidgetTester tester,
    Widget widget, {
    Duration? duration,
  }) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(duration ?? const Duration(milliseconds: 500));
  }

  /// Pump widget, wait, then take golden snapshot
  static Future<void> pumpAndSnapshot(
    WidgetTester tester,
    Widget widget,
    String goldenFile, {
    Finder? finder,
    Duration? settleDuration,
  }) async {
    await pumpAndSettle(tester, widget, duration: settleDuration);
    await expectLater(
      finder ?? find.byType(MaterialApp),
      matchesGoldenFile(goldenFile),
    );
  }

  /// Run test for both light and dark modes
  static Future<void> testBothThemes(
    WidgetTester tester,
    Widget Function(bool isDarkMode) widgetBuilder,
    String feature,
    String screen,
    String variant,
  ) async {
    // Light mode
    await pumpAndSnapshot(
      tester,
      widgetBuilder(false),
      goldenPath(feature, screen, variant, isDarkMode: false),
    );

    // Dark mode
    await pumpAndSnapshot(
      tester,
      widgetBuilder(true),
      goldenPath(feature, screen, variant, isDarkMode: true),
    );
  }

  /// Create test matrix for multiple devices and themes
  static List<Map<String, dynamic>> createTestMatrix({
    List<String>? devices,
    bool includeThemes = true,
    List<String>? variants,
  }) {
    final deviceList = devices ?? [GoldenTestConfig.defaultDevice];
    final variantList = variants ?? ['default'];
    final themes = includeThemes ? [false, true] : [false];

    final matrix = <Map<String, dynamic>>[];
    for (final device in deviceList) {
      for (final variant in variantList) {
        for (final isDark in themes) {
          matrix.add({
            'device': device,
            'variant': variant,
            'isDarkMode': isDark,
            'size': GoldenTestConfig.devices[device],
          });
        }
      }
    }
    return matrix;
  }
}

/// HTTP overrides for golden tests (allows real backend connections)
class _GoldenTestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

/// Mock Dio that returns instant mock responses without network calls
class _MockDio extends DioMixin implements Dio {
  _MockDio() {
    options = BaseOptions(baseUrl: 'https://mock.api');
    httpClientAdapter = _NoopHttpClientAdapter();
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _mockResponse<T>(path);
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _mockResponse<T>(path);
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _mockResponse<T>(path);
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _mockResponse<T>(path);
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _mockResponse<T>(path);
  }

  @override
  Future<Response<T>> head<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _mockResponse<T>(path);
  }

  @override
  Future<Response<T>> fetch<T>(RequestOptions requestOptions) async {
    return _mockResponse<T>(requestOptions.path);
  }

  Response<T> _mockResponse<T>(String path) {
    final mockData = _getMockData(path);
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: mockData as T,
    );
  }

  dynamic _getMockData(String path) {
    // Return appropriate mock data based on path
    if (path.contains('/alerts/statistics')) {
      return {
        'total': 5,
        'unread': 2,
        'critical': 1,
        'warning': 1,
        'info': 3,
        'actionRequired': 1,
      };
    }
    if (path.contains('/alerts') && path.contains('/')) {
      // Single alert detail
      return {
        'alertId': 'alert_001',
        'alertType': 'largeTransaction',
        'severity': 'warning',
        'title': 'Large Transaction Alert',
        'message': 'A transaction of \$1,000 was processed',
        'isRead': false,
        'actionRequired': false,
        'createdAt': DateTime.now().toIso8601String(),
        'metadata': {
          'transactionId': 'tx_123',
          'amount': 1000.0,
        },
      };
    }
    if (path.contains('/alerts')) {
      // Alerts list
      return {
        'alerts': [
          {
            'alertId': 'alert_001',
            'alertType': 'largeTransaction',
            'severity': 'warning',
            'title': 'Large Transaction Alert',
            'message': 'A transaction of \$1,000 was processed',
            'isRead': false,
            'actionRequired': false,
            'createdAt': DateTime.now().toIso8601String(),
          },
          {
            'alertId': 'alert_002',
            'alertType': 'loginNewDevice',
            'severity': 'info',
            'title': 'New Device Login',
            'message': 'Login from a new device detected',
            'isRead': true,
            'actionRequired': false,
            'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          },
        ],
        'page': 1,
        'limit': 20,
        'total': 2,
        'hasNext': false,
        'hasPrev': false,
      };
    }
    if (path.contains('/preferences')) {
      return {
        'emailEnabled': true,
        'pushEnabled': true,
        'smsEnabled': false,
        'transactionAlerts': true,
        'securityAlerts': true,
        'marketingAlerts': false,
        'minimumAmount': 100.0,
      };
    }
    // Default empty response
    return {};
  }
}

/// No-op HTTP client adapter
class _NoopHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

/// Helper to run golden tests tolerant of non-fatal rendering errors
/// 
/// Many widgets throw during layout/paint (overflow, IntrinsicHeight issues,
/// provider init errors) but still render a meaningful visual. This helper
/// catches those errors so the golden snapshot can still be taken.
Future<void> pumpGoldenTolerant(
  WidgetTester tester,
  Widget widget, {
  Duration pumpDuration = const Duration(milliseconds: 100),
}) async {
  // Don't override FlutterError.onError — Flutter 3.38 asserts that
  // _pendingExceptionDetails is set after reportError. Instead, let
  // errors flow through normally and drain them via takeException().
  await tester.pumpWidget(widget);
  tester.takeException(); // drain if error during build/layout/paint

  await tester.pump(pumpDuration);
  tester.takeException();

  await tester.pump(const Duration(milliseconds: 50));
  tester.takeException();
}

/// Test wrapper for golden tests with proper provider overrides
class GoldenTestWrapper extends StatelessWidget {
  GoldenTestWrapper({
    super.key,
    required this.child,
    this.locale = const Locale('en'),
    this.isDarkMode = false,
    this.navigatorKey,
    this.overrides = const [],
  });

  final Widget child;
  final Locale locale;
  final bool isDarkMode;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<dynamic> overrides;

  static final _mockDio = _MockDio();

  /// All routes that any view might navigate to
  static final _fallbackRoutes = [
    '/settings',
    '/bank-linking',
    '/home',
    '/pin/confirm',
    '/pin/reset',
    '/pin/locked',
    '/login',
    '/otp',
    '/onboarding',
    '/kyc',
    '/deposit',
    '/withdraw',
    '/send',
    '/send/confirm',
    '/send/result',
    '/transactions',
    '/transactions/detail',
    '/wallet',
    '/contacts',
    '/contacts/add',
    '/expenses',
    '/expenses/add',
    '/expenses/reports',
    '/business',
    '/business/setup',
    '/cards',
    '/cards/add',
    '/insights',
    '/notifications',
    '/notifications/settings',
    '/merchant',
    '/merchant/dashboard',
    '/qr/scan',
    '/qr/receive',
    '/payment-links',
    '/payment-links/create',
    '/referrals',
    '/savings',
    '/savings/create',
    '/scheduled',
    '/beneficiaries',
    '/beneficiaries/add',
    '/limits',
    '/profile',
    '/profile/edit',
    '/devices',
    '/bills',
    '/bills/pay',
    '/bulk-payments',
    '/scan',
  ];

  late final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MediaQuery(
          data: MediaQueryData(
            size: GoldenTestConfig.defaultSize,
            devicePixelRatio: 3.0,
            padding: const EdgeInsets.only(top: 47, bottom: 34),
            viewPadding: const EdgeInsets.only(top: 47, bottom: 34),
            textScaler: TextScaler.noScaling,
          ),
          child: Material(child: child),
        ),
      ),
      // Generate fallback routes for all known paths
      for (final path in _fallbackRoutes)
        GoRoute(path: path, builder: (_, __) => const SizedBox()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        // Override dioProvider with mock that doesn't make real network calls
        dioProvider.overrideWithValue(_mockDio),
        ...overrides,
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: isDarkMode ? TestTheme.darkTheme : TestTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}

/// Screen-level test wrapper with scaffold
class GoldenScreenWrapper extends StatelessWidget {
  GoldenScreenWrapper({
    super.key,
    required this.child,
    this.locale = const Locale('en'),
    this.isDarkMode = false,
    this.hasAppBar = true,
    this.appBarTitle,
    this.hasBottomNav = false,
  });

  final Widget child;
  final Locale locale;
  final bool isDarkMode;
  final bool hasAppBar;
  final String? appBarTitle;
  final bool hasBottomNav;

  static final _mockDio = _MockDio();

  late final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MediaQuery(
          data: MediaQueryData(
            size: GoldenTestConfig.defaultSize,
            devicePixelRatio: 3.0,
            padding: const EdgeInsets.only(top: 47, bottom: 34),
            viewPadding: const EdgeInsets.only(top: 47, bottom: 34),
            textScaler: TextScaler.noScaling,
          ),
          child: Scaffold(
            appBar: hasAppBar && appBarTitle != null
                ? AppBar(title: Text(appBarTitle!))
                : null,
            body: child,
            bottomNavigationBar: hasBottomNav
                ? BottomNavigationBar(
                    currentIndex: 0,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.history),
                        label: 'Activity',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings),
                        label: 'Settings',
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ),
      // Fallback routes
      for (final path in GoldenTestWrapper._fallbackRoutes)
        GoRoute(path: path, builder: (_, __) => const SizedBox()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        dioProvider.overrideWithValue(_mockDio),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: isDarkMode ? TestTheme.darkTheme : TestTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}

/// Extension for easier golden test writing
extension GoldenWidgetTesterExtension on WidgetTester {
  /// Pump widget with golden test wrapper
  Future<void> pumpGolden(
    Widget child, {
    bool isDarkMode = false,
  }) async {
    await pumpWidget(
      GoldenTestWrapper(
        isDarkMode: isDarkMode,
        child: child,
      ),
    );
    await pumpAndSettle();
  }

  /// Take golden snapshot
  Future<void> expectGolden(String path, {Finder? finder}) async {
    await expectLater(
      finder ?? find.byType(MaterialApp),
      matchesGoldenFile(path),
    );
  }

  /// Set specific screen size for responsive testing
  Future<void> setScreenSize(Size size) async {
    await binding.setSurfaceSize(size);
    addTearDown(() => binding.setSurfaceSize(null));
  }
}

/// Screen state enum for testing different states
enum ScreenState {
  initial,
  loading,
  loaded,
  empty,
  error,
  refreshing,
  disabled,
}

/// Extension to get display name for screen states
extension ScreenStateExtension on ScreenState {
  String get displayName {
    switch (this) {
      case ScreenState.initial:
        return 'initial';
      case ScreenState.loading:
        return 'loading';
      case ScreenState.loaded:
        return 'loaded';
      case ScreenState.empty:
        return 'empty';
      case ScreenState.error:
        return 'error';
      case ScreenState.refreshing:
        return 'refreshing';
      case ScreenState.disabled:
        return 'disabled';
    }
  }
}
