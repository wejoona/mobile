/// Feature toggles for Korido.
///
/// Controls feature visibility across the app. Can be overridden
/// by remote feature flags from the server.
class FeatureToggles {
  const FeatureToggles._();

  /// Whether bill payments are enabled.
  static bool billPayments = false;

  /// Whether virtual cards are enabled.
  static bool virtualCards = false;

  /// Whether savings pots are enabled.
  static bool savingsPots = true;

  /// Whether recurring transfers are enabled.
  static bool recurringTransfers = true;

  /// Whether payment links are enabled.
  static bool paymentLinks = true;

  /// Whether bulk payments are enabled.
  static bool bulkPayments = false;

  /// Whether QR payments are enabled.
  static bool qrPayments = true;

  /// Whether merchant pay is enabled.
  static bool merchantPay = false;

  /// Whether referrals are enabled.
  static bool referrals = true;

  /// Whether insights/analytics are enabled.
  static bool insights = true;

  /// Whether biometric authentication is enabled.
  static bool biometricAuth = true;

  /// Whether external (on-chain) transfers are enabled.
  static bool externalTransfers = false;

  /// Update toggles from remote configuration.
  static void updateFromRemote(Map<String, bool> remoteFlags) {
    billPayments = remoteFlags['bill_payments'] ?? billPayments;
    virtualCards = remoteFlags['virtual_cards'] ?? virtualCards;
    savingsPots = remoteFlags['savings_pots'] ?? savingsPots;
    recurringTransfers =
        remoteFlags['recurring_transfers'] ?? recurringTransfers;
    paymentLinks = remoteFlags['payment_links'] ?? paymentLinks;
    bulkPayments = remoteFlags['bulk_payments'] ?? bulkPayments;
    qrPayments = remoteFlags['qr_payments'] ?? qrPayments;
    merchantPay = remoteFlags['merchant_pay'] ?? merchantPay;
    referrals = remoteFlags['referrals'] ?? referrals;
    insights = remoteFlags['insights'] ?? insights;
    biometricAuth = remoteFlags['biometric_auth'] ?? biometricAuth;
    externalTransfers =
        remoteFlags['external_transfers'] ?? externalTransfers;
  }
}
