import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('iOS permission configuration', () {
    late String podfile;
    late String infoPlist;
    late String permissionService;
    late String livenessWidget;
    late String qrScanner;
    late String contactsService;

    setUpAll(() {
      podfile = File('ios/Podfile').readAsStringSync();
      infoPlist = File('ios/Runner/Info.plist').readAsStringSync();
      permissionService = File(
        'lib/services/permissions/permission_service.dart',
      ).readAsStringSync();
      livenessWidget = File(
        'lib/features/liveness/widgets/liveness_check_widget.dart',
      ).readAsStringSync();
      qrScanner = File(
        'lib/features/qr_payment/views/scan_qr_screen.dart',
      ).readAsStringSync();
      contactsService = File(
        'lib/services/contacts/contacts_service.dart',
      ).readAsStringSync();
    });

    test('compiles every iOS permission group used by mobile code', () {
      expect(livenessWidget, contains('ph.Permission.camera'));
      expect(qrScanner, contains('Permission.camera'));
      expect(contactsService, contains('ph.Permission.contacts'));
      expect(permissionService, contains('Permission.photos'));

      expect(infoPlist, contains('<key>NSCameraUsageDescription</key>'));
      expect(infoPlist, contains('<key>NSContactsUsageDescription</key>'));
      expect(infoPlist, contains('<key>NSPhotoLibraryUsageDescription</key>'));
      expect(
        infoPlist,
        contains('<key>NSPhotoLibraryAddUsageDescription</key>'),
      );

      expect(podfile, contains('PERMISSION_CAMERA=1'));
      expect(podfile, contains('PERMISSION_CONTACTS=1'));
      expect(podfile, contains('PERMISSION_PHOTOS=1'));
      expect(podfile, contains('PERMISSION_PHOTOS_ADD_ONLY=1'));
    });

    test('does not expose unsupported location permission requests', () {
      expect(infoPlist, isNot(contains('NSLocation')));
      expect(podfile, isNot(contains('PERMISSION_LOCATION=1')));
      expect(permissionService, isNot(contains('Permission.location')));
      expect(permissionService, isNot(contains('requestLocation')));
    });
  });
}
