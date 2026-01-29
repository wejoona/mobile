import '../enums/account_type.dart';

/// Business Profile entity
class BusinessProfile {
  final String id;
  final String userId;
  final String businessName;
  final String? registrationNumber;
  final BusinessType businessType;
  final String? businessAddress;
  final String? taxId;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BusinessProfile({
    required this.id,
    required this.userId,
    required this.businessName,
    this.registrationNumber,
    required this.businessType,
    this.businessAddress,
    this.taxId,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      businessName: json['businessName'] as String,
      registrationNumber: json['registrationNumber'] as String?,
      businessType: BusinessType.values.firstWhere(
        (e) => e.name == json['businessType'],
        orElse: () => BusinessType.other,
      ),
      businessAddress: json['businessAddress'] as String?,
      taxId: json['taxId'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'businessName': businessName,
      'registrationNumber': registrationNumber,
      'businessType': businessType.name,
      'businessAddress': businessAddress,
      'taxId': taxId,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BusinessProfile copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? registrationNumber,
    BusinessType? businessType,
    String? businessAddress,
    String? taxId,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      businessType: businessType ?? this.businessType,
      businessAddress: businessAddress ?? this.businessAddress,
      taxId: taxId ?? this.taxId,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
