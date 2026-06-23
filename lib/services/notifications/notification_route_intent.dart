import 'package:usdc_wallet/domain/entities/notification.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/state/fsm/app_route_contract.dart';

enum NotificationRouteIntentKind {
  transaction,
  security,
  devices,
  kyc,
  wallet,
  deposit,
  referrals,
  notifications,
  directSafeRoute,
}

class NotificationRouteIntent {
  const NotificationRouteIntent._(this.kind, {this.referenceId, this.route});

  factory NotificationRouteIntent.fromData(Map<String, dynamic> data) {
    final safeRoute = notificationSafeRouteFromPayload(data['actionUrl']);
    if (safeRoute != null) {
      return NotificationRouteIntent._(
        NotificationRouteIntentKind.directSafeRoute,
        route: safeRoute,
      );
    }

    final type = _normalized(data['type'] ?? data['category']);
    final action = _normalized(data['action']);
    final transactionId = _firstNonEmpty([
      data['transactionId'],
      data['transaction_id'],
      if (_normalized(data['referenceType']) == 'transaction')
        data['referenceId'],
    ]);

    if (_isTransaction(action) || _isTransaction(type)) {
      return NotificationRouteIntent._(
        NotificationRouteIntentKind.transaction,
        referenceId: transactionId,
      );
    }

    if (action == 'new_device_login' || type == 'new_device_login') {
      return const NotificationRouteIntent._(
        NotificationRouteIntentKind.devices,
      );
    }

    if (_isSecurity(action) || _isSecurity(type)) {
      return const NotificationRouteIntent._(
        NotificationRouteIntentKind.security,
      );
    }

    if (action == 'open_kyc' || type == 'kyc') {
      return const NotificationRouteIntent._(NotificationRouteIntentKind.kyc);
    }

    if (type == 'low_balance' || action == 'open_deposit') {
      return const NotificationRouteIntent._(
        NotificationRouteIntentKind.deposit,
      );
    }

    if (type == 'balance' || action == 'open_wallet') {
      return const NotificationRouteIntent._(
        NotificationRouteIntentKind.wallet,
      );
    }

    if (type == 'promotion' || type == 'referral') {
      return const NotificationRouteIntent._(
        NotificationRouteIntentKind.referrals,
      );
    }

    return const NotificationRouteIntent._(
      NotificationRouteIntentKind.notifications,
    );
  }

  factory NotificationRouteIntent.fromNotification(
    AppNotification notification,
  ) {
    final safeRoute = notificationSafeRouteFromPayload(notification.actionUrl);
    if (safeRoute != null) {
      return NotificationRouteIntent._(
        NotificationRouteIntentKind.directSafeRoute,
        route: safeRoute,
      );
    }

    final action = _normalized(notification.action);
    if (_isTransaction(action)) {
      return NotificationRouteIntent._(
        NotificationRouteIntentKind.transaction,
        referenceId: notification.transactionId,
      );
    }

    switch (notification.type) {
      case NotificationType.transfer:
      case NotificationType.transactionComplete:
      case NotificationType.transactionFailed:
      case NotificationType.deposit:
      case NotificationType.withdrawal:
      case NotificationType.withdrawalPending:
      case NotificationType.largeTransaction:
      case NotificationType.externalWithdrawal:
        return NotificationRouteIntent._(
          NotificationRouteIntentKind.transaction,
          referenceId: notification.transactionId,
        );
      case NotificationType.kyc:
        return const NotificationRouteIntent._(NotificationRouteIntentKind.kyc);
      case NotificationType.newDeviceLogin:
        return const NotificationRouteIntent._(
          NotificationRouteIntentKind.devices,
        );
      case NotificationType.security:
      case NotificationType.securityAlert:
      case NotificationType.unusualLocation:
      case NotificationType.suspiciousPattern:
      case NotificationType.failedAttempts:
      case NotificationType.accountChange:
      case NotificationType.rapidTransactions:
      case NotificationType.velocityLimit:
      case NotificationType.timeAnomaly:
        return const NotificationRouteIntent._(
          NotificationRouteIntentKind.security,
        );
      case NotificationType.lowBalance:
      case NotificationType.balanceThreshold:
        return const NotificationRouteIntent._(
          NotificationRouteIntentKind.deposit,
        );
      case NotificationType.addressWhitelisted:
      case NotificationType.priceAlert:
      case NotificationType.weeklySpendingSummary:
      case NotificationType.newRecipient:
        return const NotificationRouteIntent._(
          NotificationRouteIntentKind.wallet,
        );
      case NotificationType.promotion:
        return const NotificationRouteIntent._(
          NotificationRouteIntentKind.referrals,
        );
      case NotificationType.general:
      case NotificationType.roundAmount:
      case NotificationType.cumulativeDaily:
        return const NotificationRouteIntent._(
          NotificationRouteIntentKind.notifications,
        );
    }
  }

  final NotificationRouteIntentKind kind;
  final String? referenceId;
  final String? route;

  String toRoute() {
    final candidate = switch (kind) {
      NotificationRouteIntentKind.transaction =>
        referenceId == null || referenceId!.isEmpty
            ? '/transactions'
            : '/transactions/$referenceId',
      NotificationRouteIntentKind.security => '/settings/security',
      NotificationRouteIntentKind.devices => '/settings/devices',
      NotificationRouteIntentKind.kyc => '/kyc',
      NotificationRouteIntentKind.wallet => '/home',
      NotificationRouteIntentKind.deposit => '/deposit',
      NotificationRouteIntentKind.referrals => '/referrals',
      NotificationRouteIntentKind.notifications => '/notifications',
      NotificationRouteIntentKind.directSafeRoute => route ?? '/notifications',
    };

    return notificationRouteIsAllowed(candidate) ? candidate : '/notifications';
  }
}

String routeForNotificationData(Map<String, dynamic> data) =>
    NotificationRouteIntent.fromData(data).toRoute();

String routeForNotification(AppNotification notification) =>
    NotificationRouteIntent.fromNotification(notification).toRoute();

String? notificationSafeRouteFromPayload(Object? raw) {
  final value = raw?.toString().trim();
  if (value == null || value.isEmpty || !value.startsWith('/')) {
    return null;
  }
  if (value.startsWith('//') || value.contains('://')) {
    return null;
  }
  return notificationRouteIsAllowed(value) ? value : null;
}

bool notificationRouteIsAllowed(String route) {
  final path = appRoutePathForContract(route);
  if (path.isEmpty || !path.startsWith('/')) {
    return false;
  }

  final contract = appRouteContractFor(route);
  if (contract.role == AppRouteRole.unknown) {
    return false;
  }

  const exactRoutes = {
    '/home',
    '/transactions',
    '/settings/security',
    '/settings/devices',
    '/settings/kyc',
    '/kyc',
    '/deposit',
    '/referrals',
    '/notifications',
  };
  if (exactRoutes.contains(path)) {
    return true;
  }

  const allowedPrefixes = {
    '/transactions/',
    '/payment-links/detail/',
    '/payment-links/created/',
  };
  return allowedPrefixes.any(path.startsWith);
}

String? _firstNonEmpty(Iterable<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) {
      return text;
    }
  }
  return null;
}

String _normalized(Object? value) => value
    .toString()
    .trim()
    .replaceAll('-', '_')
    .replaceAll(' ', '_')
    .toLowerCase();

bool _isTransaction(String value) => {
  'transaction',
  'transaction_complete',
  'transactioncomplete',
  'transaction_failed',
  'transactionfailed',
  'transfer',
  'transfer_received',
  'transfer_sent',
  'deposit',
  'withdrawal',
  'withdrawal_pending',
  'external_withdrawal',
  'open_transaction',
}.contains(value);

bool _isSecurity(String value) => {
  'security',
  'security_alert',
  'securityalert',
  'large_transaction',
  'address_whitelisted',
  'unusual_location',
  'rapid_transactions',
  'suspicious_pattern',
  'failed_attempts',
  'account_change',
  'velocity_limit',
  'time_anomaly',
  'open_security',
}.contains(value);
