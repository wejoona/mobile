import 'package:share_plus/share_plus.dart';

/// Centralized sharing utilities.
class ShareUtils {
  ShareUtils._();

  /// Share a transaction receipt.
  static Future<void> shareTransactionReceipt({
    required String transactionId,
    required double amount,
    required String currency,
    required String recipientName,
    required DateTime date,
    String? note,
  }) async {
    final dateStr =
        '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    final buffer = StringBuffer()
      ..writeln('Korido Transfer Receipt')
      ..writeln('─' * 28)
      ..writeln('Amount: $amount $currency')
      ..writeln('To: $recipientName')
      ..writeln('Date: $dateStr')
      ..writeln('Ref: $transactionId');
    if (note != null && note.isNotEmpty) {
      buffer.writeln('Note: $note');
    }
    buffer.writeln('─' * 28);

    await SharePlus.instance.share(ShareParams(text: buffer.toString(), title: 'Korido Transfer Receipt'));
  }

  /// Share a payment link.
  static Future<void> sharePaymentLink({
    required String url,
    required double amount,
    required String currency,
    String? description,
  }) async {
    final text = description != null
        ? 'Pay $amount $currency for $description: $url'
        : 'Pay $amount $currency via Korido: $url';
    await SharePlus.instance.share(ShareParams(text: text, title: 'Korido Payment Link'));
  }

  /// Share the app download link.
  static Future<void> shareApp({String? referralCode}) async {
    const baseUrl = 'https://korido.app/download';
    final url = referralCode != null ? '$baseUrl?ref=$referralCode' : baseUrl;
    await SharePlus.instance.share(ShareParams(
      text: 'Send money instantly with Korido! Download now: $url',
      title: 'Try Korido',
    ));
  }

  /// Share plain text with optional subject.
  static Future<void> shareText(String text, {String? subject}) async {
    await SharePlus.instance.share(ShareParams(text: text, title: subject));
  }

  /// Share a QR code image file.
  static Future<void> shareQrCode(String filePath) async {
    await SharePlus.instance.share(ShareParams(
      files: [XFile(filePath)],
      title: 'Korido QR Code',
    ));
  }
}
