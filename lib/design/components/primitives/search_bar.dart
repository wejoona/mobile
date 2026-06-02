import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/utils/debounce.dart';

/// App-wide search bar with debounced input.
class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final Duration debounceDelay;
  final bool autofocus;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search...',
    required this.onChanged,
    this.onClear,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.autofocus = false,
    this.controller,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  late Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _debouncer = Debouncer(duration: widget.debounceDelay);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      cursorColor: colors.gold,
      style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: colors.textTertiary,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 20,
          color: colors.textTertiary,
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (_, value, __) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: colors.textTertiary,
              ),
              onPressed: () {
                _controller.clear();
                widget.onChanged('');
                widget.onClear?.call();
              },
            );
          },
        ),
        filled: true,
        fillColor: colors.isDark ? colors.elevated : colors.container,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.gold, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: (value) {
        _debouncer.run(() => widget.onChanged(value));
      },
    );
  }
}
