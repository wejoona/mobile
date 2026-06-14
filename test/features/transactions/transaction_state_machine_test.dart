import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/storage/hive_models.dart';
import 'package:usdc_wallet/services/storage/sync_service.dart';
import 'package:usdc_wallet/state/app_state.dart';
import 'package:usdc_wallet/state/transaction_state_machine.dart';

import '../../helpers/test_utils.dart';

class _FakeSyncService implements SyncService {
  List<Transaction> cachedTransactions = <Transaction>[];
  int cacheWrites = 0;

  @override
  Future<void> onAppStart() async {}

  @override
  Future<void> onConnectivityRestored() async {}

  @override
  void cacheWalletFromState(WalletState state) {}

  @override
  void cacheTransactionsFromList(List<Transaction> transactions) {
    cacheWrites += 1;
    cachedTransactions = transactions;
  }

  @override
  void cacheUserFromState(UserState state) {}

  @override
  CachedUserProfile? getCachedUserProfile() => null;

  @override
  List<Transaction> cachedTransactionsToDomain() => cachedTransactions;

  @override
  Future<void> clearOnLogout() async {
    cachedTransactions = [];
  }
}

void main() {
  group('TransactionStateMachine', () {
    test(
      'refresh surfaces an error when no current or cached data exists',
      () async {
        final dio = MockDio()
          ..queueErrorResponse(statusCode: 500, message: 'Server down');
        final sync = _FakeSyncService();
        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            localSyncServiceProvider.overrideWithValue(sync),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(transactionStateMachineProvider.notifier)
            .refresh(refreshWallet: false);

        final state = container.read(transactionStateMachineProvider);
        expect(state.status, TransactionListStatus.error);
        expect(state.transactions, isEmpty);
        expect(state.error, isNotNull);
      },
    );

    test('successful refresh caches live transactions', () async {
      final dio = MockDio()
        ..queueResponse({
          'transactions': [
            {
              'id': 'tx_1',
              'walletId': 'wallet_1',
              'type': 'deposit',
              'amountDecimal': '12.50',
              'currency': 'USDC',
              'status': 'completed',
              'createdAt': '2026-06-14T10:00:00.000Z',
            },
          ],
          'total': 1,
          'limit': 20,
          'offset': 0,
          'hasMore': false,
        });
      final sync = _FakeSyncService();
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(dio),
          localSyncServiceProvider.overrideWithValue(sync),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(transactionStateMachineProvider.notifier)
          .refresh(refreshWallet: false);

      final state = container.read(transactionStateMachineProvider);
      expect(state.status, TransactionListStatus.loaded);
      expect(state.transactions.single.id, 'tx_1');
      expect(state.isCached, isFalse);
      expect(sync.cacheWrites, 1);
      expect(sync.cachedTransactions.single.id, 'tx_1');
    });
  });
}
