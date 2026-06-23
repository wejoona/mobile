import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('customer privacy export route boundary', () {
    test(
      'visible export screen uses backend verified user data export route',
      () {
        final exportView = File(
          'lib/features/settings/views/export_data_view.dart',
        ).readAsStringSync();

        expect(exportView, contains("'/user/data-export'"));
        expect(exportView, isNot(contains("'/account/export'")));
        expect(exportView, isNot(contains("'/privacy/export/request'")));
      },
    );

    test('customer UI is not wired to dormant privacy request APIs', () {
      final roots = [
        Directory('lib/features'),
        Directory('lib/router'),
        Directory('lib/providers'),
      ];

      final offenders = <String>{};
      for (final root in roots) {
        if (!root.existsSync()) continue;
        for (final entity in root.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) continue;

          final content = entity.readAsStringSync();
          if (content.contains("'/account/export'") ||
              content.contains('"/account/export"') ||
              content.contains("'/privacy/export/") ||
              content.contains('"/privacy/export/') ||
              content.contains("'/privacy/deletion/") ||
              content.contains('"/privacy/deletion/') ||
              content.contains('services/privacy/data_export_service.dart')) {
            offenders.add(entity.path);
          }
        }
      }

      expect(
        offenders.toList()..sort(),
        isEmpty,
        reason:
            'Customer UI must use the verified /user/data-export route until '
            'backend-owned async privacy export/deletion request APIs exist.',
      );
    });

    test(
      'user API provider exposes account export and deactivation routes',
      () {
        final userApi = File(
          'lib/services/api/providers/user_api.dart',
        ).readAsStringSync();

        expect(userApi, contains("'/user/data-export'"));
        expect(userApi, contains("'/user/deactivate'"));
      },
    );

    test('mobile ships no dormant privacy authorities', () {
      final roots = [
        Directory('lib/services/privacy'),
        Directory('lib/services/security/privacy'),
      ];
      final dartFiles = <String>[];

      for (final root in roots) {
        if (!root.existsSync()) continue;
        dartFiles.addAll(
          root
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'))
              .map((file) => file.path),
        );
      }

      expect(
        dartFiles..sort(),
        isEmpty,
        reason:
            'Privacy export/deletion workflows are backend-owned. Mobile '
            'should use legal document consent plus verified user API routes; '
            'avoid dormant request clients or in-memory privacy authorities.',
      );
    });
  });
}
