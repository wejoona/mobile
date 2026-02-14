import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Vérifie les permissions utilisateur pour les actions sensibles.
enum Permission {
  sendMoney, receiveMoney, viewBalance, exportData,
  manageSettings, manageContacts, manageCards,
  viewTransactions, createPaymentLink, manageSavings,
}

class PermissionChecker {
  static const _tag = 'Permissions';
  // ignore: unused_field
  final AppLogger _log = AppLogger(_tag);
  Set<Permission> _granted = {};

  void setPermissions(Set<Permission> permissions) {
    _granted = permissions;
  }

  bool hasPermission(Permission permission) {
    return _granted.contains(permission);
  }

  bool hasAll(List<Permission> permissions) {
    return permissions.every(_granted.contains);
  }

  bool hasAny(List<Permission> permissions) {
    return permissions.any(_granted.contains);
  }

  List<Permission> getMissing(List<Permission> required) {
    return required.where((p) => !_granted.contains(p)).toList();
  }
}

final permissionCheckerProvider = Provider<PermissionChecker>((ref) {
  return PermissionChecker();
});
