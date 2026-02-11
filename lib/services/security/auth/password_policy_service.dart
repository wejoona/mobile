import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Password policy validation result.
class PasswordPolicyResult {
  final bool meetsPolicy;
  final List<String> violations;
  final int strengthScore;

  const PasswordPolicyResult({
    required this.meetsPolicy,
    this.violations = const [],
    required this.strengthScore,
  });
}

/// Enforces password policies for account security.
class PasswordPolicyService {
  static const int minLength = 8;
  static const int maxLength = 128;

  /// Validate password against policy.
  PasswordPolicyResult validate(String password) {
    final violations = <String>[];
    int score = 0;

    if (password.length < minLength) {
      violations.add('Minimum $minLength caracteres requis');
    } else {
      score += 20;
    }

    if (password.length > maxLength) {
      violations.add('Maximum $maxLength caracteres');
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      violations.add('Au moins une lettre majuscule requise');
    } else {
      score += 20;
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      violations.add('Au moins une lettre minuscule requise');
    } else {
      score += 20;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      violations.add('Au moins un chiffre requis');
    } else {
      score += 20;
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      violations.add('Au moins un caractere special recommande');
    } else {
      score += 20;
    }

    return PasswordPolicyResult(
      meetsPolicy: violations.isEmpty,
      violations: violations,
      strengthScore: score,
    );
  }
}

final passwordPolicyServiceProvider =
    Provider<PasswordPolicyService>((ref) {
  return PasswordPolicyService();
});
