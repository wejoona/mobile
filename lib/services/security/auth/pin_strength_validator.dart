import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PIN/password strength assessment result.
class PinStrengthResult {
  /// Score from 0 (very weak) to 100 (very strong).
  final int score;
  final String level;
  final List<String> warnings;
  final List<String> suggestions;

  const PinStrengthResult({
    required this.score,
    required this.level,
    this.warnings = const [],
    this.suggestions = const [],
  });

  bool get isAcceptable => score >= 40;
}

/// Validates PIN and password strength for the Korido wallet.
///
/// Checks for common patterns, sequential digits, repeated characters,
/// and known weak PINs that are frequently targeted in attacks.
class PinStrengthValidator {
  /// Common weak PINs to reject.
  static const _weakPins = [
    '000000', '111111', '222222', '333333', '444444',
    '555555', '666666', '777777', '888888', '999999',
    '123456', '654321', '123123', '112233', '121212',
    '000000', '696969', '131313', '420420', '101010',
  ];

  /// Validate a 6-digit PIN.
  PinStrengthResult validatePin(String pin) {
    final warnings = <String>[];
    final suggestions = <String>[];
    int score = 100;

    if (pin.length != 6) {
      return const PinStrengthResult(
        score: 0,
        level: 'invalid',
        warnings: ['Le PIN doit contenir 6 chiffres'],
      );
    }

    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      return const PinStrengthResult(
        score: 0,
        level: 'invalid',
        warnings: ['Le PIN ne doit contenir que des chiffres'],
      );
    }

    // Check weak PINs
    if (_weakPins.contains(pin)) {
      score -= 60;
      warnings.add('PIN trop courant');
      suggestions.add('Evitez les combinaisons evidentes');
    }

    // Check all same digit
    if (pin.split('').toSet().length == 1) {
      score -= 50;
      warnings.add('Tous les chiffres sont identiques');
    }

    // Check sequential
    if (_isSequential(pin)) {
      score -= 40;
      warnings.add('Sequence de chiffres detectee');
      suggestions.add('Evitez les suites comme 123456');
    }

    // Check repeated patterns
    if (_hasRepeatedPattern(pin)) {
      score -= 20;
      warnings.add('Motif repete detecte');
    }

    // Check date-like patterns (DDMMYY, YYMMDD)
    if (_looksLikeDate(pin)) {
      score -= 15;
      suggestions.add('Evitez les dates de naissance');
    }

    score = score.clamp(0, 100);
    final level = score >= 70
        ? 'fort'
        : score >= 40
            ? 'moyen'
            : 'faible';

    return PinStrengthResult(
      score: score,
      level: level,
      warnings: warnings,
      suggestions: suggestions,
    );
  }

  bool _isSequential(String pin) {
    bool ascending = true;
    bool descending = true;
    for (int i = 1; i < pin.length; i++) {
      if (int.parse(pin[i]) != int.parse(pin[i - 1]) + 1) ascending = false;
      if (int.parse(pin[i]) != int.parse(pin[i - 1]) - 1) descending = false;
    }
    return ascending || descending;
  }

  bool _hasRepeatedPattern(String pin) {
    // Check 2-char and 3-char repeats
    if (pin.substring(0, 2) == pin.substring(2, 4) &&
        pin.substring(2, 4) == pin.substring(4, 6)) return true;
    if (pin.substring(0, 3) == pin.substring(3, 6)) return true;
    return false;
  }

  bool _looksLikeDate(String pin) {
    final dd = int.tryParse(pin.substring(0, 2));
    final mm = int.tryParse(pin.substring(2, 4));
    if (dd != null && mm != null && dd >= 1 && dd <= 31 && mm >= 1 && mm <= 12) {
      return true;
    }
    return false;
  }
}

final pinStrengthValidatorProvider = Provider<PinStrengthValidator>((ref) {
  return PinStrengthValidator();
});
