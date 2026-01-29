import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/services/offline/offline_cache_service.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/beneficiaries/models/beneficiary.dart';

void main() {
  group('OfflineCacheService', () {
    late OfflineCacheService cacheService;

    setUp(() async {
      // Initialize SharedPreferences with empty values for testing
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      cacheService = OfflineCacheService(prefs);
    });

    group('Balance Caching', () {
      test('should cache and retrieve balance', () async {
        const balance = 1234.56;

        await cacheService.cacheBalance(balance);
        final cachedBalance = cacheService.getCachedBalance();

        expect(cachedBalance, balance);
      });

      test('should return null when no balance cached', () {
        final cachedBalance = cacheService.getCachedBalance();
        expect(cachedBalance, isNull);
      });

      test('should update balance when cached multiple times', () async {
        await cacheService.cacheBalance(100.0);
        await cacheService.cacheBalance(200.0);

        final cachedBalance = cacheService.getCachedBalance();
        expect(cachedBalance, 200.0);
      });
    });

    group('Transaction Caching', () {
      test('should cache and retrieve transactions', () async {
        final transactions = [
          Transaction(
            id: '1',
            walletId: 'wallet-1',
            type: TransactionType.deposit,
            status: TransactionStatus.completed,
            amount: 100.0,
            currency: 'USD',
            createdAt: DateTime.now(),
          ),
          Transaction(
            id: '2',
            walletId: 'wallet-1',
            type: TransactionType.transferInternal,
            status: TransactionStatus.completed,
            amount: 50.0,
            currency: 'USD',
            createdAt: DateTime.now(),
          ),
        ];

        await cacheService.cacheTransactions(transactions);
        final cached = cacheService.getCachedTransactions();

        expect(cached, isNotNull);
        expect(cached!.length, 2);
        expect(cached[0].id, '1');
        expect(cached[1].id, '2');
      });

      test('should limit cached transactions to 50', () async {
        final transactions = List.generate(
          60,
          (i) => Transaction(
            id: '$i',
            walletId: 'wallet-1',
            type: TransactionType.deposit,
            status: TransactionStatus.completed,
            amount: 100.0,
            currency: 'USD',
            createdAt: DateTime.now(),
          ),
        );

        await cacheService.cacheTransactions(transactions);
        final cached = cacheService.getCachedTransactions();

        expect(cached!.length, 50);
      });

      test('should return null when no transactions cached', () {
        final cached = cacheService.getCachedTransactions();
        expect(cached, isNull);
      });
    });

    group('Beneficiary Caching', () {
      test('should cache and retrieve beneficiaries', () async {
        final beneficiaries = [
          Beneficiary(
            id: '1',
            walletId: 'wallet-1',
            name: 'Amadou Diallo',
            phoneE164: '+225XXXXXXXX',
            accountType: AccountType.joonapayUser,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Beneficiary(
            id: '2',
            walletId: 'wallet-1',
            name: 'Fatou Traore',
            phoneE164: '+225YYYYYYYY',
            accountType: AccountType.joonapayUser,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        await cacheService.cacheBeneficiaries(beneficiaries);
        final cached = cacheService.getCachedBeneficiaries();

        expect(cached, isNotNull);
        expect(cached!.length, 2);
        expect(cached[0].name, 'Amadou Diallo');
        expect(cached[1].name, 'Fatou Traore');
      });

      test('should return null when no beneficiaries cached', () {
        final cached = cacheService.getCachedBeneficiaries();
        expect(cached, isNull);
      });
    });

    group('Wallet ID Caching', () {
      test('should cache and retrieve wallet ID', () async {
        const walletId = 'wallet-123';

        await cacheService.cacheWalletId(walletId);
        final cached = cacheService.getCachedWalletId();

        expect(cached, walletId);
      });

      test('should return null when no wallet ID cached', () {
        final cached = cacheService.getCachedWalletId();
        expect(cached, isNull);
      });
    });

    group('Sync Metadata', () {
      test('should update last sync timestamp', () async {
        final before = DateTime.now();

        await cacheService.cacheBalance(100.0);

        final lastSync = cacheService.getLastSync();
        expect(lastSync, isNotNull);
        expect(lastSync!.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      });

      test('should return null when never synced', () {
        final lastSync = cacheService.getLastSync();
        expect(lastSync, isNull);
      });
    });

    group('Cache Management', () {
      test('should clear all cached data', () async {
        await cacheService.cacheBalance(100.0);
        await cacheService.cacheWalletId('wallet-1');
        await cacheService.cacheTransactions([]);
        await cacheService.cacheBeneficiaries([]);

        await cacheService.clearCache();

        expect(cacheService.getCachedBalance(), isNull);
        expect(cacheService.getCachedWalletId(), isNull);
        expect(cacheService.getCachedTransactions(), isNull);
        expect(cacheService.getCachedBeneficiaries(), isNull);
        expect(cacheService.getLastSync(), isNull);
      });

      test('should detect if cache exists', () async {
        expect(cacheService.hasCachedData(), isFalse);

        await cacheService.cacheBalance(100.0);
        expect(cacheService.hasCachedData(), isTrue);
      });
    });
  });
}
