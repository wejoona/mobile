import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/core/haptics/haptic_service.dart';

/// Run 354: Custom amount keypad for send flow with haptic feedback
class SendAmountKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onDecimal;
  final bool decimalEnabled;

  const SendAmountKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.onDecimal,
    this.decimalEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Clavier numerique pour saisir le montant',
      child: Column(
        children: [
          _buildRow(['1', '2', '3']),
          const SizedBox(height: AppSpacing.sm),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: AppSpacing.sm),
          _buildRow(['7', '8', '9']),
          const SizedBox(height: AppSpacing.sm),
          _buildBottomRow(),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      children: digits.map((d) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: _KeypadButton(
              label: d,
              onTap: () {
                HapticService.lightImpact();
                onDigit(d);
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: decimalEnabled
                ? _KeypadButton(
                    label: '.',
                    onTap: () {
                      HapticService.lightImpact();
                      onDecimal?.call();
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: _KeypadButton(
              label: '0',
              onTap: () {
                HapticService.lightImpact();
                onDigit('0');
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: _KeypadButton(
              icon: Icons.backspace_outlined,
              onTap: () {
                HapticService.lightImpact();
                onDelete();
              },
              semanticLabel: 'Supprimer',
            ),
          ),
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const _KeypadButton({
    this.label,
    this.icon,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 64,
            alignment: Alignment.center,
            child: icon != null
                ? Icon(icon, color: AppColors.textPrimary, size: 24)
                : AppText(
                    label ?? '',
                    style: AppTextStyle.headingSmall,
                    color: AppColors.textPrimary,
                  ),
          ),
        ),
      ),
    );
  }
}
