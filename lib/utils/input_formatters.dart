import 'package:flutter/services.dart';

/// Text input formatter that formats currency amounts.
/// E.g. "1234.56" stays as-is, restricts to 2 decimal places.
class AmountInputFormatter extends TextInputFormatter {
  final int decimalPlaces;
  final double? maxAmount;

  AmountInputFormatter({
    this.decimalPlaces = 2,
    this.maxAmount,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Allow empty
    if (text.isEmpty) return newValue;

    // Only digits and one decimal point
    final regex = RegExp(r'^\d*\.?\d{0,' + decimalPlaces.toString() + r'}$');
    if (!regex.hasMatch(text)) return oldValue;

    // Check max amount
    if (maxAmount != null) {
      final value = double.tryParse(text);
      if (value != null && value > maxAmount!) return oldValue;
    }

    return newValue;
  }
}

/// Text input formatter for phone numbers.
/// Allows digits, +, spaces, hyphens, parentheses.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    // Allow only phone characters
    final cleaned = text.replaceAll(RegExp(r'[^\d+\-\s()]'), '');
    if (cleaned != text) {
      return TextEditingValue(
        text: cleaned,
        selection: TextSelection.collapsed(offset: cleaned.length),
      );
    }

    return newValue;
  }
}

/// Formatter that uppercases all text.
class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Formatter that limits input length with visual feedback.
class LimitedLengthFormatter extends TextInputFormatter {
  final int maxLength;

  LimitedLengthFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > maxLength) return oldValue;
    return newValue;
  }
}

/// Formatter for OTP codes - digits only, fixed length.
class OtpInputFormatter extends TextInputFormatter {
  final int length;

  OtpInputFormatter({this.length = 6});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > length) return oldValue;
    return TextEditingValue(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}
