import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

/// Public app configuration mock endpoints.
class ConfigMock {
  static void register(MockInterceptor interceptor) {
    interceptor.register(
      method: 'GET',
      path: '/config/countries',
      handler: (options) async {
        return MockResponse.success({
          'countries': SupportedCountries.all
              .map(
                (country) => {
                  'code': country.code,
                  'name': country.name,
                  'prefix': country.prefix,
                  'phoneLength': country.phoneLength,
                  'flag': country.flag,
                  'currencies': country.currencies,
                  'phoneFormat': country.phoneFormat,
                },
              )
              .toList(),
        });
      },
    );

    interceptor.register(
      method: 'GET',
      path: '/config/mobile-version',
      handler: (options) async {
        return MockResponse.success({
          'platform': options.queryParameters['platform'] ?? 'unknown',
          'currentVersion': options.queryParameters['version'] ?? '0.9.0',
          'currentBuildNumber': options.queryParameters['buildNumber'] ?? '1',
          'latestVersion': options.queryParameters['version'] ?? '0.9.0',
          'minimumSupportedVersion':
              options.queryParameters['version'] ?? '0.9.0',
          'latestBuildNumber': null,
          'minimumSupportedBuildNumber': null,
          'forceUpgrade': false,
          'upgradeRecommended': false,
          'breakingApiChange': false,
          'message': null,
          'appUrl': null,
          'apiUrl': 'http://127.0.0.1:3401/api/v1',
          'checkedAt': DateTime.now().toUtc().toIso8601String(),
        });
      },
    );
  }
}
