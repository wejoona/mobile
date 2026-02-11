import 'package:flutter_pin_service/src/pin_config.dart';

/// PIN validation utilities.
///
/// Detects weak PINs that are easy to guess:
/// - Repeated digits (0000, 1111)
/// - Sequential patterns (1234, 9876)
/// - Common PINs (0000, 1234, 1111)
class PinValidator {
  PinValidator._();

  /// Common weak PINs to reject.
  static const List<String> _commonWeakPins = [
    // Repeated digits
    '0000', '1111', '2222', '3333', '4444',
    '5555', '6666', '7777', '8888', '9999',
    // Common patterns
    '1234', '4321', '1212', '2121', '0123',
    '1010', '2020', '1122', '2211', '1357',
    '2468', '0852', '9876', '6789',
    // Dates (years)
    '1990', '1991', '1992', '1993', '1994', '1995',
    '1996', '1997', '1998', '1999', '2000', '2001',
    '2002', '2003', '2004', '2005', '2006', '2007',
    '2008', '2009', '2010', '2011', '2012', '2013',
    '2014', '2015', '2016', '2017', '2018', '2019',
    '2020', '2021', '2022', '2023', '2024', '2025',
    // Common ATM PINs
    '0000', '1234', '1111', '0852', '7777',
  ];

  /// Validate a PIN.
  ///
  /// Returns a [PinValidationResult] with success status and any error message.
  static PinValidationResult validate(String pin) {
    // Check format
    if (pin.isEmpty) {
      return PinValidationResult(
        isValid: false,
        error: PinValidationError.empty,
        message: 'PIN cannot be empty',
      );
    }

    if (pin.length != PinConfig.pinLength) {
      return PinValidationResult(
        isValid: false,
        error: PinValidationError.wrongLength,
        message: 'PIN must be ${PinConfig.pinLength} digits',
      );
    }

    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return PinValidationResult(
        isValid: false,
        error: PinValidationError.notNumeric,
        message: 'PIN must contain only digits',
      );
    }

    // Check for weak PINs if configured
    if (PinConfig.rejectWeakPins) {
      final weaknessCheck = _checkWeakness(pin);
      if (weaknessCheck != null) {
        return PinValidationResult(
          isValid: false,
          error: PinValidationError.tooWeak,
          message: weaknessCheck,
        );
      }
    }

    return PinValidationResult(isValid: true);
  }

  /// Check if PIN is weak.
  ///
  /// Returns an error message if weak, null if strong enough.
  static String? _checkWeakness(String pin) {
    // Check against common weak PINs
    if (_commonWeakPins.contains(pin)) {
      return 'This PIN is too common. Please choose a different one.';
    }

    // Check custom weak PINs
    if (PinConfig.customWeakPins.contains(pin)) {
      return 'This PIN is not allowed. Please choose a different one.';
    }

    // Check for all same digits
    if (_isAllSameDigits(pin)) {
      return 'PIN cannot be all the same digit.';
    }

    // Check for sequential ascending
    if (_isSequentialAscending(pin)) {
      return 'PIN cannot be sequential numbers.';
    }

    // Check for sequential descending
    if (_isSequentialDescending(pin)) {
      return 'PIN cannot be sequential numbers.';
    }

    // Check for repeated pairs (e.g., 1212, 2323)
    if (_isRepeatedPair(pin)) {
      return 'PIN cannot be a repeated pattern.';
    }

    return null;
  }

  /// Check if all digits are the same.
  static bool _isAllSameDigits(String pin) {
    return pin.split('').toSet().length == 1;
  }

  /// Check if digits are sequential ascending.
  static bool _isSequentialAscending(String pin) {
    final digits = pin.split('').map(int.parse).toList();
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] + 1) {
        return false;
      }
    }
    return true;
  }

  /// Check if digits are sequential descending.
  static bool _isSequentialDescending(String pin) {
    final digits = pin.split('').map(int.parse).toList();
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] - 1) {
        return false;
      }
    }
    return true;
  }

  /// Check for repeated pair pattern (e.g., 1212, 2323).
  static bool _isRepeatedPair(String pin) {
    if (pin.length != 4) return false;

    return pin[0] == pin[2] && pin[1] == pin[3] && pin[0] != pin[1];
  }

  /// Get PIN strength score (0-100).
  static int getStrengthScore(String pin) {
    if (!RegExp(r'^\d{${PinConfig.pinLength}}$').hasMatch(pin)) {
      return 0;
    }

    var score = 100;

    // Deduct for common patterns
    if (_commonWeakPins.contains(pin)) score -= 80;
    if (_isAllSameDigits(pin)) score -= 60;
    if (_isSequentialAscending(pin)) score -= 50;
    if (_isSequentialDescending(pin)) score -= 50;
    if (_isRepeatedPair(pin)) score -= 40;

    // Bonus for diverse digits
    final uniqueDigits = pin.split('').toSet().length;
    score += (uniqueDigits - 1) * 5;

    return score.clamp(0, 100);
  }

  /// Get human-readable strength label.
  static String getStrengthLabel(String pin) {
    final score = getStrengthScore(pin);
    if (score >= 80) return 'Strong';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Weak';
    return 'Very Weak';
  }
}

/// Result of PIN validation.
class PinValidationResult {
  /// Whether the PIN passed validation.
  final bool isValid;

  /// Error type if validation failed.
  final PinValidationError? error;

  /// Human-readable error message.
  final String? message;

  const PinValidationResult({
    required this.isValid,
    this.error,
    this.message,
  });

  @override
  String toString() => 'PinValidationResult(isValid: $isValid, error: $error)';
}

/// Types of PIN validation errors.
enum PinValidationError {
  /// PIN is empty.
  empty,

  /// PIN has wrong length.
  wrongLength,

  /// PIN contains non-numeric characters.
  notNumeric,

  /// PIN is too weak (common pattern).
  tooWeak,
}
