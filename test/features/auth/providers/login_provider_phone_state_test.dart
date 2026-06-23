import 'dart:io';

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

    test('canonicalizes malformed phone state before submit', () async {
      final dio = MockDio()
        ..queueResponse({'message': 'OTP sent', 'expiresIn': 300});
      final storage = MockSecureStorage();
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(dio),
          secureStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(loginProvider.notifier)
          .updatePhoneNumber('+225|+2250748805663', '+225');

      var state = container.read(loginProvider);
      expect(state.dialCode, '+225');
      expect(state.phoneNumber, '0748805663');
      expect(state.phoneValue?.e164, '+2250748805663');

      await container.read(loginProvider.notifier).submitPhoneNumber();

      state = container.read(loginProvider);
      expect(state.currentStep.name, 'otp');
      expect(dio.requestHistory.single.path, '/auth/login');
      expect(dio.requestHistory.single.data, {
        'phone': '+2250748805663',
        'countryCode': 'CI',
      });
      expect(
        await storage.read(key: StorageKeys.rememberedPhone),
        'CI|+225|0748805663|+2250748805663',
      );
    });

    test('shows cooldown copy from OTP request failures', () async {
      final dio = MockDio()
        ..queueErrorResponse(
          statusCode: 429,
          data: {
            'success': false,
            'error': {
              'code': 'E9001',
              'message': 'Too many verification requests',
              'context': {
                'cooldownReason': 'route_throttle',
                'retryAfterSeconds': 120,
                'resendAvailableIn': 120,
              },
            },
          },
        );
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(dio),
          secureStorageProvider.overrideWithValue(MockSecureStorage()),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(loginProvider.notifier)
          .updatePhoneNumber('0748805663', '+225');

      await container.read(loginProvider.notifier).submitPhoneNumber();

      final state = container.read(loginProvider);
      expect(state.isLoading, isFalse);
      expect(
        state.error,
        'Too many verification requests. You can request another in 2 minutes.',
      );
      expect(state.otpResendCountdown, 120);
      expect(dio.requestHistory.single.path, '/auth/login');
      expect(dio.requestHistory.single.data, {
        'phone': '+2250748805663',
        'countryCode': 'CI',
      });
    });

    test('keeps generic login copy for account-safe failures', () async {
      final dio = MockDio()
        ..queueErrorResponse(
          statusCode: 404,
          data: {
            'success': false,
            'error': {'code': 'USER_NOT_FOUND', 'message': 'User not found'},
          },
        );
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(dio),
          secureStorageProvider.overrideWithValue(MockSecureStorage()),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(loginProvider.notifier)
          .updatePhoneNumber('0748805663', '+225');

      await container.read(loginProvider.notifier).submitPhoneNumber();

      expect(
        container.read(loginProvider).error,
        'Unable to log in. Please check your details and try again.',
      );
    });

    test('OTP login sends accounts without PIN to first PIN setup', () {
      final providerSource = File(
        'lib/features/auth/providers/login_provider.dart',
      ).readAsStringSync();
      final viewSource = File(
        'lib/features/auth/views/login_otp_view.dart',
      ).readAsStringSync();

      expect(providerSource, contains('response.user.hasPin'));
      expect(providerSource, contains('LoginStep.needsPinSetup'));
      expect(providerSource, contains("analyticsMethod: 'otp_pin_setup'"));
      expect(viewSource, contains('LoginStep.needsPinSetup'));
      expect(viewSource, contains("context.fsmGo('/setup/set-pin')"));
    });
  });
}
