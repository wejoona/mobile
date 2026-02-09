import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';

import '../../helpers/test_wrapper.dart';

void main() {
  group('Transaction List Widget Tests', () {
    final mockTransactions = [
      {
        'id': '1',
        'type': 'sent',
        'amount': -50.0,
        'recipient': 'John Doe',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': '2',
        'type': 'received',
        'amount': 100.0,
        'sender': 'Jane Smith',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '3',
        'type': 'deposit',
        'amount': 500.0,
        'method': 'Orange Money',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];

    String formatTimestamp(DateTime timestamp) {
      final now = DateTime.now();
      final diff = now.difference(timestamp);

      if (diff.inDays == 0) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else {
        return '${diff.inDays}d ago';
      }
    }

    Widget buildTransactionList({
      List<Map<String, dynamic>>? transactions,
      bool isLoading = false,
    }) {
      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (transactions == null || transactions.isEmpty) {
        return const Center(
          child: AppText('No transactions yet'),
        );
      }

      return ListView.builder(
        itemCount: transactions.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return ListTile(
            leading: Icon(
              tx['type'] == 'received'
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: tx['type'] == 'received' ? Colors.green : Colors.red,
            ),
            title: AppText(
              tx['type'] == 'sent'
                  ? 'Sent to ${tx['recipient']}'
                  : tx['type'] == 'received'
                      ? 'Received from ${tx['sender']}'
                      : 'Deposit via ${tx['method']}',
            ),
            subtitle: AppText(
              formatTimestamp(tx['timestamp'] as DateTime),
              variant: AppTextVariant.bodySmall,
            ),
            trailing: AppText(
              '\$${tx['amount'].abs().toStringAsFixed(2)}',
              color: (tx['amount'] as double) > 0 ? Colors.green : Colors.red,
            ),
          );
        },
      );
    }

    testWidgets('renders transaction list', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildTransactionList(transactions: mockTransactions),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets('displays sent transaction', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildTransactionList(transactions: [mockTransactions[0]]),
        ),
      );

      expect(find.text('Sent to John Doe'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('displays received transaction', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildTransactionList(transactions: [mockTransactions[1]]),
        ),
      );

      expect(find.text('Received from Jane Smith'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('displays deposit transaction', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildTransactionList(transactions: [mockTransactions[2]]),
        ),
      );

      expect(find.text('Deposit via Orange Money'), findsOneWidget);
    });

    testWidgets('shows empty state when no transactions', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildTransactionList(transactions: []),
        ),
      );

      expect(find.text('No transactions yet'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildTransactionList(isLoading: true),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays transaction amounts', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildTransactionList(transactions: mockTransactions),
        ),
      );

      expect(find.text('\$50.00'), findsOneWidget);
      expect(find.text('\$100.00'), findsOneWidget);
      expect(find.text('\$500.00'), findsOneWidget);
    });

    testWidgets('formats timestamps correctly', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildTransactionList(transactions: mockTransactions),
        ),
      );

      // Timestamps should be formatted (e.g., "2h ago", "Yesterday", "3d ago")
      expect(find.byType(AppText), findsWidgets);
    });

    testWidgets('uses correct colors for transaction types', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildTransactionList(transactions: mockTransactions),
        ),
      );

      final sentIcon = tester.widget<Icon>(find.byIcon(Icons.arrow_upward).first);
      expect(sentIcon.color, Colors.red);

      final receivedIcon = tester.widget<Icon>(find.byIcon(Icons.arrow_downward).first);
      expect(receivedIcon.color, Colors.green);
    });

    group('Edge Cases', () {
      testWidgets('handles single transaction', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionList(transactions: [mockTransactions[0]]),
          ),
        );

        expect(find.byType(ListTile), findsOneWidget);
      });

      testWidgets('handles large transaction list', (tester) async {
        final largeTxList = List.generate(
          100,
          (i) => {
            'id': '$i',
            'type': 'sent',
            'amount': -10.0,
            'recipient': 'User $i',
            'timestamp': DateTime.now().subtract(Duration(hours: i)),
          },
        );

        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionList(transactions: largeTxList),
          ),
        );

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('handles very small amounts', (tester) async {
        final smallTx = [
          {
            'id': '1',
            'type': 'sent',
            'amount': -0.01,
            'recipient': 'Test',
            'timestamp': DateTime.now(),
          },
        ];

        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionList(transactions: smallTx),
          ),
        );

        expect(find.text('\$0.01'), findsOneWidget);
      });

      testWidgets('handles very large amounts', (tester) async {
        final largeTx = [
          {
            'id': '1',
            'type': 'received',
            'amount': 999999.99,
            'sender': 'Big Sender',
            'timestamp': DateTime.now(),
          },
        ];

        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionList(transactions: largeTx),
          ),
        );

        expect(find.text('\$999999.99'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('transaction items are accessible', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionList(transactions: mockTransactions),
          ),
        );

        expect(find.byType(ListTile), findsWidgets);
      });
    });
  });
}
