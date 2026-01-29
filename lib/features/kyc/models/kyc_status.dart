enum KycStatus {
  pending,
  submitted,
  approved,
  rejected,
  additionalInfoNeeded;

  bool get isPending => this == KycStatus.pending;
  bool get isSubmitted => this == KycStatus.submitted;
  bool get isApproved => this == KycStatus.approved;
  bool get isRejected => this == KycStatus.rejected;
  bool get needsAdditionalInfo => this == KycStatus.additionalInfoNeeded;

  bool get canSubmit => isPending || isRejected || needsAdditionalInfo;
  bool get isInReview => isSubmitted;
  bool get isComplete => isApproved;

  static KycStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return KycStatus.pending;
      case 'submitted':
        return KycStatus.submitted;
      case 'approved':
        return KycStatus.approved;
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
      case KycStatus.pending:
        return 'pending';
      case KycStatus.submitted:
        return 'submitted';
      case KycStatus.approved:
        return 'approved';
      case KycStatus.rejected:
        return 'rejected';
      case KycStatus.additionalInfoNeeded:
        return 'additional_info_needed';
    }
  }
}
