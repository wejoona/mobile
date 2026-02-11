import '../../lib/domain/entities/transaction.dart';
import '../../lib/domain/entities/wallet.dart';
import '../../lib/domain/entities/bank_account.dart';
import '../../lib/domain/entities/card.dart';
import '../../lib/domain/entities/savings_pot.dart';
import '../../lib/domain/entities/notification.dart';
import '../../lib/domain/entities/payment_link.dart';
import '../../lib/domain/entities/recurring_transfer.dart';
import '../../lib/domain/enums/index.dart';

/// Factory methods for creating test entities.
class MockFactories {
  MockFactories._();

  static Transaction transaction({
    String? id,
    TransactionType type = TransactionType.deposit,
    TransactionStatus status = TransactionStatus.completed,
    double amount = 100.0,
    String currency = 'USDC',
  }) {
    return Transaction(
      id: id ?? 'txn_${DateTime.now().millisecondsSinceEpoch}',
      walletId: 'wallet_test',
      type: type,
      status: status,
      amount: amount,
      currency: currency,
      createdAt: DateTime.now(),
    );
  }

  static List<Transaction> transactionList({int count = 5}) {
    return List.generate(count, (i) {
      return transaction(
        id: 'txn_$i',
        type: i.isEven ? TransactionType.deposit : TransactionType.withdrawal,
        amount: (i + 1) * 25.0,
      );
    });
  }

  static BankAccount bankAccount({
    String? id,
    String bankName = 'Test Bank',
    BankAccountStatus status = BankAccountStatus.verified,
  }) {
    return BankAccount(
      id: id ?? 'bank_test',
      userId: 'user_test',
      bankName: bankName,
      accountNumber: '1234567890',
      status: status,
      createdAt: DateTime.now(),
    );
  }
}
