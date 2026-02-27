import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/services/analytics/analytics_service.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Deep link handler for custom scheme (joonapay://) and universal links
/// Storage keys for pending deep links
const _kPendingDeepLinkPath = 'pending_deep_link_path';
const _kPendingDeepLinkParams = 'pending_deep_link_params';

class DeepLinkHandler {
  static const _storage = FlutterSecureStorage();

  /// Resume a pending deep link after authentication
  static Future<bool> resumePendingDeepLink(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final path = await _storage.read(key: _kPendingDeepLinkPath);
      if (path == null) return false;

      final paramsStr = await _storage.read(key: _kPendingDeepLinkParams);
      final params = <String, String>{};
      if (paramsStr != null && paramsStr.isNotEmpty) {
        for (final pair in paramsStr.split('&')) {
          final parts = pair.split('=');
          if (parts.length == 2) {
            params[Uri.decodeComponent(parts[0])] =
                Uri.decodeComponent(parts[1]);
          }
        }
      }

      // Clear pending deep link
      await _storage.delete(key: _kPendingDeepLinkPath);
      await _storage.delete(key: _kPendingDeepLinkParams);

      // Route to destination
      await _routeToDestination(path, params, context, ref, true);
      return true;
    } catch (e) {
      debugPrint('Error resuming deep link: $e');
      return false;
    }
  }

  /// Handle incoming deep link URI
  static Future<void> handleDeepLink(
    Uri uri,
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Log analytics
    _logDeepLinkEvent(uri, ref);

    // Get authentication state
    final authState = ref.read(authProvider);
    final isAuthenticated = authState.isAuthenticated;

    // Extract path and clean it
    String path = uri.path;
    if (path.isEmpty) path = '/';

    // Remove leading slash for consistency
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    // Extract query parameters
    final params = uri.queryParameters;

    // SECURITY: Strip any auth tokens from deep link parameters
    // Deep links should never carry authentication tokens as they can be
    // intercepted, logged, or leaked via referrer headers
    final sanitizedParams = Map<String, String>.from(params);
    const sensitiveKeys = ['token', 'access_token', 'refresh_token', 'auth_token', 'session_token', 'api_key'];
    for (final key in sensitiveKeys) {
      if (sanitizedParams.containsKey(key)) {
        debugPrint('SECURITY: Stripped sensitive parameter "$key" from deep link');
        sanitizedParams.remove(key);
      }
    }

    // Route based on path
    try {
      await _routeToDestination(
        path,
        sanitizedParams,
        context,
        ref,
        isAuthenticated,
      );
    } catch (e) {
      debugPrint('Deep link error: $e');
      _showError(context, 'Invalid link');
      if (isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  /// Route to appropriate destination based on path
  static Future<void> _routeToDestination(
    String path,
    Map<String, String> params,
    BuildContext context,
    WidgetRef ref,
    bool isAuthenticated,
  ) async {
    // Normalize path
    final normalizedPath = path.toLowerCase();

    // Handle home/wallet
    if (normalizedPath == 'home' ||
        normalizedPath == 'wallet' ||
        normalizedPath.isEmpty) {
      if (isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/login');
      }
      return;
    }

    // Handle send money
    if (normalizedPath == 'send') {
      if (!isAuthenticated) {
        _saveForLater(context, '/send', params);
        context.go('/login');
        return;
      }

      final to = params['to'];
      final amount = params['amount'];
      final note = params['note'];

      // Validate parameters
      if (to != null && !_isValidPhoneNumber(to)) {
        _showError(context, 'Invalid phone number');
        context.go('/home');
        return;
      }

      if (amount != null && !_isValidAmount(amount)) {
        _showError(context, 'Invalid amount');
        context.go('/home');
        return;
      }

      context.push('/send', extra: {
        if (to != null) 'recipient': to,
        if (amount != null) 'amount': double.parse(amount),
        if (note != null) 'note': note,
      });
      return;
    }

    // Handle receive money
    if (normalizedPath == 'receive') {
      if (!isAuthenticated) {
        _saveForLater(context, '/receive', params);
        context.go('/login');
        return;
      }

      final amount = params['amount'];
      if (amount != null && !_isValidAmount(amount)) {
        _showError(context, 'Invalid amount');
        context.go('/home');
        return;
      }

      context.push('/receive', extra: {
        if (amount != null) 'amount': double.parse(amount),
      });
      return;
    }

    // Handle transaction detail
    if (normalizedPath.startsWith('transaction/') ||
        normalizedPath.startsWith('transactions/')) {
      if (!isAuthenticated) {
        _saveForLater(context, '/transaction', params);
        context.go('/login');
        return;
      }

      final parts = normalizedPath.split('/');
      if (parts.length < 2) {
        _showError(context, 'Invalid transaction link');
        context.go('/home');
        return;
      }

      final transactionId = parts[1];
      if (!_isValidUuid(transactionId)) {
        _showError(context, 'Invalid transaction ID');
        context.go('/home');
        return;
      }

      // Validate transaction exists before navigating
      try {
        final dio = ref.read(dioProvider);
        await dio.get('/wallet/transactions/$transactionId');
      } catch (e) {
        if (context.mounted) {
          _showError(context, 'Transaction not found');
          context.go('/home');
        }
        return;
      }

      context.push('/transactions/$transactionId');
      return;
    }

    // Handle KYC
    if (normalizedPath == 'kyc' || normalizedPath.startsWith('kyc/')) {
      if (!isAuthenticated) {
        _saveForLater(context, '/kyc', params);
        context.go('/login');
        return;
      }

      if (normalizedPath == 'kyc/status') {
        context.push('/kyc');
        return;
      }

      final tier = params['tier'];
      context.push('/kyc', extra: {
        if (tier != null) 'targetTier': tier,
      });
      return;
    }

    // Handle settings routes
    if (normalizedPath.startsWith('settings')) {
      if (!isAuthenticated) {
        _saveForLater(context, '/settings', params);
        context.go('/login');
        return;
      }

      final parts = normalizedPath.split('/');
      if (parts.length == 1) {
        context.go('/settings');
        return;
      }

      final subPath = parts[1];
      final settingsRoutes = {
        'profile': '/settings/profile',
        'security': '/settings/security',
        'pin': '/settings/pin',
        'notifications': '/settings/notifications',
        'language': '/settings/language',
        'currency': '/settings/currency',
        'devices': '/settings/devices',
        'sessions': '/settings/sessions',
        'limits': '/settings/limits',
        'help': '/settings/help',
      };

      final route = settingsRoutes[subPath];
      if (route != null) {
        context.push(route);
      } else {
        context.go('/settings');
      }
      return;
    }

    // Handle payment links
    if (normalizedPath.startsWith('pay/') ||
        normalizedPath.startsWith('payment-link/')) {
      if (!isAuthenticated) {
        _saveForLater(context, path, params);
        context.go('/login');
        return;
      }

      final parts = normalizedPath.split('/');
      if (parts.length < 2) {
        _showError(context, 'Invalid payment link');
        context.go('/home');
        return;
      }

      final linkCode = parts[1];
      if (linkCode.isEmpty) {
        _showError(context, 'Invalid payment link code');
        context.go('/home');
        return;
      }

      // Validate payment link exists and is active
      try {
        final dio = ref.read(dioProvider);
        final response = await dio.get('/payment-links/$linkCode');
        final data = response.data as Map<String, dynamic>?;
        final status = data?['status'] as String?;
        if (status == 'deactivated' || status == 'expired') {
          if (context.mounted) {
            _showError(context, 'This payment link is no longer active');
            context.go('/home');
          }
          return;
        }
      } catch (e) {
        if (context.mounted) {
          _showError(context, 'Invalid payment link');
          context.go('/home');
        }
        return;
      }

      context.push('/pay/$linkCode');
      return;
    }

    // Handle deposit
    if (normalizedPath == 'deposit') {
      if (!isAuthenticated) {
        _saveForLater(context, '/deposit', params);
        context.go('/login');
        return;
      }

      final method = params['method'];
      context.push('/deposit', extra: {
        if (method != null) 'provider': method,
      });
      return;
    }

    // Handle withdraw
    if (normalizedPath == 'withdraw') {
      if (!isAuthenticated) {
        _saveForLater(context, '/withdraw', params);
        context.go('/login');
        return;
      }

      context.push('/withdraw');
      return;
    }

    // Handle bills
    if (normalizedPath == 'bills' || normalizedPath.startsWith('bills/')) {
      if (!isAuthenticated) {
        _saveForLater(context, '/bills', params);
        context.go('/login');
        return;
      }

      final parts = normalizedPath.split('/');
      if (parts.length == 1) {
        context.push('/bill-payments');
        return;
      }

      final providerId = parts[1];
      context.push('/bill-payments/form/$providerId');
      return;
    }

    // Handle airtime
    if (normalizedPath == 'airtime') {
      if (!isAuthenticated) {
        _saveForLater(context, '/airtime', params);
        context.go('/login');
        return;
      }

      context.push('/airtime');
      return;
    }

    // Handle scan
    if (normalizedPath == 'scan' || normalizedPath == 'scan-to-pay') {
      if (!isAuthenticated) {
        _saveForLater(context, '/scan', params);
        context.go('/login');
        return;
      }

      context.push('/scan-to-pay');
      return;
    }

    // Handle referrals
    if (normalizedPath == 'referrals') {
      if (!isAuthenticated) {
        _saveForLater(context, '/referrals', params);
        context.go('/login');
        return;
      }

      final code = params['code'];
      context.push('/referrals', extra: {
        if (code != null) 'referralCode': code,
      });
      return;
    }

    // Handle notifications
    if (normalizedPath == 'notifications' ||
        normalizedPath.startsWith('notifications/')) {
      if (!isAuthenticated) {
        _saveForLater(context, '/notifications', params);
        context.go('/login');
        return;
      }

      final parts = normalizedPath.split('/');
      if (parts.length == 1) {
        context.push('/notifications');
        return;
      }

      final notificationId = parts[1];
      context.push('/notifications', extra: {
        'notificationId': notificationId,
      });
      return;
    }

    // Unknown path - go to home or login
    _showError(context, 'Unknown link destination');
    if (isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  /// Validate phone number (E.164 format)
  static bool _isValidPhoneNumber(String phone) {
    return RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(phone);
  }

  /// Validate amount
  static bool _isValidAmount(String amount) {
    final parsed = double.tryParse(amount);
    if (parsed == null) return false;
    if (parsed <= 0) return false;
    if (parsed > 1000000) return false; // Max 1M USDC
    return true;
  }

  /// Validate UUID
  static bool _isValidUuid(String id) {
    return RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    ).hasMatch(id);
  }

  /// Save deep link for after authentication using secure storage
  static Future<void> _saveForLater(
    BuildContext context,
    String path,
    Map<String, String> params,
  ) async {
    try {
      await _storage.write(key: _kPendingDeepLinkPath, value: path);
      if (params.isNotEmpty) {
        final encoded = params.entries
            .map((e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        await _storage.write(key: _kPendingDeepLinkParams, value: encoded);
      }
      debugPrint('Saved deep link for after login: $path');
    } catch (e) {
      debugPrint('Error saving deep link: $e');
    }
  }

  /// Show error via snackbar
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Log deep link analytics event
  static void _logDeepLinkEvent(Uri uri, WidgetRef ref) {
    try {
      final analytics = AnalyticsService();
      analytics.trackAction('deep_link_opened', properties: {
        'uri': uri.toString(),
        'path': uri.path,
        'params': uri.queryParameters,
        'utm_source': uri.queryParameters['utm_source'] ?? 'unknown',
        'utm_campaign': uri.queryParameters['utm_campaign'] ?? 'unknown',
        'utm_medium': uri.queryParameters['utm_medium'] ?? 'unknown',
      });
      debugPrint('Deep link opened: ${uri.toString()}');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }
}
