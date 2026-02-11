import 'dart:io';
import 'dart:ui' show Color;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Local Notification Service
///
/// Handles displaying local notifications on the device.
/// Used for:
/// - Showing FCM messages when app is in foreground
/// - Scheduled local notifications
/// - Custom in-app notifications
class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  static final _logger = AppLogger('LocalNotifications');

  /// Notification tap callback
  Function(String? payload)? onNotificationTap;

  /// Initialize local notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // We request via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    _isInitialized = true;
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // High importance channel (transactions, security alerts)
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'high_importance_channel',
        'Important Notifications',
        description: 'Notifications for transactions, security alerts, and urgent updates',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
    );

    // Default channel (general notifications)
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'default_channel',
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
        enableVibration: true,
        playSound: true,
      ),
    );

    // Low importance channel (promotions, summaries)
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'low_importance_channel',
        'Updates & Promotions',
        description: 'Weekly summaries, promotions, and non-urgent updates',
        importance: Importance.low,
        enableVibration: false,
        playSound: false,
      ),
    );
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    _logger.debug('Notification tapped', response.payload);

    if (onNotificationTap != null) {
      onNotificationTap!(response.payload);
    }
  }

  /// Show a notification from FCM remote message
  Future<void> showFromRemoteMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await show(
      id: message.hashCode,
      title: notification.title ?? 'Korido',
      body: notification.body ?? '',
      payload: _encodePayload(message.data),
      channelId: _getChannelForMessageType(message.data['type']),
    );
  }

  /// Show a local notification
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'default_channel',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: _getImportanceForChannel(channelId),
      priority: _getPriorityForChannel(channelId),
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFFFBB00), // JoonaPay gold
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Cancel a notification
  Future<void> cancel(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPending() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  String _getChannelForMessageType(String? type) {
    switch (type) {
      case 'transaction':
      case 'security':
        return 'high_importance_channel';
      case 'promotion':
      case 'summary':
        return 'low_importance_channel';
      default:
        return 'default_channel';
    }
  }

  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'high_importance_channel':
        return 'Important Notifications';
      case 'low_importance_channel':
        return 'Updates & Promotions';
      default:
        return 'General Notifications';
    }
  }

  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'high_importance_channel':
        return 'Notifications for transactions, security alerts, and urgent updates';
      case 'low_importance_channel':
        return 'Weekly summaries, promotions, and non-urgent updates';
      default:
        return 'General app notifications';
    }
  }

  Importance _getImportanceForChannel(String channelId) {
    switch (channelId) {
      case 'high_importance_channel':
        return Importance.high;
      case 'low_importance_channel':
        return Importance.low;
      default:
        return Importance.defaultImportance;
    }
  }

  Priority _getPriorityForChannel(String channelId) {
    switch (channelId) {
      case 'high_importance_channel':
        return Priority.high;
      case 'low_importance_channel':
        return Priority.low;
      default:
        return Priority.defaultPriority;
    }
  }

  String _encodePayload(Map<String, dynamic> data) {
    // Simple encoding - in production use JSON
    final entries = data.entries.map((e) => '${e.key}=${e.value}');
    return entries.join('&');
  }
}

/// Local Notification Service Provider
final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService();
});

/// Provider for initializing local notifications
final localNotificationInitProvider = FutureProvider<void>((ref) async {
  final service = ref.read(localNotificationServiceProvider);
  await service.initialize();
});

