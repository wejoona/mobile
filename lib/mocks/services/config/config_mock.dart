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
  }
}
