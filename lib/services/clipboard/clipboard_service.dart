import 'package:flutter/services.dart';

/// Service for managing clipboard operations with logging.
class ClipboardService {
  /// Copy text to clipboard.
  Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Read from clipboard.
  Future<String?> paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  /// Check if clipboard has text content.
  Future<bool> hasContent() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text?.isNotEmpty ?? false;
  }

  /// Copy a wallet address and return truncated preview.
  Future<String> copyAddress(String address) async {
    await copy(address);
    if (address.length > 12) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    }
    return address;
  }
}
