/// Mobile Money Provider Model
///
/// Each provider has a payment method type that determines the UX flow:
/// - OTP: User dials USSD, gets OTP, enters in app
/// - PUSH: Backend initiates, user approves via push notification
/// - QR_LINK: QR code + deep link to open provider app

enum PaymentMethodType {
  otp,
  push,
  qrLink,
  card,
}

extension PaymentMethodTypeExt on PaymentMethodType {
  String get value {
    switch (this) {
      case PaymentMethodType.otp:
        return 'OTP';
      case PaymentMethodType.push:
        return 'PUSH';
      case PaymentMethodType.qrLink:
        return 'QR_LINK';
      case PaymentMethodType.card:
        return 'CARD';
    }
  }

  static PaymentMethodType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'OTP':
        return PaymentMethodType.otp;
      case 'PUSH':
        return PaymentMethodType.push;
      case 'QR_LINK':
        return PaymentMethodType.qrLink;
      case 'CARD':
        return PaymentMethodType.card;
      default:
        return PaymentMethodType.push;
    }
  }

  /// Whether this type requires an OTP input field
  bool get requiresOtp => this == PaymentMethodType.otp;

  /// Whether this type shows a "waiting for confirmation" screen
  bool get isAsyncConfirmation => this == PaymentMethodType.push;

  /// Whether this type shows a QR code and/or deep link
  bool get hasQrOrLink => this == PaymentMethodType.qrLink;
}

enum MobileMoneyProvider {
  orangeMoney,
  mtnMomo,
  moovMoney,
  wave,
}

extension MobileMoneyProviderExt on MobileMoneyProvider {
  String get name {
    switch (this) {
      case MobileMoneyProvider.orangeMoney:
        return 'Orange Money';
      case MobileMoneyProvider.mtnMomo:
        return 'MTN MoMo';
      case MobileMoneyProvider.moovMoney:
        return 'Moov Money';
      case MobileMoneyProvider.wave:
        return 'Wave';
    }
  }

  /// Provider code sent to the API
  String get code {
    switch (this) {
      case MobileMoneyProvider.orangeMoney:
        return 'OMCI';
      case MobileMoneyProvider.mtnMomo:
        return 'MTNCI';
      case MobileMoneyProvider.moovMoney:
        return 'MOOVCI';
      case MobileMoneyProvider.wave:
        return 'WAVECI';
    }
  }

  String get logoPath {
    switch (this) {
      case MobileMoneyProvider.orangeMoney:
        return 'assets/images/providers/orange_money.png';
      case MobileMoneyProvider.mtnMomo:
        return 'assets/images/providers/mtn_momo.png';
      case MobileMoneyProvider.moovMoney:
        return 'assets/images/providers/moov_money.png';
      case MobileMoneyProvider.wave:
        return 'assets/images/providers/wave.png';
    }
  }

  /// Default payment method type (can be overridden by API response)
  PaymentMethodType get defaultPaymentMethodType {
    switch (this) {
      case MobileMoneyProvider.orangeMoney:
        return PaymentMethodType.otp;
      case MobileMoneyProvider.mtnMomo:
        return PaymentMethodType.push;
      case MobileMoneyProvider.moovMoney:
        return PaymentMethodType.push;
      case MobileMoneyProvider.wave:
        return PaymentMethodType.qrLink;
    }
  }

  static MobileMoneyProvider? fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'OMCI':
        return MobileMoneyProvider.orangeMoney;
      case 'MTNCI':
        return MobileMoneyProvider.mtnMomo;
      case 'MOOVCI':
        return MobileMoneyProvider.moovMoney;
      case 'WAVECI':
        return MobileMoneyProvider.wave;
      default:
        return null;
    }
  }
}
