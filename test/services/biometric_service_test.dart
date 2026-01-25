import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart' hide BiometricType;
import 'package:local_auth_platform_interface/types/biometric_type.dart' as platform;
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

  group('Check device biometric support', () {
    test('should return true when device supports biometrics', () async {
      // Arrange
      when(() => mockAuth.isDeviceSupported()).thenAnswer((_) async => true);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.isDeviceSupported();

      // Assert
      expect(result, isTrue);
    });

    test('should return false when device does not support biometrics', () async {
      // Arrange
      when(() => mockAuth.isDeviceSupported()).thenAnswer((_) async => false);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.isDeviceSupported();

      // Assert
      expect(result, isFalse);
    });
  });

  group('Get available biometric types', () {
    test('should return fingerprint when available', () async {
      // Arrange
      when(() => mockAuth.getAvailableBiometrics())
          .thenAnswer((_) async => [platform.BiometricType.fingerprint]);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.getAvailableBiometrics();

      // Assert
      expect(result, contains(BiometricType.fingerprint));
    });

    test('should return faceId when face is available', () async {
      // Arrange
      when(() => mockAuth.getAvailableBiometrics())
          .thenAnswer((_) async => [platform.BiometricType.face]);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.getAvailableBiometrics();

      // Assert
      expect(result, contains(BiometricType.faceId));
    });

    test('should return multiple types when available', () async {
      // Arrange
      when(() => mockAuth.getAvailableBiometrics())
          .thenAnswer((_) async => [platform.BiometricType.fingerprint, platform.BiometricType.face]);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.getAvailableBiometrics();

      // Assert
      expect(result.length, equals(2));
    });

    test('should return empty list when no biometrics available', () async {
      // Arrange
      when(() => mockAuth.getAvailableBiometrics()).thenAnswer((_) async => []);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.getAvailableBiometrics();

      // Assert
      expect(result, isEmpty);
    });

    test('should handle PlatformException gracefully', () async {
      // Arrange
      when(() => mockAuth.getAvailableBiometrics())
          .thenThrow(PlatformException(code: 'NotAvailable'));
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.getAvailableBiometrics();

      // Assert
      expect(result, isEmpty);
    });
  });

  group('Authenticate with fingerprint/face', () {
    test('should return true on successful authentication', () async {
      // Arrange
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            authMessages: any(named: 'authMessages'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => true);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.authenticate();

      // Assert
      expect(result, isTrue);
    });

    test('should return false when authentication fails', () async {
      // Arrange
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            authMessages: any(named: 'authMessages'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => false);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.authenticate();

      // Assert
      expect(result, isFalse);
    });

    test('should use custom reason when provided', () async {
      // Arrange
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            authMessages: any(named: 'authMessages'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => true);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      await biometricService.authenticate(reason: 'Custom reason');

      // Assert
      verify(() => mockAuth.authenticate(
            localizedReason: 'Custom reason',
            authMessages: any(named: 'authMessages'),
            options: any(named: 'options'),
          )).called(1);
    });
  });

  group('Handle authentication failure', () {
    test('should handle PlatformException', () async {
      // Arrange
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            authMessages: any(named: 'authMessages'),
            options: any(named: 'options'),
          )).thenThrow(PlatformException(code: 'NotEnrolled'));
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.authenticate();

      // Assert
      expect(result, isFalse);
    });

    test('should handle NotAvailable exception', () async {
      // Arrange
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            authMessages: any(named: 'authMessages'),
            options: any(named: 'options'),
          )).thenThrow(PlatformException(code: 'NotAvailable'));
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.authenticate();

      // Assert
      expect(result, isFalse);
    });
  });

  group('Enable/disable biometric preference', () {
    test('should save enabled preference to storage', () async {
      // Arrange
      when(() => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
            lOptions: any(named: 'lOptions'),
            webOptions: any(named: 'webOptions'),
            mOptions: any(named: 'mOptions'),
            wOptions: any(named: 'wOptions'),
          )).thenAnswer((_) async {});
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      await biometricService.enableBiometric();

      // Assert
      verify(() => mockStorage.write(
            key: StorageKeys.biometricEnabled,
            value: 'true',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
            lOptions: any(named: 'lOptions'),
            webOptions: any(named: 'webOptions'),
            mOptions: any(named: 'mOptions'),
            wOptions: any(named: 'wOptions'),
          )).called(1);
    });

    test('should save disabled preference to storage', () async {
      // Arrange
      when(() => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
            lOptions: any(named: 'lOptions'),
            webOptions: any(named: 'webOptions'),
            mOptions: any(named: 'mOptions'),
            wOptions: any(named: 'wOptions'),
          )).thenAnswer((_) async {});
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      await biometricService.disableBiometric();

      // Assert
      verify(() => mockStorage.write(
            key: StorageKeys.biometricEnabled,
            value: 'false',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
            lOptions: any(named: 'lOptions'),
            webOptions: any(named: 'webOptions'),
            mOptions: any(named: 'mOptions'),
            wOptions: any(named: 'wOptions'),
          )).called(1);
    });

    test('should return true when biometric is enabled', () async {
      // Arrange
      when(() => mockStorage.read(
            key: StorageKeys.biometricEnabled,
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
            lOptions: any(named: 'lOptions'),
            webOptions: any(named: 'webOptions'),
            mOptions: any(named: 'mOptions'),
            wOptions: any(named: 'wOptions'),
          )).thenAnswer((_) async => 'true');
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.isBiometricEnabled();

      // Assert
      expect(result, isTrue);
    });

    test('should return false when biometric is disabled', () async {
      // Arrange
      when(() => mockStorage.read(
            key: StorageKeys.biometricEnabled,
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
            lOptions: any(named: 'lOptions'),
            webOptions: any(named: 'webOptions'),
            mOptions: any(named: 'mOptions'),
            wOptions: any(named: 'wOptions'),
          )).thenAnswer((_) async => 'false');
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.isBiometricEnabled();

      // Assert
      expect(result, isFalse);
    });

    test('should return false when preference not set', () async {
      // Arrange
      when(() => mockStorage.read(
            key: StorageKeys.biometricEnabled,
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
            lOptions: any(named: 'lOptions'),
            webOptions: any(named: 'webOptions'),
            mOptions: any(named: 'mOptions'),
            wOptions: any(named: 'wOptions'),
          )).thenAnswer((_) async => null);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.isBiometricEnabled();

      // Assert
      expect(result, isFalse);
    });
  });

  group('Get primary biometric type', () {
    test('should return faceId when face is available', () async {
      // Arrange
      when(() => mockAuth.getAvailableBiometrics())
          .thenAnswer((_) async => [platform.BiometricType.fingerprint, platform.BiometricType.face]);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.getPrimaryBiometricType();

      // Assert
      expect(result, equals(BiometricType.faceId));
    });

    test('should return fingerprint when only fingerprint available', () async {
      // Arrange
      when(() => mockAuth.getAvailableBiometrics())
          .thenAnswer((_) async => [platform.BiometricType.fingerprint]);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.getPrimaryBiometricType();

      // Assert
      expect(result, equals(BiometricType.fingerprint));
    });

    test('should return none when no biometrics available', () async {
      // Arrange
      when(() => mockAuth.getAvailableBiometrics()).thenAnswer((_) async => []);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.getPrimaryBiometricType();

      // Assert
      expect(result, equals(BiometricType.none));
    });
  });

  group('Authenticate sensitive', () {
    test('should call authenticate with sensitive reason', () async {
      // Arrange
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            authMessages: any(named: 'authMessages'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => true);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.authenticateSensitive();

      // Assert
      expect(result, isTrue);
      verify(() => mockAuth.authenticate(
            localizedReason: 'Confirm your identity to proceed',
            authMessages: any(named: 'authMessages'),
            options: any(named: 'options'),
          )).called(1);
    });
  });

  group('Can check biometrics', () {
    test('should return true when biometrics can be checked', () async {
      // Arrange
      when(() => mockAuth.canCheckBiometrics).thenAnswer((_) async => true);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.canCheckBiometrics();

      // Assert
      expect(result, isTrue);
    });

    test('should return false when biometrics cannot be checked', () async {
      // Arrange
      when(() => mockAuth.canCheckBiometrics).thenAnswer((_) async => false);
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.canCheckBiometrics();

      // Assert
      expect(result, isFalse);
    });

    test('should handle PlatformException', () async {
      // Arrange
      when(() => mockAuth.canCheckBiometrics)
          .thenThrow(PlatformException(code: 'NotAvailable'));
      final biometricService = BiometricService(mockAuth, mockStorage);

      // Act
      final result = await biometricService.canCheckBiometrics();

      // Assert
      expect(result, isFalse);
    });
  });
}
