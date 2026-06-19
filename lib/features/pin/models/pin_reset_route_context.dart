import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

/// Route context carried into the PIN recovery flow.
///
/// Keep the phone representations together so recovery does not rebuild a
/// mixed `+225+225...` value or lose the local/dial-code split.
class PinResetRouteContext {
  const PinResetRouteContext({
    this.localPhoneNumber,
    this.dialCode,
    this.e164Phone,
    this.countryCode,
    this.recoveryAccessToken,
  });

  factory PinResetRouteContext.fromPhoneValue(
    PhoneNumberValue phone, {
    String? recoveryAccessToken,
  }) {
    return PinResetRouteContext(
      localPhoneNumber: phone.localNumber,
      dialCode: phone.dialCode,
      e164Phone: phone.e164,
      countryCode: phone.apiCountryCode,
      recoveryAccessToken: recoveryAccessToken,
    );
  }

  factory PinResetRouteContext.fromOptionalPhoneValue({
    PhoneNumberValue? phone,
    String? recoveryAccessToken,
  }) {
    if (phone != null) {
      return PinResetRouteContext.fromPhoneValue(
        phone,
        recoveryAccessToken: recoveryAccessToken,
      );
    }

    return PinResetRouteContext(recoveryAccessToken: recoveryAccessToken);
  }

  final String? localPhoneNumber;
  final String? dialCode;
  final String? e164Phone;
  final String? countryCode;
  final String? recoveryAccessToken;

  PhoneNumberValue? get phoneValue {
    final preferredPhone = e164Phone ?? localPhoneNumber;
    final preferredCountry = countryCode ?? dialCode;
    return PhoneNumberValue.tryFromAny(
      phoneNumber: preferredPhone,
      countryCode: preferredCountry,
    );
  }
}
