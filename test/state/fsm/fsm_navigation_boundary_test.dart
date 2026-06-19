import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app screens and services navigate only through the FSM facade', () {
    final roots = [
      Directory('lib/core'),
      Directory('lib/design'),
      Directory('lib/features'),
      Directory('lib/services'),
      Directory('lib/router/widgets'),
    ];

    final forbiddenPatterns = <String, RegExp>{
      'context.go/push/pop/safePop/enterAuthenticatedApp': RegExp(
        r'context\.(?:go|push|pop|safePop|enterAuthenticatedApp)(?:<[^>]+>)?\s*\(',
      ),
      'GoRouter.of(context)': RegExp(r'GoRouter\.of\s*\('),
      'routerProvider direct navigation': RegExp(
        r'read\(routerProvider\)\.(?:go|push|pop)\s*\(',
      ),
      'local router direct navigation': RegExp(
        r'\b(?:router|_router)\.(?:go|push|pop)\s*\(',
      ),
    };

    final violations = <String>[];

    for (final root in roots.where((directory) => directory.existsSync())) {
      final files = root
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in files) {
        final relativePath = file.path;
        final lines = file.readAsLinesSync();

        for (var index = 0; index < lines.length; index++) {
          final line = lines[index];
          for (final entry in forbiddenPatterns.entries) {
            if (entry.value.hasMatch(line)) {
              violations.add(
                '$relativePath:${index + 1} uses ${entry.key}: ${line.trim()}',
              );
            }
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Route changes must go through context.fsmGo/fsmPush/fsmPop or an AppFsmNotifier method.',
    );
  });
}
