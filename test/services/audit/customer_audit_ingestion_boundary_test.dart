import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('customer audit ingestion boundary', () {
    test(
      'customer mobile code does not call inactive audit ingestion routes',
      () {
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
            if (content.contains("'/audit/") ||
                content.contains('"/audit/') ||
                content.contains('services/audit/')) {
              offenders.add(entity.path);
            }
          }
        }

        expect(
          offenders.toList()..sort(),
          isEmpty,
          reason:
              'Customer UI, navigation, and providers must not depend on mobile '
              'audit ingestion routes until a backend-owned ingestion contract '
              'with abuse controls, retention, and PII rules exists.',
        );
      },
    );

    test('mobile ships no dormant audit route clients', () {
      final root = Directory('lib/services/audit');
      final dartFiles = root.existsSync()
          ? root
                .listSync(recursive: true)
                .whereType<File>()
                .where((file) => file.path.endsWith('.dart'))
                .map((file) => file.path)
                .toList()
          : <String>[];

      expect(
        dartFiles..sort(),
        isEmpty,
        reason:
            'Audit ingestion is backend-owned. Do not ship dormant mobile '
            'clients for /audit/* routes unless a mobile-safe ingestion '
            'contract with abuse controls, retention, and PII rules exists.',
      );
    });
  });
}
