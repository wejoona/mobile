import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('customer audit ingestion boundary', () {
    test('customer mobile code does not call inactive audit ingestion routes', () {
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
    });

    test('dormant audit utilities keep explicit backend route inventory', () {
      final files = [
        File('lib/services/audit/login_attempt_tracker.dart'),
        File('lib/services/audit/security_audit_log.dart'),
        File('lib/services/audit/user_action_audit_trail.dart'),
        File('lib/services/audit/compliance_event_logger.dart'),
      ];

      for (final file in files) {
        expect(file.existsSync(), isTrue, reason: '${file.path} is missing');
      }

      final routeInventory = files
          .map((file) => file.readAsStringSync())
          .join('\n');

      expect(routeInventory, contains("'/audit/login-attempts'"));
      expect(routeInventory, contains("'/audit/security/batch'"));
      expect(routeInventory, contains("'/audit/user-actions/batch'"));
      expect(routeInventory, contains("'/audit/compliance-events/batch'"));
    });
  });
}
