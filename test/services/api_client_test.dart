import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:usdc_wallet/services/api/api_client.dart';
import '../helpers/test_utils.dart';

void main() {
  late MockSecureStorage mockStorage;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockStorage = MockSecureStorage();
  });

  tearDown(() {
    mockStorage.clear();
  });

  group('ApiException mapping from status codes', () {
    test('should map 400 to Invalid request', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 400,
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.statusCode, equals(400));
      expect(exception.message, equals('Invalid request'));
    });

    test('should map 401 to Unauthorized', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.statusCode, equals(401));
      expect(exception.message, equals('Unauthorized'));
    });

    test('should map 403 to Access denied', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 403,
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.statusCode, equals(403));
      expect(exception.message, equals('Access denied'));
    });

    test('should map 404 to Not found', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.statusCode, equals(404));
      expect(exception.message, equals('Not found'));
    });

    test('should map 422 to Validation failed', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 422,
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.statusCode, equals(422));
      expect(exception.message, equals('Validation failed'));
    });

    test('should map 500 to Server error', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.statusCode, equals(500));
      expect(exception.message, equals('Server error'));
    });

    test('should extract message from response body', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 400,
          data: {'message': 'Custom error message'},
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.message, equals('Custom error message'));
    });

    test('should handle connection timeout', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.message, equals('Connection timed out'));
    });

    test('should handle send timeout', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.sendTimeout,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.message, equals('Connection timed out'));
    });

    test('should handle receive timeout', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.receiveTimeout,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.message, equals('Connection timed out'));
    });

    test('should handle connection error', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.message, equals('No internet connection'));
    });

    test('should handle unknown errors', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.unknown,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.message, equals('An unexpected error occurred'));
    });
  });

  group('ApiException', () {
    test('toString should return message', () {
      // Arrange
      final exception = ApiException(
        message: 'Test error',
        statusCode: 400,
      );

      // Act
      final result = exception.toString();

      // Assert
      expect(result, equals('Test error'));
    });

    test('should store data from response', () {
      // Arrange
      final responseData = {'field': 'error', 'details': 'Invalid value'};
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 400,
          data: {'message': 'Validation error', ...responseData},
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.data, isNotNull);
    });

    test('should create exception with message only', () {
      // Arrange & Act
      final exception = ApiException(message: 'Simple error');

      // Assert
      expect(exception.message, equals('Simple error'));
      expect(exception.statusCode, isNull);
      expect(exception.data, isNull);
    });

    test('should create exception with all fields', () {
      // Arrange & Act
      final exception = ApiException(
        message: 'Full error',
        statusCode: 500,
        data: {'extra': 'info'},
      );

      // Assert
      expect(exception.message, equals('Full error'));
      expect(exception.statusCode, equals(500));
      expect(exception.data, equals({'extra': 'info'}));
    });
  });

  group('Storage Keys', () {
    test('should have correct key values', () {
      expect(StorageKeys.accessToken, equals('access_token'));
      expect(StorageKeys.refreshToken, equals('refresh_token'));
      expect(StorageKeys.userPin, equals('user_pin'));
      expect(StorageKeys.biometricEnabled, equals('biometric_enabled'));
    });
  });

  group('MockSecureStorage', () {
    test('should store and retrieve values', () async {
      // Act
      await mockStorage.write(key: 'test_key', value: 'test_value');
      final result = await mockStorage.read(key: 'test_key');

      // Assert
      expect(result, equals('test_value'));
    });

    test('should return null for non-existent keys', () async {
      // Act
      final result = await mockStorage.read(key: 'non_existent');

      // Assert
      expect(result, isNull);
    });

    test('should delete values', () async {
      // Arrange
      await mockStorage.write(key: 'to_delete', value: 'value');

      // Act
      await mockStorage.delete(key: 'to_delete');
      final result = await mockStorage.read(key: 'to_delete');

      // Assert
      expect(result, isNull);
    });

    test('should clear all values', () async {
      // Arrange
      await mockStorage.write(key: 'key1', value: 'value1');
      await mockStorage.write(key: 'key2', value: 'value2');

      // Act
      mockStorage.clear();
      final result1 = await mockStorage.read(key: 'key1');
      final result2 = await mockStorage.read(key: 'key2');

      // Assert
      expect(result1, isNull);
      expect(result2, isNull);
    });

    test('should check if key exists', () async {
      // Arrange
      await mockStorage.write(key: 'existing', value: 'value');

      // Act
      final exists = await mockStorage.containsKey(key: 'existing');
      final notExists = await mockStorage.containsKey(key: 'not_existing');

      // Assert
      expect(exists, isTrue);
      expect(notExists, isFalse);
    });

    test('should read all values', () async {
      // Arrange
      await mockStorage.write(key: 'key1', value: 'value1');
      await mockStorage.write(key: 'key2', value: 'value2');

      // Act
      final all = await mockStorage.readAll();

      // Assert
      expect(all['key1'], equals('value1'));
      expect(all['key2'], equals('value2'));
    });

    test('should delete all values', () async {
      // Arrange
      await mockStorage.write(key: 'key1', value: 'value1');
      await mockStorage.write(key: 'key2', value: 'value2');

      // Act
      await mockStorage.deleteAll();
      final all = await mockStorage.readAll();

      // Assert
      expect(all, isEmpty);
    });

    test('should handle null value as delete', () async {
      // Arrange
      await mockStorage.write(key: 'key', value: 'value');

      // Act
      await mockStorage.write(key: 'key', value: null);
      final result = await mockStorage.read(key: 'key');

      // Assert
      expect(result, isNull);
    });
  });
}
