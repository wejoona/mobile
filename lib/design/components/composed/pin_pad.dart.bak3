import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/index.dart';
import '../primitives/app_text.dart';

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
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: 1, 2, 3
        _buildRow([1, 2, 3], colors),
        const SizedBox(height: AppSpacing.md),
        // Row 2: 4, 5, 6
        _buildRow([4, 5, 6], colors),
        const SizedBox(height: AppSpacing.md),
        // Row 3: 7, 8, 9
        _buildRow([7, 8, 9], colors),
        const SizedBox(height: AppSpacing.md),
        // Row 4: biometric, 0, delete
        _buildBottomRow(colors),
      ],
    );
  }

  Widget _buildRow(List<int> digits, ThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.map((digit) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: _PinButton(
            colors: colors,
            child: AppText(
              digit.toString(),
              variant: AppTextVariant.headlineMedium,
              color: colors.textPrimary,
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              onDigitPressed(digit);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow(ThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Biometric or empty
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: showBiometric && onBiometricPressed != null
              ? _PinButton(
                  colors: colors,
                  child: Icon(
                    biometricIcon,
                    color: colors.gold,
                    size: 28,
                  ),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onBiometricPressed!();
                  },
                )
              : const SizedBox(width: 72, height: 72),
        ),
        // 0
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: _PinButton(
            colors: colors,
            child: AppText(
              '0',
              variant: AppTextVariant.headlineMedium,
              color: colors.textPrimary,
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              onDigitPressed(0);
            },
          ),
        ),
        // Delete
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: _PinButton(
            colors: colors,
            child: Icon(
              Icons.backspace_outlined,
              color: colors.textSecondary,
              size: 24,
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              onDeletePressed();
            },
          ),
        ),
      ],
    );
  }
}

class _PinButton extends StatelessWidget {
  const _PinButton({
    required this.child,
    required this.onTap,
    required this.colors,
  });

  final Widget child;
  final VoidCallback onTap;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.elevated,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashColor: colors.gold.withOpacity(0.2),
        highlightColor: AppColors.overlayLight,
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isFilled = index < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? (error ? colors.error : colors.gold)
                : Colors.transparent,
            border: Border.all(
              color: error
                  ? colors.error
                  : (isFilled ? colors.gold : colors.border),
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}
