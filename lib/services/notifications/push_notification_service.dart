// ignore_for_file: unreachable_from_main

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/settings/repositories/devices_repository.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/notifications/notifications_service.dart';
import 'package:usdc_wallet/services/security/device_fingerprint_service.dart';
import 'package:usdc_wallet/utils/logger.dart';

const _logger = AppLogger('PushNotifications');

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed (for background/terminated state)
  await Firebase.initializeApp();

  _logger.info('Background message received', {
    'messageId': message.messageId,
    'hasNotification': message.notification != null,
  });

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
  PushNotificationService(
    this._notificationsService,
    this._fingerprintService,
    this._devicesRepository,
  );

  final NotificationsService _notificationsService;
  final DeviceFingerprintService _fingerprintService;
  final DevicesRepository _devicesRepository;

  // Managed by dispose(); this service is lifecycle-owned by Riverpod.
  // ignore: cancel_subscriptions
  StreamSubscription<RemoteMessage>? _foregroundSubscription;

  // Managed by dispose(); this service is lifecycle-owned by Riverpod.
  // ignore: cancel_subscriptions
  StreamSubscription<String>? _tokenRefreshSubscription;

  String? _currentToken;
  bool _isInitialized = false;

  /// Callback for handling received notifications while app is in foreground
  Function(RemoteMessage message)? onForegroundMessage;

  /// Callback for handling notification tap (app was in background/terminated)
  Function(RemoteMessage message)? onMessageOpenedApp;

  /// Callback for navigation based on notification data
  Function(Map<String, dynamic> data)? onNavigate;

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  /// Initialize push notification service.
  ///
  /// This does not ask for OS notification permission by default. Callers that
  /// are behind an explicit user action, such as the notification permission
  /// screen, must pass [requestPermission] so consent stays intentional.
  Future<void> initialize({bool requestPermission = false}) async {
    if (_isInitialized) {
      return;
    }

    if (!_isFirebaseAvailable) {
      _logger.warn(
        'Firebase is not initialized; push notifications disabled for this run',
      );
      return;
    }

    try {
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      final settings = requestPermission
          ? await _requestPermissions()
          : await _messaging.getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get initial token
        _currentToken = await _messaging.getToken();
        _logger.debug('FCM Token obtained', _currentToken);

        // Listen for token refresh
        _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
          _handleTokenRefresh,
        );

        // Handle foreground messages
        _foregroundSubscription = FirebaseMessaging.onMessage.listen(
          _handleForegroundMessage,
        );

        // Handle notification tap when app was in background
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

        // Check if app was opened from terminated state via notification
        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleMessageOpenedApp(initialMessage);
        }

        _isInitialized = true;
      } else {
        _logger.warn('Push notifications not authorized for initialization', {
          'authorizationStatus': settings.authorizationStatus.name,
          'requestPermission': requestPermission,
        });
      }
    } on FirebaseException catch (error) {
      _logger.warn('Firebase messaging unavailable; push disabled', error);
    }
  }

  /// Request notification permissions
  Future<NotificationSettings> _requestPermissions() =>
      _messaging.requestPermission();

  /// Get current FCM token
  String? get currentToken => _currentToken;

  /// Check if push notifications are enabled
  Future<bool> get isEnabled async {
    if (!_isFirebaseAvailable) {
      return false;
    }

    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Register FCM token with backend
  /// Call this after user authentication
  Future<bool> registerWithBackend() async {
    if (_currentToken == null) {
      _logger.warn('No FCM token available to register');
      return false;
    }

    try {
      final fingerprint = await _safeFingerprint();
      final deviceTokenSynced = await _syncDevicePushToken(
        fingerprint,
        _currentToken!,
      );
      final legacyTokenSynced = await _registerLegacyNotificationToken(
        fingerprint,
        _currentToken!,
      );

      if (deviceTokenSynced) {
        _logger.info('FCM token registered with device backend');
      }
      return deviceTokenSynced || legacyTokenSynced;
    } on Object catch (e) {
      _logger.error('Failed to register FCM token', e);
      return false;
    }
  }

  /// Unregister FCM token from backend
  /// Call this on logout
  Future<void> unregisterFromBackend() async {
    if (_currentToken == null) {
      return;
    }

    try {
      await _notificationsService.removeFcmToken(_currentToken!);

      _logger.info('FCM token unregistered from backend');
    } on DioException catch (e) {
      _logger.error('Failed to unregister FCM token', e);
    }
  }

  /// Handle token refresh
  Future<void> _handleTokenRefresh(String newToken) async {
    _logger.info('FCM token refreshed');

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
    _logger.info('Foreground message received', {
      'messageId': message.messageId,
      'title': message.notification?.title,
      'body': message.notification?.body,
    });

    onForegroundMessage?.call(message);
  }

  /// Handle message tap (app was in background/terminated)
  void _handleMessageOpenedApp(RemoteMessage message) {
    _logger.info('Message opened app', message.messageId);

    final handleOpenedApp = onMessageOpenedApp;
    if (handleOpenedApp != null) {
      handleOpenedApp(message);
      return;
    }

    _handleNavigation(message.data);
  }

  /// Handle navigation based on notification data
  void _handleNavigation(Map<String, dynamic> data) {
    final navigate = onNavigate;
    if (navigate != null) {
      navigate(data);
      return;
    }

    // Default navigation handling
    final type = data['type'] as String?;
    final action = data['action'] as String?;
    final transactionId = data['transactionId'] as String?;

    _logger.debug('Handling navigation', {
      'type': type,
      'action': action,
      'transactionId': transactionId,
    });

    // Notification route intents are surfaced through [onNavigate]. Widgets
    // translate them into FSM-owned navigation so services never own routing.
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    if (!_isFirebaseAvailable) {
      _logger.warn('Firebase unavailable; topic subscribe skipped', topic);
      return;
    }

    await _messaging.subscribeToTopic(topic);
    _logger.info('Subscribed to topic', topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_isFirebaseAvailable) {
      _logger.warn('Firebase unavailable; topic unsubscribe skipped', topic);
      return;
    }

    await _messaging.unsubscribeFromTopic(topic);
    _logger.info('Unsubscribed from topic', topic);
  }

  bool get _isFirebaseAvailable => Firebase.apps.isNotEmpty;

  Future<DeviceFingerprint?> _safeFingerprint() async {
    try {
      return await _fingerprintService.collect();
    } on Object catch (error) {
      _logger.warn(
        'Device fingerprint unavailable for push registration',
        error,
      );
      return null;
    }
  }

  String? _displayDeviceName(DeviceFingerprint? fingerprint) {
    if (fingerprint == null) {
      return null;
    }

    final parts = [fingerprint.brand, fingerprint.model]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    return parts.isEmpty ? null : parts.join(' ');
  }

  Future<bool> _registerLegacyNotificationToken(
    DeviceFingerprint? fingerprint,
    String token,
  ) async {
    try {
      await _notificationsService.registerFcmToken(
        token: token,
        platform: Platform.isIOS ? 'ios' : 'android',
        deviceId: fingerprint?.deviceId,
        deviceName: _displayDeviceName(fingerprint),
        appVersion: fingerprint?.appVersion,
        osVersion: fingerprint?.osVersion ?? Platform.operatingSystemVersion,
      );
      return true;
    } on Object catch (error) {
      _logger.warn('Legacy notification token registration skipped', error);
      return false;
    }
  }

  Future<bool> _syncDevicePushToken(
    DeviceFingerprint? fingerprint,
    String token,
  ) async {
    final deviceId = fingerprint?.deviceId;
    if (deviceId == null || deviceId.trim().isEmpty) {
      return false;
    }

    try {
      await _devicesRepository.updateFcmToken(
        deviceIdentifier: deviceId,
        fcmToken: token,
      );
      return true;
    } on Object catch (error) {
      _logger.warn('Device FCM token sync failed', error);
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    final foregroundSubscription = _foregroundSubscription;
    final tokenRefreshSubscription = _tokenRefreshSubscription;

    if (foregroundSubscription != null) {
      unawaited(foregroundSubscription.cancel());
    }
    if (tokenRefreshSubscription != null) {
      unawaited(tokenRefreshSubscription.cancel());
    }
  }
}

/// Push Notification Service Provider
final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  // Keep watching the Dio-backed API client so provider invalidation follows
  // auth/network lifecycle changes even though calls are routed via the facade.
  ref.watch(dioProvider);
  final service = PushNotificationService(
    ref.watch(notificationsServiceProvider),
    ref.watch(deviceFingerprintServiceProvider),
    ref.watch(devicesRepositoryProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Provider for initializing push notifications
/// Use this in your app initialization
final pushNotificationInitProvider = FutureProvider<void>((ref) {
  final service = ref.read(pushNotificationServiceProvider);
  return service.initialize();
});
