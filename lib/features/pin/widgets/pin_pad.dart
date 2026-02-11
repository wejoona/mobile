import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// PIN Pad Widget
/// Custom number pad for PIN entry
class PinPad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;
  final bool shuffle;

  const PinPad({
    super.key,
    required this.onNumberPressed,
    required this.onBackspace,
    this.onBiometric,
    this.shuffle = false,
  });

  @override
  Widget build(BuildContext context) {
    final numbers = shuffle ? _getShuffledNumbers() : ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'backspace'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final value = numbers[index];

        if (value.isEmpty) {
          // Show biometric button if available
          if (onBiometric != null) {
            return _BiometricButton(onPressed: onBiometric!);
          }
          return const SizedBox.shrink();
        }

        if (value == 'backspace') {
          return _BackspaceButton(onPressed: onBackspace);
        }

        return _NumberButton(
          number: value,
          onPressed: () {
            HapticFeedback.lightImpact();
            onNumberPressed(value);
          },
        );
      },
    );
  }

  List<String> _getShuffledNumbers() {
    final nums = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    nums.shuffle();
    return [
      ...nums.take(9),
      '',
      nums[9],
      'backspace',
    ];
  }
}

class _NumberButton extends StatelessWidget {
  final String number;
  final VoidCallback onPressed;

  const _NumberButton({
    required this.number,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.elevated,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Center(
          child: Text(
            number,
            style: AppTypography.displaySmall.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _BackspaceButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackspaceButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.elevated,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: colors.textPrimary,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _BiometricButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BiometricButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Center(
          child: Icon(
            Icons.fingerprint,
            color: colors.gold,
            size: 36,
          ),
        ),
      ),
    );
  }
}
