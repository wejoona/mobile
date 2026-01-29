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

/// Input Field State (for visual styling)
enum AppInputState {
  /// Default/idle state
  idle,

  /// Field is focused
  focused,

  /// Field has value (filled)
  filled,

  /// Field has error
  error,

  /// Field is disabled
  disabled,
}

/// Luxury Wallet Input Component with Complete State Definitions and Accessibility
class AppInput extends StatefulWidget {
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
    this.semanticLabel,
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
  /// Optional semantic label for screen readers (defaults to label or hint)
  final String? semanticLabel;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasValue = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    // Check initial value
    if (widget.controller != null) {
      _hasValue = widget.controller!.text.isNotEmpty;
      widget.controller!.addListener(_onTextChange);
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    widget.controller?.removeListener(_onTextChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChange() {
    setState(() {
      _hasValue = widget.controller?.text.isNotEmpty ?? false;
    });
  }

  AppInputState _getCurrentState() {
    if (!widget.enabled) return AppInputState.disabled;
    if (widget.error != null) return AppInputState.error;
    if (_isFocused) return AppInputState.focused;
    if (_hasValue) return AppInputState.filled;
    return AppInputState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final currentState = _getCurrentState();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build semantic label
    final String effectiveLabel = widget.semanticLabel ??
        widget.label ??
        widget.hint ??
        'Text input';

    final String semanticHint = widget.readOnly
        ? 'Read only'
        : widget.error != null
            ? 'Error: ${widget.error}'
            : widget.helper ?? '';

    return Semantics(
      label: effectiveLabel,
      hint: semanticHint,
      textField: true,
      enabled: widget.enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            ExcludeSemantics(
              child: AppText(
                widget.label!,
                variant: AppTextVariant.labelMedium,
                color: _getLabelColor(currentState, isDark),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          keyboardType: _getKeyboardType(),
          textInputAction: widget.textInputAction,
          inputFormatters: _getInputFormatters(),
          onChanged: (value) {
            widget.onChanged?.call(value);
            _onTextChange();
          },
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          validator: widget.validator,
          style: _getTextStyle(currentState, isDark),
          textAlign: _getTextAlign(),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.error,
            helperText: widget.helper,
            prefix: widget.prefix,
            suffix: widget.suffix,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _getIconColor(currentState, isDark),
                    size: 20,
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? Icon(
                    widget.suffixIcon,
                    color: _getIconColor(currentState, isDark),
                    size: 20,
                  )
                : null,
            counterText: '',
            filled: true,
            fillColor: _getFillColor(currentState, isDark),
            hintStyle: _getHintStyle(isDark),
            errorStyle: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.errorText : AppColorsLight.errorText,
            ),
            helperStyle: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: _getBorderSide(currentState, isDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: _getBorderSide(AppInputState.idle, isDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: _getBorderSide(AppInputState.focused, isDark),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: _getBorderSide(AppInputState.error, isDark),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: isDark ? AppColors.errorBase : AppColorsLight.errorBase,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: _getBorderSide(AppInputState.disabled, isDark),
            ),
          ),
        ),
      ],
      ),
    );
  }

  /// Get fill color based on state
  Color _getFillColor(AppInputState state, bool isDark) {
    switch (state) {
      case AppInputState.disabled:
        return isDark
            ? AppColors.elevated.withOpacity(0.5)
            : AppColorsLight.elevated.withOpacity(0.5);
      case AppInputState.error:
        return isDark
            ? AppColors.errorBase.withOpacity(0.05)
            : AppColorsLight.errorLight;
      case AppInputState.focused:
        return isDark ? AppColors.elevated : AppColorsLight.elevated;
      case AppInputState.filled:
        // Subtle tint when field has value
        return isDark
            ? AppColors.elevated.withOpacity(0.8)
            : AppColorsLight.container;
      case AppInputState.idle:
        return isDark ? AppColors.elevated : AppColorsLight.elevated;
    }
  }

  /// Get border side based on state
  BorderSide _getBorderSide(AppInputState state, bool isDark) {
    switch (state) {
      case AppInputState.disabled:
        return BorderSide(
          color: isDark ? AppColors.borderSubtle : AppColorsLight.borderSubtle,
          width: 1,
        );
      case AppInputState.error:
        return BorderSide(
          color: isDark ? AppColors.errorBase : AppColorsLight.errorBase,
          width: 1,
        );
      case AppInputState.focused:
        // Gold highlight on focus
        return BorderSide(
          color: isDark ? AppColors.gold500 : AppColorsLight.gold500,
          width: 2,
        );
      case AppInputState.filled:
        return BorderSide(
          color: isDark ? AppColors.borderDefault : AppColorsLight.borderDefault,
          width: 1,
        );
      case AppInputState.idle:
        return BorderSide(
          color: isDark ? AppColors.borderDefault : AppColorsLight.borderDefault,
          width: 1,
        );
    }
  }

  /// Get text color based on state
  Color _getTextColor(AppInputState state, bool isDark) {
    switch (state) {
      case AppInputState.disabled:
        return isDark ? AppColors.textDisabled : AppColorsLight.textDisabled;
      default:
        return isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    }
  }

  /// Get label color based on state
  Color _getLabelColor(AppInputState state, bool isDark) {
    switch (state) {
      case AppInputState.disabled:
        return isDark ? AppColors.textDisabled : AppColorsLight.textDisabled;
      case AppInputState.error:
        return isDark ? AppColors.errorText : AppColorsLight.errorText;
      case AppInputState.focused:
        return isDark ? AppColors.gold500 : AppColorsLight.gold500;
      default:
        return isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    }
  }

  /// Get icon color based on state
  Color _getIconColor(AppInputState state, bool isDark) {
    switch (state) {
      case AppInputState.disabled:
        return isDark ? AppColors.textDisabled : AppColorsLight.textDisabled;
      case AppInputState.error:
        return isDark ? AppColors.errorBase : AppColorsLight.errorBase;
      case AppInputState.focused:
        return isDark ? AppColors.gold500 : AppColorsLight.gold500;
      default:
        return isDark ? AppColors.textTertiary : AppColorsLight.textTertiary;
    }
  }

  TextInputType? _getKeyboardType() {
    if (widget.keyboardType != null) return widget.keyboardType;

    switch (widget.variant) {
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
    if (widget.inputFormatters != null) return widget.inputFormatters;

    switch (widget.variant) {
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

  TextStyle _getTextStyle(AppInputState state, bool isDark) {
    final baseStyle = widget.variant == AppInputVariant.amount ||
            widget.variant == AppInputVariant.pin
        ? AppTypography.monoLarge
        : AppTypography.bodyLarge;

    return baseStyle.copyWith(color: _getTextColor(state, isDark));
  }

  TextStyle _getHintStyle(bool isDark) {
    return AppTypography.bodyMedium.copyWith(
      color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
    );
  }

  TextAlign _getTextAlign() {
    switch (widget.variant) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          AppText(
            label!,
            variant: AppTextVariant.labelMedium,
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
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
                  color: isDark ? AppColors.elevated : AppColorsLight.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDefault
                        : AppColorsLight.borderDefault,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      countryCode,
                      variant: AppTextVariant.bodyLarge,
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColorsLight.textPrimary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: isDark
                          ? AppColors.textTertiary
                          : AppColorsLight.textTertiary,
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
