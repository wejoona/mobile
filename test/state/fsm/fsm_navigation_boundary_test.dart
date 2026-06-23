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
      'Navigator route push': RegExp(
        r'Navigator(?:\.of\s*\([^)]*\))?\.(?:push|pushNamed|pushReplacement|pushReplacementNamed|popAndPushNamed|restorablePush|restorablePushNamed)\s*\(',
      ),
      'Navigator route pop': RegExp(
        r'Navigator(?:\.of\s*\([^)]*\))?\.pop(?:<[^>]+>)?\s*\(',
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
            if (_isAllowedModalPop(file.path, lines, index, entry.key)) {
              continue;
            }
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

  test('FSM state views never bypass the FSM navigation facade', () {
    final root = Directory('lib/features/fsm_states/views');
    expect(
      root.existsSync(),
      isTrue,
      reason: 'FSM state view contracts must be scanned from the package root.',
    );

    final forbiddenPatterns = <String, RegExp>{
      'Navigator route pop': RegExp(
        r'Navigator(?:\.of\s*\([^)]*\))?\.pop(?:<[^>]+>)?\s*\(',
      ),
      'Navigator route push': RegExp(
        r'Navigator(?:\.of\s*\([^)]*\))?\.(?:push|pushNamed|pushReplacement|pushReplacementNamed|popAndPushNamed|restorablePush|restorablePushNamed)\s*\(',
      ),
      'raw context route call': RegExp(
        r'context\.(?:go|push|pop|safePop)(?:<[^>]+>)?\s*\(',
      ),
      'raw GoRouter access': RegExp(r'GoRouter\.of\s*\('),
    };

    final violations = <String>[];

    final files = root
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        final line = lines[index];
        for (final entry in forbiddenPatterns.entries) {
          if (_isAllowedModalPop(file.path, lines, index, entry.key)) {
            continue;
          }
          if (entry.value.hasMatch(line)) {
            violations.add(
              '${file.path}:${index + 1} uses ${entry.key}: ${line.trim()}',
            );
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'FSM state views must use context.fsmGo/fsmPush/fsmPop/fsmSafePop so recovery and fallback behavior stays deterministic.',
    );
  });
}

bool _isAllowedModalPop(
  String path,
  List<String> lines,
  int index,
  String patternName,
) {
  if (patternName != 'Navigator route pop') {
    return false;
  }

  final line = lines[index];
  final modalOwnerPath = RegExp(
    '/(widgets|dialogs|components)/|sheet|dialog|picker|select',
  );
  if (modalOwnerPath.hasMatch(path)) {
    return true;
  }

  final modalContextName = RegExp(r'\b(dialogContext|sheetContext|ctx)\b');
  if (modalContextName.hasMatch(line)) {
    return true;
  }

  final hasResult = RegExp(
    r'Navigator(?:\.of\s*\([^)]*\))?\.pop(?:<[^>]+>)?\s*\([^,]+,',
  ).hasMatch(line);
  if (hasResult) {
    return true;
  }

  final start = (index - 60).clamp(0, lines.length - 1);
  final end = (index + 3).clamp(0, lines.length - 1);
  final window = lines.sublist(start, end + 1).join('\n');
  return RegExp(
    r'showDialog|showModalBottomSheet|AlertDialog|Dialog\(|BottomSheet|builder:\s*\(',
  ).hasMatch(window);
}
