import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/auth/providers/login_provider.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

import '../../../helpers/test_utils.dart';

void main() {
  group('LoginNotifier phone state', () {
    test('prefills empty login state from remembered local phone', () async {
      final storage = MockSecureStorage();
      await storage.write(
        key: StorageKeys.rememberedPhone,
        value: '+225|0748805663',
      );

      final container = ProviderContainer(
        overrides: [secureStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      container.read(loginProvider);
      await pumpEventQueue();

      final state = container.read(loginProvider);
      expect(state.dialCode, '+225');
      expect(state.phoneNumber, '0748805663');
      expect(state.rememberDevice, isTrue);
    });

    test(
      'does not overwrite user input when remembered phone loads late',
      () async {
        final storage = MockSecureStorage();
        await storage.write(
          key: StorageKeys.rememberedPhone,
          value: '+225|0102030405',
        );

        final container = ProviderContainer(
          overrides: [secureStorageProvider.overrideWithValue(storage)],
        );
        addTearDown(container.dispose);

        container
            .read(loginProvider.notifier)
            .updatePhoneNumber('0748805663', '+225');
        await pumpEventQueue();

        final state = container.read(loginProvider);
        expect(state.dialCode, '+225');
        expect(state.phoneNumber, '0748805663');
      },
    );
  });
}
