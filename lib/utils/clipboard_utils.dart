import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Clipboard utilities for copying text with visual feedback.
class ClipboardUtils {
  ClipboardUtils._();

  /// Copy text to clipboard and show a snackbar.
  static Future<void> copy(
    BuildContext context,
    String text, {
    String? label,
    Duration duration = const Duration(seconds: 2),
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(label ?? 'Copied to clipboard'),
            duration: duration,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  /// Copy a wallet address with truncated preview.
  static Future<void> copyAddress(
    BuildContext context,
    String address,
  ) async {
    final preview = address.length > 12
        ? '${address.substring(0, 6)}...${address.substring(address.length - 4)}'
        : address;
    await copy(context, address, label: 'Address copied: $preview');
  }

  /// Copy a transaction ID.
  static Future<void> copyTransactionId(
    BuildContext context,
    String txId,
  ) async {
    await copy(context, txId, label: 'Transaction ID copied');
  }

  /// Read current clipboard content.
  static Future<String?> read() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
