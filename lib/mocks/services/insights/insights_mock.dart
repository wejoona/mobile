import 'dart:math';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/domain/enums/index.dart';

/// Mock data generator for insights testing
class InsightsMock {
  static final Random _random = Random();

  /// Generate mock transactions for the last 3 months
  static List<Transaction> generateMockTransactions() {
    final transactions = <Transaction>[];
    final now = DateTime.now();

    // Generate 50-100 transactions over 90 days
    final transactionCount = 50 + _random.nextInt(50);

    for (int i = 0; i < transactionCount; i++) {
      // Random date within last 90 days
      final daysAgo = _random.nextInt(90);
      final createdAt = now.subtract(Duration(days: daysAgo));

      // Random transaction type
      final types = [
        TransactionType.withdrawal,
        TransactionType.transferExternal,
        TransactionType.transferInternal,
        TransactionType.deposit,
      ];
      final type = types[_random.nextInt(types.length)];

      // Random amount based on type
      double amount;
      String? category;
      switch (type) {
        case TransactionType.withdrawal:
          amount = 10 + _random.nextDouble() * 200; // $10-$210
          category = 'Bills';
          break;
        case TransactionType.transferExternal:
        case TransactionType.transferInternal:
          amount = 5 + _random.nextDouble() * 100; // $5-$105
          category = 'Transfers';
          break;
        case TransactionType.deposit:
          amount = 50 + _random.nextDouble() * 500; // $50-$550
          category = 'Deposits';
          break;
      }

      final fee = type == TransactionType.withdrawal ? 0.5 + _random.nextDouble() : null;

      transactions.add(Transaction(
        id: 'txn_${i}_${DateTime.now().millisecondsSinceEpoch}',
        walletId: 'wallet_test',
        type: type,
        status: TransactionStatus.completed,
        amount: amount,
        currency: 'USD',
        fee: fee,
        description: _getDescription(type, category),
        recipientPhone: type != TransactionType.deposit ? _getRecipientPhone() : null,
        recipientWalletId: type == TransactionType.transferInternal
            ? 'wallet_${_random.nextInt(10)}'
            : null,
        recipientAddress: type == TransactionType.transferExternal
            ? '0x${_random.nextInt(999999999).toRadixString(16).padLeft(40, '0')}'
            : null,
        metadata: category != null // ignore: unnecessary_null_comparison
            ? {
                'category': category,
                'recipientName': _getRecipientName(),
              }
            // ignore: dead_code
            : null,
        createdAt: createdAt,
        completedAt: createdAt.add(Duration(minutes: 1 + _random.nextInt(10))),
      ));
    }

    // Sort by date descending
    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return transactions;
  }

  static String _getDescription(TransactionType type, String? category) {
    switch (type) {
      case TransactionType.withdrawal:
        return 'Bill payment';
      case TransactionType.transferExternal:
        return 'External transfer';
      case TransactionType.transferInternal:
        return 'Sent to friend';
      case TransactionType.deposit:
        return 'Mobile money deposit';
    }
  }

  static String _getRecipientPhone() {
    final phones = [
      '+225 07 12 34 56',
      '+225 05 87 65 43',
      '+221 77 123 45 67',
      '+223 70 11 22 33',
      '+225 01 98 76 54',
    ];
    return phones[_random.nextInt(phones.length)];
  }

  static String _getRecipientName() {
    final names = [
      'Amadou Diallo',
      'Fatou Traoré',
      'Ousmane Kone',
      'Aissata Sy',
      'Ibrahim Camara',
      'Mariama Sanogo',
      'Moussa Coulibaly',
      'Kadiatou Keita',
    ];
    return names[_random.nextInt(names.length)];
  }
}
