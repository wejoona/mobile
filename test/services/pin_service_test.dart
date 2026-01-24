import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:usdc_wallet/services/pin/pin_service.dart';
import '../helpers/test_utils.dart';

void main() {
  late PinService pinService;
  late MockSecureStorage mockStorage;
  late MockDio mockDio;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockStorage = MockSecureStorage();
    mockDio = MockDio();
    pinService = PinService(mockStorage, mockDio);
  });

  tearDown(() {
    mockDio.reset();
    mockStorage.clear();
  });

  group('Set PIN with PBKDF2 hashing', () {
    test('should set PIN and store hash, not plain text', () async {
      // Act
      final result = await pinService.setPin('7392');

      // Assert
      expect(result, isTrue);

      // Verify hash is stored, not plain PIN
      final storedHash = mockStorage.storage['pin_hash'];
      expect(storedHash, isNotNull);
      expect(storedHash, isNot(equals('7392'))); // Not plain text

      // Verify salt is stored
      final storedSalt = mockStorage.storage['pin_salt'];
      expect(storedSalt, isNotNull);
      expect(storedSalt!.length, equals(16));
    });

    test('should reset attempts counter when setting PIN', () async {
      // Arrange - simulate existing attempts
      await mockStorage.write(key: 'pin_attempts', value: '3');

      // Act
      await pinService.setPin('7392');

      // Assert
      final attempts = mockStorage.storage['pin_attempts'];
      expect(attempts, equals('0'));
    });

    test('should clear lockout when setting PIN', () async {
      // Arrange - simulate locked state
      await mockStorage.write(
        key: 'pin_locked_until',
        value: DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
      );

      // Act
      await pinService.setPin('7392');

      // Assert
      final lockedUntil = mockStorage.storage['pin_locked_until'];
      expect(lockedUntil, isNull);
    });

    test('should reject PIN with wrong length', () async {
      // Act
      final result = await pinService.setPin('123'); // Only 3 digits

      // Assert
      expect(result, isFalse);
    });

    test('should reject PIN with non-digit characters', () async {
      // Act
      final result = await pinService.setPin('12ab');

      // Assert
      expect(result, isFalse);
    });
  });

  group('Verify PIN locally with hash comparison', () {
    test('should return success for correct PIN', () async {
      // Arrange - set PIN first
      await pinService.setPin('7392');

      // Act
      final result = await pinService.verifyPinLocally('7392');

      // Assert
      expect(result.success, isTrue);
    });

    test('should return failure for incorrect PIN', () async {
      // Arrange
      await pinService.setPin('7392');

      // Act
      final result = await pinService.verifyPinLocally('1234');

      // Assert
      expect(result.success, isFalse);
      expect(result.message, contains('Incorrect PIN'));
    });

    test('should return error when PIN not set', () async {
      // Act
      final result = await pinService.verifyPinLocally('7392');

      // Assert
      expect(result.success, isFalse);
      expect(result.message, equals('PIN not set'));
    });

    test('should reset attempts on successful verification', () async {
      // Arrange
      await pinService.setPin('7392');
      await mockStorage.write(key: 'pin_attempts', value: '2');

      // Act
      final result = await pinService.verifyPinLocally('7392');

      // Assert
      expect(result.success, isTrue);
      expect(mockStorage.storage['pin_attempts'], equals('0'));
    });
  });

  group('Verify PIN with backend API', () {
    test('should return success with PIN token on valid verification', () async {
      // Arrange
      mockDio.queueResponse({
        'valid': true,
        'message': 'PIN verified',
        'pinToken': 'a' * 64,
        'expiresIn': 300,
      });

      // Act
      final result = await pinService.verifyPinWithBackend('1234');

      // Assert
      expect(result.success, isTrue);
      expect(result.pinToken, equals('a' * 64));
      expect(result.expiresIn, equals(300));
    });

    test('should store PIN token in secure storage', () async {
      // Arrange
      mockDio.queueResponse({
        'valid': true,
        'pinToken': 'test-pin-token',
        'expiresIn': 300,
      });

      // Act
      await pinService.verifyPinWithBackend('1234');

      // Assert
      final storedToken = mockStorage.storage['pin_verification_token'];
      expect(storedToken, equals('test-pin-token'));
    });

    test('should handle 401 unauthorized response', () async {
      // Arrange
      mockDio.queueErrorResponse(statusCode: 401);

      // Act
      final result = await pinService.verifyPinWithBackend('wrong');

      // Assert
      expect(result.success, isFalse);
      expect(result.message, equals('Incorrect PIN'));
    });

    test('should handle 429 rate limit response', () async {
      // Arrange
      mockDio.queueErrorResponse(statusCode: 429);

      // Act
      final result = await pinService.verifyPinWithBackend('1234');

      // Assert
      expect(result.success, isFalse);
      expect(result.isLocked, isTrue);
      expect(result.message, contains('Too many attempts'));
    });
  });

  group('Detect weak PINs', () {
    test('should reject repeated digits (0000)', () async {
      final result = await pinService.setPin('0000');
      expect(result, isFalse);
    });

    test('should reject repeated digits (1111)', () async {
      final result = await pinService.setPin('1111');
      expect(result, isFalse);
    });

    test('should reject sequential digits (1234)', () async {
      final result = await pinService.setPin('1234');
      expect(result, isFalse);
    });

    test('should reject reverse sequential digits (4321)', () async {
      final result = await pinService.setPin('4321');
      expect(result, isFalse);
    });

    test('should reject common weak PINs (1212)', () async {
      final result = await pinService.setPin('1212');
      expect(result, isFalse);
    });

    test('should reject common weak PINs (0852)', () async {
      final result = await pinService.setPin('0852');
      expect(result, isFalse);
    });

    test('should accept strong PIN (7392)', () async {
      final result = await pinService.setPin('7392');
      expect(result, isTrue);
    });

    test('should accept strong PIN (8641)', () async {
      final result = await pinService.setPin('8641');
      expect(result, isTrue);
    });
  });

  group('Track failed attempts with 15-minute lockout', () {
    test('should track failed attempt count', () async {
      // Arrange
      await pinService.setPin('7392');

      // Act
      await pinService.verifyPinLocally('wrong');
      await pinService.verifyPinLocally('wrong');

      // Assert
      expect(mockStorage.storage['pin_attempts'], equals('2'));
    });

    test('should show remaining attempts after failure', () async {
      // Arrange
      await pinService.setPin('7392');
      await mockStorage.write(key: 'pin_attempts', value: '3');

      // Act
      final result = await pinService.verifyPinLocally('wrong');

      // Assert
      expect(result.success, isFalse);
      expect(result.remainingAttempts, equals(1)); // 5 - 4 = 1
    });

    test('should lock after 5 failed attempts', () async {
      // Arrange
      await pinService.setPin('7392');
      await mockStorage.write(key: 'pin_attempts', value: '4');

      // Act
      final result = await pinService.verifyPinLocally('wrong');

      // Assert
      expect(result.success, isFalse);
      expect(result.isLocked, isTrue);
      expect(result.lockRemainingSeconds, equals(900)); // 15 minutes
    });

    test('should reject verification during lockout period', () async {
      // Arrange
      await pinService.setPin('7392');
      final lockUntil = DateTime.now().add(const Duration(minutes: 10));
      await mockStorage.write(
        key: 'pin_locked_until',
        value: lockUntil.toIso8601String(),
      );

      // Act
      final result = await pinService.verifyPinLocally('7392');

      // Assert
      expect(result.success, isFalse);
      expect(result.isLocked, isTrue);
      expect(result.message, contains('Too many failed attempts'));
    });

    test('should clear lockout after expiry', () async {
      // Arrange
      await pinService.setPin('7392');
      final expiredLock = DateTime.now().subtract(const Duration(minutes: 1));
      await mockStorage.write(
        key: 'pin_locked_until',
        value: expiredLock.toIso8601String(),
      );
      await mockStorage.write(key: 'pin_attempts', value: '5');

      // Act
      final result = await pinService.verifyPinLocally('7392');

      // Assert
      expect(result.success, isTrue);
    });
  });

  group('Get/validate PIN token from backend', () {
    test('should return stored PIN token if valid', () async {
      // Arrange
      final expiry = DateTime.now().add(const Duration(minutes: 5));
      await mockStorage.write(key: 'pin_verification_token', value: 'valid-token');
      await mockStorage.write(key: 'pin_token_expiry', value: expiry.toIso8601String());

      // Act
      final token = await pinService.getPinToken();

      // Assert
      expect(token, equals('valid-token'));
    });

    test('should return null for expired token', () async {
      // Arrange
      final expiry = DateTime.now().subtract(const Duration(minutes: 1));
      await mockStorage.write(key: 'pin_verification_token', value: 'expired-token');
      await mockStorage.write(key: 'pin_token_expiry', value: expiry.toIso8601String());

      // Act
      final token = await pinService.getPinToken();

      // Assert
      expect(token, isNull);
    });

    test('hasValidPinToken should return true for valid token', () async {
      // Arrange
      final expiry = DateTime.now().add(const Duration(minutes: 5));
      await mockStorage.write(key: 'pin_verification_token', value: 'valid-token');
      await mockStorage.write(key: 'pin_token_expiry', value: expiry.toIso8601String());

      // Act
      final hasToken = await pinService.hasValidPinToken();

      // Assert
      expect(hasToken, isTrue);
    });

    test('hasValidPinToken should return false when no token', () async {
      // Act
      final hasToken = await pinService.hasValidPinToken();

      // Assert
      expect(hasToken, isFalse);
    });
  });

  group('Clear PIN and reset state', () {
    test('should clear all PIN-related data', () async {
      // Arrange
      await pinService.setPin('7392');
      await mockStorage.write(key: 'pin_attempts', value: '2');
      await mockStorage.write(key: 'pin_verification_token', value: 'token');

      // Act
      await pinService.clearPin();

      // Assert
      expect(mockStorage.storage['pin_hash'], isNull);
      expect(mockStorage.storage['pin_salt'], isNull);
      expect(mockStorage.storage['pin_attempts'], isNull);
      expect(mockStorage.storage['pin_locked_until'], isNull);
      expect(mockStorage.storage['pin_verification_token'], isNull);
    });
  });

  group('Change PIN with old PIN verification', () {
    test('should change PIN when old PIN is correct', () async {
      // Arrange
      await pinService.setPin('7392');
      final oldHash = mockStorage.storage['pin_hash'];

      // Act
      final result = await pinService.changePin('7392', '9012');

      // Assert
      expect(result, isTrue);
      expect(mockStorage.storage['pin_hash'], isNot(equals(oldHash)));
    });

    test('should reject change when old PIN is incorrect', () async {
      // Arrange
      await pinService.setPin('7392');

      // Act
      final result = await pinService.changePin('wrong', '9012');

      // Assert
      expect(result, isFalse);
    });

    test('should reject weak new PIN', () async {
      // Arrange
      await pinService.setPin('7392');

      // Act
      final result = await pinService.changePin('7392', '1234'); // Sequential

      // Assert
      expect(result, isFalse);
    });
  });

  group('hasPin', () {
    test('should return false when no PIN is set', () async {
      // Act
      final hasPin = await pinService.hasPin();

      // Assert
      expect(hasPin, isFalse);
    });

    test('should return true when PIN is set', () async {
      // Arrange
      await pinService.setPin('7392');

      // Act
      final hasPin = await pinService.hasPin();

      // Assert
      expect(hasPin, isTrue);
    });

    test('should return false after clearing PIN', () async {
      // Arrange
      await pinService.setPin('7392');
      await pinService.clearPin();

      // Act
      final hasPin = await pinService.hasPin();

      // Assert
      expect(hasPin, isFalse);
    });
  });

  group('PBKDF2 hashing verification', () {
    test('should produce same hash for same PIN and salt', () async {
      // Arrange
      await pinService.setPin('7392');
      final hash1 = mockStorage.storage['pin_hash'];
      final salt = mockStorage.storage['pin_salt'];

      // Create new service with same storage
      final newService = PinService(mockStorage, mockDio);
      final result = await newService.verifyPinLocally('7392');

      // Assert
      expect(result.success, isTrue);
    });

    test('should produce different hash with different salt', () async {
      // Arrange - set first PIN
      await pinService.setPin('7392');
      final hash1 = mockStorage.storage['pin_hash'];

      // Clear and set same PIN again (new salt)
      await pinService.clearPin();
      await pinService.setPin('7392');
      final hash2 = mockStorage.storage['pin_hash'];

      // Assert - different salt = different hash
      expect(hash1, isNot(equals(hash2)));
    });
  });
}
