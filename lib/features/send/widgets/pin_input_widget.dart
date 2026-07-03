import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

class PinInputWidget extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final String? error;
  final bool obscureText;
  final bool enabled;

  const PinInputWidget({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.error,
    this.obscureText = true,
    this.enabled = true,
  });

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  int _resetRevision = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SecurityCodeFields(
          key: ValueKey(_resetRevision),
          length: widget.length,
          onChanged: widget.onChanged,
          onCompleted: widget.onCompleted,
          error: widget.error,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
        ),
        if (widget.error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () {
              setState(() => _resetRevision++);
              widget.onChanged?.call('');
            },
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
}
