import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/features/insights/providers/insights_provider.dart';

void main() {
  group('customer insights API boundary', () {
    test('visible insights provider uses verified transaction stats route', () {
      final provider = File(
        'lib/features/insights/providers/insights_provider.dart',
      ).readAsStringSync();

      expect(ApiEndpoints.walletTransactionStats, '/wallet/transactions/stats');
      expect(provider, contains('ApiEndpoints.walletTransactionStats'));
      expect(provider, isNot(contains("'/insights")));
      expect(provider, isNot(contains("'/analytics")));
    });

    test('spending insights parse backend transaction stats response', () {
      final insights = SpendingInsights.fromJson({
        'totalTransactions': 7,
        'totalDeposited': 1250,
        'totalDepositedDecimal': '1250.000000',
        'totalWithdrawn': 125,
        'totalWithdrawnDecimal': '125.000000',
        'totalTransferred': 300,
        'totalTransferredDecimal': '300.000000',
      });

      expect(insights.totalReceived, 1250);
      expect(insights.totalSpent, 425);
      expect(insights.netFlow, 825);
      expect(insights.transactionCount, 7);
    });

    test('spending insights parse wrapped backend decimal stats response', () {
      final insights = SpendingInsights.fromJson({
        'data': {
          'totalTransactions': '4',
          'totalDeposited': 999999999,
          'totalDepositedDecimal': '42.500000',
          'totalWithdrawn': 999999999,
          'totalWithdrawnDecimal': '5.250000',
          'totalTransferred': 999999999,
          'totalTransferredDecimal': '10.750000',
        },
      });

      expect(insights.totalReceived, 42.5);
      expect(insights.totalSpent, 16);
      expect(insights.netFlow, 26.5);
      expect(insights.transactionCount, 4);
    });

    test('customer UI is not wired to dormant insights or expenses APIs', () {
      final roots = [
        Directory('lib/features'),
        Directory('lib/router'),
        Directory('lib/providers'),
      ];

      final offenders = <String>{};
      for (final root in roots) {
        if (!root.existsSync()) continue;
        for (final entity in root.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) continue;

          final content = entity.readAsStringSync();
          if (content.contains(".get('/insights") ||
              content.contains('.get("/insights') ||
              content.contains(".post('/insights") ||
              content.contains('.post("/insights') ||
              content.contains(".get('/analytics") ||
              content.contains('.get("/analytics') ||
              content.contains(".post('/analytics") ||
              content.contains('.post("/analytics') ||
              content.contains(".get('/expenses") ||
              content.contains('.get("/expenses') ||
              content.contains(".post('/expenses") ||
              content.contains('.post("/expenses') ||
              content.contains(".put('/expenses") ||
              content.contains('.put("/expenses') ||
              content.contains(".delete('/expenses") ||
              content.contains('.delete("/expenses') ||
              content.contains('services/api/providers/insights_api.dart') ||
              content.contains('services/api/providers/expenses_api.dart') ||
              content.contains('services/expenses/expenses_service.dart')) {
            offenders.add(entity.path);
          }
        }
      }

      expect(
        offenders.toList()..sort(),
        isEmpty,
        reason:
            'Customer screens must use verified transaction stats and local '
            'expense aggregation until backend-owned insights/expenses APIs '
            'are part of the mobile contract.',
      );
    });
  });
}
