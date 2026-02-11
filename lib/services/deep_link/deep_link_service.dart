import 'package:flutter/foundation.dart';

/// Service for parsing and generating Korido deep links.
class DeepLinkService {
  static const String scheme = 'korido';
  static const String host = 'app.korido.co';

  /// Parse a deep link URI into a route action.
  static DeepLinkAction? parse(Uri uri) {
    // korido://send?phone=+225...&amount=100
    // https://app.korido.co/send?phone=+225...
    // korido://pay/PLK_xxxxx
    // korido://request?amount=50

    final path = uri.host == host ? uri.path : '/${uri.host}${uri.path}';

    if (path.startsWith('/send')) {
      return DeepLinkAction.send(
        phone: uri.queryParameters['phone'],
        amount: double.tryParse(uri.queryParameters['amount'] ?? ''),
        note: uri.queryParameters['note'],
      );
    }

    if (path.startsWith('/pay/')) {
      final linkId = path.replaceFirst('/pay/', '');
      return DeepLinkAction.payLink(linkId: linkId);
    }

    if (path.startsWith('/request')) {
      return DeepLinkAction.request(
        amount: double.tryParse(uri.queryParameters['amount'] ?? ''),
        from: uri.queryParameters['from'],
      );
    }

    if (path.startsWith('/deposit')) {
      return DeepLinkAction.deposit();
    }

    if (path.startsWith('/referral/')) {
      final code = path.replaceFirst('/referral/', '');
      return DeepLinkAction.referral(code: code);
    }

    debugPrint('Unknown deep link: $uri');
    return null;
  }

  /// Generate a send money deep link.
  static Uri sendLink({
    required String phone,
    double? amount,
    String? note,
  }) {
    return Uri(
      scheme: 'https',
      host: host,
      path: '/send',
      queryParameters: {
        'phone': phone,
        if (amount != null) 'amount': amount.toString(),
        if (note != null) 'note': note,
      },
    );
  }

  /// Generate a payment link URL.
  static Uri paymentLink(String linkId) {
    return Uri(scheme: 'https', host: host, path: '/pay/$linkId');
  }

  /// Generate a referral link.
  static Uri referralLink(String code) {
    return Uri(scheme: 'https', host: host, path: '/referral/$code');
  }
}

/// Parsed deep link action.
sealed class DeepLinkAction {
  const DeepLinkAction();

  factory DeepLinkAction.send({String? phone, double? amount, String? note}) =
      SendAction;
  factory DeepLinkAction.payLink({required String linkId}) = PayLinkAction;
  factory DeepLinkAction.request({double? amount, String? from}) =
      RequestAction;
  factory DeepLinkAction.deposit() = DepositAction;
  factory DeepLinkAction.referral({required String code}) = ReferralAction;
}

class SendAction extends DeepLinkAction {
  final String? phone;
  final double? amount;
  final String? note;
  const SendAction({this.phone, this.amount, this.note});
}

class PayLinkAction extends DeepLinkAction {
  final String linkId;
  const PayLinkAction({required this.linkId});
}

class RequestAction extends DeepLinkAction {
  final double? amount;
  final String? from;
  const RequestAction({this.amount, this.from});
}

class DepositAction extends DeepLinkAction {
  const DepositAction();
}

class ReferralAction extends DeepLinkAction {
  final String code;
  const ReferralAction({required this.code});
}
