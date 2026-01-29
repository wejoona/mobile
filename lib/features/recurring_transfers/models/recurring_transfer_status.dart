enum RecurringTransferStatus {
  active,
  paused,
  completed,
  cancelled,
}

extension RecurringTransferStatusExtension on RecurringTransferStatus {
  String toJson() {
    switch (this) {
      case RecurringTransferStatus.active:
        return 'active';
      case RecurringTransferStatus.paused:
        return 'paused';
      case RecurringTransferStatus.completed:
        return 'completed';
      case RecurringTransferStatus.cancelled:
        return 'cancelled';
    }
  }

  static RecurringTransferStatus fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'active':
        return RecurringTransferStatus.active;
      case 'paused':
        return RecurringTransferStatus.paused;
      case 'completed':
        return RecurringTransferStatus.completed;
      case 'cancelled':
        return RecurringTransferStatus.cancelled;
      default:
        throw ArgumentError('Invalid status: $json');
    }
  }

  String getDisplayName(String locale) {
    if (locale.startsWith('fr')) {
      switch (this) {
        case RecurringTransferStatus.active:
          return 'Actif';
        case RecurringTransferStatus.paused:
          return 'En pause';
        case RecurringTransferStatus.completed:
          return 'Terminé';
        case RecurringTransferStatus.cancelled:
          return 'Annulé';
      }
    }
    switch (this) {
      case RecurringTransferStatus.active:
        return 'Active';
      case RecurringTransferStatus.paused:
        return 'Paused';
      case RecurringTransferStatus.completed:
        return 'Completed';
      case RecurringTransferStatus.cancelled:
        return 'Cancelled';
    }
  }
}
