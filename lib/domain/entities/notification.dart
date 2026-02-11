/// Notification entity.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final String? actionUrl;
  final String? transactionId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    this.actionUrl,
    this.transactionId,
    this.data,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
      transactionId: json['transactionId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

enum NotificationType {
  transaction,
  security,
  kyc,
  promotion,
  system,
  general,
}
