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

  factory PinResetRouteContext.fromRouteQuery(
    Map<String, String> query, {
    PinResetRouteContext? extraContext,
  }) {
    final queryContext = PinResetRouteContext(
      localPhoneNumber: _clean(query['phone'] ?? query['localPhoneNumber']),
      dialCode: _clean(query['dialCode']),
      e164Phone: _clean(query['e164'] ?? query['e164Phone']),
      countryCode: _clean(query['countryCode']),
      returnTo: safeReturnTo(query['returnTo']),
    );

    if (extraContext == null) {
      return queryContext;
    }

    return PinResetRouteContext(
      localPhoneNumber:
          extraContext.localPhoneNumber ?? queryContext.localPhoneNumber,
      dialCode: extraContext.dialCode ?? queryContext.dialCode,
      e164Phone: extraContext.e164Phone ?? queryContext.e164Phone,
      countryCode: extraContext.countryCode ?? queryContext.countryCode,
      recoveryAccessToken: extraContext.recoveryAccessToken,
      returnTo: extraContext.returnTo ?? queryContext.returnTo,
    );
  }

  final String? localPhoneNumber;
  final String? dialCode;
  final String? e164Phone;
  final String? countryCode;
  final String? recoveryAccessToken;
  final String? returnTo;

  String get routePath {
    final query = <String, String>{
      if (e164Phone != null && e164Phone!.isNotEmpty) 'e164': e164Phone!,
      if (localPhoneNumber != null && localPhoneNumber!.isNotEmpty)
        'phone': localPhoneNumber!,
      if (countryCode != null && countryCode!.isNotEmpty)
        'countryCode': countryCode!,
      if (dialCode != null && dialCode!.isNotEmpty) 'dialCode': dialCode!,
      if (returnTo != null && returnTo!.isNotEmpty) 'returnTo': returnTo!,
    };

    if (query.isEmpty) {
      return '/pin/reset';
    }

    return Uri(path: '/pin/reset', queryParameters: query).toString();
  }

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

  bool get hasData =>
      phoneValue != null || recoveryAccessToken != null || returnTo != null;

  static String? _clean(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
