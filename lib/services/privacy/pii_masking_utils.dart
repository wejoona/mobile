/// Utilitaires de masquage des informations personnelles (PII).
///
/// Masque les données sensibles pour l'affichage dans les logs,
/// les interfaces et les rapports.
class PiiMaskingUtils {
  /// Masquer un numéro de téléphone: +225 07 ** ** 89
  static String maskPhone(String phone) {
    if (phone.length < 6) return '***';
    return '${phone.substring(0, phone.length > 8 ? phone.length - 6 : 3)} ** ** ${phone.substring(phone.length - 2)}';
  }

  /// Masquer un email: j***@example.com
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***';
    final name = parts[0];
    if (name.length <= 1) return '***@${parts[1]}';
    return '${name[0]}${'*' * (name.length - 1)}@${parts[1]}';
  }

  /// Masquer un nom: K**** Ouattara
  static String maskName(String name) {
    final parts = name.split(' ');
    return parts.map((p) {
      if (p.length <= 1) return p;
      return '${p[0]}${'*' * (p.length - 1)}';
    }).join(' ');
  }

  /// Masquer un numéro de carte: **** **** **** 1234
  static String maskCardNumber(String number) {
    final clean = number.replaceAll(' ', '');
    if (clean.length < 4) return '****';
    return '**** **** **** ${clean.substring(clean.length - 4)}';
  }

  /// Masquer une adresse de portefeuille: 0x1234...abcd
  static String maskWalletAddress(String address) {
    if (address.length < 10) return '***';
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// Masquer un numéro d'identité: CI-****-1234
  static String maskIdNumber(String id) {
    if (id.length < 4) return '****';
    return '${'*' * (id.length - 4)}${id.substring(id.length - 4)}';
  }

  /// Masquer un IBAN: CI** **** **** **** **89
  static String maskIban(String iban) {
    if (iban.length < 6) return '****';
    return '${iban.substring(0, 2)}** **** **** **** **${iban.substring(iban.length - 2)}';
  }

  /// Masquer un montant: ***,***
  static String maskAmount(double amount) => '***,***';

  /// Masquer les données selon le type
  static String mask(String value, PiiType type) {
    switch (type) {
      case PiiType.phone: return maskPhone(value);
      case PiiType.email: return maskEmail(value);
      case PiiType.name: return maskName(value);
      case PiiType.cardNumber: return maskCardNumber(value);
      case PiiType.walletAddress: return maskWalletAddress(value);
      case PiiType.idNumber: return maskIdNumber(value);
      case PiiType.iban: return maskIban(value);
    }
  }
}

enum PiiType { phone, email, name, cardNumber, walletAddress, idNumber, iban }
