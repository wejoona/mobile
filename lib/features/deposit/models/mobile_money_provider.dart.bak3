/// Mobile Money Provider Model
enum MobileMoneyProvider {
  orangeMoney,
  wave,
  mtnMomo,
}

extension MobileMoneyProviderExt on MobileMoneyProvider {
  String get name {
    switch (this) {
      case MobileMoneyProvider.orangeMoney:
        return 'Orange Money';
      case MobileMoneyProvider.wave:
        return 'Wave';
      case MobileMoneyProvider.mtnMomo:
        return 'MTN MoMo';
    }
  }

  String get id {
    switch (this) {
      case MobileMoneyProvider.orangeMoney:
        return 'orange_money';
      case MobileMoneyProvider.wave:
        return 'wave';
      case MobileMoneyProvider.mtnMomo:
        return 'mtn_momo';
    }
  }

  String get logoPath {
    switch (this) {
      case MobileMoneyProvider.orangeMoney:
        return 'assets/images/providers/orange_money.png';
      case MobileMoneyProvider.wave:
        return 'assets/images/providers/wave.png';
      case MobileMoneyProvider.mtnMomo:
        return 'assets/images/providers/mtn_momo.png';
    }
  }

  String? get ussdCode {
    switch (this) {
      case MobileMoneyProvider.orangeMoney:
        return '#144#';
      case MobileMoneyProvider.wave:
        return null; // Wave uses app-only
      case MobileMoneyProvider.mtnMomo:
        return '*133#';
    }
  }

  String? get deepLink {
    switch (this) {
      case MobileMoneyProvider.orangeMoney:
        return 'orangemoney://';
      case MobileMoneyProvider.wave:
        return 'wave://';
      case MobileMoneyProvider.mtnMomo:
        return 'momo://';
    }
  }

  double get feePercentage {
    switch (this) {
      case MobileMoneyProvider.orangeMoney:
        return 1.5;
      case MobileMoneyProvider.wave:
        return 0.0;
      case MobileMoneyProvider.mtnMomo:
        return 1.5;
    }
  }
}
