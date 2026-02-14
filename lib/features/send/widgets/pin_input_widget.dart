import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class PinInputWidget extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final String? error;
  final bool obscureText;

  const PinInputWidget({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.error,
    this.obscureText = true,
  });

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );

    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _pin => _controllers.map((c) => c.text).join();

  void _onChanged() {
    widget.onChanged?.call(_pin);

    // Check if complete
    if (_pin.length == widget.length) {
      widget.onCompleted?.call(_pin);
    }
  }

  void _clearAll() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    _onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.length,
            (index) => _buildPinField(index),
          ),
        ),
        if (widget.error != null) ...[
          SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: _clearAll,
            child: AppText(
              AppLocalizations.of(context)!.action_clear,
              variant: AppTextVariant.bodySmall,
              color: context.colors.gold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPinField(int index) {
    return Container(
      width: 48,
      height: 56,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.colors.container,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: widget.error != null
              ? context.colors.error
              : _focusNodes[index].hasFocus
                  ? context.colors.gold
                  : context.colors.textSecondary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        obscureText: widget.obscureText,
        style: AppTypography.headlineMedium.copyWith(
          color: context.colors.textPrimary,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Move to next field
            if (index < widget.length - 1) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Last field, unfocus
              _focusNodes[index].unfocus();
            }
          }
          _onChanged();
        },
        onTap: () {
          // Clear current field on tap
          _controllers[index].clear();
        },
      ),
    );
  }
}
