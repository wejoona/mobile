import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

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
///
/// This client-side boundary intentionally does not attempt to decrypt until the
/// backend publishes a real notification JWE contract. Lock-screen content must
/// stay generic rather than decode a reversible placeholder payload.
class PushNotificationEncryptor {
  static const _tag = 'PushEncrypt';
  final AppLogger _log = AppLogger(_tag);

  /// Decrypt an encrypted push notification.
  NotificationContent decrypt(EncryptedNotification notification) {
    _log.warn(
      'Encrypted notification received before JWE decrypt contract is implemented',
      {'keyId': notification.keyId, 'version': notification.version},
    );
    return genericPreview();
  }

  NotificationContent genericPreview() {
    return const NotificationContent(
      title: 'Korido',
      body: 'You have a new secure notification',
    );
  }

  /// Create a safe preview (no sensitive data) for lock screen.
  String safePreview(NotificationContent content) {
    // Mask amounts and account details
    return content.body
        .replaceAll(RegExp(r'\d{4,}'), '****')
        .replaceAll(RegExp(r'[A-Z0-9]{10,}'), '****');
  }
}

final pushNotificationEncryptorProvider = Provider<PushNotificationEncryptor>((
  ref,
) {
  return PushNotificationEncryptor();
});
