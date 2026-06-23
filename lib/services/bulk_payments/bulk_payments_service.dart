import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';
import 'package:usdc_wallet/features/bulk_payments/models/bulk_batch.dart';
import 'package:usdc_wallet/features/bulk_payments/models/bulk_payment.dart';

class BulkPaymentsService {
  final Dio _dio;

  BulkPaymentsService(this._dio);

  Future<List<BulkBatch>> getBatches() async {
    final response = await _dio.get('/bulk-payments/batches');
    final data = response.data;
    // Backend returns { batches: [...] }; handle both wrapped and direct list
    final List items;
    if (data is Map && data.containsKey('batches')) {
      items = data['batches'] as List? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      items = [];
    }
    return items
        .whereType<Map>()
        .map((json) => BulkBatch.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<BulkBatch> submitBatch(
    BulkBatch batch, {
    required String pinToken,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post(
      '/bulk-payments/batches',
      data: {
        'name': batch.name,
        'payments': batch.validPayments.map((p) => p.toJson()).toList(),
      },
      options: Options(
        headers: transactionHeaders(
          pinToken: pinToken,
          idempotencyKey: idempotencyKey,
        ),
      ),
    );
    return BulkBatch.fromJson(_batchPayload(response.data));
  }

  Future<BulkBatch> getBatchStatus(String batchId) async {
    final response = await _dio.get('/bulk-payments/batches/$batchId');
    return BulkBatch.fromJson(_batchPayload(response.data));
  }

  Future<String> downloadFailedPayments(String batchId) async {
    final response = await _dio.get(
      '/bulk-payments/batches/$batchId/failed-report',
    );
    final data = response.data;
    if (data is Map) return data['csv'] as String? ?? '';
    return data?.toString() ?? '';
  }

  // === Compatibility methods used by older bulk screens ===
  Future<List<dynamic>> getBulkPayments() async => [];

  Future<BulkBatch> parseCsvFile(String csvContent) async {
    final lines = const LineSplitter()
        .convert(csvContent)
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return BulkBatch.fromPayments(
        id: _draftId(),
        name: 'Bulk payment draft',
        payments: const [],
      );
    }

    final rows = lines.map(_parseCsvLine).toList();
    final dataRows = _looksLikeHeader(rows.first) ? rows.skip(1) : rows;
    final payments = dataRows.map(BulkPayment.fromCsvRow).toList();

    return BulkBatch.fromPayments(
      id: _draftId(),
      name: 'Bulk payment draft',
      payments: payments,
    );
  }

  Map<String, dynamic> _batchPayload(dynamic data) {
    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }
}

String _draftId() => 'draft-${DateTime.now().microsecondsSinceEpoch}';

bool _looksLikeHeader(List<String> row) {
  if (row.length < 2) return false;
  final first = row.first.trim().toLowerCase();
  final second = row[1].trim().toLowerCase();
  return first.contains('phone') ||
      first.contains('number') ||
      second.contains('amount') ||
      second.contains('montant');
}

List<String> _parseCsvLine(String line) {
  final values = <String>[];
  final buffer = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        buffer.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char == ',' && !inQuotes) {
      values.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }

  values.add(buffer.toString());
  return values;
}
