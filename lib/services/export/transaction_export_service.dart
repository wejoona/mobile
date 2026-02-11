import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';

/// Service for exporting transaction history to CSV.
class TransactionExportService {
  /// Export transactions to CSV and return the file path.
  Future<String> exportToCsv(List<Transaction> transactions) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
      'Date,Type,Status,Amount,Currency,Fee,Recipient,Description,Reference',
    );

    // Rows
    for (final tx in transactions) {
      final date = tx.createdAt.toIso8601String();
      final type = tx.type.name;
      final status = tx.status.name;
      final amount = tx.amount.toStringAsFixed(2);
      final currency = tx.currency;
      final fee = tx.fee?.toStringAsFixed(2) ?? '0.00';
      final recipient = _escapeCsv(tx.recipientPhone ?? tx.recipientAddress ?? '');
      final description = _escapeCsv(tx.description ?? '');
      final reference = tx.reference;

      buffer.writeln(
        '$date,$type,$status,$amount,$currency,$fee,$recipient,$description,$reference',
      );
    }

    // Write to temp file
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/korido_transactions_$timestamp.csv');
    await file.writeAsString(buffer.toString());

    return file.path;
  }

  /// Export a single transaction receipt as text.
  Future<String> exportReceipt(Transaction tx) async {
    final buffer = StringBuffer()
      ..writeln('KORIDO TRANSFER RECEIPT')
      ..writeln('=' * 30)
      ..writeln('Reference: ${tx.reference}')
      ..writeln('Date: ${tx.createdAt}')
      ..writeln('Type: ${tx.type.name}')
      ..writeln('Amount: ${tx.amount} ${tx.currency}')
      ..writeln('Status: ${tx.status.name}');

    if (tx.fee != null && tx.fee! > 0) {
      buffer.writeln('Fee: ${tx.fee} ${tx.currency}');
    }
    if (tx.recipientPhone != null) {
      buffer.writeln('Recipient: ${tx.recipientPhone}');
    }
    if (tx.description != null) {
      buffer.writeln('Description: ${tx.description}');
    }

    buffer.writeln('=' * 30);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/receipt_${tx.id}.txt');
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
