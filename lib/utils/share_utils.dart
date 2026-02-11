import 'package:flutter/material.dart';
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

    await Share.share(buffer.toString(), subject: 'Korido Transfer Receipt');
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
    await Share.share(text, subject: 'Korido Payment Link');
  }

  /// Share the app download link.
  static Future<void> shareApp({String? referralCode}) async {
    const baseUrl = 'https://korido.app/download';
    final url =
        referralCode != null ? '$baseUrl?ref=$referralCode' : baseUrl;
    await Share.share(
      'Send money instantly with Korido! Download now: $url',
      subject: 'Try Korido',
    );
  }

  /// Share plain text with optional subject.
  static Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  /// Share a QR code image file.
  static Future<void> shareQrCode(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Korido QR Code',
    );
  }
}
