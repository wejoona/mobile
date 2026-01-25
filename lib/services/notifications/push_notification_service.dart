import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../api/api_client.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed (for background/terminated state)
  await Firebase.initializeApp();

  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print('Notification: ${message.notification!.title} - ${message.notification!.body}');
    }
  }

  // Handle the background message
  // Note: You cannot access providers here since the app is in background
  // For complex handling, store in local database and process on app open
}

/// Push Notification Service
///
/// Manages Firebase Cloud Messaging (FCM) for push notifications:
/// - Requests notification permissions
/// - Registers FCM token with backend
/// - Handles token refresh
/// - Processes foreground and background messages
///
/// Usage:
/// 1. Call initialize() early in app lifecycle (after Firebase.initializeApp())
/// 2. Call registerWithBackend() after user authentication
/// 3. Call unregisterFromBackend() on logout
class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final Dio _dio;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  String? _currentToken;
  bool _isInitialized = false;

  /// Callback for handling received notifications while app is in foreground
  Function(RemoteMessage message)? onForegroundMessage;

  /// Callback for handling notification tap (app was in background/terminated)
  Function(RemoteMessage message)? onMessageOpenedApp;

  /// Callback for navigation based on notification data
  Function(Map<String, dynamic> data)? onNavigate;

  PushNotificationService(this._dio);

  /// Initialize push notification service
  /// Call this early in app lifecycle after Firebase.initializeApp()
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions
    final settings = await _requestPermissions();

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {

      // Get initial token
      _currentToken = await _messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $_currentToken');
      }

      // Listen for token refresh
      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(_handleTokenRefresh);

      // Handle foreground messages
      _foregroundSubscription = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app was in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Check if app was opened from terminated state via notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      _isInitialized = true;
    } else {
      if (kDebugMode) {
        print('Push notifications not authorized: ${settings.authorizationStatus}');
      }
    }
  }

  /// Request notification permissions
  Future<NotificationSettings> _requestPermissions() async {
    return await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// Get current FCM token
  String? get currentToken => _currentToken;

  /// Check if push notifications are enabled
  Future<bool> get isEnabled async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
           settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Register FCM token with backend
  /// Call this after user authentication
  Future<void> registerWithBackend() async {
    if (_currentToken == null) {
      if (kDebugMode) {
        print('No FCM token available to register');
      }
      return;
    }

    try {
      final deviceInfo = await _getDeviceInfo();

      await _dio.post('/notifications/push/token', data: {
        'token': _currentToken,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'deviceId': deviceInfo['deviceId'],
        'deviceName': deviceInfo['deviceName'],
        'appVersion': deviceInfo['appVersion'],
        'osVersion': deviceInfo['osVersion'],
      });

      if (kDebugMode) {
        print('FCM token registered with backend');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Failed to register FCM token: ${e.message}');
      }
      // Don't throw - registration failure shouldn't break the app
    }
  }

  /// Unregister FCM token from backend
  /// Call this on logout
  Future<void> unregisterFromBackend() async {
    if (_currentToken == null) return;

    try {
      await _dio.delete('/notifications/push/token', data: {
        'token': _currentToken,
      });

      if (kDebugMode) {
        print('FCM token unregistered from backend');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Failed to unregister FCM token: ${e.message}');
      }
    }
  }

  /// Handle token refresh
  void _handleTokenRefresh(String newToken) async {
    if (kDebugMode) {
      print('FCM token refreshed: $newToken');
    }

    // Unregister old token if we have one
    if (_currentToken != null && _currentToken != newToken) {
      await unregisterFromBackend();
    }

    _currentToken = newToken;

    // Register new token
    await registerWithBackend();
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // Invoke callback if set
    if (onForegroundMessage != null) {
      onForegroundMessage!(message);
    }
  }

  /// Handle message tap (app was in background/terminated)
  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('Message opened app: ${message.messageId}');
      print('Data: ${message.data}');
    }

    // Invoke callback if set
    if (onMessageOpenedApp != null) {
      onMessageOpenedApp!(message);
    }

    // Handle navigation based on message data
    _handleNavigation(message.data);
  }

  /// Handle navigation based on notification data
  void _handleNavigation(Map<String, dynamic> data) {
    if (onNavigate != null) {
      onNavigate!(data);
      return;
    }

    // Default navigation handling
    final type = data['type'] as String?;
    final action = data['action'] as String?;
    final transactionId = data['transactionId'] as String?;

    if (kDebugMode) {
      print('Handling navigation - type: $type, action: $action, transactionId: $transactionId');
    }

    // Navigation logic would go here
    // This should integrate with your router (e.g., GoRouter)
    // Example:
    // switch (type) {
    //   case 'transaction':
    //     if (transactionId != null) {
    //       router.push('/transactions/$transactionId');
    //     }
    //     break;
    //   case 'security':
    //     router.push('/settings/security');
    //     break;
    //   case 'kyc':
    //     router.push('/kyc');
    //     break;
    // }
  }

  /// Get device information
  Future<Map<String, String>> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'deviceId': androidInfo.id,
          'deviceName': '${androidInfo.brand} ${androidInfo.model}',
          'osVersion': 'Android ${androidInfo.version.release}',
          'appVersion': '1.0.0', // TODO: Get from package_info_plus
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'deviceId': iosInfo.identifierForVendor ?? '',
          'deviceName': iosInfo.name,
          'osVersion': 'iOS ${iosInfo.systemVersion}',
          'appVersion': '1.0.0', // TODO: Get from package_info_plus
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get device info: $e');
      }
    }

    return {
      'deviceId': '',
      'deviceName': 'Unknown Device',
      'osVersion': '',
      'appVersion': '1.0.0',
    };
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    if (kDebugMode) {
      print('Subscribed to topic: $topic');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    if (kDebugMode) {
      print('Unsubscribed from topic: $topic');
    }
  }

  /// Dispose resources
  void dispose() {
    _foregroundSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
  }
}

/// Push Notification Service Provider
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final dio = ref.watch(dioProvider);
  return PushNotificationService(dio);
});

/// Provider for initializing push notifications
/// Use this in your app initialization
final pushNotificationInitProvider = FutureProvider<void>((ref) async {
  final service = ref.read(pushNotificationServiceProvider);
  await service.initialize();
});
