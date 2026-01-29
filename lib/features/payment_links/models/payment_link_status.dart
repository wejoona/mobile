enum PaymentLinkStatus {
  pending,
  viewed,
  paid,
  expired,
  cancelled;

  String toJson() => name;
}

extension PaymentLinkStatusExtension on PaymentLinkStatus {
  static PaymentLinkStatus fromJson(String value) {
    return PaymentLinkStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentLinkStatus.pending,
    );
  }

  String displayName(bool isFrench) {
    switch (this) {
      case PaymentLinkStatus.pending:
        return isFrench ? 'En attente' : 'Pending';
      case PaymentLinkStatus.viewed:
        return isFrench ? 'Vue' : 'Viewed';
      case PaymentLinkStatus.paid:
        return isFrench ? 'Payé' : 'Paid';
      case PaymentLinkStatus.expired:
        return isFrench ? 'Expiré' : 'Expired';
      case PaymentLinkStatus.cancelled:
        return isFrench ? 'Annulé' : 'Cancelled';
    }
  }
}
