/// Account type enum - personal vs business
enum AccountType {
  personal,
  business,
}

/// Business type enum
enum BusinessType {
  soleProprietor,
  llc,
  corporation,
  partnership,
  ngo,
  other,
}

extension BusinessTypeExtension on BusinessType {
  String get displayName {
    switch (this) {
      case BusinessType.soleProprietor:
        return 'Sole Proprietor';
      case BusinessType.llc:
        return 'LLC';
      case BusinessType.corporation:
        return 'Corporation';
      case BusinessType.partnership:
        return 'Partnership';
      case BusinessType.ngo:
        return 'NGO';
      case BusinessType.other:
        return 'Other';
    }
  }
}
