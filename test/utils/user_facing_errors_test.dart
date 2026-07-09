import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/utils/user_facing_errors.dart';

void main() {
  group('UserFacingErrors', () {
    test('returns backend message when user-safe', () {
      final error = ApiException(message: 'Solde insuffisant', statusCode: 400);

      expect(UserFacingErrors.message(error), 'Solde insuffisant');
    });

    test('hides technical ApiException messages', () {
      final error = ApiException(
        message: 'DioException [bad response]: null',
        statusCode: 500,
      );

      expect(
        UserFacingErrors.message(error),
        'Erreur serveur. Veuillez réessayer.',
      );
    });

    test('maps Dio timeout to French copy', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/wallet'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        UserFacingErrors.message(error),
        'La connexion a expiré. Veuillez réessayer.',
      );
    });

    test('maps unauthenticated responses without leaking internals', () {
      final error = ApiException(message: '', statusCode: 401);

      expect(
        UserFacingErrors.message(error),
        'Votre session a expiré. Veuillez vous reconnecter.',
      );
    });

    test('falls back for unknown values', () {
      expect(
        UserFacingErrors.message(StateError('bad state')),
        UserFacingErrors.fallbackMessage,
      );
    });
  });
}