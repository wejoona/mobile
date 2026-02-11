/// West African bank directory for bank linking.
class WestAfricanBanks {
  WestAfricanBanks._();

  static const List<BankInfo> coteDivoire = [
    BankInfo(code: 'SGBCI', name: 'Société Générale CI', swiftCode: 'SGBFCIAB'),
    BankInfo(code: 'BIAO', name: 'BIAO Côte d\'Ivoire', swiftCode: 'BIAOCIAB'),
    BankInfo(code: 'BICICI', name: 'BICICI', swiftCode: 'BICICIAB'),
    BankInfo(code: 'ECOBANK', name: 'Ecobank CI', swiftCode: 'EABORAAB'),
    BankInfo(code: 'BOA', name: 'Bank of Africa CI', swiftCode: 'AFRICIAB'),
    BankInfo(code: 'NSIA', name: 'NSIA Banque', swiftCode: 'NSIACIAB'),
    BankInfo(code: 'CORIS', name: 'Coris Bank International CI', swiftCode: 'CRISCIAB'),
    BankInfo(code: 'UBA', name: 'United Bank for Africa CI', swiftCode: 'UABORAAB'),
    BankInfo(code: 'BACI', name: 'Banque Atlantique CI', swiftCode: 'BQATCIAB'),
    BankInfo(code: 'SIB', name: 'SIB (Attijariwafa)', swiftCode: 'SIBKCIAB'),
    BankInfo(code: 'BNI', name: 'Banque Nationale d\'Investissement', swiftCode: 'BNINCIAB'),
    BankInfo(code: 'BRIDGE', name: 'Bridge Bank Group', swiftCode: 'BRIDCIAB'),
    BankInfo(code: 'ORABANK', name: 'Orabank CI', swiftCode: 'ORABCIAB'),
    BankInfo(code: 'BGFI', name: 'BGFI Bank CI', swiftCode: 'BGFICIAB'),
    BankInfo(code: 'VERSUS', name: 'Versus Bank', swiftCode: 'VERSCIAB'),
  ];

  static const List<MobileMoneyInfo> mobileMoneyCI = [
    MobileMoneyInfo(code: 'ORANGE', name: 'Orange Money', prefix: '+225 07'),
    MobileMoneyInfo(code: 'MTN', name: 'MTN MoMo', prefix: '+225 05'),
    MobileMoneyInfo(code: 'MOOV', name: 'Moov Money', prefix: '+225 01'),
    MobileMoneyInfo(code: 'WAVE', name: 'Wave', prefix: '+225'),
  ];

  /// Get all banks for a country code.
  static List<BankInfo> forCountry(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'CI':
        return coteDivoire;
      default:
        return [];
    }
  }
}

class BankInfo {
  final String code;
  final String name;
  final String? swiftCode;
  final String? logoAsset;

  const BankInfo({
    required this.code,
    required this.name,
    this.swiftCode,
    this.logoAsset,
  });
}

class MobileMoneyInfo {
  final String code;
  final String name;
  final String prefix;
  final String? logoAsset;

  const MobileMoneyInfo({
    required this.code,
    required this.name,
    required this.prefix,
    this.logoAsset,
  });
}
