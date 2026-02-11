/// Parses QR code content into deep link actions.
/// Supports Korido QR codes, wallet addresses, and payment links.
library;

import 'deep_link_service.dart';

/// Parses scanned QR code data into actionable deep link results.
class QrDeepLinkParser {
  const QrDeepLinkParser._();

  /// Parse raw QR code data into a deep link action.
  static QrParseResult parse(String rawData) {
    final trimmed = rawData.trim();

    // Try as URI first (korido:// or https://app.korido.co/...)
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) {
      final action = DeepLinkService.parse(uri);
      if (action != null) {
        return QrParseResult.deepLink(action);
      }
    }

    // Check for Stellar address (starts with G, 56 chars)
    if (RegExp(r'^G[A-Z2-7]{55}$').hasMatch(trimmed)) {
      return QrParseResult.walletAddress(
        address: trimmed,
        network: 'stellar',
      );
    }

    // Check for Solana address (32-44 base58 chars)
    if (RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$').hasMatch(trimmed)) {
      return QrParseResult.walletAddress(
        address: trimmed,
        network: 'solana',
      );
    }

    // Check for Korido payment link ID format (PLK_xxxxx)
    if (RegExp(r'^PLK_[a-zA-Z0-9]+$').hasMatch(trimmed)) {
      return QrParseResult.deepLink(DeepLinkAction.payLink(linkId: trimmed));
    }

    // Check for phone number
    if (RegExp(r'^\+?[0-9]{8,15}$').hasMatch(trimmed)) {
      return QrParseResult.phoneNumber(trimmed);
    }

    return QrParseResult.unknown(trimmed);
  }
}

/// Result of parsing a QR code.
sealed class QrParseResult {
  const QrParseResult();

  factory QrParseResult.deepLink(DeepLinkAction action) = QrDeepLink;
  factory QrParseResult.walletAddress({
    required String address,
    required String network,
  }) = QrWalletAddress;
  factory QrParseResult.phoneNumber(String phone) = QrPhoneNumber;
  factory QrParseResult.unknown(String rawData) = QrUnknown;
}

class QrDeepLink extends QrParseResult {
  final DeepLinkAction action;
  const QrDeepLink(this.action);
}

class QrWalletAddress extends QrParseResult {
  final String address;
  final String network;
  const QrWalletAddress({required this.address, required this.network});
}

class QrPhoneNumber extends QrParseResult {
  final String phone;
  const QrPhoneNumber(this.phone);
}

class QrUnknown extends QrParseResult {
  final String rawData;
  const QrUnknown(this.rawData);
}
