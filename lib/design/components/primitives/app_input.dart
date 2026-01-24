import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/index.dart';
import 'app_text.dart';

/// Input Field Variants
enum AppInputVariant {
  /// Standard input field
  standard,

  /// Phone number input
  phone,

  /// PIN/OTP input
  pin,

  /// Amount/Currency input
  amount,

  /// Search input
  search,
}

/// Luxury Wallet Input Component
class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.variant = AppInputVariant.standard,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helper;
  final String? error;
  final Widget? prefix;
  final Widget? suffix;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final AppInputVariant variant;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          AppText(
            label!,
            variant: AppTextVariant.labelMedium,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: autofocus,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: _getKeyboardType(),
          textInputAction: textInputAction,
          inputFormatters: _getInputFormatters(),
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          validator: validator,
          style: _getTextStyle(),
          textAlign: _getTextAlign(),
          decoration: InputDecoration(
            hintText: hint,
            errorText: error,
            helperText: helper,
            prefix: prefix,
            suffix: suffix,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textTertiary, size: 20)
                : null,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: AppColors.textTertiary, size: 20)
                : null,
            counterText: '',
          ),
        ),
      ],
    );
  }

  TextInputType? _getKeyboardType() {
    if (keyboardType != null) return keyboardType;

    switch (variant) {
      case AppInputVariant.phone:
        return TextInputType.phone;
      case AppInputVariant.pin:
        return TextInputType.number;
      case AppInputVariant.amount:
        return const TextInputType.numberWithOptions(decimal: true);
      case AppInputVariant.search:
        return TextInputType.text;
      case AppInputVariant.standard:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    if (inputFormatters != null) return inputFormatters;

    switch (variant) {
      case AppInputVariant.phone:
        return [FilteringTextInputFormatter.digitsOnly];
      case AppInputVariant.pin:
        return [FilteringTextInputFormatter.digitsOnly];
      case AppInputVariant.amount:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ];
      case AppInputVariant.search:
      case AppInputVariant.standard:
        return null;
    }
  }

  TextStyle _getTextStyle() {
    switch (variant) {
      case AppInputVariant.amount:
        return AppTypography.monoLarge;
      case AppInputVariant.pin:
        return AppTypography.monoLarge;
      default:
        return AppTypography.bodyLarge;
    }
  }

  TextAlign _getTextAlign() {
    switch (variant) {
      case AppInputVariant.amount:
      case AppInputVariant.pin:
        return TextAlign.center;
      default:
        return TextAlign.start;
    }
  }
}

/// Phone Input with country code
class PhoneInput extends StatelessWidget {
  const PhoneInput({
    super.key,
    required this.controller,
    this.countryCode = '+225',
    this.onCountryCodeTap,
    this.onChanged,
    this.error,
    this.label,
  });

  final TextEditingController controller;
  final String countryCode;
  final VoidCallback? onCountryCodeTap;
  final ValueChanged<String>? onChanged;
  final String? error;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          AppText(
            label!,
            variant: AppTextVariant.labelMedium,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          children: [
            // Country code selector
            GestureDetector(
              onTap: onCountryCodeTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      countryCode,
                      variant: AppTextVariant.bodyLarge,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Phone number input
            Expanded(
              child: AppInput(
                controller: controller,
                variant: AppInputVariant.phone,
                hint: '0X XX XX XX XX',
                onChanged: onChanged,
                error: error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
