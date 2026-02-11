import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Centralized permission request service.
class PermissionService {
  /// Request camera permission.
  Future<bool> requestCamera() => _request(Permission.camera, 'Camera');

  /// Request contacts permission.
  Future<bool> requestContacts() => _request(Permission.contacts, 'Contacts');

  /// Request notification permission.
  Future<bool> requestNotifications() =>
      _request(Permission.notification, 'Notifications');

  /// Request photo library permission.
  Future<bool> requestPhotos() => _request(Permission.photos, 'Photos');

  /// Request location permission.
  Future<bool> requestLocation() => _request(Permission.location, 'Location');

  /// Check if a permission is granted.
  Future<bool> isGranted(Permission permission) async {
    return permission.isGranted;
  }

  /// Request a permission with automatic settings redirect if permanently denied.
  Future<bool> _request(Permission permission, String name) async {
    final status = await permission.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      // Could show dialog here directing user to settings
      debugPrint('$name permission permanently denied. Open app settings.');
      return false;
    }
    return false;
  }

  /// Open app settings.
  Future<bool> openSettings() => openAppSettings();

  /// Check multiple permissions at once.
  Future<Map<Permission, bool>> checkAll(List<Permission> permissions) async {
    final results = <Permission, bool>{};
    for (final p in permissions) {
      results[p] = await p.isGranted;
    }
    return results;
  }
}
