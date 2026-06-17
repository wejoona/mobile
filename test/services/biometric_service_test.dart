import 'package:local_auth_platform_interface/types/auth_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_platform_interface/types/biometric_type.dart'
    as platform;
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import '../helpers/test_utils.dart';

// Create a mock for FlutterSecureStorage
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockLocalAuthentication mockAuth;
  late MockFlutterSecureStorage mockStorage;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockAuth = MockLocalAuthentication();
    mockStorage = MockFlutterSecureStorage();
  });

  BiometricService service() => BiometricService(mockAuth, mockStorage);

  void stubBiometricAvailable() {
    when(() => mockAuth.canCheckBiometrics).thenAnswer((_) async => true);
  }

  group('Check device biometric support', () {
    test('should return true when device supports biometrics', () async {
      // Arrange
      when(() => mockAuth.isDeviceSupported()).thenAnswer((_) async => true);
      final biometricService = service();

      // Act
      final result = await biometricService.isDeviceSupported();

      // Assert
      expect(result, isTrue);
    });

    test(
      'should return false when device does not support biometrics',
      () async {
        // Arrange
        when(() => mockAuth.isDeviceSupported()).thenAnswer((_) async => false);
        final biometricService = service();

        // Act
        final result = await biometricService.isDeviceSupported();

        // Assert
        expect(result, isFalse);
      },
    );
  });

  group('Get available biometric types', () {
    test('should return fingerprint when available', () async {
      // Arrange
      when(
        () => mockAuth.getAvailableBiometrics(),
      ).thenAnswer((_) async => [platform.BiometricType.fingerprint]);
      final biometricService = service();

      // Act
      final result = await biometricService.getAvailableBiometrics();

      // Assert
      expect(result, contains(BiometricType.fingerprint));
    });

    test('should return faceId when face is available', () async {
      // Arrange
      when(
        () => mockAuth.getAvailableBiometrics(),
      ).thenAnswer((_) async => [platform.BiometricType.face]);
      final biometricService = service();

      // Act
      final result = await biometricService.getAvailableBiometrics();

      // Assert
      expect(result, contains(BiometricType.faceId));
    });

    test('should return multiple types when available', () async {
      // Arrange
      when(() => mockAuth.getAvailableBiometrics()).thenAnswer(
        (_) async => [
          platform.BiometricType.fingerprint,
          platform.BiometricType.face,
        ],
      );
      final biometricService = service();

      // Act
      final result = await biometricService.getAvailableBiometrics();

      // Assert
      expect(result.length, equals(2));
    });

    test('should return empty list when no biometrics available', () async {
      // Arrange
      when(() => mockAuth.getAvailableBiometrics()).thenAnswer((_) async => []);
      final biometricService = service();

      // Act
      final result = await biometricService.getAvailableBiometrics();

      // Assert
      expect(result, isEmpty);
    });

    test('should handle PlatformException gracefully', () async {
      // Arrange
      when(() => mockAuth.getAvailableBiometrics()).thenThrow(
        const LocalAuthException(
          code: LocalAuthExceptionCode.noBiometricHardware,
        ),
      );
      final biometricService = service();

      // Act
      final result = await biometricService.getAvailableBiometrics();

      // Assert
      expect(result, isEmpty);
    });
  });

  group('Authenticate with fingerprint/face', () {
    test('should return true on successful authentication', () async {
      // Arrange
      stubBiometricAvailable();
      when(
        () => mockAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          authMessages: any(named: 'authMessages'),
          biometricOnly: any(named: 'biometricOnly'),
          sensitiveTransaction: any(named: 'sensitiveTransaction'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenAnswer((_) async => true);
      final biometricService = service();

      // Act
      final result = await biometricService.authenticate();

      // Assert
      expect(result.success, isTrue);
    });

    test('should return false when authentication fails', () async {
      // Arrange
      stubBiometricAvailable();
      when(
        () => mockAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          authMessages: any(named: 'authMessages'),
          biometricOnly: any(named: 'biometricOnly'),
          sensitiveTransaction: any(named: 'sensitiveTransaction'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenAnswer((_) async => false);
      final biometricService = service();

      // Act
      final result = await biometricService.authenticate();

      // Assert
      expect(result.success, isFalse);
      expect(result.failureReason, BiometricFailureReason.cancelled);
    });

    test('should use custom reason when provided', () async {
      // Arrange
      stubBiometricAvailable();
      when(
        () => mockAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          authMessages: any(named: 'authMessages'),
          biometricOnly: any(named: 'biometricOnly'),
          sensitiveTransaction: any(named: 'sensitiveTransaction'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenAnswer((_) async => true);
      final biometricService = service();

      // Act
      await biometricService.authenticate(localizedReason: 'Custom reason');

      // Assert
      verify(
        () => mockAuth.authenticate(
          localizedReason: 'Custom reason',
          authMessages: any(named: 'authMessages'),
          biometricOnly: any(named: 'biometricOnly'),
          sensitiveTransaction: any(named: 'sensitiveTransaction'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).called(1);
    });
  });

  group('Handle authentication failure', () {
    test('should handle PlatformException', () async {
      // Arrange
      stubBiometricAvailable();
      when(
        () => mockAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          authMessages: any(named: 'authMessages'),
          biometricOnly: any(named: 'biometricOnly'),
          sensitiveTransaction: any(named: 'sensitiveTransaction'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenThrow(
        const LocalAuthException(
          code: LocalAuthExceptionCode.noBiometricsEnrolled,
        ),
      );
      final biometricService = service();

      // Act
      final result = await biometricService.authenticate();

      // Assert
      expect(result.success, isFalse);
      expect(result.failureReason, BiometricFailureReason.notEnrolled);
    });

    test('should handle NotAvailable exception', () async {
      // Arrange
      stubBiometricAvailable();
      when(
        () => mockAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          authMessages: any(named: 'authMessages'),
          biometricOnly: any(named: 'biometricOnly'),
          sensitiveTransaction: any(named: 'sensitiveTransaction'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenThrow(
        const LocalAuthException(
          code: LocalAuthExceptionCode.noBiometricHardware,
        ),
      );
      final biometricService = service();

      // Act
      final result = await biometricService.authenticate();

      // Assert
      expect(result.success, isFalse);
      expect(result.failureReason, BiometricFailureReason.notEnrolled);
    });
  });

  group('Enable/disable biometric preference', () {
    test('should save enabled preference to storage', () async {
      // Arrange
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async {});
      final biometricService = service();

      // Act
      await biometricService.enableBiometric(userId: 'user-1');

      // Assert
      verify(
        () => mockStorage.write(
          key: StorageKeys.biometricEnabled,
          value: 'true',
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).called(1);
      verify(
        () => mockStorage.write(
          key: 'biometric_user_id',
          value: 'user-1',
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).called(1);
    });

    test('should save disabled preference to storage', () async {
      // Arrange
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => mockStorage.delete(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async {});
      final biometricService = service();

      // Act
      await biometricService.disableBiometric();

      // Assert
      verify(
        () => mockStorage.write(
          key: StorageKeys.biometricEnabled,
          value: 'false',
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).called(1);
    });

    test('should return true when biometric is enabled', () async {
      // Arrange
      when(
        () => mockStorage.read(
          key: StorageKeys.biometricEnabled,
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async => 'true');
      when(
        () => mockStorage.read(
          key: 'biometric_user_id',
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async => 'user-1');
      when(
        () => mockStorage.read(
          key: 'user_id',
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async => 'user-1');
      final biometricService = service();

      // Act
      final result = await biometricService.isBiometricEnabled();

      // Assert
      expect(result, isTrue);
    });

    test(
      'should return false when biometric belongs to another user',
      () async {
        // Arrange
        when(
          () => mockStorage.read(
            key: StorageKeys.biometricEnabled,
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
            lOptions: any(named: 'lOptions'),
            webOptions: any(named: 'webOptions'),
            mOptions: any(named: 'mOptions'),
            wOptions: any(named: 'wOptions'),
          ),
        ).thenAnswer((_) async => 'true');
        when(
          () => mockStorage.read(
            key: 'biometric_user_id',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
            lOptions: any(named: 'lOptions'),
            webOptions: any(named: 'webOptions'),
            mOptions: any(named: 'mOptions'),
            wOptions: any(named: 'wOptions'),
          ),
        ).thenAnswer((_) async => 'user-a');
        when(
          () => mockStorage.read(
            key: 'user_id',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
            lOptions: any(named: 'lOptions'),
            webOptions: any(named: 'webOptions'),
            mOptions: any(named: 'mOptions'),
            wOptions: any(named: 'wOptions'),
          ),
        ).thenAnswer((_) async => 'user-b');
        final biometricService = service();

        // Act
        final result = await biometricService.isBiometricEnabled();

        // Assert
        expect(result, isFalse);
      },
    );

    test('should return false when biometric is disabled', () async {
      // Arrange
      when(
        () => mockStorage.read(
          key: StorageKeys.biometricEnabled,
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async => 'false');
      final biometricService = service();

      // Act
      final result = await biometricService.isBiometricEnabled();

      // Assert
      expect(result, isFalse);
    });

    test('should return false when preference not set', () async {
      // Arrange
      when(
        () => mockStorage.read(
          key: StorageKeys.biometricEnabled,
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
          lOptions: any(named: 'lOptions'),
          webOptions: any(named: 'webOptions'),
          mOptions: any(named: 'mOptions'),
          wOptions: any(named: 'wOptions'),
        ),
      ).thenAnswer((_) async => null);
      final biometricService = service();

      // Act
      final result = await biometricService.isBiometricEnabled();

      // Assert
      expect(result, isFalse);
    });
  });

  group('Get primary biometric type', () {
    test('should return faceId when face is available', () async {
      // Arrange
      when(() => mockAuth.getAvailableBiometrics()).thenAnswer(
        (_) async => [
          platform.BiometricType.fingerprint,
          platform.BiometricType.face,
        ],
      );
      final biometricService = service();

      // Act
      final result = await biometricService.getPrimaryBiometricType();

      // Assert
      expect(result, equals(BiometricType.faceId));
    });

    test('should return fingerprint when only fingerprint available', () async {
      // Arrange
      when(
        () => mockAuth.getAvailableBiometrics(),
      ).thenAnswer((_) async => [platform.BiometricType.fingerprint]);
      final biometricService = service();

      // Act
      final result = await biometricService.getPrimaryBiometricType();

      // Assert
      expect(result, equals(BiometricType.fingerprint));
    });

    test('should return none when no biometrics available', () async {
      // Arrange
      when(() => mockAuth.getAvailableBiometrics()).thenAnswer((_) async => []);
      final biometricService = service();

      // Act
      final result = await biometricService.getPrimaryBiometricType();

      // Assert
      expect(result, equals(BiometricType.none));
    });
  });

  group('Authenticate sensitive', () {
    test('should call authenticate with sensitive reason', () async {
      // Arrange
      stubBiometricAvailable();
      when(
        () => mockAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          authMessages: any(named: 'authMessages'),
          biometricOnly: any(named: 'biometricOnly'),
          sensitiveTransaction: any(named: 'sensitiveTransaction'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenAnswer((_) async => true);
      final biometricService = service();

      // Act
      final result = await biometricService.authenticateSensitive();

      // Assert
      expect(result.success, isTrue);
      verify(
        () => mockAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          authMessages: any(named: 'authMessages'),
          biometricOnly: any(named: 'biometricOnly'),
          sensitiveTransaction: any(named: 'sensitiveTransaction'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).called(1);
    });
  });

  group('Can check biometrics', () {
    test('should return true when biometrics can be checked', () async {
      // Arrange
      when(() => mockAuth.canCheckBiometrics).thenAnswer((_) async => true);
      final biometricService = service();

      // Act
      final result = await biometricService.canCheckBiometrics();

      // Assert
      expect(result, isTrue);
    });

    test('should return false when biometrics cannot be checked', () async {
      // Arrange
      when(() => mockAuth.canCheckBiometrics).thenAnswer((_) async => false);
      final biometricService = service();

      // Act
      final result = await biometricService.canCheckBiometrics();

      // Assert
      expect(result, isFalse);
    });

    test('should handle PlatformException', () async {
      // Arrange
      when(() => mockAuth.canCheckBiometrics).thenThrow(
        const LocalAuthException(
          code: LocalAuthExceptionCode.noBiometricHardware,
        ),
      );
      final biometricService = service();

      // Act
      final result = await biometricService.canCheckBiometrics();

      // Assert
      expect(result, isFalse);
    });
  });
}
