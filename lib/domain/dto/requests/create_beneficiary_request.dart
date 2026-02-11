/// Request DTO for creating a beneficiary.
class CreateBeneficiaryDto {
  final String name;
  final String phone;
  final String? email;
  final String? accountType;
  final String? bankAccountId;
  final bool isFavorite;

  const CreateBeneficiaryDto({
    required this.name,
    required this.phone,
    this.email,
    this.accountType,
    this.bankAccountId,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
        if (accountType != null) 'accountType': accountType,
        if (bankAccountId != null) 'bankAccountId': bankAccountId,
        'isFavorite': isFavorite,
      };
}
