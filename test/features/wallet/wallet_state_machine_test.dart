import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
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
            appFsmProvider.overrideWith(() => _NoopAppFsmNotifier()),
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
  });
}
