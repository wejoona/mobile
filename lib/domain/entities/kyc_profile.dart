import 'package:usdc_wallet/features/kyc/models/kyc_status.dart';

/// KYC profile entity - user verification state.
class KycProfile {
  final String userId;
  final KycLevel level;
  final KycStatus status;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? documentType;
  final String? documentNumber;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final DateTime? expiresAt;

  const KycProfile({
    required this.userId,
    required this.level,
    required this.status,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.nationality,
    this.documentType,
    this.documentNumber,
    this.rejectionReason,
    this.submittedAt,
    this.verifiedAt,
    this.expiresAt,
  });

  /// Full name.
  String get fullName => [firstName, lastName]
      .where((n) => n != null && n.isNotEmpty)
      .join(' ');

  /// Whether KYC is fully verified.
  bool get isVerified => status == KycStatus.verified;

  /// Whether KYC is pending review.
  bool get isPending => status == KycStatus.pending;

  /// Whether KYC has been rejected.
  bool get isRejected => status == KycStatus.rejected;

  /// Whether KYC verification has expired.
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Whether the user needs to complete KYC for higher limits.
  bool get needsUpgrade => level == KycLevel.none || level == KycLevel.basic;

  /// Transaction limits based on KYC level (USDC).
  double get dailyLimit {
    switch (level) {
      case KycLevel.none:
        return 0;
      case KycLevel.basic:
        return 100;
      case KycLevel.standard:
        return 1000;
      case KycLevel.enhanced:
        return 10000;
      case KycLevel.premium:
        return 50000;
    }
  }

  factory KycProfile.fromJson(Map<String, dynamic> json) {
    return KycProfile(
      userId: json['userId'] as String,
      level: KycLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => KycLevel.none,
      ),
      status: KycStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => KycStatus.none,
      ),
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      nationality: json['nationality'] as String?,
      documentType: json['documentType'] as String?,
      documentNumber: json['documentNumber'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }
}

enum KycLevel { none, basic, standard, enhanced, premium }

// Re-export KycStatus from the canonical location
export 'package:usdc_wallet/features/kyc/models/kyc_status.dart';
