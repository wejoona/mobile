import 'package:flutter/services.dart';

/// Utility for clipboard operations.
class ClipboardUtils {
  ClipboardUtils._();

  /// Copy text to clipboard.
  static Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Read text from clipboard.
  static Future<String?> paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
