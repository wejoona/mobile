import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Fetches supported countries from GET /config/countries (public, no auth).
/// Falls back to local SupportedCountries on failure.
final countriesProvider = FutureProvider<List<CountryConfig>>((ref) async {
  try {
    final dio = ref.watch(dioProvider);
    final response = await dio.get('/config/countries');
    final data = response.data;
    final rawCountries = data is List
        ? data
        : data is Map<String, dynamic>
        ? data['countries'] as List? ?? []
        : const [];
    final countries = rawCountries
        .cast<Map<String, dynamic>>()
        .map(_countryFromJson)
        .toList();

    if (countries.isNotEmpty) return countries;
  } catch (_) {
    // Fall back to local config
  }

  return SupportedCountries.all;
});

CountryConfig _countryFromJson(Map<String, dynamic> json) {
  final code = json['code'] as String;
  final local = SupportedCountries.allIncludingDisabled.firstWhere(
    (country) => country.code == code,
    orElse: () => CountryConfig(
      code: code,
      name: json['name'] as String? ?? code,
      prefix: '',
      phoneLength: 8,
      flag: '',
      currencies: const ['USD'],
    ),
  );
  final dialCode =
      json['prefix'] as String? ??
      (json['dialCode'] as String?)?.replaceFirst('+', '');
  final currency = json['currency'] as String?;

  return CountryConfig(
    code: code,
    name: json['name'] as String,
    prefix: dialCode ?? local.prefix,
    phoneLength: json['phoneLength'] as int? ?? local.phoneLength,
    flag: json['flag'] as String? ?? local.flag,
    currencies:
        (json['currencies'] as List?)?.cast<String>() ??
        [if (currency != null) currency, 'USD'],
    defaultCurrency:
        json['defaultCurrency'] as String? ??
        json['default_currency'] as String? ??
        local.defaultCurrency,
    depositCurrencies:
        (json['depositCurrencies'] as List?)?.cast<String>() ??
        (json['deposit_currencies'] as List?)?.cast<String>() ??
        local.depositCurrencies,
    depositRails:
        (json['depositRails'] as List?)?.cast<String>() ??
        (json['deposit_rails'] as List?)?.cast<String>() ??
        local.depositRails,
    depositMinAmount:
        (json['depositMinAmount'] as num?)?.toDouble() ??
        (json['deposit_min_amount'] as num?)?.toDouble() ??
        local.depositMinAmount,
    depositMaxAmount:
        (json['depositMaxAmount'] as num?)?.toDouble() ??
        (json['deposit_max_amount'] as num?)?.toDouble() ??
        local.depositMaxAmount,
    depositQuickAmounts:
        (json['depositQuickAmounts'] as List?)
            ?.map((value) => (value as num).toDouble())
            .toList() ??
        (json['deposit_quick_amounts'] as List?)
            ?.map((value) => (value as num).toDouble())
            .toList() ??
        local.depositQuickAmounts,
    phoneFormat: json['phoneFormat'] as String? ?? local.phoneFormat,
    isEnabled: true,
  );
}

/// Selected country state — persists choice across the session
final selectedCountryProvider =
    NotifierProvider<SelectedCountryNotifier, CountryConfig>(
      SelectedCountryNotifier.new,
    );

class SelectedCountryNotifier extends Notifier<CountryConfig> {
  @override
  CountryConfig build() => SupportedCountries.defaultCountry;

  void select(CountryConfig country) => state = country;
}
