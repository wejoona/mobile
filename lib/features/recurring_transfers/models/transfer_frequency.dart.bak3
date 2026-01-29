enum TransferFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
}

extension TransferFrequencyExtension on TransferFrequency {
  String toJson() {
    switch (this) {
      case TransferFrequency.daily:
        return 'daily';
      case TransferFrequency.weekly:
        return 'weekly';
      case TransferFrequency.biweekly:
        return 'biweekly';
      case TransferFrequency.monthly:
        return 'monthly';
    }
  }

  static TransferFrequency fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'daily':
        return TransferFrequency.daily;
      case 'weekly':
        return TransferFrequency.weekly;
      case 'biweekly':
        return TransferFrequency.biweekly;
      case 'monthly':
        return TransferFrequency.monthly;
      default:
        throw ArgumentError('Invalid frequency: $json');
    }
  }

  String getDisplayName(String locale) {
    if (locale.startsWith('fr')) {
      switch (this) {
        case TransferFrequency.daily:
          return 'Quotidien';
        case TransferFrequency.weekly:
          return 'Hebdomadaire';
        case TransferFrequency.biweekly:
          return 'Bi-hebdomadaire';
        case TransferFrequency.monthly:
          return 'Mensuel';
      }
    }
    switch (this) {
      case TransferFrequency.daily:
        return 'Daily';
      case TransferFrequency.weekly:
        return 'Weekly';
      case TransferFrequency.biweekly:
        return 'Bi-weekly';
      case TransferFrequency.monthly:
        return 'Monthly';
    }
  }
}
