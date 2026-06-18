import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';

void main() {
  group('customer compliance API boundary', () {
    test('customer-facing mobile code does not call admin compliance routes', () {
      final roots = [
        Directory('lib/features'),
        Directory('lib/router'),
        Directory('lib/providers'),
      ];

      final offenders = <String>[];
      for (final root in roots) {
        if (!root.existsSync()) continue;
        for (final entity in root.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) continue;
          final content = entity.readAsStringSync();
          if (content.contains("'/compliance/") ||
              content.contains('"/compliance/')) {
            offenders.add(entity.path);
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'Customer UI/navigation must not call admin/compliance-officer routes. '
            'Use user-facing APIs such as /user/limits, /wallet/kyc/status, '
            'or a dedicated mobile-safe endpoint instead.',
      );
    });

    test('customer transaction limits are sourced from user limits routes', () {
      final limitsService = File(
        'lib/services/limits/limits_service.dart',
      ).readAsStringSync();

      expect(ApiEndpoints.limits, '/user/limits');
      expect(ApiEndpoints.limitsUsage, '/user/limits/usage');
      expect(limitsService, contains('ApiEndpoints.limits'));
      expect(limitsService, contains('ApiEndpoints.limitsUsage'));
      expect(limitsService, isNot(contains("'/compliance/limits'")));
    });

    test('mobile ships no dormant compliance decision clients', () {
      final root = Directory('lib/services/compliance');
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
            'Compliance, reporting, sanctions, CDD/EDD, and limit decisions '
            'are backend-owned. Mobile should call explicit customer-safe '
            'endpoints such as /user/limits and /wallet/kyc/status only.',
      );
    });
  });
}
