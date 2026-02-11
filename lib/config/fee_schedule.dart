/// Fee schedule for different transaction types.
class FeeSchedule {
  FeeSchedule._();

  /// Calculate fee for internal transfers (between Korido users).
  static double internalTransfer(double amount) {
    // Free for internal transfers
    return 0.0;
  }

  /// Calculate fee for external transfers (to other wallets/banks).
  static double externalTransfer(double amount) {
    // 1% with min $0.50, max $10
    final fee = amount * 0.01;
    return fee.clamp(0.50, 10.0);
  }

  /// Calculate fee for mobile money deposit.
  static double mobileMoneyDeposit(double amount) {
    // 1.5% for mobile money deposits
    return amount * 0.015;
  }

  /// Calculate fee for bank withdrawal.
  static double bankWithdrawal(double amount) {
    // Flat $1 for bank withdrawals
    return 1.0;
  }

  /// Calculate fee for payment link.
  static double paymentLink(double amount) {
    // 2% for payment links (merchant fee)
    return amount * 0.02;
  }

  /// Calculate fee for bill payment.
  static double billPayment(double amount) {
    // Flat $0.25 for bill payments
    return 0.25;
  }

  /// Get fee description for display.
  static String feeDescription(String type) {
    switch (type) {
      case 'internal':
        return 'Free';
      case 'external':
        return '1% (min \$0.50, max \$10)';
      case 'mobile_money':
        return '1.5%';
      case 'bank_withdrawal':
        return 'Flat \$1.00';
      case 'payment_link':
        return '2%';
      case 'bill':
        return 'Flat \$0.25';
      default:
        return 'Varies';
    }
  }
}
