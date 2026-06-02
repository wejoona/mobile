import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
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
    if (shuffle) {
      return _ShuffledPinPad(
        numbers: _getShuffledNumbers(),
        onNumberPressed: onNumberPressed,
        onBackspace: onBackspace,
        onBiometric: onBiometric,
      );
    }

    return SecurityNumberPad(
      onDigitPressed: (digit) => onNumberPressed('$digit'),
      onDeletePressed: onBackspace,
      onBiometricPressed: onBiometric,
      showBiometric: onBiometric != null,
    );
  }

  List<String> _getShuffledNumbers() {
    final nums = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    nums.shuffle();
    return [...nums.take(9), '', nums[9], 'backspace'];
  }
}

class _ShuffledPinPad extends StatelessWidget {
  const _ShuffledPinPad({
    required this.numbers,
    required this.onNumberPressed,
    required this.onBackspace,
    this.onBiometric,
  });

  final List<String> numbers;
  final Function(String) onNumberPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.25,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: numbers.length,
      itemBuilder: (context, index) {
        final value = numbers[index];
        if (value.isEmpty) {
          return onBiometric == null
              ? const SizedBox.shrink()
              : _FeaturePadButton.icon(
                  icon: Icons.fingerprint_rounded,
                  onPressed: onBiometric,
                  isAccent: true,
                );
        }
        if (value == 'backspace') {
          return _FeaturePadButton.icon(
            icon: Icons.backspace_outlined,
            onPressed: onBackspace,
          );
        }
        return _FeaturePadButton.label(
          label: value,
          onPressed: () => onNumberPressed(value),
        );
      },
    );
  }
}

class _FeaturePadButton extends StatelessWidget {
  const _FeaturePadButton.label({required this.label, required this.onPressed})
    : icon = null,
      isAccent = false;

  const _FeaturePadButton.icon({
    required this.icon,
    required this.onPressed,
    this.isAccent = false,
  }) : label = null;

  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.elevated.withValues(alpha: colors.isDark ? 0.78 : 1),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  color: isAccent ? colors.gold : colors.textSecondary,
                  size: 24,
                )
              : AppText(
                  label ?? '',
                  variant: AppTextVariant.moneyMedium,
                  color: colors.textPrimary,
                ),
        ),
      ),
    );
  }
}
