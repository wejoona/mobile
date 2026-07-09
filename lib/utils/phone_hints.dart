import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';

/// Builds a phone input hint from the country's dial code and format pattern.
String phoneHintForCountry(CountryConfig country) {
  final format = country.phoneFormat ?? 'XX XX XX XX XX';
  return '${country.fullPrefix} $format';
}

/// User profile country when available, otherwise the session-selected country.
final effectiveCountryProvider = Provider<CountryConfig>((ref) {
  final userCountryCode = ref.watch(
    userStateMachineProvider.select((state) => state.countryCode),
  );
  final selectedCountry = ref.watch(selectedCountryProvider);
  return SupportedCountries.findByCode(userCountryCode) ?? selectedCountry;
});

/// Reactive phone hint for input fields (e.g. send, beneficiaries).
final phoneInputHintProvider = Provider<String>(
  (ref) => phoneHintForCountry(ref.watch(effectiveCountryProvider)),
);