import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_service.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeatureFlagsService', () {
    late _MockDio dio;
    late FeatureFlagsService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      dio = _MockDio();
      service = FeatureFlagsService(dio, prefs);
    });

    test('returns cached flags on unauthenticated 401 without throwing', () async {
      when(() => dio.get('/feature-flags/me')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/feature-flags/me'),
          response: Response(
            requestOptions: RequestOptions(path: '/feature-flags/me'),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      await service.init();
      final flags = await service.fetchFlags();

      expect(flags, isEmpty);
    });
  });
}