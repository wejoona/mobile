import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

const double _securityPadKeyWidth = 74;
const double _securityPadKeyHeight = 68;
const double _securityPadIconSize = 27;
const double _securityPadDigitSize = 26;

class SecurityCodeDots extends StatelessWidget {
  const SecurityCodeDots({
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
        final color = error
            ? colors.errorText
            : isFilled
            ? colors.gold
            : colors.border;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          width: isFilled ? 28 : 14,
          height: 14,
          decoration: BoxDecoration(
            color: isFilled ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: color, width: 1.6),
          ),
        );
      }),
    );
  }
}

class SecurityNumberPad extends StatelessWidget {
  const SecurityNumberPad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.onBiometricPressed,
    this.showBiometric = false,
    this.isLoading = false,
    this.loadingLabel,
    this.biometricIcon = Icons.fingerprint_rounded,
  });

  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;
  final bool isLoading;
  final String? loadingLabel;
  final IconData biometricIcon;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _PadLoadingPanel(label: loadingLabel);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _row(context, const [1, 2, 3]),
        const SizedBox(height: AppSpacing.sm),
        _row(context, const [4, 5, 6]),
        const SizedBox(height: AppSpacing.sm),
        _row(context, const [7, 8, 9]),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PadSlot(
              child: showBiometric && onBiometricPressed != null
                  ? _PadButton.icon(
                      icon: biometricIcon,
                      onPressed: isLoading ? null : onBiometricPressed,
                      isAccent: true,
                    )
                  : const SizedBox(
                      width: _securityPadKeyWidth,
                      height: _securityPadKeyHeight,
                    ),
            ),
            _PadSlot(
              child: _PadButton.digit(
                digit: 0,
                onPressed: isLoading ? null : () => _pressDigit(0),
              ),
            ),
            _PadSlot(
              child: _PadButton.icon(
                icon: Icons.backspace_outlined,
                onPressed: onDeletePressed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(BuildContext context, List<int> digits) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: digits
        .map(
          (digit) => _PadSlot(
            child: _PadButton.digit(
              digit: digit,
              onPressed: isLoading ? null : () => _pressDigit(digit),
            ),
          ),
        )
        .toList(),
  );

  void _pressDigit(int digit) {
    onDigitPressed(digit);
  }
}

class SecurityCodeFields extends StatefulWidget {
  const SecurityCodeFields({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.error,
    this.hasError = false,
    this.obscureText = true,
    this.autoFocus = true,
    this.enabled = true,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final String? error;
  final bool hasError;
  final bool obscureText;
  final bool autoFocus;
  final bool enabled;

  @override
  State<SecurityCodeFields> createState() => _SecurityCodeFieldsState();
}

class _SecurityCodeFieldsState extends State<SecurityCodeFields> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _didComplete = false;

  String get _code => _controller.text;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_handleFocusChanged);

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.enabled) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = widget.hasError || widget.error != null;

    return Column(
      children: [
        Semantics(
          label: 'Verification code',
          value: '${_code.length} of ${widget.length} digits entered',
          textField: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled ? () => _focusNode.requestFocus() : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.length,
                    (index) => _field(colors, index, hasError),
                  ),
                ),
                Positioned.fill(child: _inputField()),
              ],
            ),
          ),
        ),
        if (widget.error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          AppText(
            widget.error!,
            variant: AppTextVariant.bodySmall,
            color: colors.errorText,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _field(ThemeColors colors, int index, bool hasError) {
    final hasDigit = index < _code.length;
    final activeIndex = _code.length >= widget.length
        ? widget.length - 1
        : _code.length;
    final isActive =
        widget.enabled &&
        _focusNode.hasFocus &&
        !hasError &&
        index == activeIndex;

    return Container(
      width: 46,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: hasError
            ? colors.error.withValues(alpha: colors.isDark ? 0.14 : 0.08)
            : colors.elevated.withValues(alpha: colors.isDark ? 0.78 : 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: hasError
              ? colors.errorText
              : isActive || hasDigit
              ? colors.gold
              : colors.border,
          width: isActive || hasDigit ? 1.8 : 1,
        ),
      ),
      child: Center(
        child: AppText(
          hasDigit
              ? widget.obscureText
                    ? '•'
                    : _code[index]
              : '',
          variant: AppTextVariant.moneyMedium,
          color: colors.textPrimary,
        ),
      ),
    );
  }

  Widget _inputField() {
    return TextField(
      key: const ValueKey('security_code_input'),
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.oneTimeCode],
      maxLength: widget.length,
      cursorColor: Colors.transparent,
      style: const TextStyle(color: Colors.transparent, fontSize: 1),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(widget.length),
      ],
      decoration: const InputDecoration(
        counterText: '',
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        fillColor: Colors.transparent,
      ),
      onChanged: _onCodeChanged,
    );
  }

  void _onCodeChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > widget.length
        ? digits.substring(0, widget.length)
        : digits;
    if (clipped != value) {
      _controller.value = TextEditingValue(
        text: clipped,
        selection: TextSelection.collapsed(offset: clipped.length),
      );
      return;
    }

    if (clipped.length < widget.length) {
      _didComplete = false;
    }
    setState(() {});
    widget.onChanged?.call(_code);
    if (_code.length == widget.length && !_didComplete) {
      _didComplete = true;
      _focusNode.unfocus();
      widget.onCompleted?.call(_code);
    }
  }
}

class _PadSlot extends StatelessWidget {
  const _PadSlot({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    child: child,
  );
}

class _PadButton extends StatelessWidget {
  const _PadButton.digit({required int digit, required this.onPressed})
    : label = '$digit',
      icon = null,
      isAccent = false;

  const _PadButton.icon({
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
    final foreground = isAccent ? colors.gold : colors.textPrimary;

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
        splashColor: colors.gold.withValues(alpha: 0.14),
        child: SizedBox(
          width: _securityPadKeyWidth,
          height: _securityPadKeyHeight,
          child: Center(
            child: icon != null
                ? Icon(icon, color: foreground, size: _securityPadIconSize)
                : AppText(
                    label ?? '',
                    style: AppTypography.moneyMedium.copyWith(
                      fontSize: _securityPadDigitSize,
                    ),
                    color: foreground,
                  ),
          ),
        ),
      ),
    );
  }
}

class _PadLoadingPanel extends StatelessWidget {
  const _PadLoadingPanel({this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accentBg = colors.goldSubtle.withValues(
      alpha: colors.isDark ? 0.58 : 0.72,
    );
    final panelShadow = colors.isDark
        ? AppShadows.goldGlow
        : AppShadows.lightGoldGlow;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: colors.container.withValues(alpha: colors.isDark ? 0.92 : 1),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: colors.gold.withValues(alpha: colors.isDark ? 0.34 : 0.24),
            ),
            boxShadow: panelShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.square(
                      dimension: 72,
                      child: CircularProgressIndicator(
                        color: colors.gold,
                        strokeWidth: 3.2,
                        strokeCap: StrokeCap.round,
                        backgroundColor: colors.borderSubtle,
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified_user_rounded,
                        color: colors.gold,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppText(
                label ?? 'Securing your session...',
                variant: AppTextVariant.titleSmall,
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppText(
                'Verifying locally and syncing your account.',
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
