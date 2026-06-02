import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// PIN Pad for secure input
/// Used in login, transaction confirmation, etc.
class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.onBiometricPressed,
    this.showBiometric = true,
    this.biometricIcon = Icons.fingerprint,
  });

  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;
  final IconData biometricIcon;

  @override
  Widget build(BuildContext context) => SecurityNumberPad(
    onDigitPressed: onDigitPressed,
    onDeletePressed: onDeletePressed,
    onBiometricPressed: onBiometricPressed,
    showBiometric: showBiometric,
    biometricIcon: biometricIcon,
  );
}

/// PIN Dots indicator
class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.length,
    required this.filled,
    this.error = false,
  });

  final int length;
  final int filled;
  final bool error;

  @override
  Widget build(BuildContext context) =>
      SecurityCodeDots(length: length, filled: filled, error: error);
}
