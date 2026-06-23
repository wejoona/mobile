import 'package:flutter/foundation.dart';

typedef DeepLinkRouteOpener = void Function(String route);

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
  final DeepLinkRouteOpener _openRoute;

  DeepLinkHandler(this._openRoute);

  /// Route a deep link URI.
  void handleUri(Uri uri) {
    if (kDebugMode) debugPrint('[DeepLink] Handling: $uri');

    final path = uri.path;
    final host = uri.host;

    // korido:// scheme. Legacy joonapay:// links remain supported.
    if (uri.scheme == 'korido' || uri.scheme == 'joonapay') {
      _handleKoridoScheme(host, uri);
      return;
    }

    // Korido universal links. Legacy JoonaPay domains remain accepted.
    if (host == 'korido.app' ||
        host == 'www.korido.app' ||
        host == 'app.korido.co' ||
        host == 'joonapay.com' ||
        host == 'www.joonapay.com') {
      _handleUniversalLink(path, uri);
      return;
    }

    if (kDebugMode) debugPrint('[DeepLink] Unhandled URI: $uri');
  }

  void _handleKoridoScheme(String host, Uri uri) {
    switch (host) {
      case 'home':
        _openRoute('/home');
        break;
      case 'pay':
        final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
        if (id != null) {
          _openRoute('/pay/$id');
        } else {
          _goToSend(uri);
        }
        break;
      case 'send':
        _goToSend(uri);
        break;
      case 'receive':
        _openRoute('/receive');
        break;
      case 'deposit':
        _openRoute('/deposit');
        break;
      case 'referral':
      case 'referrals':
        _goToReferrals(uri);
        break;
      case 'transaction':
      case 'transactions':
        if (uri.pathSegments.isNotEmpty) {
          _openRoute('/transactions/${uri.pathSegments.first}');
        }
        break;
      default:
        if (kDebugMode) debugPrint('[DeepLink] Unknown korido:// host: $host');
    }
  }

  void _handleUniversalLink(String path, Uri uri) {
    if (path.startsWith('/pay/')) {
      final id = path.substring(5);
      _openRoute('/pay/$id');
    } else if (path == '/send') {
      _goToSend(uri);
    } else if (path.startsWith('/referral/')) {
      final code = path.substring('/referral/'.length);
      _goToReferrals(uri, code: code);
    } else if (path == '/referrals') {
      _goToReferrals(uri);
    } else if (path.startsWith('/transactions/')) {
      final id = path.substring('/transactions/'.length);
      _openRoute('/transactions/$id');
    } else if (path == '/download') {
      // Ignore — this is for non-users
    } else {
      if (kDebugMode) debugPrint('[DeepLink] Unknown universal link: $path');
    }
  }

  void _goToSend(Uri uri) {
    final phone = uri.queryParameters['phone'] ?? uri.queryParameters['to'];
    if (phone == null || phone.trim().isEmpty) {
      _openRoute('/send');
      return;
    }

    _openRoute(
      Uri(
        path: '/send',
        queryParameters: {
          'phone': phone,
          if (uri.queryParameters['name'] != null)
            'name': uri.queryParameters['name']!,
          if (uri.queryParameters['amount'] != null)
            'amount': uri.queryParameters['amount']!,
          if (uri.queryParameters['note'] != null)
            'note': uri.queryParameters['note']!,
        },
      ).toString(),
    );
  }

  void _goToReferrals(Uri uri, {String? code}) {
    final referralCode = code ?? uri.queryParameters['code'];
    _openRoute(
      Uri(
        path: '/referrals',
        queryParameters: {
          if (referralCode != null && referralCode.trim().isNotEmpty)
            'code': referralCode,
        },
      ).toString(),
    );
  }
}
