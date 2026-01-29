enum DocumentType {
  nationalId,
  passport,
  driversLicense;

  bool get requiresBackSide => this == DocumentType.nationalId || this == DocumentType.driversLicense;

  String toApiString() {
    switch (this) {
      case DocumentType.nationalId:
        return 'national_id';
      case DocumentType.passport:
        return 'passport';
      case DocumentType.driversLicense:
        return 'drivers_license';
    }
  }

  static DocumentType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'national_id':
        return DocumentType.nationalId;
      case 'passport':
        return DocumentType.passport;
      case 'drivers_license':
        return DocumentType.driversLicense;
      default:
        return DocumentType.nationalId;
    }
  }
}
