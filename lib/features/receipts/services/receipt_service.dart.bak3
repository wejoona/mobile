import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/enums/index.dart';
import '../models/receipt_data.dart';
import '../models/receipt_format.dart';

/// Service for generating and sharing transaction receipts
class ReceiptService {
  /// Generate receipt image from transaction
  /// Returns PNG bytes
  ///
  /// Note: This is a simplified implementation that returns a placeholder.
  /// For full implementation, use screenshot package with a GlobalKey
  /// attached to ReceiptWidget in a visible widget tree.
  Future<Uint8List> generateReceiptImage(Transaction transaction) async {
    // TODO: Implement proper image generation using screenshot package
    // For now, generate using PDF and return placeholder

    // Throw UnsupportedError to indicate this needs proper implementation
    throw UnsupportedError(
      'Image generation requires implementing screenshot capture with GlobalKey. '
      'Use generateReceiptPdf() instead or implement screenshot capture in UI layer.',
    );
  }

  /// Generate receipt PDF from transaction
  /// Returns PDF bytes
  Future<Uint8List> generateReceiptPdf(Transaction transaction) async {
    final receiptData = ReceiptData.fromTransaction(transaction);
    final pdf = pw.Document();

    final dateFormatter = DateFormat('MMM dd, yyyy  •  HH:mm');
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Container(
                        width: 80,
                        height: 80,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#D4AF37'),
                          borderRadius: pw.BorderRadius.circular(16),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'JP',
                            style: pw.TextStyle(
                              fontSize: 32,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      pw.Text(
                        'TRANSACTION RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 32),

                // Status
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: _getPdfStatusColor(receiptData),
                        width: 2,
                      ),
                      borderRadius: pw.BorderRadius.circular(24),
                    ),
                    child: pw.Text(
                      receiptData.getStatusLabel().toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: _getPdfStatusColor(receiptData),
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 32),

                // Divider
                pw.Divider(),
                pw.SizedBox(height: 24),

                // Amount Section
                _buildPdfRow('Amount', currencyFormatter.format(receiptData.amount)),
                if (receiptData.fee > 0) ...[
                  pw.SizedBox(height: 12),
                  _buildPdfRow('Fee', currencyFormatter.format(receiptData.fee)),
                ],
                pw.SizedBox(height: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: _buildPdfRow(
                    'Total',
                    '${currencyFormatter.format(receiptData.total)} ${receiptData.currency}',
                    isBold: true,
                  ),
                ),
                pw.SizedBox(height: 24),

                // Divider
                pw.Divider(),
                pw.SizedBox(height: 24),

                // Recipient (if applicable)
                if (receiptData.recipientPhone != null || receiptData.recipientAddress != null) ...[
                  pw.Text(
                    'Recipient',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  if (receiptData.recipientPhone != null)
                    _buildPdfRow('Phone', receiptData.recipientPhone!),
                  if (receiptData.recipientAddress != null) ...[
                    pw.SizedBox(height: 8),
                    _buildPdfRow('Address', receiptData.recipientAddress!),
                  ],
                  pw.SizedBox(height: 24),
                  pw.Divider(),
                  pw.SizedBox(height: 24),
                ],

                // Transaction Details
                _buildPdfRow('Date', dateFormatter.format(receiptData.date)),
                pw.SizedBox(height: 12),
                _buildPdfRow('Reference', receiptData.referenceNumber),
                pw.SizedBox(height: 12),
                _buildPdfRow('Type', receiptData.getTypeLabel()),
                if (receiptData.description != null) ...[
                  pw.SizedBox(height: 12),
                  _buildPdfRow('Note', receiptData.description!),
                ],
                pw.SizedBox(height: 32),

                // Divider
                pw.Divider(),
                pw.SizedBox(height: 24),

                // QR Code
                pw.Center(
                  child: pw.BarcodeWidget(
                    data: receiptData.referenceNumber,
                    barcode: pw.Barcode.qrCode(),
                    width: 120,
                    height: 120,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    receiptData.truncatedId,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),

                pw.Spacer(),

                // Footer
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Thank you for using',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'JoonaPay',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#D4AF37'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Save receipt image to device gallery
  Future<bool> saveToGallery(Uint8List imageBytes, String fileName) async {
    try {
      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        name: fileName,
        quality: 100,
      );
      return result['isSuccess'] ?? false;
    } catch (e) {
      debugPrint('Error saving to gallery: $e');
      return false;
    }
  }

  /// Share receipt via system share sheet
  Future<void> shareReceipt({
    required Transaction transaction,
    required ReceiptFormat format,
    String? customMessage,
  }) async {
    final receiptData = ReceiptData.fromTransaction(transaction);
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'JoonaPay_Receipt_$timestamp';

    // For now, always use PDF format until image generation is implemented
    final pdfBytes = await generateReceiptPdf(transaction);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName.pdf');
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: customMessage ?? 'Payment receipt from JoonaPay\n\nRef: ${receiptData.referenceNumber}',
    );
  }

  /// Share receipt via WhatsApp
  Future<bool> shareViaWhatsApp({
    required Transaction transaction,
    String? phoneNumber,
  }) async {
    try {
      final receiptData = ReceiptData.fromTransaction(transaction);
      final dateStr = DateFormat('MMM dd, yyyy').format(receiptData.date);
      final amountStr = NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(receiptData.total);

      final message = '''
Payment receipt from JoonaPay

Amount: $amountStr ${receiptData.currency}
Date: $dateStr
Reference: ${receiptData.referenceNumber}
Status: ${receiptData.getStatusLabel()}

Thank you for using JoonaPay!
''';

      final encodedMessage = Uri.encodeComponent(message);
      final url = phoneNumber != null
          ? 'whatsapp://send?phone=$phoneNumber&text=$encodedMessage'
          : 'whatsapp://send?text=$encodedMessage';

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      debugPrint('Error sharing via WhatsApp: $e');
      return false;
    }
  }

  /// Share receipt via email
  Future<bool> shareViaEmail({
    required Transaction transaction,
    required String recipientEmail,
  }) async {
    try {
      final receiptData = ReceiptData.fromTransaction(transaction);
      final dateStr = DateFormat('MMM dd, yyyy • HH:mm').format(receiptData.date);
      final amountStr = NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(receiptData.total);

      final subject = Uri.encodeComponent('JoonaPay Transaction Receipt - ${receiptData.referenceNumber}');
      final body = Uri.encodeComponent('''
Dear Customer,

Here is your transaction receipt from JoonaPay:

Transaction ID: ${receiptData.transactionId}
Reference: ${receiptData.referenceNumber}
Date: $dateStr
Type: ${receiptData.getTypeLabel()}
Amount: $amountStr ${receiptData.currency}
Status: ${receiptData.getStatusLabel()}

${receiptData.description != null ? 'Note: ${receiptData.description}\n\n' : ''}
Thank you for using JoonaPay!

Best regards,
The JoonaPay Team
''');

      final uri = Uri.parse('mailto:$recipientEmail?subject=$subject&body=$body');
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      return false;
    } catch (e) {
      debugPrint('Error sharing via email: $e');
      return false;
    }
  }

  pw.Widget _buildPdfRow(String label, String value, {bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  PdfColor _getPdfStatusColor(ReceiptData receiptData) {
    switch (receiptData.status) {
      case TransactionStatus.completed:
        return PdfColor.fromHex('#10B981');
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return PdfColor.fromHex('#F59E0B');
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return PdfColor.fromHex('#EF4444');
    }
  }
}
