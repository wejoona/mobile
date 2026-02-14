import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Masks sensitive data in logs and UI.
class DataMaskingService {
  static const _tag = 'DataMask';
  // ignore: unused_field
  final AppLogger _log = AppLogger(_tag);

  /// Mask phone number: +225 07 XX XX 89 → +225 07 ** ** 89
  String maskPhone(String phone) {
    if (phone.length < 8) return '***';
    return '${phone.substring(0, 7)}****${phone.substring(phone.length - 2)}';
  }

  /// Mask email: user@example.com → u***@example.com
  String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***';
    final name = parts[0];
    return '${name[0]}***@${parts[1]}';
  }

  /// Mask wallet address: 0x1234...5678
  String maskAddress(String address) {
    if (address.length < 10) return '***';
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// Mask amount for display.
  String maskAmount(double amount) => '*** FCFA';

  /// Mask IBAN.
  String maskIban(String iban) {
    if (iban.length < 8) return '***';
    return '${iban.substring(0, 4)}****${iban.substring(iban.length - 4)}';
  }
}

final dataMaskingServiceProvider = Provider<DataMaskingService>((ref) {
  return DataMaskingService();
});
