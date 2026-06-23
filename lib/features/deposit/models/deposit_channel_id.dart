/// Canonical Korido deposit channel identifiers.
///
/// Mobile may receive older marketing/provider codes from legacy widgets, but
/// Korido API accepts channel ids from `/wallet/deposit/channels`.
class DepositChannelId {
  final String value;

  const DepositChannelId._(this.value);

  static const orangeMoneyCi = DepositChannelId._('orange_money_ci');
  static const mtnMomoCi = DepositChannelId._('mtn_momo_ci');
  static const moovMoneyCi = DepositChannelId._('moov_money_ci');
  static const waveCi = DepositChannelId._('wave_ci');

  static DepositChannelId parse(String raw) {
    final normalized = _normalize(raw);
    switch (normalized) {
      case 'orange_money_ci':
      case 'omci':
      case 'orange':
      case 'orange_money':
        return orangeMoneyCi;
      case 'mtn_momo_ci':
      case 'mtnci':
      case 'mtn':
      case 'mtn_momo':
      case 'mtn_mobile_money':
        return mtnMomoCi;
      case 'moov_money_ci':
      case 'moovci':
      case 'moov':
      case 'moov_money':
        return moovMoneyCi;
      case 'wave_ci':
      case 'waveci':
      case 'wave':
        return waveCi;
      default:
        return DepositChannelId._(normalized);
    }
  }

  String get legacyProviderCode {
    switch (value) {
      case 'orange_money_ci':
        return 'OMCI';
      case 'mtn_momo_ci':
        return 'MTNCI';
      case 'moov_money_ci':
        return 'MOOVCI';
      case 'wave_ci':
        return 'WAVECI';
      default:
        return value.toUpperCase();
    }
  }

  bool requiresPhone(String? methodType) {
    final method = methodType?.trim().toUpperCase();
    if (method == 'CARD' || method == 'BANK_TRANSFER' || method == 'ACH') {
      return false;
    }
    if (method == 'MOBILE_MONEY' ||
        method == 'OTP' ||
        method == 'PUSH' ||
        method == 'QR_LINK') {
      return true;
    }
    return const {
      'orange_money_ci',
      'mtn_momo_ci',
      'moov_money_ci',
      'wave_ci',
    }.contains(value);
  }

  static String _normalize(String value) =>
      value.trim().replaceAll('-', '_').toLowerCase();
}

String normalizeDepositChannelId(String value) =>
    DepositChannelId.parse(value).value;

String normalizeDepositProviderCode(String value) =>
    DepositChannelId.parse(value).legacyProviderCode;

bool depositChannelRequiresPhone(String channelId, String? methodType) =>
    DepositChannelId.parse(channelId).requiresPhone(methodType);

String depositChannelIdFromJson(Map<String, dynamic> json) {
  final raw =
      json['channelId'] ??
      json['id'] ??
      json['code'] ??
      json['providerCode'] ??
      json['provider'];
  if (raw == null) {
    return '';
  }
  return normalizeDepositChannelId(raw.toString());
}
