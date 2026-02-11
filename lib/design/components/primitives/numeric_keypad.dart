import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom numeric keypad for PIN and amount entry.
class NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyPressed;
  final VoidCallback onDelete;
  final VoidCallback? onBiometric;
  final bool showBiometric;
  final bool showDecimal;
  final double buttonSize;

  const NumericKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onDelete,
    this.onBiometric,
    this.showBiometric = false,
    this.showDecimal = false,
    this.buttonSize = 72,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      [
        showDecimal ? '.' : (showBiometric ? 'bio' : ''),
        '0',
        'del',
      ],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            if (key.isEmpty) {
              return SizedBox(width: buttonSize, height: buttonSize);
            }
            if (key == 'del') {
              return _KeyButton(
                size: buttonSize,
                onTap: onDelete,
                child: const Icon(Icons.backspace_outlined, size: 24),
              );
            }
            if (key == 'bio') {
              return _KeyButton(
                size: buttonSize,
                onTap: onBiometric ?? () {},
                child: const Icon(Icons.fingerprint_rounded, size: 28),
              );
            }
            return _KeyButton(
              size: buttonSize,
              onTap: () {
                HapticFeedback.lightImpact();
                onKeyPressed(key);
              },
              child: Text(
                key,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final double size;
  final VoidCallback onTap;
  final Widget child;

  const _KeyButton({
    required this.size,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}
