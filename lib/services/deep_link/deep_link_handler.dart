import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Handles deep link routing for Korido app.
///
/// Supported deep links:
/// - korido://pay/:paymentLinkId → Payment link screen
/// - korido://send?phone=:phone → Pre-filled send screen
/// - korido://receive → QR receive screen
/// - korido://deposit → Deposit screen
/// - https://korido.app/pay/:id → Payment link (universal link)
/// - https://korido.app/referral/:code → Referral code
class DeepLinkHandler {
  final GoRouter _router;

  DeepLinkHandler(this._router);

  /// Route a deep link URI.
  void handleUri(Uri uri) {
    if (kDebugMode) debugPrint('[DeepLink] Handling: $uri');

    final path = uri.path;
    final host = uri.host;

    // korido:// scheme
    if (uri.scheme == 'korido') {
      _handleKoridoScheme(host, uri);
      return;
    }

    // https://korido.app universal links
    if (host == 'korido.app' || host == 'www.korido.app') {
      _handleUniversalLink(path, uri);
      return;
    }

    if (kDebugMode) debugPrint('[DeepLink] Unhandled URI: $uri');
  }

  void _handleKoridoScheme(String host, Uri uri) {
    switch (host) {
      case 'pay':
        final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
        if (id != null) _router.go('/payment-link/$id');
        break;
      case 'send':
        final phone = uri.queryParameters['phone'];
        if (phone != null) {
          _router.go('/send?phone=$phone');
        } else {
          _router.go('/send');
        }
        break;
      case 'receive':
        _router.go('/receive');
        break;
      case 'deposit':
        _router.go('/deposit');
        break;
      default:
        if (kDebugMode) debugPrint('[DeepLink] Unknown korido:// host: $host');
    }
  }

  void _handleUniversalLink(String path, Uri uri) {
    if (path.startsWith('/pay/')) {
      final id = path.substring(5);
      _router.go('/payment-link/$id');
    } else if (path.startsWith('/referral/')) {
      final code = path.substring(10);
      _router.go('/referral?code=$code');
    } else if (path == '/download') {
      // Ignore — this is for non-users
    } else {
      if (kDebugMode) debugPrint('[DeepLink] Unknown universal link: $path');
    }
  }
}
