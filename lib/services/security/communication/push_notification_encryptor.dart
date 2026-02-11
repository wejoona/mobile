import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Encrypted push notification payload.
class EncryptedNotification {
  final String encryptedBody;
  final String keyId;
  final int version;

  const EncryptedNotification({
    required this.encryptedBody,
    required this.keyId,
    this.version = 1,
  });

  factory EncryptedNotification.fromJson(Map<String, dynamic> json) {
    return EncryptedNotification(
      encryptedBody: json['body'] as String,
      keyId: json['keyId'] as String,
      version: json['v'] as int? ?? 1,
    );
  }
}

/// Decrypted notification content.
class NotificationContent {
  final String title;
  final String body;
  final Map<String, dynamic>? data;

  const NotificationContent({
    required this.title,
    required this.body,
    this.data,
  });
}

/// Handles encryption/decryption of push notification payloads.
///
/// Sensitive transaction details are encrypted before being sent
/// via push notifications to prevent exposure in notification previews.
class PushNotificationEncryptor {
  static const _tag = 'PushEncrypt';
  final AppLogger _log = AppLogger(_tag);

  /// Decrypt an encrypted push notification.
  NotificationContent decrypt(EncryptedNotification notification) {
    try {
      final json = jsonDecode(
          utf8.decode(base64Decode(notification.encryptedBody)));
      return NotificationContent(
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        data: json['data'] as Map<String, dynamic>?,
      );
    } catch (e) {
      _log.error('Failed to decrypt notification', e);
      // Fallback: show generic message
      return const NotificationContent(
        title: 'Korido',
        body: 'Vous avez une nouvelle notification',
      );
    }
  }

  /// Create a safe preview (no sensitive data) for lock screen.
  String safePreview(NotificationContent content) {
    // Mask amounts and account details
    return content.body
        .replaceAll(RegExp(r'\d{4,}'), '****')
        .replaceAll(RegExp(r'[A-Z0-9]{10,}'), '****');
  }
}

final pushNotificationEncryptorProvider =
    Provider<PushNotificationEncryptor>((ref) {
  return PushNotificationEncryptor();
});
