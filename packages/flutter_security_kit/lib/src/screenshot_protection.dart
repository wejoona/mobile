import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'security_config.dart';

/// Screenshot Protection Service
///
/// Prevents screenshots and screen recording on sensitive screens.
///
/// ## Usage
///
/// ```dart
/// final protection = ScreenshotProtection();
///
/// // Enable protection for current screen
/// await protection.enable();
///
/// // Disable when leaving sensitive screen
/// await protection.disable();
///
/// // Use with widget lifecycle
/// @override
/// void initState() {
///   super.initState();
///   ScreenshotProtection().enable();
/// }
///
/// @override
/// void dispose() {
///   ScreenshotProtection().disable();
///   super.dispose();
/// }
/// ```
///
/// ## Widget Mixin
///
/// For easier integration, use the [ScreenshotProtectedState] mixin:
///
/// ```dart
/// class _MySecureScreenState extends State<MySecureScreen>
///     with ScreenshotProtectedState {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(...);
///   }
/// }
/// ```
class ScreenshotProtection {
  static final ScreenshotProtection _instance = ScreenshotProtection._internal();
  factory ScreenshotProtection() => _instance;
  ScreenshotProtection._internal();

  /// Method channel for native screenshot protection.
  MethodChannel? _channel;

  /// Whether protection is currently enabled.
  bool _isEnabled = false;

  /// Reference count for nested protection requests.
  int _refCount = 0;

  /// Set the method channel for screenshot protection.
  void setChannel(MethodChannel channel) {
    _channel = channel;
  }

  /// Default channel name if using automatic setup.
  static const String defaultChannelName =
      'flutter_security_kit/screenshot_protection';

  /// Whether screenshot protection is currently enabled.
  bool get isEnabled => _isEnabled;

  /// Enable screenshot protection.
  ///
  /// Uses reference counting - call [disable] the same number of times.
  Future<bool> enable() async {
    _refCount++;

    if (_isEnabled) {
      _log('Protection already enabled (refCount: $_refCount)');
      return true;
    }

    // Skip in debug mode if configured
    if (!SecurityConfig.shouldPerformChecks) {
      _log('Protection skipped (debug mode)');
      _isEnabled = true;
      return true;
    }

    try {
      if (Platform.isAndroid) {
        return await _enableAndroid();
      } else if (Platform.isIOS) {
        return await _enableiOS();
      }
      return false;
    } catch (e) {
      _log('Failed to enable protection: $e');
      return false;
    }
  }

  /// Disable screenshot protection.
  ///
  /// Only actually disables when refCount reaches 0.
  Future<bool> disable() async {
    if (_refCount > 0) {
      _refCount--;
    }

    if (_refCount > 0) {
      _log('Protection still needed (refCount: $_refCount)');
      return true;
    }

    if (!_isEnabled) {
      return true;
    }

    try {
      if (Platform.isAndroid) {
        return await _disableAndroid();
      } else if (Platform.isIOS) {
        return await _disableiOS();
      }
      return false;
    } catch (e) {
      _log('Failed to disable protection: $e');
      return false;
    }
  }

  /// Force disable protection (ignores refCount).
  Future<bool> forceDisable() async {
    _refCount = 0;
    _isEnabled = false;

    try {
      if (Platform.isAndroid) {
        return await _disableAndroid();
      } else if (Platform.isIOS) {
        return await _disableiOS();
      }
      return false;
    } catch (e) {
      _log('Failed to force disable protection: $e');
      return false;
    }
  }

  /// Android: Uses FLAG_SECURE window flag.
  Future<bool> _enableAndroid() async {
    if (_channel != null) {
      try {
        await _channel!.invokeMethod('enableSecureFlag');
        _isEnabled = true;
        _log('Android FLAG_SECURE enabled');
        return true;
      } on PlatformException catch (e) {
        _log('Failed to enable FLAG_SECURE: ${e.message}');
        return false;
      }
    }

    // Fallback: Use platform view workaround
    // Note: This requires native implementation
    _log('Channel not set - cannot enable protection');
    return false;
  }

  Future<bool> _disableAndroid() async {
    if (_channel != null) {
      try {
        await _channel!.invokeMethod('disableSecureFlag');
        _isEnabled = false;
        _log('Android FLAG_SECURE disabled');
        return true;
      } on PlatformException catch (e) {
        _log('Failed to disable FLAG_SECURE: ${e.message}');
        return false;
      }
    }
    return false;
  }

  /// iOS: Uses hidden overlay technique.
  Future<bool> _enableiOS() async {
    if (_channel != null) {
      try {
        await _channel!.invokeMethod('enableScreenProtection');
        _isEnabled = true;
        _log('iOS screen protection enabled');
        return true;
      } on PlatformException catch (e) {
        _log('Failed to enable iOS protection: ${e.message}');
        return false;
      }
    }

    _log('Channel not set - cannot enable protection');
    return false;
  }

  Future<bool> _disableiOS() async {
    if (_channel != null) {
      try {
        await _channel!.invokeMethod('disableScreenProtection');
        _isEnabled = false;
        _log('iOS screen protection disabled');
        return true;
      } on PlatformException catch (e) {
        _log('Failed to disable iOS protection: ${e.message}');
        return false;
      }
    }
    return false;
  }

  void _log(String message) {
    if (SecurityConfig.enableLogging) {
      debugPrint('[ScreenshotProtection] $message');
    }
  }
}

/// Mixin for StatefulWidgets that need screenshot protection.
///
/// Automatically enables protection on mount and disables on dispose.
///
/// ```dart
/// class _MySecureScreenState extends State<MySecureScreen>
///     with ScreenshotProtectedState {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(...);
///   }
/// }
/// ```
mixin ScreenshotProtectedState<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    ScreenshotProtection().enable();
  }

  @override
  void dispose() {
    ScreenshotProtection().disable();
    super.dispose();
  }
}

/// Widget wrapper that enables screenshot protection.
///
/// ```dart
/// ScreenshotProtectedWidget(
///   child: MySecureContent(),
/// )
/// ```
class ScreenshotProtectedWidget extends StatefulWidget {
  final Widget child;

  const ScreenshotProtectedWidget({
    super.key,
    required this.child,
  });

  @override
  State<ScreenshotProtectedWidget> createState() =>
      _ScreenshotProtectedWidgetState();
}

class _ScreenshotProtectedWidgetState extends State<ScreenshotProtectedWidget>
    with ScreenshotProtectedState {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Route observer that enables screenshot protection for specific routes.
///
/// ```dart
/// MaterialApp(
///   navigatorObservers: [
///     ScreenshotProtectionRouteObserver(
///       protectedRoutes: ['/pin', '/transfer', '/settings/security'],
///     ),
///   ],
/// )
/// ```
class ScreenshotProtectionRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final Set<String> protectedRoutes;

  ScreenshotProtectionRouteObserver({
    required Iterable<String> protectedRoutes,
  }) : protectedRoutes = Set.from(protectedRoutes);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateProtection(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _updateProtection(previousRoute);
    } else {
      ScreenshotProtection().forceDisable();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _updateProtection(newRoute);
    }
  }

  void _updateProtection(Route<dynamic> route) {
    final routeName = route.settings.name;
    if (routeName != null && _isProtectedRoute(routeName)) {
      ScreenshotProtection().enable();
    } else {
      ScreenshotProtection().disable();
    }
  }

  bool _isProtectedRoute(String routeName) {
    // Exact match
    if (protectedRoutes.contains(routeName)) {
      return true;
    }

    // Wildcard match (e.g., '/settings/*' matches '/settings/security')
    for (final pattern in protectedRoutes) {
      if (pattern.endsWith('/*')) {
        final prefix = pattern.substring(0, pattern.length - 2);
        if (routeName.startsWith(prefix)) {
          return true;
        }
      }
    }

    return false;
  }
}
