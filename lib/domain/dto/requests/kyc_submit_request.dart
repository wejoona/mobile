/// Request DTO for submitting KYC documents.
class KycSubmitRequest {
  final String documentType;
  final String documentNumber;
  final String? frontImagePath;
  final String? backImagePath;
  final String? selfieImagePath;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String nationality;
  final String? address;

  const KycSubmitRequest({
    required this.documentType,
    required this.documentNumber,
    this.frontImagePath,
    this.backImagePath,
    this.selfieImagePath,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.nationality,
    this.address,
  });

  Map<String, dynamic> toJson() => {
        'documentType': documentType,
        'documentNumber': documentNumber,
        if (frontImagePath != null) 'frontImagePath': frontImagePath,
        if (backImagePath != null) 'backImagePath': backImagePath,
        if (selfieImagePath != null) 'selfieImagePath': selfieImagePath,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'nationality': nationality,
        if (address != null) 'address': address,
      };
}
