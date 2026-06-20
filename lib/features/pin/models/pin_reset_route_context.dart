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
    this.returnTo,
  });

  factory PinResetRouteContext.fromPhoneValue(
    PhoneNumberValue phone, {
    String? recoveryAccessToken,
    String? returnTo,
  }) {
    return PinResetRouteContext(
      localPhoneNumber: phone.localNumber,
      dialCode: phone.dialCode,
      e164Phone: phone.e164,
      countryCode: phone.apiCountryCode,
      recoveryAccessToken: recoveryAccessToken,
      returnTo: safeReturnTo(returnTo),
    );
  }

  factory PinResetRouteContext.fromOptionalPhoneValue({
    PhoneNumberValue? phone,
    String? recoveryAccessToken,
    String? returnTo,
  }) {
    if (phone != null) {
      return PinResetRouteContext.fromPhoneValue(
        phone,
        recoveryAccessToken: recoveryAccessToken,
        returnTo: returnTo,
      );
    }

    return PinResetRouteContext(
      recoveryAccessToken: recoveryAccessToken,
      returnTo: safeReturnTo(returnTo),
    );
  }

  final String? localPhoneNumber;
  final String? dialCode;
  final String? e164Phone;
  final String? countryCode;
  final String? recoveryAccessToken;
  final String? returnTo;

  static String? safeReturnTo(String? raw) {
    final returnTo = raw?.trim();
    if (returnTo == null || returnTo.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(returnTo);
    if (uri == null ||
        uri.hasScheme ||
        uri.hasAuthority ||
        !returnTo.startsWith('/') ||
        returnTo.startsWith('//')) {
      return null;
    }

    final path = uri.path;
    if (path == '/pin/reset' ||
        path.startsWith('/login') ||
        path.startsWith('/signup') ||
        path.startsWith('/onboarding') ||
        path.startsWith('/session-locked')) {
      return null;
    }

    return returnTo;
  }

  PhoneNumberValue? get phoneValue {
    final preferredPhone = e164Phone ?? localPhoneNumber;
    final preferredCountry = countryCode ?? dialCode;
    return PhoneNumberValue.tryFromAny(
      phoneNumber: preferredPhone,
      countryCode: preferredCountry,
    );
  }
}
