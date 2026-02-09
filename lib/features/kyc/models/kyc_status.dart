enum KycStatus {
  /// No KYC started
  none,
  /// KYC pending (documents not yet submitted)
  pending,
  /// Documents submitted, awaiting upload
  documentsPending,
  /// All documents submitted, under review
  submitted,
  /// KYC approved / verified
  verified,
  /// KYC rejected
  rejected,
  /// Additional info needed
  additionalInfoNeeded;

  bool get isNone => this == KycStatus.none;
  bool get isPending => this == KycStatus.pending || this == KycStatus.documentsPending;
  bool get isSubmitted => this == KycStatus.submitted;
  bool get isVerified => this == KycStatus.verified;
  bool get isRejected => this == KycStatus.rejected;
  bool get needsAdditionalInfo => this == KycStatus.additionalInfoNeeded;

  bool get canSubmit => isNone || isPending || isRejected || needsAdditionalInfo;
  bool get isInReview => isSubmitted;
  bool get isComplete => isVerified;

  /// Whether KYC needs to be done/completed (not verified yet)
  bool get needsKyc => isNone || isPending || isRejected || needsAdditionalInfo;

  static KycStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'none':
        return KycStatus.none;
      case 'pending':
        return KycStatus.pending;
      case 'documents_pending':
        return KycStatus.documentsPending;
      case 'submitted':
      case 'pending_verification':
      case 'manual_review':
      case 'in_review':
        return KycStatus.submitted;
      case 'approved':
      case 'verified':
      case 'auto_approved':
        return KycStatus.verified;
      case 'rejected':
        return KycStatus.rejected;
      case 'additional_info_needed':
        return KycStatus.additionalInfoNeeded;
      default:
        return KycStatus.pending;
    }
  }

  String toApiString() {
    switch (this) {
      case KycStatus.none:
        return 'none';
      case KycStatus.pending:
        return 'pending';
      case KycStatus.documentsPending:
        return 'documents_pending';
      case KycStatus.submitted:
        return 'submitted';
      case KycStatus.verified:
        return 'verified';
      case KycStatus.rejected:
        return 'rejected';
      case KycStatus.additionalInfoNeeded:
        return 'additional_info_needed';
    }
  }
}
