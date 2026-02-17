import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Fetches supported countries from GET /config/countries (public, no auth).
/// Falls back to local SupportedCountries on failure.
final countriesProvider = FutureProvider<List<CountryConfig>>((ref) async {
  try {
    final dio = ref.watch(dioProvider);
    final response = await dio.get('/config/countries');
    final data = response.data as Map<String, dynamic>;
    final countries = (data['countries'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((json) => CountryConfig(
              code: json['code'] as String,
              name: json['name'] as String,
              prefix: json['prefix'] as String,
              phoneLength: json['phoneLength'] as int,
              flag: json['flag'] as String? ?? '',
              currencies: (json['currencies'] as List?)
                      ?.cast<String>() ??
                  ['USD'],
              phoneFormat: json['phoneFormat'] as String?,
              isEnabled: true,
            ))
        .toList();

    if (countries.isNotEmpty) return countries;
  } catch (_) {
    // Fall back to local config
  }

  return SupportedCountries.all;
});

/// Selected country state — persists choice across the session
final selectedCountryProvider =
    StateProvider<CountryConfig>((ref) => SupportedCountries.defaultCountry);
