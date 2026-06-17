import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/state/app_state.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_base.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';

import '../../helpers/test_utils.dart';

class _NoopAppFsmNotifier extends AppFsmNotifier {
  @override
  AppState build() => const AppState.initial();

  @override
  void handleEffects(List<FsmEffect> effects) {}
}

void main() {
  group('WalletStateMachine', () {
    test('availableBalance exposes the spendable USDC balance', () {
      const state = WalletState(usdBalance: 0, usdcBalance: 42.25);

      expect(state.availableBalance, 42.25);
    });

    test(
      'availableBalanceProvider uses the same wallet state as home',
      () async {
        final dio = MockDio();
        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            appFsmProvider.overrideWith(_NoopAppFsmNotifier.new),
          ],
        );
        addTearDown(container.dispose);

        container
            .read(walletStateMachineProvider.notifier)
            .state = const WalletState(
          status: WalletStatus.loaded,
          walletId: 'wallet-home',
          usdcBalance: 42.25,
          pendingBalance: 1.5,
        );

        expect(container.read(availableBalanceProvider), 42.25);
        expect(dio.requestHistory, isEmpty);
      },
    );

    test(
      'creates a wallet automatically when fresh users have no wallet',
      () async {
        final dio = MockDio()
          ..queueErrorResponse(
            statusCode: 404,
            data: {
              'message': 'Wallet not found',
              'error': 'Not Found',
              'statusCode': 404,
            },
          )
          ..queueResponse({
            'id': 'wallet-1',
            'circleWalletAddress': null,
            'currency': 'USDC',
            'balance': 0,
            'status': 'active',
          });

        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            appFsmProvider.overrideWith(_NoopAppFsmNotifier.new),
          ],
        );
        addTearDown(container.dispose);

        await container.read(walletStateMachineProvider.notifier).fetch();

        final requests = dio.requestHistory;
        expect(requests.map((request) => request.method), ['GET', 'POST']);
        expect(requests.map((request) => request.path), [
          '/wallet',
          '/wallet/create',
        ]);

        final state = container.read(walletStateMachineProvider);
        expect(state.status, WalletStatus.loaded);
        expect(state.walletId, 'wallet-1');
        expect(state.usdcBalance, 0);
      },
    );

    test(
      'creates a wallet automatically from live API error envelope',
      () async {
        final dio = MockDio()
          ..queueErrorResponse(
            statusCode: 404,
            data: {
              'success': false,
              'error': {'code': 'NOT_FOUND', 'message': 'Wallet not found'},
              'meta': {'path': '/api/v1/wallet', 'method': 'GET'},
            },
          )
          ..queueResponse({
            'id': 'wallet-live-envelope',
            'userId': 'user-1',
            'circleWalletId': null,
            'circleWalletAddress': null,
            'currency': 'USDC',
            'balance': 0,
            'balanceDecimal': '0.000000',
            'status': 'active',
          });

        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            appFsmProvider.overrideWith(_NoopAppFsmNotifier.new),
          ],
        );
        addTearDown(container.dispose);

        await container.read(walletStateMachineProvider.notifier).fetch();

        expect(dio.requestHistory.map((request) => request.path), [
          '/wallet',
          '/wallet/create',
        ]);

        final state = container.read(walletStateMachineProvider);
        expect(state.status, WalletStatus.loaded);
        expect(state.walletId, 'wallet-live-envelope');
      },
    );

    test('manual refresh recovers a loading wallet state', () async {
      final dio = MockDio()
        ..queueResponse({
          'walletId': 'wallet-refresh',
          'walletAddress': '0xabc',
          'blockchain': 'polygon',
          'balances': [
            {'currency': 'USDC', 'available': 25, 'pending': 1, 'total': 26},
          ],
        });

      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(dio),
          appFsmProvider.overrideWith(_NoopAppFsmNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      container.read(walletStateMachineProvider.notifier).state =
          const WalletState(status: WalletStatus.loading);

      await container.read(walletStateMachineProvider.notifier).refresh();

      expect(dio.requestHistory.map((request) => request.path), ['/wallet']);

      final state = container.read(walletStateMachineProvider);
      expect(state.status, WalletStatus.loaded);
      expect(state.walletId, 'wallet-refresh');
      expect(state.usdcBalance, 25);
    });

    test(
      'uses the first positive spendable backend balance when USDC row is absent',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'walletId': 'wallet-multi-currency',
            'walletAddress': '0xabc',
            'blockchain': 'polygon',
            'currency': 'USD',
            'balances': [
              {
                'currency': 'EUR',
                'availableDecimal': '0.000000',
                'pendingDecimal': '0.000000',
                'totalDecimal': '0.000000',
              },
              {
                'currency': 'USD',
                'availableDecimal': '42.750000',
                'pendingDecimal': '0.250000',
                'totalDecimal': '43.000000',
              },
            ],
          });

        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            appFsmProvider.overrideWith(_NoopAppFsmNotifier.new),
          ],
        );
        addTearDown(container.dispose);

        await container.read(walletStateMachineProvider.notifier).fetch();

        final state = container.read(walletStateMachineProvider);
        expect(state.status, WalletStatus.loaded);
        expect(state.usdcBalance, 42.75);
        expect(state.pendingBalance, 0.25);
      },
    );

    test(
      'hydrates live backend balance metadata and address aliases',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'walletId': 'wallet-live',
            'address': '0xfeedface',
            'blockchain': 'stellar',
            'currency': 'USDC',
            'sourceOfTruth': 'blnk',
            'readStatus': 'fresh',
            'isStale': false,
            'degraded': false,
            'balances': [
              {
                'currency': 'USDC',
                'availableDecimal': '123.450000',
                'pendingDecimal': '6.550000',
                'totalDecimal': '130.000000',
              },
            ],
          });

        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            appFsmProvider.overrideWith(_NoopAppFsmNotifier.new),
          ],
        );
        addTearDown(container.dispose);

        await container.read(walletStateMachineProvider.notifier).fetch();

        final state = container.read(walletStateMachineProvider);
        expect(state.status, WalletStatus.loaded);
        expect(state.walletId, 'wallet-live');
        expect(state.walletAddress, '0xfeedface');
        expect(state.blockchain, 'stellar');
        expect(state.usdcBalance, 123.45);
        expect(state.pendingBalance, 6.55);
        expect(state.balanceSourceOfTruth, 'blnk');
        expect(state.balanceReadStatus, 'fresh');
        expect(state.isStale, isFalse);
        expect(state.isDegraded, isFalse);
      },
    );

    test(
      'uses total-only USDC rows when the backend omits available fields',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'walletId': 'wallet-total-only',
            'walletAddress': '0xabc',
            'blockchain': 'polygon',
            'currency': 'USDC',
            'balances': [
              {'currency': 'USDC', 'totalDecimal': '88.125000'},
            ],
          });

        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            appFsmProvider.overrideWith(_NoopAppFsmNotifier.new),
          ],
        );
        addTearDown(container.dispose);

        await container.read(walletStateMachineProvider.notifier).fetch();

        final state = container.read(walletStateMachineProvider);
        expect(state.status, WalletStatus.loaded);
        expect(state.walletId, 'wallet-total-only');
        expect(state.usdcBalance, 88.125);
      },
    );

    test(
      'manual refresh displays flat live balance when stale rows are empty',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'walletId': 'wallet-flat-live',
            'walletAddress': '0xabc',
            'blockchain': 'polygon',
            'currency': 'USDC',
            'balanceUsdc': '77.125000',
            'availableBalance': '75.000000',
            'pendingBalance': '2.125000',
            'balances': [
              {
                'currency': 'USDC',
                'availableDecimal': '0.000000',
                'pendingDecimal': '0.000000',
                'totalDecimal': '0.000000',
              },
            ],
          });

        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            appFsmProvider.overrideWith(_NoopAppFsmNotifier.new),
          ],
        );
        addTearDown(container.dispose);

        await container.read(walletStateMachineProvider.notifier).refresh();

        final state = container.read(walletStateMachineProvider);
        expect(state.status, WalletStatus.loaded);
        expect(state.usdcBalance, 75);
        expect(state.pendingBalance, 2.125);
        expect(state.availableBalance, 75);
      },
    );

    test(
      'manual refresh creates a wallet when the API reports no wallet',
      () async {
        final dio = MockDio()
          ..queueErrorResponse(
            statusCode: 404,
            data: {
              'success': false,
              'error': {'code': 'NOT_FOUND', 'message': 'Wallet not found'},
            },
          )
          ..queueResponse({
            'id': 'wallet-created-from-refresh',
            'circleWalletAddress': null,
            'currency': 'USDC',
            'balance': 0,
            'balanceDecimal': '0.000000',
            'status': 'active',
          });

        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            appFsmProvider.overrideWith(_NoopAppFsmNotifier.new),
          ],
        );
        addTearDown(container.dispose);

        await container.read(walletStateMachineProvider.notifier).refresh();

        expect(dio.requestHistory.map((request) => request.path), [
          '/wallet',
          '/wallet/create',
        ]);

        final state = container.read(walletStateMachineProvider);
        expect(state.status, WalletStatus.loaded);
        expect(state.walletId, 'wallet-created-from-refresh');
        expect(state.usdcBalance, 0);
      },
    );

    test(
      'wallet creation clears stale balance metadata when response has none',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'id': 'wallet-created-without-source',
            'currency': 'USDC',
            'balance': 0,
            'balanceDecimal': '0.000000',
            'status': 'active',
          });

        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            appFsmProvider.overrideWith(_NoopAppFsmNotifier.new),
          ],
        );
        addTearDown(container.dispose);

        container
            .read(walletStateMachineProvider.notifier)
            .state = const WalletState(
          status: WalletStatus.loaded,
          walletId: 'old-wallet',
          balanceSourceOfTruth: 'blnk',
          balanceReadStatus: 'fresh',
        );

        await container
            .read(walletStateMachineProvider.notifier)
            .createWallet();

        final state = container.read(walletStateMachineProvider);
        expect(state.walletId, 'wallet-created-without-source');
        expect(state.balanceSourceOfTruth, isNull);
        expect(state.balanceReadStatus, isNull);
      },
    );

    test(
      'concurrent manual refreshes share the in-flight wallet request',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'walletId': 'wallet-refresh-once',
            'walletAddress': '0xabc',
            'blockchain': 'polygon',
            'balances': [
              {'currency': 'USDC', 'available': 31, 'pending': 0, 'total': 31},
            ],
          });

        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            appFsmProvider.overrideWith(_NoopAppFsmNotifier.new),
          ],
        );
        addTearDown(container.dispose);

        final firstRefresh = container
            .read(walletStateMachineProvider.notifier)
            .refresh();
        final secondRefresh = container
            .read(walletStateMachineProvider.notifier)
            .refresh();

        await Future.wait([firstRefresh, secondRefresh]);

        expect(dio.requestHistory.map((request) => request.path), ['/wallet']);

        final state = container.read(walletStateMachineProvider);
        expect(state.status, WalletStatus.loaded);
        expect(state.walletId, 'wallet-refresh-once');
        expect(state.usdcBalance, 31);
      },
    );

    test(
      'manual refresh failure preserves balance but marks it cached degraded',
      () async {
        final dio = MockDio()
          ..queueErrorResponse(
            statusCode: 503,
            data: {'message': 'Ledger temporarily unavailable'},
          );

        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            appFsmProvider.overrideWith(_NoopAppFsmNotifier.new),
          ],
        );
        addTearDown(container.dispose);

        container.read(walletStateMachineProvider.notifier).state = WalletState(
          status: WalletStatus.loaded,
          walletId: 'wallet-existing',
          walletAddress: '0xabc',
          blockchain: 'polygon',
          usdcBalance: 42,
          pendingBalance: 1,
          lastUpdated: DateTime.utc(2026, 6, 14),
        );

        await container.read(walletStateMachineProvider.notifier).refresh();

        expect(dio.requestHistory.map((request) => request.path), ['/wallet']);

        final state = container.read(walletStateMachineProvider);
        expect(state.status, WalletStatus.loaded);
        expect(state.walletId, 'wallet-existing');
        expect(state.usdcBalance, 42);
        expect(state.pendingBalance, 1);
        expect(state.isCached, isTrue);
        expect(state.isDegraded, isTrue);
        expect(state.isStale, isTrue);
        expect(state.balanceSourceOfTruth, 'local_cache');
        expect(state.balanceReadStatus, 'cached_degraded');
        expect(state.balanceWarning, contains('Live balance'));
      },
    );
  });
}
